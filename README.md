# Tinker
3DS Homebrew Theme Manager for Shufflehax/Menuhax/Themehax. Heavily inspired by CHMM2 and made using Rinnegatamante's [lpp-3ds](https://gbatemp.net/threads/release-lua-player-plus-3ds-lpp-3ds-lua-interpreter-for-3ds.384202/). Please post bug reports or questions in [the GBATemp development thread](https://gbatemp.net/threads/tinker-shuffle-menuhax-theme-manager.407445/), I'm more likely to see them there.

<p align="center">
  <img src="https://i.imgur.com/751cheX.png">
</p>

## Installation
1. [Download the .zip file here.](https://github.com/HeyItsJono/Tinker/releases/latest)
2. Extract it to the 3ds folder on your SD Card; the path should look like this: `/3ds/Tinker/`
3. Place your themes in a Themes folder at the __root__ of your SD Card, just like you would for CHMM2. Themes should each have their own folder with their contents in them like so:
   
   ```
   /Themes/Theme1/
   /Themes/Theme2/
   etc
   ```
  
   (Theme1, Theme2, etc are just examples of theme names, your theme folders can be named anything, as long as they are in /Themes/)

## Usage Guide
* Browse the available themes on the bottom screen using the DPad arrow keys.
* Press Y while over a theme to bring up a theme preview on the top screen. Once Y is pressed, the top screen portion of the preview should appear. It will last about 5 seconds, then the bottom screen portion will appear. That will disappear after about 5 seconds and you should be able to move again.
* Press A to apply the theme, this will bring up a confirmation dialogue. Pressing A will open up Menuhax Manager, choose Install Custom Theme to install the theme. Pressing B will close the dialogue box and the theme will not be applied.
* Press the Start button to exit the application and return to the Homebrew Launcher. This glitches out if you're using the Gridlauncher so you'll have to hold Right Bumper+Left Bumper+Down Arrow+B button to exit.

## Things to note
* You can't use the touchscreen or circlepad to navigate, circlepad is planned for a future release but touchscreen support probably won't happen because effort.
* The Settings button (blue circle with the gear in it) is inaccessible for now, that'll be implemented later when I actually find settings worth implementing.
* No support for theme shuffling just yet, I'm looking into it to see if it's possible to implement.
* This only works for Menuhax theme implementation, use CHMM2 if you're looking for standard custom theme installation.
* __If you have a very large number of themes then the app will likely hang at a black screen on start up for a long time as it loads them all__

## Changelog
* v1.0.2 (3/1/16)
  * Introduced proper error dialogue for when Tinker detects Menuhax Manager is not installed, rather than having it throw a Lua-style error.
  * Added banners for use with Masher's Gridlauncher (a standard one which is used by default, and a 3dsflow one which can be used by renaming the standard one to something else, and renaming the 3dsflow one to "Tinker-banner-fullscreen.png")
  * Added a .3ds file - this has not been tested at all, I have no idea if it works or what it does. I don't have any means of testing it currently.
* v1.0.1 (1/1/16)
  * Introduced proper error dialogue for when no themes are detected, rather than having it throw a Lua-style error.
* v1.0.0 (31/12/15)
  * Initial release

## Credits
* [Rinnegatamante](https://gbatemp.net/members/rinnegatamante.356821/) for lpp-3ds and also for their incredible work on CHMM2 and Sunshell. Without all of those things this project would not be possible.
* [ihaveamac](https://gbatemp.net/members/ihaveamac.364799/) for guidance and support in getting features like .3dsx launching working/
