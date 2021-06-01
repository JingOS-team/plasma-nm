# Plasma-nm

Network-related settings of plasma-settings for JingOS. Contains wifi and vpn functions.
Based on the kde open source project: https://invent.kde.org/plasma/plasma-nm.git



## Features

* Plasma applet written in QML for managing network connections

* Run on JingOS platform

* Brand new UI & UE with JingOS-style , based on JingUI Framework

* Support keyboard & touchpad & mouse & screen touch

* All keys support pressed / hovered effects

* Well-designed interface material:

  * Font
  * Icon
  * Picture
  
* The Plasma-nm that the application handles follow the [ical](https://tools.ietf.org/html/rfc5545) standard.



## Links

* Home page: https://www.jingos.com/

* Project page: https://github.com/JingOS-team/plasma-nm

* Issues: https://github.com/JingOS-team/plasma-nm/issues

* Development channel: https://forum.jingos.com/



## Dependencies

* Qt5 

* Cmake

* KI18n

* Kirigami (JingOS Version)

* Service

* Plasma

* networkmanager-qt
 
* NetworkManager 0.9.10 and newer

* Wallet

* Notifications

* modemmanager-qt
  - requires ModemManager 1.0.0 and newer as runtime dependency
  - Plasma-nm is compiled with ModemManager support by default when modemmanager-qt is found,
    when you want to explicitly disable ModemManager support, use -DDISABLE_MODEMMANAGER_SUPPORT=true cmake parameter.

* openconnect
  - if you want to build the OpenConnect VPN plugin

* NetworkManager-fortisslvpn|iodine|l2tp|openconnect|openswan|openvpn|pptp|ssh|sstp|strongswan|vpnc
  - these are runtime dependencies for VPN plugins



## Build

To build Plasma-nm from source on Linux, execute the below commands.



### Compile

```
  mkdir build
  cd build
  cmake ../ -DCMAKE_INSTALL_PREFIX=/usr [-DDISABLE_MODEMMANAGER_SUPPORT=true]
  make
```



#### Run

```
bin/plasma-settings -m wifi
bin/plasma-settings -m vpn
```



#### Install

```
sudo make install
```

