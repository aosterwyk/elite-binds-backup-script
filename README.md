#  elite-config-backup-script

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/aosterwyk/elite-config-backup-script?sort=semver)](https://github.com/aosterwyk/elite-config-backup-script/releases) [![GitHub last commit](https://img.shields.io/github/last-commit/aosterwyk/elite-config-backup-script)](https://github.com/aosterwyk/elite-config-backup-script/commits/master) [![GitHub last commit (branch)](https://img.shields.io/github/last-commit/aosterwyk/elite-config-backup-script/dev?label=last%20commit%20%28dev%29)](https://github.com/aosterwyk/elite-config-backup-script/commits/dev) [![Discord](https://img.shields.io/discord/90687557523771392?color=000000&label=%20&logo=discord)](https://discord.gg/QNppY7T) [![Twitch Status](https://img.shields.io/twitch/status/varixx?label=%20&logo=twitch)](https://twitch.tv/VariXx) 

A powershell script to backup your Elite Dangerous binds. 

## Installation

Download or clone the repo and run the script in a powershell window.

If you are seeing execution policy errors use the command below to bypass execution policy:

`powershell.exe -ExecutionPolicy Bypass -File eliteConfigBackup.ps1`

## Usage

Run the script to copy any .binds files in `%localappdata%\Frontier Developments\Elite Dangerous\Options\Bindings` to the current directory.

### Switches
**-force**: The script will add a timestamp to the filename if the file already exists in the backup destination. Use `-force` to overwrite the file instead.

**-backupPath**: The backup will be placed in the working directory (where the script is being run) by default. Use `-backupDestination <location>` to use a different location. 

## Support

[Discord server](https://discord.gg/QNppY7T) or DM `VariXx#8317`

## License

[MIT](https://choosealicense.com/licenses/mit/)

