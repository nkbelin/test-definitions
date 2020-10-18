#!/bin/bash

if [[ $(fastboot devices) ]]; then 
    fastboot reboot
    echo "going out of fastboot"
    sleep 5
fi
