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

local format, math = format, math

-- GLOBALS: InterfaceOptionsFrame_OpenToCategory
-- GLOBALS: InCombatLockdown, LowHealthAlarm_DB

function A:ToggleOptions()
	if InCombatLockdown() then
		self:PrintError(L["CHAT/CombatLoadError"])
		return
	end
	InterfaceOptionsFrame_OpenToCategory("Low Health Alarm")
end

function A:SetDefaultOptions()
	LowHealthAlarm_DB = DF
	ACR:NotifyChange(appName)
end

function A:BuildOptionsTable()
	AC:RegisterOptionsTable(appName, self.Options)
	self.optionsFrame = ACD:AddToBlizOptions(appName, "Low Health Alarm")
	self.optionsFrame.default = function() self:SetDefaultOptions() end

	-- Settings here need to be the same name as the settings in DF...
	self.Options.args = {
		VersionHeader = {
			name = format(L["DLG/Version"], self:GetVersion(false, false)),
			type = "header",
			order = 0
		},
		Enabled = {
			name = L["DLG/Enable"],
			desc = L["DLGTT/Enable"],
			type = "toggle",
			order = 10,
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
			order = 20,
		},
		Settings = {
			name = L["DLG/Main Config"],
			type = "group",
			order = 30,
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
							max = self:GetSetting("HP_WARNING") - 0.01, -- Temporary... Will be modified by setters/getters here.
							step = 0.01,
							isPercent = true,
							set = function(info, value)
									-- Sets the min/max of neighbouring sliders so values can't overlap and break the addon.
									self.Options.args.Settings.args.Thresholds.args.HP_WARNING.min = value + 0.01
									LowHealthAlarm_DB[info[#info]] = value
								end,
							order = 0
						},
						HP_WARNING  = {
							name = L["DLG/\"Dangerous\" Health"],
							desc = L["DLGTT/\"Dangerous\" Health"],
							type = "range",
							min = self:GetSetting("HP_CRITICAL") + 0.01,
							max = self:GetSetting("HP_LOW") - 0.01,
							step = 0.01,
							isPercent = true,
							set = function(info, value)
									-- Sets the min/max of neighbouring sliders so values can't overlap and break the addon.
									self.Options.args.Settings.args.Thresholds.args.HP_CRITICAL.max = value - 0.01
									self.Options.args.Settings.args.Thresholds.args.HP_LOW.min = value + 0.01
									LowHealthAlarm_DB[info[#info]] = value
								end,
							order = 10
						},
						HP_LOW      = {
							name = L["DLG/\"Low\" Health"],
							desc = L["DLGTT/\"Low\" Health"],
							type = "range",
							min = self:GetSetting("HP_WARNING") + 0.01,
							max = 0.8,
							step = 0.01,
							isPercent = true,
							set = function(info, value)
									-- Sets the min/max of neighbouring sliders so values can't overlap and break the addon.
									self.Options.args.Settings.args.Thresholds.args.HP_WARNING.max = value - 0.01
									LowHealthAlarm_DB[info[#info]] = value
								end,
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
				Testing = {
					name = L["DLG/Test Buttons"],
					type = "group",
					inline = true,
					order = 40,
					args = {
						SlowBeep = {
							name = L["DLG/\"Low\" Beep"],
							type = "execute",
							order = 0,
							func = function()
							  A:Print(format(L["CHAT/Testing"], L["DLG/\"Low\" Health"]))
							  A:SetBeepSpeed(self:GetSetting("Base") * self:GetSetting("Multiplier"))
							end
						},
						MedBeep = {
							name = L["DLG/\"Dangerous\" Beep"],
							type = "execute",
							order = 10,
							func = function()
							  A:Print(format(L["CHAT/Testing"], L["DLG/\"Dangerous\" Health"]))
							  A:SetBeepSpeed(self:GetSetting("Base"))
							end
						},
						FastBeep = {
							name = L["DLG/\"Critical\" Beep"],
							type = "execute",
							order = 20,
							func = function()
							  A:Print(format(L["CHAT/Testing"], L["DLG/\"Critical\" Health"]))
							  A:SetBeepSpeed(self:GetSetting("Base") / self:GetSetting("Multiplier"))
							end
						},
						StopBeep = {
							name = L["DLG/Stop All"],
							type = "execute",
							order = 30,
							width = "full",
							func = function()
								A:Print(L["CHAT/StopBeeps"])
								A:SetBeepSpeed(0)
							end
						}
					}
				},
				Misc = {
					name = L["DLG/Misc Settings"],
					type = "group",
					order = 50,
					inline = true,
					args = {
						SkipFirstBeep = {
							name = L["DLG/Skip First Beep"],
							desc = L["DLGTT/Skip First Beep"],
							type = "toggle"
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
end
