local appName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(appName, "enUS", true, true)

if L then

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="concat")@

--@do-not-package@
L["CHAT/BrokenConfig"] = "Your config is out of date, resetting it!"
L["CHAT/CombatLoadError"] = "Cannot load options in combat."
L["CHAT/LoginMessage"] = "Version §6%s§r successfully loaded."
L["CHAT/NoConfig"] = "Could not load your config, loading the default settings."
L["DLG/Base Speed"] = "Base Speed"
L["DLG/Channel"] = "Channel"
L["DLG/\"Critical\" Health"] = "\"Critical\" Health"
L["DLG/\"Dangerous\" Health"] = "\"Dangerous\" Health"
L["DLG/Enable"] = "Enable"
L["DLG/Login Message"] = "Login Message"
L["DLG/\"Low\" Health"] = "\"Low\" Health"
L["DLG/Main Config"] = "Main Config"
L["DLG/Multiplier"] = "Multiplier"
L["DLG/Sound Effect"] = "Sound Effect"
L["DLG/Speed Explanation"] = [=[Setting the beeping speed here allows you to configure how fast or slow the addon's sound is played.
The speed is divided by "Multiplier" when health is "Critical".
The speed is used, untouched, when health is "Dangerous".
The speed is multiplied by "Multiplier", when health is "Low".]=]
L["DLG/Speed Settings"] = "Speed Settings"
L["DLG/Threshold Settings"] = "Threshold Settings"
L["DLG/Volume"] = "Volume"
L["DLGTT/Base Speed"] = "The base speed of the beeping sound."
L["DLGTT/Beep File"] = "The sound effect to play."
L["DLGTT/\"Critical\" Health"] = "Under this value, your health is considered \"Critical\"ly low."
L["DLGTT/\"Dangerous\" Health"] = "Under this value, your health is considered \"Dangerous\"ly low."
L["DLGTT/Enable"] = "Enables / Disables the addon."
L["DLGTT/Login Message"] = "Enables / disables login messages"
L["DLGTT/\"Low\" Health"] = "Under this value, your health is considered \"Low\"."
L["DLGTT/Multiplier"] = "The multiplier for the base speed."
L["DLGTT/Sound Channel"] = "The sound channel to play the sound on."
L["DLGTT/Volume"] = [=[The "Volume" of the beeping sound.
 1 is played at normal volume, higher numbers are louder.]=]
--@end-do-not-package@
end
