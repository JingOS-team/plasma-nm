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
    property int preferWidth: 934 * appScale
    property int preferHeigh: 69 * appScale
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
            leftMargin: 18 * appScale
            topMargin: 68 * appScale
        }

        height: 36 * appScale
        width: childrenRect.width

        Image {
            id: backIcon

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            width: 34 * appScale
            height: 34 * appScale

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
                leftMargin: 15 * appScale
                verticalCenter: parent.verticalCenter
            }

            font.pointSize: defaultFontSize + 9
            font.bold: true
            text: wifiName
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            top: topItem.bottom
            bottom: root.bottom
            topMargin: 42 * appScale
            bottomMargin: 37 * appScale
            horizontalCenter: root.horizontalCenter
        }

        width: preferWidth

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            spacing: 37 * appScale

            Row {
                width: preferWidth
                height: preferHeigh

                visible: isConnecttingFailed ? false : isConnected ? false : currentItemType == 1 ? true : currentItemType == 2 & isConnectting ? true : false
                
                Rectangle {
                    id: connectWifi

                    anchors.fill: parent

                    radius: 15 * appScale
                    color: "white"

                    SwitchItem {
                        id: connectItem

                        titleName: (!isConnectedSuccess
                                    & isConnectting) ? "On Connection" : "Connect"
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

                Rectangle {
                    id: forgetWifi

                    anchors.fill: parent

                    radius: 15 * appScale
                    color: "white"

                    SwitchItem {
                        id: networkStateItem

                        titleName: isConnectedSuccess ? "Forget This Network" : (currentModel.ItemType == 1) | isConnected ? "Forget This Network" : "Join This Network"
                        titleColor: "#FF3C4BE8"
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {

                                if (networkStateItem.titleName == "Forget This Network") {
                                    if (nameEquals) {
                                        connectionPath = connectiontedPath
                                    }
                                    handler.removeConnection(connectionPath)
                                    handler.requestScan()
                                    //currenProxyModel.sourceModel.sourceModel.isAllowUpdate = true
                                    wifi_root.popView()
                                } else if (networkStateItem.titleName == "Join This Network") {
                                    isOperator = true
                                    passwordPop.echoMode = TextInput.Password
                                    passwordPop.wifiName = wifiName
                                    passwordPop.devicePath = devicePath
                                    passwordPop.specificPath = specificPath
                                    passwordPop.visible = true
                                    isConnecttingFailed = false
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

                    radius: 15 * appScale
                    color: "white"

                    SwitchItem {
                        titleName: "Auto-Join"
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

                spacing: 12 * appScale
                visible: false
                
                Rectangle {
                    width: preferWidth
                    height: preferHeigh
                    
                    radius: 15 * appScale
                    color: "white"

                    SwitchItem {
                        titleName: "Low Kata Mode "
                        switchChecked: false
                    }
                }

                Kirigami.Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 875 * appScale

                    wrapMode: Text.WordWrap
                    font.pointSize: defaultFontSize - 4
                    color: "#4D000000"
                    text: "Low Data Mode helps reduce your pad data usage over your cellular network or specific WLAN networks you select.When Low Data Mode is turned on,automatic updates and background tasks,such as Photos syncing,are paused."
                }
            }

            Column {
                width: preferWidth

                spacing: 12 * appScale
                visible: isConnected

                Kirigami.Label {
                    id: mLable

                    anchors {
                        left: parent.left
                        leftMargin: 31 * appScale
                    }

                    text: "IPV4 Address"
                    color: "#4D000000"
                    font.pointSize: defaultFontSize - 4
                }

                Rectangle {
                    width: preferWidth
                    height: childrenRect.height

                    radius: 15 * appScale

                    SwitchItem {
                        id: ipTitle

                        anchors.top: parent.top

                        width: preferWidth

                        titleName: "Configure IP"
                        switchVisible: false
                        showBottomLine: true
                    }

                    SelectItem {
                        id: ipAddress
                        
                        anchors.top: ipTitle.bottom

                        width: parent.width

                        titleName: "IP Address"
                        selectName: currentModel.IpAddress
                        arrowVisible: false
                    }

                    SelectItem {
                        id: subnetMask

                        anchors.top: ipAddress.bottom
                            
                        width: parent.width

                        titleName: "Subnet Mask"
                        selectName: currentModel.SubnetMask
                        arrowVisible: false
                    }

                    SelectItem {
                        id: router

                        anchors.top: subnetMask.bottom
                            
                        width: parent.width

                        titleName: "Router"
                        selectName: defaultIpv4Method
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

                    radius: 15 * appScale
                    color: "white"

                    SwitchItem {
                        titleName: "Renew Lease"
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
                spacing: 12 * appScale

                Kirigami.Label {
                    anchors {
                        left: parent.left
                        leftMargin: 31 * appScale
                    }

                    text: "DNS"
                    color: "#4D000000"
                    font.pointSize: defaultFontSize - 4
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 15 * appScale

                    SelectItem {
                        titleName: "Configure DNS"
                        selectName: wifi_root.defaultDnsMethod
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

                spacing: 12 * appScale

                Kirigami.Label {

                    anchors {
                        left: parent.left
                        leftMargin: 31 * appScale
                    }

                    text: "Http Proxy"
                    color: "#4D000000"
                    font.pointSize: defaultFontSize - 4
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 15 * appScale

                    SelectItem {
                        titleName: "Configure Proxy"
                        selectName: "Off"
                        arrowVisible: true
                        showBottomLine: false
                    }
                }
            }
        }
    }

    JInputDialog {
        id: passwordPop

        parent: forgetWifi
        focus: true
        title: "Enter Password"
        echoMode: TextInput.Password

        onCancelButtonClicked: {
            passwordPop.visible = false
        }

        onOkButtonClicked: {
            kcm.addAndActivateConnection(passwordPop.devicePath,
                                         passwordPop.specificPath,
                                         passwordPop.inputText)

            passwordPop.visible = false
        }

        onEnteredClick: {
            kcm.addAndActivateConnection(passwordPop.devicePath,
                                         passwordPop.specificPath,
                                         passwordPop.inputText)
            passwordPop.visible = false
        }
    }
}
