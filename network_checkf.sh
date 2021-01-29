gateway_ips='52.33.18.109'
nic='eth1'
network_check_threshold=1
reboot_server=true
reboot_cycle=10
last_bootfile=/tmp/.last_net_autoboot


network_check_tries=0

function date_log {
    echo "$(date +'%Y-%m-%d %T') $1"
}

function check_gateways {
    for ip in $gateway_ips; do
        ping -c 1 $ip > /dev/null 2>&1
        # The $? variable always contains the return code of the previous command.
        # In BASH return code 0 usually means that everything executed successfully.
        # In the next if we are checking if the ping command execution was successful.
        if [[ $? == 0 ]]; then
            return 0
        fi
    done
    return 1
}


function restart_wlan {
    date_log "Network was not working for the previous $network_check_tries checks."
    date_log "Restarting $nic"
    
    /sbin/ip link set "$nic" down
    sleep 5
    /sbin/ip link set "$nic" up
    sleep 60
}


while [ $network_check_tries -lt $network_check_threshold ]; do
    
    network_check_tries=$((network_check_tries+1))

    
    if check_gateways; then
        
        date_log "Network is working correctly" && exit 0
    else
        
        date_log "Network is down, failed check number $network_check_tries of $network_check_threshold"
    fi

    
    if [ $network_check_tries -ge $network_check_threshold ]; then
        date_log "Network is still not working, rebooting"
	/sbin/reboot
    fi
    sleep 5
done
