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
import org.kde.kirigami 2.10 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Rectangle {
    id: root

    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: 934 * appScale
    property int preferHeigh: 69 * appScale
    property int selectIndex: 0

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
            leftMargin: 18 * appScale
            topMargin: 68 * appScale
        }

        height: 36 * appScale
        width: parent.width

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
            text: currentModel.Name + " Confiaure IPv4"
        }

        Image {
            id: confirmIcon

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 68 * appScale

            width: 34 * appScale
            height: 34 * appScale

            source: "qrc:/image/pwd_confirm.png"

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
            topMargin: 42 * appScale
            horizontalCenter: parent.horizontalCenter
        }

        width: preferWidth
        height: listView.height

        radius: 15 * appScale
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
                titleName: model.displayName
                showBottomLine: index == listView.count - 1 ? false : true

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        selectIndex = index
                        wifi_root.selectIpv4Method(model.displayName)
                    }
                }
            }
        }

        SwitchItem {
            anchors {
                top: listView.bottom
                topMargin: 39 * appScale
            }

            radius: 15 * appScale
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
            topMargin: 39 * appScale
        }

        visible: defaultIpv4Method === "Manual"

        Kirigami.Label {
            anchors {
                left: parent.left
                leftMargin: 30 * appScale
            }

            font.pointSize: defaultFontSize - 4
            text: "Manual IP"
        }

        Rectangle {
            width: parent.width
            height: childrenRect.height

            radius: 15 * appScale
            color: "white"

            Column {
                width: parent.width

                InputItem {
                    id: ipAddress

                    titleName: "IpAddress "
                    hintText: "0.0.0.0"
                    inputName: currentModel.IpAddress
                }

                InputItem {
                    id: netMask

                    titleName: "NetMask"
                    hintText: "255.255.0.0"
                    inputName: currentModel.SubnetMask
                }

                InputItem {
                    id: gateWay
                    
                    titleName: "GateWay"
                    hintText: "0.0.0.0"
                    inputName: currentModel.GateWay
                }
            }
        }
    }
}
