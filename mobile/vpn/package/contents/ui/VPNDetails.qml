
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

Item {
    id: detail_root

    property var currentModel
    property var currentName
    property var connectionPath

    anchors.fill: parent

    Item {
        id: title

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 48 * appScale
            leftMargin: 14 * appScale
            rightMargin: 20 * appScale
        }

        width: parent.width
        height: 22 * appScale

        Image {
            id: icon_back

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            width: 22 * appScale
            height: 22 * appScale

            source: "../image/icon_back.png"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    popView()
                }
            }
        }

        Text {
            anchors.left: icon_back.right
            anchors.leftMargin: 10 * appScale
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width / 2

            font.bold: true
            font.pixelSize: 20
            text: currentName
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
        }

        Kirigami.JIconButton {
            id: img_confirm

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            width: 53 * appScale + 10
            height: 21 * appScale + 10

            visible: !(currentModel.ConnectionState == 1
                       || currentModel.ConnectionState == 2)
            enabled: detailItem.visible == true | editConfig.addEnable

            Text {
                id: stateText

                anchors.centerIn: parent

                text: editConfig.visible ? i18n("Done") : i18n("Edit")
                color: detailItem.visible == true | editConfig.addEnable ? "#FF3C4BE8" : "#2E000000"
                font.pixelSize: 17
            }

            onClicked: {
                if (stateText.text == i18n("Done")) {
                    editConfig.updateVPNConfig()
                    currentName = editConfig.desText

                    typeText.text = editConfig.currentType
                    gateWayText.text = editConfig.gateWayText
                    userNameText.text = editConfig.userNameText
                    editConfig.visible = false
                    detailItem.visible = true
                } else if (stateText.text == i18n("Edit")) {
                    editConfig.initParams()
                    editConfig.visible = true
                    detailItem.visible = false
                }
            }
        }
    }

    Item {
        id: detailItem

        anchors {
            top: title.bottom
            left: parent.left
        }

        width: parent.width

        Rectangle {
            id: content

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 20 * appScale
                topMargin: 18 * appScale
            }

            width: parent.width - 40 * appScale
            height: column.height

            radius: 10 * appScale
            color: "white"

            Column {
                id: column

                anchors {
                    left: content.left
                    top: content.top
                }

                width: content.width
                height: 45 * appScale * 3 + 1

                Rectangle {
                    anchors {
                        left: parent.left
                    }

                    width: column.width
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
                        color: "black"
                        text: i18n("Type")
                    }

                    Text {
                        id: typeText

                        anchors {
                            right: parent.right
                            rightMargin: 20 * appScale
                            verticalCenter: parent.verticalCenter
                        }

                        font.pixelSize: 14
                        color: "#99000000"
                        text: kcm.getConnectionType()
                    }
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScale
                        rightMargin: 20 * appScale
                    }

                    width: column.width
                    height: 1

                    color: "#FFE5E5EA"
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        topMargin: 45 * appScale
                    }

                    width: column.width
                    height: 45 * appScale

                    color: "white"
                    radius: 15 * appScale

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 20 * appScale
                            verticalCenter: parent.verticalCenter
                        }

                        font.pixelSize: 14
                        color: "black"
                        text: i18n("Gateway")
                    }

                    Text {
                        id: gateWayText

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 20 * appScale
                        }

                        font.pixelSize: 14
                        color: "#99000000"
                        text: kcm.getServerName()
                    }
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScale
                        rightMargin: 20 * appScale
                    }

                    width: column.width
                    height: 1

                    visible: userNameRect.visible
                    color: "#FFE5E5EA"
                }

                Rectangle {
                    id: userNameRect

                    anchors {
                        left: parent.left
                    }

                    width: column.width
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
                        color: "black"
                        text: i18n("Username")
                    }

                    Text {
                        id: userNameText

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 20 * appScale
                        }

                        font.pixelSize: 14
                        color: "#99000000"
                        text: kcm.getUserName()
                    }
                }
            }
        }

        Text {
            id: tipText

            anchors {
                left: content.left
                top: content.bottom
                leftMargin: 20 * appScale
                topMargin: 9 * appScale
            }

            text: i18n("To configure the settings for ”%1”,use the ”%1” application.",
                       currentName.length > 16 ? currentName.substr(
                                                     0,
                                                     16) + "..." : currentName)
            font.pixelSize: 12
            color: "#4D000000"
        }

        Rectangle {
            anchors {
                left: content.left
                right: content.right
                top: tipText.bottom
                topMargin: 24 * appScale
            }

            height: 45 * appScale

            color: "white"
            radius: 10 * appScale

            Text {
                anchors.centerIn: parent

                text: i18n("Delete VPN")
                color: "#FF3C4BE8"
                font.pixelSize: 14

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        deleteDialog.visible = true
                    }
                }
            }
        }
    }

    EditConfig {
        id: editConfig

        anchors {
            left: parent.left
            top: title.bottom
            leftMargin: 20 * appScale
            topMargin: 18 * appScale
        }

        width: parent.width - 40 * appScale

        visible: false
    }

    Kirigami.JDialog {
        id: deleteDialog

        title: i18n("Delete VPN")
        inputEnable: false
        text: i18n("Are you sure you want to delete this VPN?")
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("Delete")
        rightButtonTextColor: "#FF3C4BE8"

        onRightButtonClicked: {
            kcm.removeVPNConnection(connectionPath)
            popView()
            deleteDialog.visible = false
        }
        
        onLeftButtonClicked: {
            deleteDialog.visible = false
        }
    }
}
