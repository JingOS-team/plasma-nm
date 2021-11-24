/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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
import QtQuick.Controls 2.10
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import jingos.display 1.0
Item {
    id: home_root

    property bool isCurrentVpnConnected: false
    property bool isLvCompleted: false
    property var isConnectingClick: false
    property var isConnectFaild: false

    width: parent.width
    height: parent.height
    
    Connections {
        target: kcm

        onVpnConnectedFaild: {
            isConnectFaild = true
            slince_switch.checked = false
        }

        onVpnConnectedSuccess: {
        }

        onActivateVpnConnectionFailed:{
            console.log("onActivateVpnConnectionFailed   currentModel.Name:"+currentModel.Name+"  name:"+name)
            if(currentModel.Name == name){
                isConnectFaild = true
                slince_switch.checked = false 
                errorDialog.visible = true
            }
        }
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    function switchVPN(status) {
        if (status) {
            isCurrentVpnConnected = true
            kcm.activateVPNConnection(currentModel.ConnectionPath,
                                      currentModel.DevicePath,
                                      currentModel.SpecificPath)
        } else {
            isCurrentVpnConnected = false
            if (!isConnectFaild) {
                kcm.deactivateVPNConnection(currentModel.ConnectionPath,
                                            currentModel.DevicePath)
            } else {
                isConnectFaild = false
            }
        }
    }
    
    Item {
        anchors.fill: parent


        Item {
            id: vpn_title
            anchors {
                left: parent.left
                leftMargin: 20 * appScaleSize
                right: parent.right
                rightMargin: 20 * appScaleSize
                top: parent.top
                topMargin:  JDisplay.statusBarHeight
            }

            height: 62 * appScaleSize

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 6 * appScaleSize

                color: majorForeground
                text: i18n("VPN")
                font.pixelSize: 20 * appFontSize
                font.weight: Font.Bold
            }
        }

        Rectangle {
            id: vpn_area

            anchors {
                left: parent.left
                top: vpn_title.bottom
                leftMargin: 20 * appScaleSize
                topMargin: 18 * appScaleSize
            }

            width: parent.width - 40 * appScaleSize
            height: 45 * appScaleSize

            color: cardBackground
            radius: 10 * appScaleSize

            Rectangle {
                id: vpn_item

                anchors {
                    top: parent.top
                }

                width: parent.width
                height: 45 * appScaleSize

                color: "transparent"

                Text {
                    id: slince_title

                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    color: majorForeground
                    text: i18n("Status")
                    font.pixelSize: 14 * appFontSize
                }

                Text{
                    anchors {
                        right: slince_switch.left
                        rightMargin: slince_switch.visible ? 10 * appScaleSize : 0
                        verticalCenter: parent.verticalCenter
                    }    

                    color: isDarkTheme ? "#8CF7F7F7" : "#993C3C43"
                    font.pixelSize: 14 * appFontSize
                    text: isVpnConnected ? i18n("Connected") : isCurrentVpnConnected ? i18n("Connecting") : i18n("Not Connected")
                }

                Kirigami.JSwitch {
                    id: slince_switch

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 17 * appScaleSize
                    }

                    width:listView.count != 0 ? 46 * appScaleSize : 0
                    implicitWidth: 43 * appScaleSize
                    implicitHeight: 26 * appScaleSize
                    
                    checked: isCurrentVpnConnected 
                    visible: listView.count != 0
                    
                    onCheckedChanged: {
                        if (isLvCompleted) {
                            switchVPN(checked)
                            if (checked
                                    && listView.currentIndex == kcm.getValue(
                                        "selectIndex")) {
                                currentModel.isCurrentItem = true
                            }
                            if (!checked) {
                                currentModel.isCurrentItem = false
                            }
                        }
                    }

                    Component.onCompleted: {
                        isLvCompleted = true
                    }
                }
            }
        }

        Text {
            id: tipText

            anchors {
                top: vpn_area.bottom
                left: vpn_area.left
                topMargin: 8 * appScaleSize
                leftMargin: 20 * appScaleSize
            }

            visible: listView.currentIndex != -1
            text: i18n("To connect using ”%1”, use the “%1” application.",
                       currentModel.Name.length > 16 ? currentModel.Name.substr(
                                                           0,
                                                           16) + "..." : currentModel.Name)
            color: minorForeground
            font.pixelSize: 12 * appFontSize
        }

        Rectangle {
            id: listRect

            anchors {
                top: tipText.bottom
                left: parent.left
                leftMargin: 20 * appScaleSize
                topMargin: 24 * appScaleSize
            }

            width: parent.width - 40 * appScaleSize
            height: listView.height

            color: cardBackground
            radius: 10 * appScaleSize

            ListView {
                id: listView

                anchors.top: parent.top
                width: parent.width
                height: listView.count < 7 ? listView.count * 60 * appScaleSize
                                             - 1 : 6 * 60 * appScaleSize - 1
                model: vpnProxyModel
                clip: true

                Component.onCompleted: {
                    if (!isCurrentVpnConnected) {
                        listView.currentIndex = kcm.getValue("selectIndex")
                    }
                }

                delegate: Item {
                    id: listItem

                    property var connectionState: model.ConnectionState
                    property bool isCurrentItem: ListView.isCurrentItem

                    width: listView.width
                    height: 60 * appScaleSize

                    Component.onCompleted: {
                        if (index == 0) {
                            currentModel = model
                        }
                        if (model.ConnectionState == PlasmaNM.Enums.Activated) {
                            listView.currentIndex = index
                            currentModel = model
                            isCurrentVpnConnected = true
                        }
                    }

                    onIsCurrentItemChanged: {
                        if (isCurrentItem) {
                            currentModel = model
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        propagateComposedEvents: true

                        onClicked: {

                            kcm.saveValue("selectIndex", index)
                            if (listView.currentIndex != index) {
                                if (isCurrentVpnConnected | model.ConnectionState
                                        == PlasmaNM.Enums.Activating) {
                                    isConnectingClick = true
                                    isCurrentVpnConnected = false
                                }
                                listView.currentIndex = index
                                currentModel = model
                            }
                        }
                    }

                    Image {
                        id: selectImg

                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 21 * appScaleSize
                        }

                        width: 22 * appScaleSize
                        height: 22 * appScaleSize

                        visible: isCurrentItem
                        source: "../image/icon_confirm.png"
                    }

                    Item {
                        id: nameRect

                        anchors {
                            left: selectImg.right
                            leftMargin: 9 * appScaleSize
                            verticalCenter: parent.verticalCenter
                        }

                        width: parent.width / 2
                        height: childrenRect.height

                        Text {
                            id: vpnName

                            width: nameRect.width

                            text: model.Name
                            font.pixelSize: 14 * appFontSize
                            color: majorForeground

                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }

                        Text {
                            id: vpnDes

                            anchors.top: vpnName.bottom
                            anchors.topMargin: 5

                            width: nameRect.width

                            text: m_gateWayText == "" ? kcm.getServerName(model.ConnectionPath) : m_gateWayText
                            font.pixelSize: 12 * appFontSize
                            color: minorForeground
                        }
                    }

                    Image {
                        id: infoImg

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 18 * appScaleSize
                        }

                        width: 22 * appScaleSize
                        height: 22 * appScaleSize

                        source: "../image/icon_info.png"

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                //currentModel = model
                                kcm.onDetailClicked(model.ConnectionPath,
                                                    model.DevicePath)
                                gotoPage("detail_view", {
                                             "currentModel": model,
                                             "currentName": model.Name,
                                             "connectionPath": model.ConnectionPath,
                                             "devicePath": model.DevicePath
                                         })
                            }
                        }
                    }

                    Kirigami.Separator {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            leftMargin: 20 * appScaleSize
                            rightMargin: 18 * appScaleSize
                        }

                        height: 1

                        visible: index != listView.count - 1
                        color: dividerForeground
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    top: listRect.bottom
                    topMargin: listView.count == 0 ? 0 : 25 * appScaleSize
                }

                width: parent.width
                height: 45 * appScaleSize

                color: cardBackground
                radius: 10 * appScaleSize

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: highlightColor
                    text: i18n("Add VPN Configuration…")
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        gotoPage("config_view")
                    }
                }
            }
        }
    }
    
    ListModel {
        id: listModel

        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
        ListElement {
            Name: "Shadowrocket"
        }
    }

    Kirigami.JDialog {
        id: errorDialog
        
        title: i18n("Unable to turn on VPN")
        text: i18n("Please make sure the data network is turned on")
        centerButtonText: i18n("OK")

        onCenterButtonClicked: {
            errorDialog.visible = false
        }
    }
}
