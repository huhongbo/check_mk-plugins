#!/bin/bash
#
# A Disk Temprature plugin for the check_mk nagios system.
# Place me in /usr/lib/check_mk_agent/plugins on the client
# This script is based on S.M.A.R.T. (Self-Monitoring, Analysis, and Reporting Technology)
# sudo /usr/sbin/smartctl -A /dev/sda -q errorsonly
# cat /proc/partitions | awk '{print $4}' | grep -vE 'name|[0-9]' | xargs echo

# Ravi Bhure <ravibhure@gmail.com>
## Check Disk Temprature

# Script to check disk temprature
# If returned Drive failure expected in less than 24 hours. SAVE ALL DATA: alarming condition, please inform Admin person immediately

# Following threshold set for disk temprature in celcius
# warning = 50
# critical = 60

LOG=/usr/bin/logger
FLAG=0
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
crit="No"
null="NULL"
ok="Yes"
Hostname=`hostname`

print_help(){
    echo "Usage: $0 -d sda [-w 40] [-c 50]"
    echo ""
    echo "Options:"
    echo "  -d/--disk"
    echo "     A disk can be defined via -d. Choose sda and sdb."
    echo "  -w/--warning"
    echo "     Defines a warning level for a target which is explained"
    echo "     below. Default is: off"
    echo "  -c/--critical"
    echo "     Defines a critical level for a target which is explained"
    echo "     below. Default is: off"
    echo "     "
    exit 3
}
if [ "$#" -lt 1 ]
then
  print_help
fi

while test -n "$1"; do
    case "$1" in
        -help|-h)
            print_help
            exit 3
            ;;
        --disk|-d)
            disk=$2
            shift
            ;;
        --warning|-w)
            warning=$2
            shift
            ;;
        --critical|-c)
            critical=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit 3
            ;;
        esac
    shift
done

TEMP=`/usr/sbin/smartctl -a /dev/$disk  | grep "Temperature_Celsius" | awk '{print $10}' | wc -l`

if [ $TEMP -eq "0" ];then
  vol_temp=`/usr/sbin/smartctl -a /dev/$disk  | grep "Current Drive Temperature:" | awk '{print $4}' | head -1`
else
  vol_temp=`/usr/sbin/smartctl -a /dev/$disk  | grep "Temperature_Celsius" | awk '{print $10}' | head -1`
fi
#echo $vol_temp
#vol_temp=46
if [ -n "$warning" -a -n "$critical" ]
then
  if [ $vol_temp -ge "$critical" ];then
    $LOG "Critical:- Disk Temprature of /dev/$disk: $vol_temp °C"
    echo "CRITICAL - $Hostname -  Disk Temprature of /dev/$disk: $vol_temp °C | 'vol_temp'=$vol_temp"
    exit $STATE_CRITICAL;
  elif [ $vol_temp -ge "$warning" -a "$vol_temp" -lt "$critical" ];then
    $LOG "Warning:- Disk Temprature of /dev/$disk: $vol_temp °C"
    echo "WARNING - $Hostname -  Disk Temprature of /dev/$disk: $vol_temp °C | 'vol_temp'=$vol_temp"
    exit $STATE_WARNING;
  else
    echo "OK - $Hostname -  Disk Temprature of /dev/$disk: $vol_temp °C | 'vol_temp'=$vol_temp"
    exit $STATE_OK;
  fi
else
  echo "OK - $Hostname -  Disk Temprature of /dev/$disk: $vol_temp °C | 'vol_temp'=$vol_temp"
  exit $STATE_OK;
fi
#End
