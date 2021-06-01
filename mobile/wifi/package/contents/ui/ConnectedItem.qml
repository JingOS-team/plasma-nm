/*
 *   Copyright 2021 Wang Rui <wangrui@jingos.com>
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

import org.kde.kcm 1.2 as KCM
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.extras 2.0 as PlasmaExtras

Rectangle {
    id: root

    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: root.width - 40 * appScale
    property int preferHeigh: 45 * appScale
    property bool isConnected: currentModel.ConnectionState == PlasmaNM.Enums.Activated
    property var currentName: currentModel.Name
    property bool isOperator: false
    property bool isConnecttingFailed: false
    property bool isConnectting: networkStatus.networkStatus == "Connecting"
                                 & editorProxyModel.currentConnectedName != currentName
    property bool isConnectedSuccess: isOperator & editorProxyModel.currentConnectedName
                                      == currentName
    property bool nameEquals: editorProxyModel.currentConnectedName == currentName
    property var currentItemType: currentModel.ItemType
    property var devicePath: currentModel.DevicePath
    property var connectionPath: currentModel.ConnectionPath
    property var connectiontedPath: editorProxyModel.currentConnectedPath
    property var specificPath: currentModel.SpecificPath
    property var wifiName: currentModel.Name

    color: "#FFF6F9FF"

    onIsConnecttingChanged: {
        if (!isConnectting) {
            isConnecttingFailed = true
        }
    }

    Component.onCompleted: {
        defaultIpv4Method = currentModel.Router
        defaultDnsMethod = currentModel.Router
        isOperator = false
        isConnecttingFailed = false
    }

    Item {
        id: topItem

        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 14 * appScale
            topMargin: 48 * appScale
        }

        width: childrenRect.width
        height: 20 * appScale

        Image {
            id: backIcon

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            width: 22 * appScale
            height: 22 * appScale

            source: "qrc:/image/arrow_left.png"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    currenProxyModel.sourceModel.sourceModel.isAllowUpdate = true
                    wifi_root.popView()
                }
            }
        }

        Kirigami.Label {
            id: title

            anchors {
                left: backIcon.right
                leftMargin: 11 * appScale
                verticalCenter: parent.verticalCenter
            }

            font.pixelSize: 20
            font.bold: true
            text: wifiName
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            top: topItem.bottom
            bottom: root.bottom
            topMargin: 31 * appScale
            bottomMargin: 20 * appScale
            horizontalCenter: root.horizontalCenter
        }

        width: preferWidth

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            spacing: 24 * appScale

            Row {
                width: preferWidth
                height: preferHeigh

                visible: isConnecttingFailed ? false : isConnected ? false : currentItemType == 1 ? true : currentItemType == 2 & isConnectting ? true : false
                
                Rectangle {
                    id: connectWifi

                    anchors.fill: parent

                    radius: 10 * appScale
                    color: "white"

                    SwitchItem {
                        id: connectItem

                        titleName: (!isConnectedSuccess
                                    & isConnectting) ? i18n("On Connection") : i18n("Connect")
                        titleColor: isConnectedSuccess ? "#FF3C4BE8" : isConnectting ? "#FFA8A8AC" : "#FF3C4BE8"
                        isConnecting: isConnectedSuccess ? false : isConnectting
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                isOperator = true
                                handler.activateConnection(connectionPath,
                                                           devicePath,
                                                           specificPath)
                            }
                        }
                    }
                }
            }

            Row {
                width: preferWidth
                height: preferHeigh

                visible:isConnectedSuccess | !isConnectting

                Rectangle {
                    id: forgetWifi

                    anchors.fill: parent

                    radius: 10 * appScale
                    color: "white"

                    SwitchItem {
                        id: networkStateItem

                        titleName: isConnectedSuccess ? i18n("Forget This Network") : (currentModel.ItemType == 1) | isConnected ? i18n("Forget This Network") : i18n("Join This Network")
                        titleColor: "#FF3C4BE8"
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {

                                if (networkStateItem.titleName == i18n("Forget This Network")) {
                                    deleteDialog.visible = true
                                } else if (networkStateItem.titleName == i18n("Join This Network")) {

                                    isOperator = true
                                    passwordPop.devicePath = devicePath
                                    passwordPop.specificPath = specificPath
                                    passwordPop.text = i18n("Enter the password for”%1”",currentName);
                                    isConnecttingFailed = false
                                    if(currentModel.SecurityType == -1 | currentModel.SecurityType == 0){
                                        kcm.addNoSecurityConnection(connectionPath,
                                                        devicePath,
                                                        specificPath)
                                                       return;
                                    }
                                    passwordPop.visible = true
                                }
                            }
                        }
                    }
                }
            }

            Row {
                width: preferWidth
                height: preferHeigh

                visible: currentModel.ItemType == 1

                Rectangle {
                    anchors.fill: parent

                    radius: 10 * appScale
                    color: "white"

                    SwitchItem {
                        titleName: i18n("Auto-Join")
                        switchChecked: currentModel.Autoconnect

                        onAutoConnectChecked: {
                            if (checked !== currentModel.Autoconnect) {
                                currentModel.Autoconnect = checked
                            }
                        }
                    }
                }
            }

            Column {
                width: preferWidth

                spacing: 4 * appScale
                visible: false
                
                Rectangle {
                    width: preferWidth
                    height: preferHeigh
                    
                    radius: 10 * appScale
                    color: "white"

                    SwitchItem {
                        titleName: i18n("Low Kata Mode ")
                        switchChecked: false
                    }
                }

                Kirigami.Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 563 * appScale

                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: "#4D000000"
                    text: i18n("Low Data Mode helps reduce your pad data usage over your cellular network or specific WLAN networks you select.When Low Data Mode is turned on,automatic updates and background tasks,such as Photos syncing,are paused.")
                }
            }

            Column {
                width: preferWidth

                spacing: 10 * appScale
                visible: isConnected

                Text {
                    id: mLable

                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                    }

                    text: i18n("IPV4 Address")
                    color: "#4D000000"
                    font.pixelSize: 12
                }

                Rectangle {
                    width: preferWidth
                    height: childrenRect.height

                    radius: 10 * appScale

                    SwitchItem {
                        id: ipTitle

                        anchors.top: parent.top

                        width: preferWidth

                        titleName: i18n("Configure IP")
                        switchVisible: false
                        showBottomLine: true
                    }

                    SelectItem {
                        id: ipAddress
                        
                        anchors.top: ipTitle.bottom

                        width: parent.width

                        titleName: i18n("IP Address")
                        selectName: currentModel.IpAddress
                        arrowVisible: false
                    }

                    SelectItem {
                        id: subnetMask

                        anchors.top: ipAddress.bottom
                            
                        width: parent.width

                        titleName: i18n("Subnet Mask")
                        selectName: currentModel.SubnetMask
                        arrowVisible: false
                    }

                    SelectItem {
                        id: router

                        anchors.top: subnetMask.bottom
                            
                        width: parent.width

                        titleName: i18n("Router")
                        selectName: i18n(defaultIpv4Method)
                        arrowVisible: true
                        showBottomLine: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                wifi_root.gotoPage("ipv4_view")
                            }
                        }
                    }
                }
            }

            Row {
                width: preferWidth
                height: preferHeigh

                visible: false

                Rectangle {
                    anchors.fill: parent

                    radius: 10 * appScale
                    color: "white"

                    SwitchItem {
                        titleName: i18n("Renew Lease")
                        titleColor: "#FF3C4BE8"
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (isConnected) {
                                    handler.deactivateConnection(
                                                currentModel.ConnectionPath,
                                                currentModel.DevicePath)
                                }
                            }
                        }
                    }
                }
            }

            Column {
                width: preferWidth
                spacing: 4 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                    }

                    text: i18n("DNS")
                    color: "#4D000000"
                    font.pixelSize: 12
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 10 * appScale

                    SelectItem {
                        titleName: i18n("Configure DNS")
                        selectName: i18n(wifi_root.defaultDnsMethod)
                        arrowVisible: true
                        showBottomLine: false
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            wifi_root.gotoPage("dns_view")
                        }
                    }
                }
            }

            Column {
                width: preferWidth

                spacing: 4 * appScale
                visible: false
                
                Text {

                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                    }

                    text: i18n("Http Proxy")
                    color: "#4D000000"
                    font.pixelSize: 12
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 10 * appScale

                    SelectItem {
                        titleName: i18n("Configure Proxy")
                        selectName: i18n("Off")
                        arrowVisible: true
                        showBottomLine: false
                    }
                }
            }
        }
    }

    Kirigami.JDialog {
        id: deleteDialog

        title: i18n("Forget WLAN Network")
        inputEnable: false
        text: i18n("Your device will no longer join this WLAN network.")
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("Forget")
        rightButtonTextColor: "#FF3C4BE8"

        onRightButtonClicked: {
            if (nameEquals) {
                connectionPath = connectiontedPath
            }
            handler.removeConnection(connectionPath)
            handler.requestScan()
            wifi_root.popView()
            deleteDialog.visible = false
        }
        
        onLeftButtonClicked: {
            deleteDialog.visible = false
        }
    }
}
