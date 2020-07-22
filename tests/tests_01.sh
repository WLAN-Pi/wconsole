#! /bin/bash
#
# wconsole test suite - all tests to be peformed from the CLI 
# of the WLAN Pi while switched in to wconsole mode
#
#

MODULE=wconsole
VERSION=1.01
COMMENTS="Inital test script"
SCRIPT_NAME=$(basename $0)

# Tests log file
LOG_FILE="test_results.log"
# WLAN Pi status file (hostspot, wiperf etc...)
STATUS_FILE="/etc/wlanpi-state"
# initialize test counter
c=0

# root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

########################################
# Helper functions
########################################

inc () {  c=$((c + 1));  }
info () {  inc; echo "(info) Test $c : $1" | tee -a $LOG_FILE;  }
good () {  echo "( ok ) $1" | tee -a $LOG_FILE; }
bad () {  echo "(fail) $1" | tee -a $LOG_FILE; exit 1;  }
comment () {  echo $1 | tee -a $LOG_FILE; }

########################################
# Test suite
########################################

run_tests () {

  comment ""
  comment "###########################################"
  comment "  Running $MODULE test suite"
  comment "###########################################"
  comment ""

  # check what state the WLAN Pi is in
  info "Checking current mode is wconsole"
  if  [[ `cat $STATUS_FILE | grep 'wconsole'` ]]; then good "WLAN Pi is in wconsole mode"; else bad "WLAN Pi is not in wconsole mode"; fi

  # check hostapd running 
  info "Checking hostapd running"
  if [[ `pgrep hostapd` ]]; then good "hostapd running"; else bad "hostapd not running"; fi

  # check ser2net running
  info "Checking ser2net running"
  if [[ `pgrep hostapd` ]]; then good; else bad; fi

  # check dhcpd running
  info "Checking dhcpd running"
  if [[ `pgrep dhcpd` ]]; then good; else bad; fi

  # check wlan0 up and running with correct IP address
  wlan0_ip=192.168.42.1
  info "Checking wlan0 has correct IP (${wlan0_ip})"
  if [[ `ifconfig wlan0 | grep $wlan0_ip` ]]; then good; else bad; fi

  # check expected ports open
  info "Checking selection of expected network ports open"
  port_array=(:9600 :9601 :9602 :9603 :9604 :9605 :9606 :9607 :9608)
  for port in "${port_array[@]}"; do
    if [[ `netstat -a | grep $port` ]]; then good $port; else bad $port; fi
  done

  # check ufw port ranges are configured
  info "Checking expected ufw port ranges are open"
  range_array=(2400:2408/tcp 4800:4808/tcp 9600:9608/tcp 19200:19208/tcp 11520:11528/tcp 2000:2008/tcp)
  for range in "${range_array[@]}"; do
    if [[ `ufw status | grep $range` ]]; then good $range; else bad $range; fi
  done

  # To do:
  #
  # DHCP checks:
  #     1. DHCP config ?
  # 
  # Others..?

  comment ""
  comment "###########################################"
  comment "  End of $MODULE test suite"
  comment "###########################################"
  comment ""

}

########################################
# main
########################################

case "$1" in
  -v)
        echo ""
        echo "Test script version: $VERSION"
        echo $COMMENTS
        echo ""
        ;;
  -h)
        echo "Usage: $SCRIPT_NAME [ -h | -v ]"
        echo ""
        echo "  $SCRIPT_NAME -v : script version"
        echo "  $SCRIPT_NAME -h : script help"
        echo "  $SCRIPT_NAME   : run test suite"
        echo ""
        exit 0
        ;;
  *)
        run_tests
        exit 0
        ;;
esac

exit 0
