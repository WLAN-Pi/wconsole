# wconsole
*Turn your WLANPi in to a wireless serial console cable*

It can be annoying to have to sit in an equipment room to use the serial console port on an item of networking equipment. This project allows you to use an WLANPi to connect to your serial console cable via a wireless link while sat in the comfort of a nearby office, rather than sat with your laptop on the equipment room floor :) 

To provide a wireless console serial port, you will need:

 - a supported wireless adapter plugged in to one port of the WLANPi (e.g. CF-912ac)
 - A (compatable) USB to serial cable connected to one of the WLANPi USB ports (e.g. Prolific Technology, Inc. PL2303 Serial Port)

Before attempting to use wconsole, you must install the followings packages on your WLANPi by performing the following steps:

1. Connect your WLANPi via the Ethernet port to a network with Internet access
2. SSH to the WLANPi and login
3. Execute the following commands:
    apt-get update
    apt-get install ser2net

Once the packages are installed, copy the supplied wconsole gzipped archive (see the bundle dir on the github repo) to the /etc directory of the WLANPi (e.g.using SFTP). Extract the files from the archive using the command:

```
 tar xvfz rconsole.tar.gz
```

Change to the newly created directory /etc/wconsole:

```
 cd /etc/wconsole
```

Run the installation script to configure hostapd, ser2net isc-dhcp-server and set ufw ports files:

```
 sudo ./wconsole_switcher install
```

Flip the WLANPi in to wconsole mode:

```
 sudo ./wconsole_switcher on
```

At this point, the WLANPi will reboot. Following the reboot, an SSID of RCONSOLE will be available on channel 1. Join the SSID and use the default key: Password1.

Once you have joined the SSID, open a telnet session to 192.168.42.1:9600. This will provide access to the serial console cable plugged in to the USB port.

To switch out of rconsole mode, SSH to the WLANPi using network address 192.168.42.1 (while connected to the rconsole SSID) and run the command: 

```
 sudo /etc/wconsole/wconsole_switcher off
```

(Note: the [wlanpi-nanohat-oled](https://github.com/WLAN-Pi/wlanpi-nanohat-oled) project provides an easy option to enable/disable wconsole mode)
