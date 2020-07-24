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
LOG_FILE="${SCRIPT_NAME}_results.log"
# WLAN Pi status file (hostspot, wiperf etc...)
STATUS_FILE="/etc/wlanpi-state"
# initialize test counter
test_counter=0
# test failure number
failure=0
# initialize error counter
err=0

# root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

##############################################
# Helper functions - see docs at end of file
##############################################

summary () {
  if [[ $failure = 0 ]]; then completed=$test_counter; else completed=$failure; fi
  echo ""
  echo "-----------------------------------"
  echo " Total tests: $test_counter"
  echo " Number tests completed: $completed"
  echo " Errors: $err"
  echo "-----------------------------------"
  echo ""
}

inc ()     { test_counter=$((test_counter + 1));  }
info ()    { inc; echo "(info) Test $test_counter : $1" | tee -a $LOG_FILE;  }
pass ()    { echo "(pass) $1" | tee -a $LOG_FILE; }
fail ()    { echo "(fail) $1" | tee -a $LOG_FILE; err=$((err + 1)); failure=$test_counter; }
skip ()    { echo "(skip) Test skipped due to earlier failure " | tee -a $LOG_FILE; }
comment () { echo $1 | tee -a $LOG_FILE; }


check ()     { if [[ ! $failure = 0 ]]; then skip; return; fi;  if [[ $1 ]];   then pass; else fail; fi; }
check_not () { if [[ ! $failure = 0 ]]; then skip; return; fi;  if [[ ! $1 ]]; then pass; else fail; fi; }

file_exists ()    { info "Checking file exists: $1"; if [[ ! $failure = 0 ]]; then skip; return; fi;  if [[ -e $1 ]]; then pass; else fail; fi; }
dir_exists ()     { info "Checking directory exists: $1"; if [[ ! $failure = 0 ]]; then skip; return; fi;  if [[ -d $1 ]]; then pass; else fail; fi; }
symlink_exists () { info "Checking symlink exists: $1"; if [[ ! $failure = 0 ]]; then skip; return; fi;  if [[ -L $1 ]]; then pass; else fail; fi; }
check_process ()  { info "Checking process running: $1"; if [[ ! $failure = 0 ]]; then skip; return; fi;  if [[ `pgrep $1` ]]; then pass; else fail; fi; }

########################################
# Test rig overview
########################################
echo "\

=======================================================
Test rig description:

  1. WLAN Pi running image to be tested
  2. Supported wireless NIC card on one of USB ports
  3. WLAN Pi is switched in to wconsole mode
  4. wconsole config files are default

======================================================="

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
  check `cat $STATUS_FILE | grep 'wconsole'`

  # check we have directories expected
  dir_exists "/etc/wconsole"

  # check various files exist
  file_exists "/etc/wconsole/conf/hostapd.conf"
  file_exists "/etc/wconsole/conf/ser2net.conf"
  file_exists "/etc/wconsole/default/isc-dhcp-server"
  file_exists "/etc/wconsole/default/ufw"
  file_exists "/etc/wconsole/dhcp/dhcpd.conf"
  file_exists "/etc/wconsole/network/interfaces"
  file_exists "/etc/wconsole/sysctl/sysctl.conf"
  file_exists "/usr/bin/wconsole_switcher"

  # check file symbolic links exist
  symlink_exists "/etc/network/interfaces"
  symlink_exists "/etc/default/isc-dhcp-server"
  symlink_exists "/etc/dhcp/dhcpd.conf"
  symlink_exists "/etc/network/interfaces"
  symlink_exists "/etc/ser2net.conf"
  symlink_exists "/etc/hostapd.conf"
  symlink_exists "/etc/sysctl.conf"
  symlink_exists "/etc/default/ufw"
  symlink_exists "/etc/ufw/before.rules"


  # check hostapd running 
  check_process "hostapd"

  # check ser2net running
  check_process "ser2net"

  # check dhcpd running
  check_process "dhcpd"

  # check wlan port is in correct state (Mode:Master)
  info "Checking wlan adapter in master mode"
  check `iwconfig wlan0 | grep 'Mode:Master'`

  # check wlan0 up and running with correct IP address
  wlan0_ip=192.168.42.1
  info "Checking wlan0 has correct IP (${wlan0_ip})"
  check `ifconfig wlan0 | grep $wlan0_ip`

  # check expected ports open
  info "Checking selection of expected network ports open"
  if [[ $failure = 0 ]]; then 
    port_array=(:9600 :9601 :9602 :9603 :9604 :9605 :9606 :9607 :9608)
    for port in "${port_array[@]}"; do
      if [[ `netstat -a | grep $port` ]]; then pass $port; else fail $port; fi
    done
  else
    skip 
  fi

  # check ufw port ranges are configured
  info "Checking expected ufw port ranges are open"
  if [[ $failure = 0 ]]; then
    range_array=(2400:2408/tcp 4800:4808/tcp 9600:9608/tcp 19200:19208/tcp 11520:11528/tcp 2000:2008/tcp)
    for range in "${range_array[@]}"; do
      if [[ `ufw status | grep $range` ]]; then pass $range; else fail $range; fi
    done
  else
    skip 
  fi

  # To do:
  #
  # DHCP checks:
  #     1. DHCP config ?
  # 
  # Others..?

  # Print summary
  summary

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
        echo "  $SCRIPT_NAME    : run test suite"
        echo ""
        exit 0
        ;;
  *)
        run_tests
        exit 0
        ;;
esac

exit 0

<< 'HOWTO'

#################################################################################################################

Test Utility Documentation
--------------------------

 This script uses a set of useful utilities to simplify running a series of 
 tests from this bash script. The syntax of the utilities is shown below:

 inc: increment the test counter (a global var 'c')
 info: write the text in $1 (var passed to function)  and the next test number to stdout & the log file
 pass: write a "pass" msg to stdout & the log file, with optional additional msg in $1 (var passed to function)
 fail: write a "fail" msg to stdout & the log file, with optional additional msg in $1 (var passed to function)
       (sets fail flag to bypass subsequent tests)
 skip: write a "skip" msg to stdout & the log file
 comment: output text supplied in $1 to std & log file

 check: call pass() if condition passed is true (can inc option msg via $1), otherwise fail()
 check_not: call pass() if condition passed is false (can inc option msg via $1), otherwise fail()

 file_exists: call pass() if file name passed via $1 exists, else call fail()
 dir_exists: call pass() if dir name passed via $1 exists, else call fail()
 symlink_exists: call pass() if file name passed via $1 is a symlink, else call fail()
 check_process: call pass() if process name passed via $1 is running, else call fail()


#################################################################################################################
HOWTO
