#!/bin/sh
#

#if autoupdate is not present in crontab, include it.
crontab -l | grep /usr/bin/autoupdate >> /dev/null
if [ $? != 0 ]; then
  #get a fairly random update-time, to protect the servers from DoS
  HOUR=$(( $(tr -cd 0-9 </dev/urandom | head -c 2) % 24))
  MIN=$(( $(tr -cd 0-9 </dev/urandom | head -c 2) % 60))
  echo "$MIN $HOUR * * 4        /usr/bin/autoupdate a" >> /etc/crontabs/root
  /etc/init.d/cron restart
fi

#set LAST_UPGR to the date of the first reboot. Ensure, that the router has
#internet connection (thus ntp access)
ping -c3 8.8.8.8
if [ $? = 0 ]; then
  TODAY=$(date -u +%Y%m%d)
  uci set autoupdate.upgrade_date.last_upgr="$TODAY"
  uci commit autoupdate
  exit 0
else
  exit 1
fi
