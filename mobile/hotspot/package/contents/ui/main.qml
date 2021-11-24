/*
 *   Copyright 2020 Tobias Fella <fella@posteo.de>
 *   Copyright 2021 Liu Bangguo <liubangguo@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.6
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.15 as Kirigami
import org.kde.kcm 1.2
import jingos.display 1.0

Rectangle {
    property real appScaleSize: JDisplay.dp(1.0)
    property real appFontSize: JDisplay.sp(1.0)
    property var majorForeground: Kirigami.JTheme.majorForeground
    property var minorForeground: Kirigami.JTheme.minorForeground
    property var settingMinorBackground: Kirigami.JTheme.settingMinorBackground
    property var cardBackground: Kirigami.JTheme.cardBackground
    property var highlightColor: Kirigami.JTheme.highlightColor
    property var dividerForeground: Kirigami.JTheme.dividerForeground
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"

    anchors.fill: parent

    color: settingMinorBackground

    PlasmaNM.Handler {
        id: handler
    }

    PlasmaNM.Configuration {
        id: configuration
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    Component.onCompleted:{
        configuration.hotspotName = kcm.getDeviceName();
        if(configuration.hotspotPassword == ""){
            configuration.hotspotPassword = kcm.getRadomPassword()
        }
    }

    Item {
        id: title

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 48 * appScaleSize
            leftMargin: 20 * appScaleSize
            rightMargin: 20 * appScaleSize
        }

        width: parent.width
        height: 22 * appScaleSize

        Text {
            id: titleName
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            font.bold: true
            font.pixelSize: 20 * appFontSize
            text: i18n("Personal Hotspot")
            color: majorForeground
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            top: title.bottom
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
            topMargin: 18 * appScaleSize
        }

        width: parent.width - 40 * appScaleSize
        height: 45 * 2 + 1

        color: cardBackground
        radius: 10 * appScaleSize

        Rectangle {
            id: switch_item

            width: parent.width
            height: 45 * appScaleSize //parent.height

            color: "transparent"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("Allow Others to Join")
                font.pixelSize: 14 * appFontSize
                color: majorForeground
            }

            Kirigami.JSwitch {
                id: hotspot_swith

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 20 * appScaleSize
                }

                checkable: true

                checked: handler.hotspotSupported && enabledConnections.wirelessEnabled

                onToggled: {
                    if(hotspot_swith.checked){
                        if(enabledConnections.wirelessEnabled){
                            handler.createHotspot()
                        }else{
                            hotspot_swith.checked = false
                            tipDialog.visible = true
                        }
                    } else {
                        handler.stopHotspot()
                    }
                }
            }
        }

        Kirigami.Separator {
            id: separator1

            anchors {
                top: switch_item.bottom
                left: parent.left
                right: parent.right
                rightMargin: 20 * appScaleSize
                leftMargin: 20 * appScaleSize
            }

            width: parent.width
            height: 1

            color: dividerForeground
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: separator1.bottom
            }

            height: 45 * appScaleSize

            color: "transparent"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("WLAN Password")
                font.pixelSize: 14 * appFontSize
                color: majorForeground
            }

            Text {
                id: wlanPassword
                anchors {
                    right: options_right.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                
                width: parent.width / 4

                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
                text: configuration.hotspotPassword
                font.pixelSize: 14 * appFontSize
                color: !isDarkTheme ? "#99000000" : "#8CF7F7F7"
            }

            Image {
                id: options_right

                anchors {
                    right: parent.right
                    rightMargin: 17 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                width: 22 * appScaleSize
                height: 22 * appScaleSize

                source: "../image/icon_right.png"
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    kcm.getRadomPassword()
                    passwordDialog.inputText = configuration.hotspotPassword
                    passwordDialog.visible = true
                }
            }
        }
    }

    Kirigami.JDialog {
        id: passwordDialog

        title: i18n("Enter Password")
        text: i18n("The password must contain at least 8 characters.Changing the password will disconnect any currently connected users. Other users will join your shared WLAN network using this password.")
        inputEnable: true
        showPassword: false
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("OK")
        validator: RegExpValidator {regExp: /^[\u4e00-\u9fa5 -~]+$/ }
        
        onInputTextChanged:{
            if(inputText.length > 7 ){
                rightButtonEnable = true
            }else{
                rightButtonEnable = false
            }
            if(inputText.length > 32){
                passwordDialog.inputText = inputText.substring(0,32)
            }
        }

        onRightButtonClicked: {
            if (passwordDialog.inputText.length > 7) {
                wlanPassword.text = passwordDialog.inputText
                configuration.hotspotPassword = passwordDialog.inputText
                passwordDialog.visible = false
            }
        }
        
        onLeftButtonClicked: {
            passwordDialog.visible = false
        }
    }

    Kirigami.JDialog {
        id: tipDialog

        title: i18n("Turn on WLAN")
        inputEnable: false
        text: i18n("Do you \nwant to enable it over WLAN?")
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("Turn on")
        rightButtonTextColor: highlightColor

        onRightButtonClicked: {
            handler.enableWireless(true)
            timer.running = true
            hotspot_swith.checked = true
            tipDialog.visible = false
        }
        
        onLeftButtonClicked: {
            tipDialog.visible = false
        }
    }
     Timer {
        id: timer
        interval: 1500
        repeat: false
        running: false

        onTriggered: {
            handler.createHotspot()
        }
    }
}

