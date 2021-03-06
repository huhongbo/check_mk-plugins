#!/usr/bin/env python

# Monitor the system load of a Barracuda WAFs via SNMP
# Herward Cooper <coops@fawk.eu> - 2012

# OID .1.3.6.1.4.1.20632.8.8

barracuda_waf_system_load_default_values = (50, 75)

def inventory_barracuda_waf_system_load(checkname, info):
    inventory=[]
    status = int(info[0][0])
    inventory.append( (None, None, "barracuda_waf_system_load_default_values") )
    return inventory


def check_barracuda_waf_system_load(item, params, info):
    warn, crit = params
    state = int(info[0][0])
    perfdata = [ ( "load", state, warn, crit ) ]
    if state > crit:
        return (2, "CRITICAL - Load %s percent" % state, perfdata)
    elif state > warn:
        return (1, "WARNING - Load %s percent" % state, perfdata)
    else:
        return (0, "OK - Load %s percent" % state, perfdata)

check_info["barracuda_waf_system_load"] = (check_barracuda_waf_system_load, "Barracuda WAF System Load", 1, inventory_barracuda_waf_system_load)

snmp_info["barracuda_waf_system_load"] = ( ".1.3.6.1.4.1.20632.8", ["8"] )