# autoupdate
This script wants to get the upgrade process of a freifunk-berlin router via terminal smooth and easy.

## Features
* manual mode
  * saves a backup on your (remote) machine
    * (needs to be configured in /etc/config/autoupdate)
  * gets the model of the router and its uplink type
  * fetches the corresponding *sysupgrade.bin* and downloads it
  * does the upgrade

* automatic mode
  * does save backup in /root/
  * does upgrade automatically

At default autoupdate is only avaiable in manual mode. To set it working automatically, you need to set a variable in the config file.

## Usage
### Manual Mode
To start autoupdate in manual mode, just type `autoupdate` in the CLI of your Freifunk Berlin router.

Before setting the script into auto mode (see below) it is strongly recommended to run it one time manually! Please check, if 
the router model and the uplink type is recognised correctly (especially hardware revisions). If not, you should override 
them by storing the correct values in the config files.

For example:
`TP-LINK TL-WR1043ND v3` states itself as `TP-LINK TL-WR1043ND v2`. Give `ROUTER="TP-LINK TL-WR1043ND v3"` in */etc/config/autoupdate*

### Automatic Mode
Set `AUTO="ON"` in config file. The script will check weekly for updates.
If AUTO is set to ON, the automatic update might also be started manually by `autoupdate a`.

## Disclaimer
Upgrades which are not supported by the developers of Freifunk Berlin might break your configuration. Therefore this script should not 
be used in crucial environments like backbone-setups. This script supports stable releases only.

If you are looking for a completely automatic updater supporting developer releases, you
should have a look at gluon-Autoupdater!
https://github.com/freifunk-gluon/packages/tree/master/admin/autoupdater
