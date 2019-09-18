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
The script will give some explanatory text, if you start it without operators.

### -m) Manual Mode
To start autoupdate in manual mode, type `autoupdate -m` in the CLI of your Freifunk Berlin router.

Before setting the script into auto mode (see below) it is strongly recommended to run it one time manually! Please check, if 
the router model and the uplink type is recognised correctly (especially hardware revisions). If not, you should override 
them by storing the correct values in the config file. `/etc/config/autoupdate`

For example:
`TP-LINK TL-WR1043ND v3` states itself as `TP-LINK TL-WR1043ND v2`. To fix that, set
```
config 'autoupdate' 'router'
	option 'router' 'null'
```
to
```
config 'autoupdate' 'router'
        option 'router' 'TP-LINK TL-WR1043ND v3'
```
You may also use uci, if you are more comfortable with that:
```
uci set autoupdate.router.router='TP-LINK TL-WR1043ND v3'
uci commit autoupdate
```

### -a) Automatic Mode
Set `autoupdate.automode.automode='true'` in the config file. Also the values`on, yes, 1` are accepted. The script will 
check for updates weekly on Thursday.
If automode is set on, the automatic update might also be started manually by `autoupdate -a`.

### -r) Do Remote Backup
If you set up the values in config file, this will trigger the router to save a backup directly onto your 
remote machine. For this your machine must be accessible via ssh. Please mind to really give a slash at the end of the remote path.
```
	option 'client_path' '/complete/path/to/your/backups/'
```

### -s) Send Router String
This "sends" _(have a look in details section)_ the router string to the developers. This happens every week on Monday. With that
string sent we can manage to take the link lists up to date, because the strings may vary in different firmware versions. _(have a look above)_ 


## Technical Details
### Format of Link Definition Files
To get the right download link, the script loads a signed json file. This file should have a form like this:
```json
{
  "date":"20190512",
  "ROUTER-NAME#1":
  {
    "default": "http://link-to-sysupgrade.bin",
    "tunneldigger": "http://link-to-sysupgrade.bin"
  },
  "ROUTER-NAME#2":
  {
    "default": "http://link-to-sysupgrade.bin",
    "tunneldigger": "http://link-to-sysupgrade.bin"
  }
}
```
To generate those files automatically, you should have a look at json-creator https://github.com/Akira25/json-creator

### Signing of Link Definiton Files.
The link lists are signed to ensure their authenticy. We use openwrt-built-in `usign` for that. The script checks 
the certificate against all keys in `/usr/share/autoupdate/`. To get a successful verification only one key needs to be 
valid. For further details on the certification process, please check json-creator manual.

_That might change in later versions. For example: gluon-autoupdate mostly takes at least 3 valid keys until update is performed._

### Send String Function
Actually the string is not "send". Due to the limited functions of the routers, the string is transmitted via wget. wget will
try to get `http://some-defined-server.berlin/devicename;$ROUTER;`. It will fail by intention, but the device strings can be
extracted fairly easy from the web server's `access.log`.

_Have a look at name-finder._

## Disclaimer
Upgrades which are not supported by the developers of Freifunk Berlin might break your configuration. Therefore this script should not 
be used in crucial environments like backbone-setups.

If you are comfortable with C, you should have a look at gluon-autoupdater too.
https://github.com/freifunk-gluon/packages/tree/master/admin/autoupdater

