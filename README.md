# awesomewm-config
My configuration for awesome WM 4.3


# Screenshots
![alt text](images/screenshot1.png?raw=true)
With system_info widget:
![alt text](images/screenshot2.png?raw=true)
Wallpaper can be found in `images/` folder.


# Dependencies
| Dependence | Explanation |
|:-------:|:-------|
| scrot	| Used in screenshots script |
| trans | Used in translation scripts |
| xclip | Get selection for translation script |
| jq | Parse json in weather widget |
| lm_sensors | Temperature monitoring for system_info widget |
| feh | Set wallpaper (you need to choose image as wallpaper using feh) |
| rofi | Desktop files launcher |
| notify-send | Notification sending |

Also, you need sign up on openweathermap.org and get API key for weather widget work.


# How to setup
1. Install awesome wm. You must have version 4.3 or higher:
	* Debian-based: `sudo apt install awesome`
	* Arch-based: `sudo pacman -S awesome`
2. Get dependencies:
	* Debian-based: 	`sudo apt install scrot xclip jq lm_sensors feh libnotify-bin`
	* Arch-based: `sudo pacman -S scrot xclip jq lm_sensors feh libnotify`
	* You can get trans (translate-shell) from [here](https://github.com/soimort/translate-shell).
3. Git clone configuration files in your config  directory and rename directory in awesome.
```bash
   cd .config
   git clone https://github.com/kotbaton/awesomewm-config.git
   mv awesomewm-config awesome
   cd awesome
   ```
4. Create settings.lua and use your favorite editor to set variables you need. You can find tips in comments in settings.lua file.
```bash
   cp settings_default.lua settings.lua
   vim settings.lua
```
5. Restart awesome with `Super+Ctrl+r`. Press `Super+Shift+a` to get hotkeys help.


# Directories structure explanation
* **rc.lua** — main configuration file. In this file you can edit your layouts set (but not forget to uncomment icons for it in theme.lua file), edit top panel configuration, configure hotkeys, configure title bar and set rules for clients.
* **gruvbox-theme** — theme directory.
	* **theme.lua** — edit this file if you want to change some colors.
* **scripts** — bash scripts for different purposes.
* **modules**
	* **layouts** — my custom layouts. Must be uncommented in modules/init.lua
	* **menus** — functions for build clientmenu and mainmenu.
	* **tools** — functions for read and write tagnames and third-party script for application menu building.
	* **widgets** — different widgets.
		* **battery.lua**
		* **menu_button.lua** — button in left part of top panel. You can change text on this button in this file.
		* **player.lua** — widget which display text provided by settings.player_commands.GET_TRACK_CMD. It must work for any player if you set player_commands in settings in right way. Was tested for cmus and spotify.
		* **system_info.lua** — very long file with all monitoring widgets used in system_info popup.
		* **tray.lua** — tray widget in right part of top panel. In this file you can change text on tray button.
		* **volume.lua** — module with volume widget and volume control functions.

