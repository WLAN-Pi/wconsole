# wconsole
*Turn your WLANPi in to a wireless serial console cable*

It can be annoying to have to sit in an equipment room to use the serial console port on an item of networking equipment. This project allows you to use an WLANPi to connect to your serial console cable via a Wi-Fi link while sat in the comfort of a nearby office, rather than sat with your laptop on the equipment room floor :) 

##Requirements

To provide a wireless console serial port, you will need:

 - a supported wireless adapter plugged in to one port of the WLANPi (e.g. CF-912AC, CF-915AC)
 - A (compatable) USB to serial cable connected to one of the WLANPi USB ports (e.g. Prolific Technology, Inc. PL2303 Serial Port)
 - A recent generation WLANPi that has 2 USB sockets
 - WLANPi distribution v1.6.1 or later on the WLANPi (https://github.com/WLAN-Pi/wlanpi/releases)

Before attempting to use wconsole, you must ensure you have the correct packages installed on your WLANPi. The packages used are:

 - isc-dhcp-server (installed as part of the standard distribution)
 - hostapd (installed as part of the standard distribution)
 - ufw  (installed as part of the standard distribution)
 - ser2net (unlikley to be present until next WLANPi distribution mid/late 2019)

Initially, do a check for the availability of the ser2net package on the WLANPi by accessing the WLANPi via SSH and running the following command: 

```
 sudo apt list --installed | grep ser2net
```
Here is the type of output you may expect to see if/when it is installed:

```
 root@wlanpi:/home/wlanpi# sudo apt list --installed | grep ser2net

 WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

 ser2net/stable,now 2.10.1-1+b1 arm64 [installed]
```

Assuming the ser2net package is missing from your WLANPi, install it as follows:

1. Connect your WLANPi via the Ethernet port to a network with Internet access
2. SSH to the WLANPi and login
3. Execute the following commands:

```
    apt-get update
    apt-get install ser2net
```

## Installation

Once the required packages are installed, copy the gzipped archive in the bundle folder in this github repo to the /etc directory of the WLANPi (e.g.using SFTP). Extract the files from the archive using the command:

```
 tar xvfz wconsole.tar.gz
```

Change to the newly created directory /etc/wconsole:

```
 cd /etc/wconsole

```

Run the installation script to configure hostapd, ser2net isc-dhcp-server files and set the required ufw ports:

```
 sudo ./wconsole_switcher install
```

As there are quite a few networking changes we need to make for wconsole to operate correctly, we need to flip the WLANPi in to a new mode of operation that uses a different network configuration. The 'wconsole_switcher' script is used to switch bewteen the usual "classic" mode of operation and the "wconsole" mode of operation. 

When moving to the wconsole mode, various configuration files are and changed on the WLANPi, with the orignal networking files being preserved to allow restoration to the original configuration. 

When moving back to the original "classic" mode, all changed files are restored to their original state. 

When moving between modes, the WLANPi will reboot to ensure that all new network configuration starts cleanly. 

## Enabling Wconsole Mode

To flip the WLANPi in to wconsole mode, SSH to the WLANPi and excute the following commands:

```
 sudo /etc/wconsole/wconsole_switcher on
```

At this point, the WLANPi will reboot so that the new networking configuration will take effect. Following the reboot, by default, an SSID of "WCONSOLE" will be available on channel 1. You can join the SSID using the default key: Password1.

Once you have joined the SSID, open a telnet session to 192.168.42.1:9600. This will provide access to the serial console cable plugged in to the USB port, operating with a serial port configuration of 9600,8,N,1.

## Exiting Wconsole Mode

To switch out of rconsole mode, SSH to the WLANPi using network address 192.168.42.1 (while connected to the rconsole SSID) and run the command: 

```
 sudo /etc/wconsole/wconsole_switcher off
```

When this command is executed, the original ("classic" mode) networking configuration files will be restored and the WLANPi will reboot. After the reboot, the WLANPi will operation as it did before the switch to "wconsole" mode.

## Configurations Options

It is very likely that you will not want to use this utility with the default shared key, channel and SSID. 

To change from the default settings, ensure that the WLANPi is in standard "classic"mode. Then, edit the file: /etc/wconsole/conf/hostapd.conf. This can be done by opening an SSH session to the WLANPi and using the 'nano' editor:

```
 sudo nano /etc/wconsole/conf/hostapd.conf
```

Change the following fields with your desired values:

```
 ssid=WCONSOLE
 channel=1
 wpa_passphrase=Password1
```

Once you have made your changes, hit Ctrl-X to exit and hit "Y" to save the changes when prompted.

Next, flip the WLANPi back in to "wconsole" mode as described in previous sections. After the accompanying reboot, the WLANPi should use the newly configured parameters.

(Note: if you make these changes while in "wconsole" mode, they will not take effect. You must start in "classic" mode, make the updates, then switch to "wconsole" mode)

## Alternative Switching Option

If you feel brave, the [wlanpi-nanohat-oled](https://github.com/WLAN-Pi/wlanpi-nanohat-oled) project provides an easy option to enable/disable wconsole mode via a front pane menu system. Take a look at the project page to find out more details.
