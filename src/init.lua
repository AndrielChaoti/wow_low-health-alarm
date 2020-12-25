--[[
	Project: LowHealthAlarm
	Friendly Name: Low Health Alarm
	Author: Vandesdelca32

	File: init.lua
	Purpose: Initialization/Setup

	Version: @file-revision@

	ALL RIGHTS RESERVED.
	COPYRIGHT (c)2019 Andriel Chaoti
]]

local AppName, App = ...

-- Get the libraries loaded up
local MyAddon = LibStub("AceAddon-3.0"):NewAddon(AppName, "AceEvent-3.0", "LibVan32-2.0")
local LSM = LibStub("LibSharedMedia-3.0")
local AC = LibStub("AceConfig-3.0")

--LibStub("LibVan32-1.0"):Embed(MyAddon, AppName)

MyAddon._Major = "@project-version@"
MyAddon._Revision = "@project-abbreviated-hash@"

-- GLOBALS: SLASH_LOWHEALTHALARM1,SLASH_LOWHEALTHALARM2,SLASH_LOWHEALTHALARM3
-- GLOBALS: SlashCmdList, LowHealthAlarm_DB, format

-- Initialize Options...
local AppDefaults = {
	_VER				= 3,												-- Settings Version
	Enabled			= true,											-- Enable Switch
	LoginMessage	= true,											-- Show Login Message
	HP_CRITICAL		= 0.10,											-- Beep Level Critical (%)
	HP_WARNING		= 0.25,											-- Beep Level Warning (%)
	HP_LOW			= 0.40,											-- Beep Level Low (%)
	Base				= 1.0,											-- Beep Speed Base Value
	Multiplier		= 2.0,											-- Beep Speed Multiplier Value
	BeepFile			= "LoZ: Link to the Past Beep",			-- Beep Sound Effect
	BeepVolume		= 3,												-- Beep "volume"
	SoundChannel	= "SFX",											-- The sound channel that beeps will play on
	SkipFirstBeep  = true, 											-- Used to work around the zone change beeping
}

local function Get( info )
	return LowHealthAlarm_DB[info[#info]]
end

local function Set( info, value )
	LowHealthAlarm_DB[info[#info]] = value
end

MyAddon.Options = {
	type = "group",
	name = AppName,
	get = Get,
	set = Set,
	args = {},
}

local L = LibStub("AceLocale-3.0"):GetLocale(AppName)
App[1] = MyAddon			-- The entire addon.
App[2] = L			-- Localization data when I get there.
App[3] = AppDefaults 			-- Default settings table
_G[AppName] = App

function MyAddon:OnInitialize()
	-- Do init tasks here, like loading the Saved Variables,
	-- or setting up slash commands.
	SLASH_LOWHEALTHALARM1 = "/lh"
	SLASH_LOWHEALTHALARM2 = "/lha"
	SLASH_LOWHEALTHALARM3 = "/lowhealth"

	-- Handle slash commands (just going to open the config dialog)
	SlashCmdList["LOWHEALTHALARM"] = function(...)
		self:ToggleOptions()
	end

	-- Set up the config
	self:CheckSettingsDB()
	self:BuildOptionsTable()

	-- Add in our sounds...
	LSM:Register("sound", "LoZ: Link to the Past Beep", [[Interface\AddOns\LowHealthAlarm\media\LTTP_LowHealth.ogg]])

	self:SetEnabledState(self:GetSetting("Enabled"))
	for _, module in self:IterateModules() do
		module:SetEnabledState(self:GetSetting("Enabled"))
	end
end

function MyAddon:OnEnable()
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from
	-- the game that wasn't available in OnInitialize
	local verStr = self:GetVersion(false, true)
	if self:GetSetting("LoginMessage") then
		self:Print(format(L["CHAT/LoginMessage"], verStr))
	end

	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("PLAYER_DEAD")
end

function MyAddon:OnDisable()
  -- Unhook, Unregister Events, Hide frames that you created.
  -- You would probably only use an OnDisable if you want to
  -- build a "standby" mode, or be able to toggle modules on/off.
  self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
  self:UnregisterEvent("PLAYER_DEAD")
  self:SetBeepSpeed(0)
end

