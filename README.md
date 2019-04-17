# autoupdate
This script wants to get the upgrade process of a freifunk-berlin router via terminal smooth and easy.

## Features
* figure out the model of the router and its uplink type
  * fetching the corresponding *sysupgrade.bin*
* do the upgrade

### to be implemented
* doing a backup

## Disclaimer
This script does not provide an automatic update procces like unattended-upgrades. It 
needs to be run manually. In addition it supports stable releases only.
If you are looking for a completely automatic updater supporting developer releases, you
should have a look at gluon-Autoupdater!
https://github.com/freifunk-gluon/packages/tree/master/admin/autoupdater
