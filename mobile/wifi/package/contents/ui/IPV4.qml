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

Rectangle {
    id: root

    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: root.width - 40 * appScale
    property int preferHeigh: 34 * appScale
    property int selectIndex: 0
    property bool isConfigChanged: false

    color: "#FFF6F9FF"

    Component.onCompleted: {
        if (currentModel.Router == "Automatic") {
            selectIndex = 0
        } else if (currentModel.Router == "Manual") {
            selectIndex = 1
        }
    }

    Item {
        id: topItem

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            leftMargin: 14 * appScale
            topMargin: 48 * appScale
        }

        height: 20 * appScale
        width: parent.width

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
                    wifi_root.popView()
                }
            }
        }

        Kirigami.Label {
            id: title

            anchors {
                left: backIcon.right
                leftMargin: 10 * appScale
                verticalCenter: parent.verticalCenter
            }

            font.pixelSize: 20
            font.bold: true
            text: currentModel.Name +" "+ i18n(" Confiaure IPv4")
        }

        Kirigami.JIconButton {
            id: confirmIcon

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 31 * appScale

            width: 40 * appScale + 10
            height: 22 * appScale + 10

            enabled: isConfigChanged

            Text{
                anchors.centerIn: parent
                
                font.pixelSize: 17
                text: i18n("Save")
                color: confirmIcon.enabled ? "#FF3C4BE8" : "#2E000000"
            }
            //source: "qrc:/image/pwd_confirm.png"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (defaultIpv4Method === "Automatic") {
                        currentModel.Router = "Automatic"
                        currentModel.UpdateConnect = "update"
                    } else if (defaultIpv4Method === "Manual") {
                        currentModel.Router = "Manual"
                        currentModel.IpAddress = ipAddress.inputName
                        currentModel.SubnetMask = netMask.inputName
                        currentModel.GateWay = gateWay.inputName
                        currentModel.UpdateConnect = "update"
                    }
                    wifi_root.popView()
                }
            }
        }
    }

    Rectangle {
        id: routerSetting

        anchors {
            top: topItem.bottom
            topMargin: 31 * appScale
            horizontalCenter: parent.horizontalCenter
        }

        width: preferWidth
        height: listView.height

        radius: 10 * appScale
        color: "white"

        ListView {
            id: listView

            width: parent.width
            height: childrenRect.height

            model: listMode

            delegate: SelectItem {
                anchors.horizontalCenter: parent.horizontalCenter
                    
                width: parent.width

                imgPath: "qrc:/image/select_blue.png"
                arrowVisible: index == selectIndex
                titleName: i18n(model.displayName)
                showBottomLine: index == listView.count - 1 ? false : true

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        isConfigChanged = true
                        selectIndex = index
                        wifi_root.selectIpv4Method(model.displayName)
                    }
                }
            }
        }

        SwitchItem {
            anchors {
                top: listView.bottom
                topMargin: 24 * appScale
            }

            radius: 10 * appScale
            color: "white"
            visible: false
            switchVisible: false
            titleName: "Client ID "
            showBottomLine: false
        }
    }

    ListModel {
        id: listMode

        ListElement {
            displayName: "Automatic"
            value: 0
        }

        ListElement {
            displayName: "Manual"
            value: 1
        }
    }

    Column {
        id: columnSetting

        anchors {
            top: routerSetting.bottom
            left: routerSetting.left
            right: routerSetting.right
            topMargin: 24 * appScale
        }

        spacing: 10 * appScale
        visible: defaultIpv4Method === "Manual"

        Text {
            anchors {
                left: parent.left
                leftMargin: 20 * appScale
            }
            font.pixelSize: 14
            text: i18n("Manual IP")
        }

        Rectangle {
            width: parent.width
            height: childrenRect.height

            radius: 10 * appScale
            color: "white"

            Column {
                width: parent.width

                InputItem {
                    id: ipAddress

                    titleName: i18n("IpAddress")
                    hintText: "0.0.0.0"
                    inputName: currentModel.IpAddress
                }

                InputItem {
                    id: netMask

                    titleName: i18n("NetMask")
                    hintText: "255.255.0.0"
                    inputName: currentModel.SubnetMask
                }

                InputItem {
                    id: gateWay
                    
                    titleName: i18n("GateWay")
                    hintText: "0.0.0.0"
                    inputName: currentModel.GateWay
                    showBottomLine: false
                }
            }
        }
    }
}
