DISK MONITORING
===============

check_disk_health.sh
--------------------
A Disk Temprature plugin for the check_mk nagios system.
Place me in /usr/lib/check_mk_agent/plugins on the client
This script is based on S.M.A.R.T. (Self-Monitoring, Analysis, and Reporting Technology)

Probably the most interesting values here are these lines:
```bash
# Code: https://technutopia.com/forum/showthread.php?t=1266
# ==================================================================================================
# ID# ATTRIBUTE_NAME          FLAG   VALUE WORST THRESH    TYPE    UPDATED  WHEN_FAILED RAW_VALUE  |
#  5 Reallocated_Sector_Ct    0x0033   100   100   036    Pre-fail  Always       -       0         |
# 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0         |
# 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0         |
# ==================================================================================================
# The Reallocated_Sector_Ct attribute shows the number of reallocated sectors on the disk. That means, number of bad sectors that have been <fixed> by
# allocating a spare sector and using that instead of the damaged one.
# Current_Pending_Sectors and Offline_Uncorrectable attributes indicates the number of sectors that are unreadable but the disk firmware has not replaced #them yet with  the spare sectors because its possible that the data becomes readable later or the data gets overwritten. If any of the latter cases #happends, the disk firmware will replace the damaged sectors with the spare sectors.

```bash

check_disk_temp.sh
------------------
A Disk Temprature plugin for the check_mk nagios system.
Place me in /usr/lib/check_mk_agent/plugins on the client
This script is based on S.M.A.R.T. (Self-Monitoring, Analysis, and Reporting Technology)

Install instructions
--------------------
Run this command on all check_mk client server which can setup the client side check_mk mrpe.cfg checks for disks.

```bash
# wget -q -O - https://raw.github.com/ravibhure/check_mk-plugins/master/disk_monitoring/install_disk_check.sh | bash
```bash

This script will download check_disk_health.sh & check_disk_temp.sh on target client server and update the mrpe.cfg file.
For nagios server side setup, one should need to take mrpe reinventory of these servers and setup the check_mk base file to keep delay of 10min for these specific checks.
