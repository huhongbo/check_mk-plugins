#!/bin/bash
# Script to install disk monitoring plugin for check_mk

# Author: Ravi bhure < ravibhure@gmail.com>

# wget -q -O - https://raw.github.com/ravibhure/check_mk-plugins/master/disk_monitoring/install_disk_check.sh | bash

mrpe_dir=/etc/check_mk
mrpeconf=$mrpe_dir/mrpe.cfg
plugindir=/usr/lib/check_mk_agent/plugins

# Get disk list from partition table
disklist=`cat /proc/partitions  | awk '{print $NF}' | grep -vE 'name|loop'  | grep -v '[1-9]' | xargs echo`


dwn_chk_scripts(){
  if [ ! -f $plugindir/check_disk_temp.sh ] ;then
    echo "check_disk_temp.sh not found, copying into check_mk plugin directory"
    wget -q -P $plugindir https://raw.github.com/ravibhure/check_mk-plugins/master/disk_monitoring/check_disk_temp.sh
  fi
  if [ ! -f $plugindir/check_disk_health.sh ] ;then
    echo "check_disk_health.sh not found, copying into check_mk plugin directory"
    wget -q -P $plugindir https://raw.github.com/ravibhure/check_mk-plugins/master/disk_monitoring/check_disk_health.sh
  fi
  chmod +x $plugindir/*
}

# Update mrpe.cfg
update_mrpe(){
  if ! grep --quiet Check_Disk_Temp $mrpeconf ; then
    echo "Check_Disk_Temp check entry updating in $mrpeconf"
    for disk in $disklist ; do
      echo "Check_Disk_Temp   $plugindir/check_disk_temp.sh -d $disk -w 45 -c 50" >> $mrpeconf
    done
  fi
  if ! grep --quiet Check_Disk_Health $mrpeconf ; then
    echo "Check_Disk_Health check entry updating in $mrpeconf"
    for disk in $disklist ; do
      echo "Check_Disk_Health   $plugindir/check_disk_health.sh -d $disk  -w 40 -c 50 " >> $mrpeconf
    done
  fi
}

# create /etc/check_mk if not found
if [ ! -d $mrpe_dir ] ; then
  echo "$mrpe_dir not found, creating and updating $mrpeconf"
  mkdir $mrpe_dir ;
  update_mrpe
else
  echo "$mrpe_dir already exists"
  echo "Updating $mrpeconf"
  if [ -f "$mrpeconf" ] ; then
    update_mrpe
  fi
fi

# Downloading disk monitoring plugins 
dwn_chk_scripts

# End
