#!/usr/bin/with-contenv bash

# Check registration status and update
if /opt/nessus/sbin/nessuscli fetch --check; then
    
    /opt/nessus/sbin/nessuscli update --all
    
else
    
    if [ -n "${LICENSE}" ];then
        echo "-- Registering as a Nessus Pro scanner and downloading updates"
        /opt/nessus/sbin/nessuscli fetch --register "${LICENSE}"
    elif [ -n "${SECURITYCENTER}" ];then
        echo "-- Registering as a SecurityCenter-linked scanner"
        /opt/nessus/sbin/nessuscli fetch --security-center
    fi
    
fi
