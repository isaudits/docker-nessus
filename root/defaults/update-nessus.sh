#!/usr/bin/with-contenv bash

# only run update at startup if scanner initialization is complete
if [ -f /opt/nessus/var/nessus/first_run ]; then
    
    CHECK=$(/opt/nessus/sbin/nessuscli fetch --check)
    
    if [ -n "${LICENSE}" ];then
        echo "-- Registering as a Nessus Pro scanner and downloading updates"
        /opt/nessus/sbin/nessuscli fetch --register "${LICENSE}"
    elif [ -n "${SECURITYCENTER}" ];then
        echo "-- Registering as a SecurityCenter-linked scanner"
        /opt/nessus/sbin/nessuscli fetch --security-center
    fi
    
fi
