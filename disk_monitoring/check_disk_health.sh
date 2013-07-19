#!/bin/bash
#
# A Disk Health plugin for the check_mk nagios system.
# Place me in /usr/lib/check_mk_agent/plugins on the client
# This script is based on S.M.A.R.T. (Self-Monitoring, Analysis, and Reporting Technology)
# Ravi Bhure <ravibhure@gmail.com>
## Check Disk Health

# Probably the most interesting values here are these lines:
# Code: https://technutopia.com/forum/showthread.php?t=1266
# ==================================================================================================
# ID# ATTRIBUTE_NAME          FLAG   VALUE WORST THRESH    TYPE    UPDATED  WHEN_FAILED RAW_VALUE  |
#  5 Reallocated_Sector_Ct    0x0033   100   100   036    Pre-fail  Always       -       0         |
# 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0         |
# 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0         |
# ==================================================================================================
# The Reallocated_Sector_Ct attribute shows the number of reallocated sectors on the disk. That means, number of bad sectors that have been "fixed" by
# allocating a spare sector and using that instead of the damaged one.
# Current_Pending_Sectors and Offline_Uncorrectable attributes indicates the number of sectors that are unreadable but the disk firmware has not replaced #them yet with  the spare sectors because it's possible that the data becomes readable later or the data gets overwritten. If any of the latter cases #happends, the disk firmware will replace the damaged sectors with the spare sectors.

# Script to check disk health
# Following threshold set for disk health
# warning = 5
# critical = 10


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

# Volume health to get the reallocated sectors
vol_health=`/usr/sbin/smartctl -a /dev/$disk  | grep "Reallocated_Sector_Ct" | awk '{print $10}' | head -1`


if [ -n "$warning" -a -n "$critical" ]
then
  if [ $vol_health -ge "$critical" ];then
    #$LOG "Critical:- Disk Health of /dev/$disk: $vol_health"
    echo "CRITICAL - $Hostname -  Bad Sectores on /dev/$disk: $vol_health | 'bad_sect'=$vol_health"
    exit $STATE_CRITICAL;
  elif [ $vol_health -ge "$warning" -a "$vol_health" -lt "$critical" ];then
    #$LOG "Warning:- Disk Health of /dev/$disk: $vol_health"
    echo "WARNING - $Hostname -  Bad Sectores on /dev/$disk: $vol_health | 'bad_sect'=$vol_health"
    exit $STATE_WARNING;
  else
    echo "OK - $Hostname -  Bad Sectores on /dev/$disk: $vol_health| 'bad_sect'=$vol_health"
    exit $STATE_OK;
  fi
else
  echo "OK - $Hostname -  Bad Sectores on /dev/$disk: $vol_health | 'bad_sect'=$vol_health"
  exit $STATE_OK;
fi
#End
