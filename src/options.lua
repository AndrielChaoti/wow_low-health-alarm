--[[
	Project: LowHealthAlarm
	Friendly Name: Low Health Alarm
	Author: Vandesdelca32

	File: options.lua
	Purpose: Option Menu Setup

	Version: @file-revision@

	ALL RIGHTS RESERVED.
	COPYRIGHT (c)2016 VANDESDELCA32
]]

local appName = ...
local A, L, DF = unpack(select(2, ...))

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local DEFAULT_WIDTH = 610
local DEFAULT_HEIGHT = 450

ACD:SetDefaultSize(DEFAULT_WIDTH, DEFAULT_HEIGHT, appName)

A.optionsFrame = ACD:AddToBlizOptions(appName, "Low Health Alarm")
A.optionsFrame.default = function() A:SetDefaultOptions() end
-- GLOBALS: InterfaceOptionsFrame_OpenToCategory
-- GLOBALS: InCombatLockdown, LowHealthAlarm_DB


AC:RegisterOptionsTable(appName, A.Options)

function A:ToggleOptions()
	if InCombatLockdown() then
		self:PrintErr(L.CHAT.CombatLoadError)
		return
	end
	InterfaceOptionsFrame_OpenToCategory("Low Health Alarm")
end

function A:SetDefaultOptions()
	LowHealthAlarm_DB = DF
	ACR:NotifyChange(appName)
end

-- Settings here need to be the same name as the settings in DF...
A.Options.args = {
	Enabled = {
		name = L["DLG/Enable"],
		desc = L["DLGTT/Enable"],
		type = "toggle",
		order = 0,
		set = function(info, value)
			if value == false then
				A:Disable()
			else
				A:Enable()
			end
			LowHealthAlarm_DB.Enabled = value
		end
	},
	LoginMessage = {
		name = L["DLG/Login Message"],
		desc = L["DLGTT/Login Message"],
		type = "toggle",
		order = 10,
	},
	Settings = {
		name = L["DLG/Main Config"],
		type = "group",
		order = 20,
		inline = true,
		args = {
			Thresholds = {
				name = L["DLG/Threshold Settings"],
				--desc = "The settings controlling when the addon will make noise",
				type = "group",
				inline = true,
				order = 20,
				args = {
					HP_CRITICAL = {
						name = L["DLG/\"Critical\" Health"],
						desc = L["DLGTT/\"Critical\" Health"],
						type = "range",
						min = 0.01,
						max = 1.0,
						softMax = 0.5,
						step = 0.01,
						isPercent = true,
						order = 0
					},
					HP_WARNING  = {
						name = L["DLG/\"Dangerous\" Health"],
						desc = L["DLGTT/\"Dangerous\" Health"],
						type = "range",
						min = 0.01,
						max = 1.0,
						softMax = 0.5,
						step = 0.01,
						isPercent = true,
						order = 10
					},
					HP_LOW      = {
						name = L["DLG/\"Low\" Health"],
						desc = L["DLGTT/\"Low\" Health"],
						type = "range",
						min = 0.01,
						max = 1.0,
						softMax = 0.5,
						step = 0.01,
						isPercent = true,
						order = 20
					}
				}
			},
			Speed = {
				name = L["DLG/Speed Settings"],
				--desc = "How often the addon will make noise",
				type = "group",
				inline = true,
				order = 30,
				args = {
					ExplanationText = {
						type = "description",
						name = L["DLG/Speed Explanation"],
						width = "full",
						order = 0
					},
					Base = {
						name = L["DLG/Base Speed"],
						desc = L["DLGTT/Base Speed"],
						type = "range",
						min = 0.1,
						max = math.huge,
						softMax = 4,
						bigStep = 0.1,
						order = 1
					},
					Multiplier = {
						name = L["DLG/Multiplier"],
						desc = L["DLGTT/Multiplier"],
						type = "range",
						min = 0.1,
						max = math.huge,
						softMin = 1,
						softMax = 4,
						bigStep = 0.5,
						order = 2
					}
				}
			},
			BeepFile = {
				type = "select",
				dialogControl = "LSM30_Sound",
				name = L["DLG/Sound Effect"],
				desc = L["DLGTT/Sound Effect"],
				values = LSM:HashTable("sound"),
				order = 0,
			},
			BeepVolume = {
				name = L["DLG/Volume"],
				desc = L["DLGTT/Volume"],
				type = "range",
				min = 1,
				max = 5,
				step = 1,
				order = 10
			},
			SoundChannel = {
				name = L["DLG/Channel"],
				desc = L["DLGTT/Channel"],
				type = "select",
				style = "dropdown",
				order = 9,
				values = {
					["Master"] = "Master",
					["SFX"] = "Sound Effects",
					["Music"] = "Music",
					["Ambience"] = "Ambience",
					["Dialog"] = "Dialog"
				}
			}
		}
	}
}
