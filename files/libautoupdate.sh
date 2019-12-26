#internal definitions for autoupdate

PATH_PUB_KEY="/usr/share/autoupdate/"
PATH_BIN="/tmp/sysupgrade.bin"
PATH_JSON="/tmp/router.json"
PATH_BAK="/tmp/backup.tar.gz"
PATH_AUTOBAK="/root/backup/"

#load json-functions
. /usr/share/libubox/jshn.sh

#funtions for autoupdate

get_date() {
    TODAY=$(date -u +%Y-%m-%d)
}

get_hostname() {
    HOSTNAME=$(uci -q get system.@system[0].hostname)
}

get_branch() {
    JSON_LINK="$JSON_LINK_SERVER""$BRANCH"".json"
}

#download the link definition file
get_def() {
    wget -q "$JSON_LINK" -O "$PATH_JSON"
    wget -q "$JSON_LINK".sig -O "$PATH_JSON".sig
}

#check the links against a public key, to verify their origin
verify_def() {
    CERTS=$(find $PATH_PUB_KEY -name '*.pub')
    for CERT in $CERTS; do
        usign -V -p $CERT -m "$PATH_JSON" -x "$PATH_JSON".sig
        if [ $? = 0 ]; then
            logger -t "autoupdate" "Link definition file match with $CERT"
            echo "Link definition file matches with $CERT"
            echo "Verification successful."
            return 0
        fi
    done
    logger -t "autoupdate" "Link definition file cannot be verified with any key from $PATH_PUB_KEY"
    echo ""
    echo "ERROR: Failed to verify link definiton file..."
    echo ""
    exit 1
}

#get the router model string. CAUTION: sometimes this string does not match the hardware
get_router() {
    if [ "$ROUTER" = "null" ]; then
        ROUTER=$(grep machine /proc/cpuinfo | cut -d':' -f 2 | cut -c 2-)
    fi
    if [ -z "$ROUTER" ]; then
        echo "Couldn't get the router-model. Please refer to the manual how to define it."
        logger -t "autoupdate" "Couldn't get router-model. Refer the manual, please."
        exit 1
    fi
}

commit_routerstring() {
    get_router
    ROUTER2=$(echo "$ROUTER" | sed -f /usr/share/autoupdate/urlencode.sed)
    wget "$DOMAIN/devicename;$ROUTER2;" 2>/dev/null
    #we 'send' the string into the webservers log and can grab them from there via a script. Server will normally give HTTP error 404.
    if [ $? == 8 ]; then
        echo "String submitted successfully."
    else
        echo "An error occured while submitting the string. Is there a way to the internet?"
    fi
}

#determine the current firmware-type (tunnel/no-tunnel, etc)
get_type() {
    if [ "$TYPE" = "null" ]; then
        UPLINK=$(uci -q get ffberlin-uplink.preset.current)
        if [ "$UPLINK" = "tunnelberlin_tunneldigger" ]; then
            TYPE="tunneldigger"
        else
            TYPE="default"
        fi
    fi
}

create_backup_file() {
    sysupgrade -b "$PATH_BAK"
}

create_backup_dir() {
    if [ ! -d "$PATH_AUTOBAK" ]; then
        mkdir "$PATH_AUTOBAK"
    fi
}

empty_backup_dir() {
    local WC
    WC=$(ls "$PATH_AUTOBAK" | wc -l)
    if [ $WC != 0 ]; then
        rm "$PATH_AUTOBAK"*
    fi
}

set_preserved_backup_dir() {
    #set $PATH_AUTOBAK to be preserved on reflash
    grep -q "$PATH_AUTOBAK" /etc/sysupgrade.conf
    if [ $? = 1 ]; then
        echo "$PATH_AUTOBAK" >>/etc/sysupgrade.conf
    fi
}

remote_backup() {
    if [ "$CLIENT_NAME" = "complete-hostname" ] && [ "$CLIENT_USER" = "user" ] && [ "$CLIENT_PATH" = "/complete/path/to/your/backups/" ]; then
        echo ""
        echo "You must specify some settings for this feature."
        echo "Have a look at: /etc/config/autoupdate"
        echo ""
        exit 1
    fi
    get_date
    get_hostname
    create_backup_file
    scp "$PATH_BAK" "$CLIENT_USER""@$CLIENT_NAME"":$CLIENT_PATH""$TODAY""_$HOSTNAME"".tar.gz"
}

#create backup archive and save it in /root/backup/.
do_auto_backup() {
    create_backup_file
    create_backup_dir
    empty_backup_dir
    set_preserved_backup_dir
    get_date
    get_hostname
    create_backup_file
    #copy backupdata to save memory
    cp "$PATH_BAK" "$PATH_AUTOBAK""$TODAY""_$HOSTNAME"".tar.gz"

    #set $PATH_AUTOBAK to be preserved on reflash
    grep -q "$PATH_AUTOBAK" /etc/sysupgrade.conf
    if [ $? = 1 ]; then
        echo "$PATH_AUTOBAK" >>/etc/sysupgrade.conf
    fi
}

chk_upgr() {
    #check if there happened any changes in the link-file
    JSON=$(cat "$PATH_JSON")
    json_load "$JSON"
    json_get_var JDATE date
    if [ $JDATE -lt $LAST_UPGR ]; then
        logger -t "autoupgrade" "Updatecheck: No updates avaiable."
        echo "No updates avaiable."
        exit 0
    fi
}

#get link to the new firmware file
get_link() {
    JSON=$(cat $PATH_JSON)
    json_load "$JSON"
    json_get_var JDATE date
    json_select "$ROUTER"
    json_get_var LINK $TYPE
    if [ -z "$LINK" ]; then
        logger -t "autoupdate" "No upgrade done. This router is not supported by autoupgrade."
        exit 0
    fi
}

#download new firmware binary.
get_bin() {
    wget $LINK -O $PATH_BIN
}

write_update_date() {
    TODAY=$(date -u +%Y%m%d)
    uci set autoupdate.upgrade_date.last_upgr="$TODAY"
    uci commit autoupdate
}

get_package_list() {
    get_date
    local LIST
    LIST=$(opkg list-installed | cut -d ' ' -f 1)
    echo $LIST >>"$PATH_AUTOBAK""/$TODAY""_package-list"
}
