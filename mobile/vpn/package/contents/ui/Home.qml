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

Item {
    id: home_root

    property bool isVPNConnected: false
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
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    function switchVPN(status) {
        if (status) {
            isVPNConnected = true
            kcm.activateVPNConnection(currentModel.ConnectionPath,
                                      currentModel.DevicePath,
                                      currentModel.SpecificPath)
        } else {
            isVPNConnected = false
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

        Text {
            id: vpn_title

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 20 * appScale
                topMargin: 48 * appScale
            }

            width: parent.width / 3
            height: 22 * appScale

            text: i18n("VPN")
            font.pixelSize: 20
            font.weight: Font.Bold
        }

        Rectangle {
            id: vpn_area

            anchors {
                left: parent.left
                top: vpn_title.bottom
                leftMargin: 20 * appScale
                topMargin: 18 * appScale
            }

            width: parent.width - 40 * appScale
            height: 45 * appScale

            color: "white"
            radius: 10 * appScale

            Rectangle {
                id: vpn_item

                anchors {
                    top: parent.top
                }

                width: parent.width
                height: parent.height

                color: "transparent"

                Text {
                    id: slince_title

                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    text: i18n("VPN Status")
                    font.pixelSize: 14
                }

                Kirigami.JSwitch {
                    id: slince_switch

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 17 * appScale
                    }

                    checked: isVPNConnected
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
                topMargin: 8 * appScale
                leftMargin: 20 * appScale
            }

            visible: listView.currentIndex != -1
            text: i18n("To connect using ”%1”, use the “%1” application.",
                       currentModel.Name.length > 16 ? currentModel.Name.substr(
                                                           0,
                                                           16) + "..." : currentModel.Name)
            color: "#4D000000"
            font.pixelSize: 12
        }

        Rectangle {
            id: listRect

            anchors {
                top: tipText.bottom
                left: parent.left
                leftMargin: 20 * appScale
                topMargin: 24 * appScale
            }

            width: parent.width - 40 * appScale
            height: listView.height

            color: "white"
            radius: 10 * appScale

            ListView {
                id: listView

                anchors.top: parent.top
                width: parent.width
                height: listView.count < 7 ? listView.count * 60 * appScale
                                             - 1 : 6 * 60 * appScale - 1
                model: vpnProxyModel
                clip: true

                Component.onCompleted: {
                    if (!isVPNConnected) {
                        listView.currentIndex = kcm.getValue("selectIndex")
                    }
                }

                delegate: Item {
                    id: listItem

                    property var connectionState: model.ConnectionState
                    property bool isCurrentItem: ListView.isCurrentItem

                    width: listView.width
                    height: 60 * appScale

                    Component.onCompleted: {
                        if (index == 0) {
                            currentModel = model
                        }
                        if (model.ConnectionState == PlasmaNM.Enums.Activated) {
                            listView.currentIndex = index
                            currentModel = model
                            isVPNConnected = true
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
                                if (isVPNConnected | model.ConnectionState
                                        == PlasmaNM.Enums.Activating) {
                                    isConnectingClick = true
                                    isVPNConnected = false
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
                            leftMargin: 21 * appScale
                        }

                        width: 22 * appScale
                        height: 22 * appScale

                        visible: isCurrentItem
                        source: "../image/icon_confirm.png"
                    }

                    Item {
                        id: nameRect

                        anchors {
                            left: selectImg.right
                            leftMargin: 9 * appScale
                            verticalCenter: parent.verticalCenter
                        }

                        width: parent.width / 2
                        height: childrenRect.height

                        Text {
                            id: vpnName

                            width: nameRect.width

                            text: model.Name
                            font.pixelSize: 14
                            color: "#FF000000"

                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }

                        Text {
                            id: vpnDes

                            anchors.top: vpnName.bottom
                            anchors.topMargin: 5

                            width: nameRect.width

                            text: kcm.getServerName(model.ConnectionPath)
                            font.pixelSize: 12
                            color: "#4D000000"
                        }
                    }

                    Image {
                        id: infoImg

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 18 * appScale
                        }

                        width: 22 * appScale
                        height: 22 * appScale

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
                                             "connectionPath": model.ConnectionPath
                                         })
                            }
                        }
                    }

                    Kirigami.Separator {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            leftMargin: 20 * appScale
                            rightMargin: 18 * appScale
                        }

                        height: 1

                        visible: index != listView.count - 1
                        color: "#FFE5E5EA"
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    top: listRect.bottom
                    topMargin: listView.count == 0 ? 0 : 25 * appScale
                }

                width: parent.width
                height: 45 * appScale

                color: "white"
                radius: 10 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF3C4BE8"
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
}
