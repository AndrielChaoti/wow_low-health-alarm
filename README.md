# About
***Low Health Alarm. It does what the title says.***
  
## About
This addon is desinged, quite simply, to just play a repeated and annoying sound when your health is below configured thresholds. You can set it up to use any sound you want, but it comes with a sound by default.

## Configuration
You can get to the addon's settings by typing `/lowhealth`, `/lh` or `/lha` in chat, or opening the configuration in the Blizzard interface panel.

### Speed explanation:
The addon has configurable "speed" settings, which means, it can beep faster the lower health you are. The system works pretty simply, but here's an explanation:

*"Low" health will beep slowly (speed * multiplier)
*"Dangerous" health will beep at a medium rate (speed)
*"Critical" health will beep at a fast rate (speed / multiplier)

### Quick Setup Example
#### If you want your sound effect to play once every second, regardless of your health:

**Set the "Base Speed" to 1.0, and set the "Multiplier" to 1.** This will set your sound effect to play every one second when your health is below the "Low" threshold, and it will not change between the other thresholds. A good example of this usage scenario is the Kingdom Hearts low health alarm, where it plays the siren sound constantly on low health.

#### If you want to play your sound faster the lower health you are:
**Set the "Base Speed" to your desired setting, and then set the multiplier to any number larger than 1.** Currently, the multiplier setting does not support going below 1, so you cannot slow down the beeps the lower your health.
## Problems? Suggestions? Bugs?
If you're having a problem with the addon, have a suggestion for a new feature, or you noticed a bug, just [submit a ticket](https://github.com/AndrielChaoti/wow_low-health-alarm/issues) and I'll try to get it fixed as fast as I can!
