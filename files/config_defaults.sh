#!/bin/sh
#
# get a fairly random update-time, to protect the servers from DoS
HOUR=$(( $(tr -cd 0-9 </dev/urandom | head -c 2) % 24))
MIN=$(( $(tr -cd 0-9 </dev/urandom | head -c 2) % 60))
echo "$MIN $HOUR * * 2	/usr/bin/autoupdate a" >> /etc/crontabs/root
/etc/init.d/cron restart

# set LAST_UPGR to the date of the first reboot
TODAY=$(date -u +%Y%m%d)
uci set autoupdate.upgrade_date.last_upgr="$TODAY"
uci commit autoupdate

exit 0
