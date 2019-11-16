# Wi-Fi Console
*Turn your WLANPi in to a wireless serial console cable*

It can be annoying to have to sit in an equipment room to use the serial console port on an item of networking equipment. This project allows you to use a WLANPi to connect to your serial console cable via a Wi-Fi link while sat in the comfort of a nearby office, rather than sat with your laptop on the equipment room floor :) 

![WLANPi wconsole demo](https://github.com/WLAN-Pi/wconsole/blob/master/images/wlanpi_console.jpg)

## Requirements

To provide a wireless console serial port using your WLANPi, you will need:

 - a supported wireless adapter plugged in to one USB port of the WLANPi (e.g. CF-912AC, CF-915AC)
 - A recent generation WLANPi that has 2 USB sockets
 - A (compatible) USB to serial cable connected to one the other WLANPi USB port (e.g. Prolific Technology, Inc. PL2303 Serial Port)
 - WLANPi distribution v1.6.1 or later installed on the WLANPi (https://github.com/WLAN-Pi/wlanpi/releases)

## Enabling Wi-Fi Console Mode

To flip the WLANPi in to "Wi-Fi Console" mode, using the front panel menu system select the following options

```
 Menu > Actions > W-Console > Confirm
```

At this point, the WLANPi will reboot so that the new networking configuration will take effect. Following the reboot, the "Wi-Fi Console" mode is reported on the WLANPi display.

## Disabling Wi-Fi Console Mode

To flip the WLANPi back to classic mode use the front panel menu system select the following options

```
 Menu > Actions > Classic Mode > Confirm
```

The WLANPi will reboot and start up in the default, classic mode.

# Using Wi-Fi Console

Following the WLANPi reboot, by default, an SSID of "wifi_console" will be available on channel 1. You can join the SSID with a wireless client (e.g. your laptop) using the default shared key: wifipros

Once you have joined the SSID, open a telnet session to the WLANPi at 192.168.42.1 using network port 9600. This will provide access to the serial console cable plugged in to the USB port, operating with a serial port configuration of 9600,8,N,1.

In addition to the serial port configuration on TCP 9600 the following ports are also configured in the "ser2net" configuration file:

 - TCP port 2400 : serial port config: 2400,8,N,1
 - TCP port 4800 : serial port config: 4800,8,N,1
 - TCP port 9600 : serial port config: 9600,8,N,1
 - TCP port 19200: serial port config: 19200,8,N,1

(If you wish to experiment yourself with the network port allocations, see the /etc/wconsole/conf/ser2net.conf file)

 ## Configurations Options

It is very likely that you will not want to use this utility with the default shared key, channel and SSID. 

To change from the default settings, ensure that the WLANPi is operating in standard "classic"mode. Then, edit the file: /etc/wconsole/conf/hostapd.conf. This can be done by opening an SSH session to the WLANPi and using the 'nano' editor:

```
 sudo nano /etc/wconsole/conf/hostapd.conf
```

Change the following fields to your desired values:

```
 ssid=wifi_console
 channel=1
 wpa_passphrase=wifipros
```

Once you have made your changes, hit Ctrl-X to exit and hit "Y" to save the changes when prompted.

Next, flip the WLANPi back in to "Wi-Fi Console" mode as described in previous sections. After the accompanying reboot, the WLANPi should operate using the newly configured parameters.

(Note: if you make these changes while in "Wi-Fi Console" mode, they will not take effect. You must start in "classic" mode, make the updates, then switch to "Wi-Fi Console" mode)


# Legacy Options (Not Recommended For General Use)

(It is possible to flip in to Wi-Fi console mode using the Linux CLI, but it is strongly recommended to use the native WLANPi front panel navigation menu)

As there are quite a few networking changes we need to make for Wi-Fi Console to operate correctly, we need to flip the WLANPi in to a completely new mode of operation that uses a different network configuration. The 'wconsole_switcher' script is used to switch between the usual "classic" mode of operation and the "Wi-Fi Console" mode of operation. 

When moving to the "Wi-Fi Console" mode, various configuration files are changed on the WLANPi, with the original networking files being preserved to allow restoration to the original ("classic" mode) configuration. 

When moving back to the original "classic" mode, all changed files are restored to their original state. 

When moving between modes, the WLANPi will reboot to ensure that all new network configuration starts cleanly. 

## Enabling Wi-Fi Console Mode (Via CLI)

To flip the WLANPi in to "Wi-Fi Console" mode, SSH to the WLANPi and execute the following command:

```
 sudo /etc/wconsole/wconsole_switcher on
```

At this point, the WLANPi will reboot so that the new networking configuration will take effect. 


## Exiting Wi-Fi Console Mode (via CLI)

To switch out of "Wi-Fi Console" mode, SSH to the WLANPi using network address 192.168.42.1 (while connected to the Wi-Fi Console SSID, using standard port 22) and run the command: 

```
 sudo /etc/wconsole/wconsole_switcher off
```

When this command is executed, the original ("classic" mode) networking configuration files will be restored and the WLANPi will reboot. After the reboot, the WLANPi will operatw as it did before the switch to "Wi-Fi Console" mode.

