--[[
	Project: LowHealthAlarm
	Friendly Name: Low Health Alarm
	Author: Vandesdelca32

	File: core.lua
	Purpose: Main Addon Functionality

	Version: @file-revision@

	ALL RIGHTS RESERVED.
	COPYRIGHT (c)2016 VANDESDELCA32
]]
local A, L, DF = unpack(select(2, ...))
local LSM = LibStub("LibSharedMedia-3.0")


-- GLOBALS: LowHealthAlarm_DB, strfind
local select, error, tconcat, tostringall, type = select, error, table.concat, tostringall, type
local assert, PlaySoundFile, debugprofilestop = assert, PlaySoundFile, debugprofilestop
local UnitHealth, UnitHealthMax, UnitIsDeadOrGhost = UnitHealth, UnitHealthMax, UnitIsDeadOrGhost
local timer = C_Timer

----------------------
-- Useful Functions --
----------------------
--- Gets a setting or it's equivalent in the defaults table if it can't be found
-- @arg ... a list of table keys
-- @return A value representing the setting requested.
function A:GetSetting(...)
	local t = LowHealthAlarm_DB -- Start by setting t to the top-level settings table
	local dt = DF -- And the top-level defaults table.
	for i = 1, select("#", ...) do
		local key = select(i, ...)
		if t[key] == nil then -- If the key doesn't exist in the table,
			t[key] = dt[key] -- use the default value instead (modified to accept false key values!)
		end
		t = t[key] -- Set t to the value at key in the current table

		if dt[key] == nil then -- Check if this is actually a valid setting
			error("no such setting: " .. tconcat({tostringall(...)}, ", "), 2)
		end
		dt = dt[key] -- and dt to the value at key in the defaults table, so we can parse multiple table levels.

		if type(t) ~= "table" then -- If the new value of t isn't a table, return it now (terminating the function early)
			return t
		end
		-- Otherwise, t is the new table and we move on to the next key

		-- We repeat the above until we've processed every key or encountered a non-table value.
	end
	return t
end

--- Check and make sure the SavedVariables database exists
-- and is up to date.
function A:CheckSettingsDB()
	-- They don't have a settings database
	if not LowHealthAlarm_DB then
		self:PrintError(L["CHAT/NoConfig"])
		LowHealthAlarm_DB = DF
		return false
	-- Or their settings are outdated
	elseif self:GetSetting("_VER") ~= DF._VER then
		self:PrintError(L["CHAT/BrokenConfig"])
		LowHealthAlarm_DB = DF
		return false
	end
	return true
end

--- Get the addon's version string
-- @arg short Set to true to return a shorter version string. (Ex. r411)
-- @return A string reperesenting the addon's current version (Ex. "release_v4.6.3.411")
function A:GetVersion(short, startup)

	local v, rev = self._Major, self._Revision
	-- Check the build status:
	if startup then
		if (v:find("^r%d+") or v:find("^alpha") or v:find("^@.+@$")) then
			self._DebugMode = true
			--self:PrintDebug(L.CHAT.DebugModeEnabled)
		end
	end

	if v:find("^@") then
		v = "DEV_VERSION"
	end

	if rev:find("^@") then
		rev = "???"
	end

	if short then
		-- Try to discern what release stage:
		if strfind(v, "release") then
			return "r" .. rev
		elseif strfind(v, "beta") then
			return "b" .. rev
		else
			return "a" .. rev
		end
	end
	return v .. "." .. rev
end

-----------
-- Addon --
-----------

local firstBeep, lastBeepTime, ticker
A.BeepSpeed = 0

function A:Beep()
	if (not lastBeepTime) or (debugprofilestop() >= lastBeepTime + A.BeepSpeed) then
		lastBeepTime = debugprofilestop()
		local volume = self:GetSetting("BeepVolume")
		local soundFile = assert(LSM:Fetch("sound", self:GetSetting("BeepFile")))
		local soundChannel = self:GetSetting("SoundChannel")
		for i = 1, volume do
			-- Workaround: Cancel the first beep, so we ignore zone change beeping...
			if not firstBeep and self:GetSetting("SkipFirstBeep") then firstBeep = true; return end
			PlaySoundFile(soundFile, soundChannel);
		end
	end
end

--- Check the unit's health
function A:CheckHealth()
	local hPercent = UnitHealth("player") / UnitHealthMax("player")

	-- Don't beep if we're dead:
	if UnitIsDeadOrGhost("player") then return end

	local beepSpeed, multiplier = self:GetSetting("Base"), self:GetSetting("Multiplier")
	local criticalHealth, warningHealth, lowHealth = self:GetSetting("HP_CRITICAL"), self:GetSetting("HP_WARNING"), self:GetSetting("HP_LOW")
	-- Check Health Percents:
	if hPercent <= criticalHealth then
		self:SetBeepSpeed(beepSpeed/multiplier)
	elseif hPercent <= warningHealth and hPercent > criticalHealth then
		self:SetBeepSpeed(beepSpeed)
	elseif hPercent <= lowHealth and hPercent > warningHealth then
		self:SetBeepSpeed(beepSpeed * multiplier)
	elseif hPercent > lowHealth then
		self:SetBeepSpeed(0)
	end
end

--- Set the beeping speed
function A:SetBeepSpeed(speed)
	-- Check the current speed:
	if speed == self.BeepSpeed then return end

	if not self.BeepSpeed or self.BeepSpeed > 0 then
		-- Cancel the current beeps and start anew.
		ticker:Cancel()
	end

	if speed == 0 then
		ticker:Cancel()
		firstBeep = false
	else
		ticker = timer.NewTicker(speed, function() self:Beep() end)
		self:Beep()
	end

	self.BeepSpeed = speed
end

--------------------
-- Event handling --
--------------------
function A:UNIT_HEALTH(event, ...)
	local unitName = select(1, ...)
	if unitName == "player" then
		self:CheckHealth();
	end
end

function A:PLAYER_DEAD( event, ... )
	self:SetBeepSpeed(0)
end
