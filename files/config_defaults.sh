#!/bin/sh
#

#if autoupdate is not present in crontab, include it.
crontab -l | grep /usr/bin/autoupdate >>/dev/null
if [ $? != 0 ]; then
    #get a fairly random update-time, to protect the servers from DoS
    HOUR=$(($(tr -cd 0-9 </dev/urandom | head -c 2) % 24))
    MIN=$(($(tr -cd 0-9 </dev/urandom | head -c 2) % 60))
    echo "$MIN $HOUR * * 4        /usr/bin/autoupdate -a" >>/etc/crontabs/root
    echo "$MIN $HOUR * * 1        /usr/bin/autoupdate -s" >>/etc/crontabs/root
    /etc/init.d/cron restart
fi

#set LAST_UPGR to the date of the first reboot. Ensure, that the router has
#internet connection (thus ntp access)
ping -c3 8.8.8.8
if [ $? = 0 ]; then
    TODAY=$(date -u +%Y%m%d)
    uci set autoupdate.upgrade_date.last_upgr="$TODAY"
    uci commit autoupdate
else
    exit 1
fi

#get the list of packages and compare
#afterwards reinstall missing packages, which where lost during upgrade
OUTPUT="/tmp/to_be_installed.list"

if [ ! -e $OUTPUT ]; then
    FILE=$(find /root/backup/ -name *_package-list)
    LIST_OLD=$(cat "$FILE")
    LIST_NEW=$(opkg list-installed | cut -d ' ' -f 1)
    echo "$LIST_NEW" >> /tmp/list_new

    #get one package of old list and check, if contained in new list
    PACKAGE=$(echo $LIST_OLD | cut -d ' ' -f 1)
    #set counter for iteration over the package list
    LEN=$((2 + $(echo $LIST_NEW | wc -w)))

    #while not every package from the old list was checked, do
    while [ $LEN -ge 1 ]; do
        #check if package is include in new package list
        grep $PACKAGE /tmp/list_new
        if [ $? = 0 ]; then
            #pop first element
            LIST_OLD=$(echo $LIST_OLD | cut -d ' ' -f 2-)
            PACKAGE=$(echo $LIST_OLD | cut -d ' ' -f 1)
        else
            #add package to list of packages to be installed
            echo "$PACKAGE" >>$OUTPUT
            LIST_OLD=$(echo $LIST_OLD | cut -d ' ' -f 2-)
            PACKAGE=$(echo $LIST_OLD | cut -d ' ' -f 1)
        fi
        LEN=$(($LEN - 1))
    done

fi

#if there is no list, no differences were found. exit with succes.
if [ ! -e $OUTPUT ]; then
    logger -t "autoupdate" "No packages to be installed."
    exit 0
fi

#install the packages collected in to_be_installed.list
opkg update
if [ $? != 0 ]; then
    logger -t "autoupdate" "Wasn't able to perform opkg update."
    exit 1
fi
PAK_LIST=$(cat $OUTPUT)
opkg install $PAK_LIST
if [ $? != 0 ]; then
    logger -t "autoupdate" "Wasn't able to install $PAK_LIST. Are those packages avaiable for this firmware?"
    exit 1
fi

exit 0
