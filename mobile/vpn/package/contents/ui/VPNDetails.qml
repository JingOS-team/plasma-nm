
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
import jingos.display 1.0

Item {
    id: detail_root

    property var currentModel
    property var currentName
    property var connectionPath
    property var devicePath

    anchors.fill: parent

    Item {
        id: title

        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
            top: parent.top
            topMargin: JDisplay.statusBarHeight
        }
        height: 62 * appScaleSize

        Item {
            width: parent.width
            height: icon_back.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 6 * appScaleSize

            Kirigami.JIconButton {
                id: icon_back
                width: (22 + 8) * appScaleSize
                height: (22 + 8) * appScaleSize

                source: isDarkTheme ? Qt.resolvedUrl("../image/icon_back_dark.png") : Qt.resolvedUrl("../image/icon_back.png")
                onClicked: {
                    popView()
                }
            }

            Text {
                anchors.left: icon_back.right
                anchors.leftMargin: 10 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width / 2

                font.bold: true
                font.pixelSize: 20 * appFontSize
                text: currentName
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                color: majorForeground
            }

            Kirigami.JButton {
                id: img_confirm

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                visible: !(currentModel.ConnectionState == 1
                           || currentModel.ConnectionState == 2)
                enabled: detailItem.visible == true || editConfig.addEnable

                backgroundColor:"transparent"
                fontColor: detailItem.visible == true || editConfig.addEnable ? Kirigami.JTheme.highlightColor : Kirigami.JTheme.disableForeground
                font.pixelSize: 17 * appFontSize
                text: editConfig.visible ? i18n("Done") : i18n("Edit")

                onClicked: {
                    if (img_confirm.text == i18n("Done")) {
                        editConfig.updateVPNConfig()
                        currentName = editConfig.desText

                        typeText.text = editConfig.currentType
                        gateWayText.text = editConfig.gateWayText
                        userNameText.text = editConfig.userNameText
                        m_gateWayText = editConfig.gateWayText
                        editConfig.visible = false
                        detailItem.visible = true
                    } else if (img_confirm.text == i18n("Edit")) {
                        kcm.onDetailClicked(connectionPath,devicePath)
                        editConfig.initParams()
                        editConfig.visible = true
                        detailItem.visible = false
                    }
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
                leftMargin: 20 * appScaleSize
                topMargin: 11 * appScaleSize
            }

            width: parent.width - 40 * appScaleSize
            height: column.height

            radius: 10 * appScaleSize
            color: cardBackground

            Column {
                id: column

                anchors {
                    left: content.left
                    top: content.top
                }

                width: content.width
                height: childrenRect.height + 1

                Rectangle {
                    anchors {
                        left: parent.left
                    }

                    width: column.width
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
                        color: majorForeground
                        text: i18n("Type")
                    }

                    Text {
                        id: typeText

                        anchors {
                            right: parent.right
                            rightMargin: 20 * appScaleSize
                            verticalCenter: parent.verticalCenter
                        }

                        font.pixelSize: 14 * appFontSize
                        color: majorForeground
                        text: kcm.getConnectionType()
                    }
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScaleSize
                        rightMargin: 20 * appScaleSize
                    }

                    width: column.width
                    height: 1

                    color: dividerForeground
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        topMargin: 45 * appScaleSize
                    }

                    width: column.width
                    height: 45 * appScaleSize

                    color: cardBackground
                    radius: 15 * appScaleSize

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 20 * appScaleSize
                            verticalCenter: parent.verticalCenter
                        }

                        font.pixelSize: 14 * appFontSize
                        color: majorForeground
                        text: i18n("Gateway")
                    }

                    Text {
                        id: gateWayText

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 20 * appScaleSize
                        }

                        font.pixelSize: 14 * appFontSize
                        color: majorForeground
                        text: kcm.getServerName()
                    }
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScaleSize
                        rightMargin: 20 * appScaleSize
                    }

                    width: column.width
                    height: 1

                    visible: userNameRect.visible
                    color: dividerForeground
                }

                Rectangle {
                    id: userNameRect

                    anchors {
                        left: parent.left
                    }

                    visible: kcm.getConnectionType() != "OpenVPN"

                    width: column.width
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
                        color: majorForeground
                        text: i18n("Username")
                    }

                    Text {
                        id: userNameText

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 20 * appScaleSize
                        }

                        font.pixelSize: 14 * appFontSize
                        color: majorForeground
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
                leftMargin: 20 * appScaleSize
                topMargin: 9 * appScaleSize
            }

            text: i18n("To configure the settings for ”%1”,use the ”%1” application.",
                       currentName.length > 16 ? currentName.substr(
                                                     0,
                                                     16) + "..." : currentName)
            font.pixelSize: 12 * appFontSize
            color: minorForeground
        }

        Rectangle {
            anchors {
                left: content.left
                right: content.right
                top: tipText.bottom
                topMargin: 24 * appScaleSize
            }

            height: 45 * appScaleSize

            color: cardBackground
            radius: 10 * appScaleSize

            Text {
                anchors.centerIn: parent

                text: i18n("Delete VPN")
                color: highlightColor
                font.pixelSize: 14 * appFontSize

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
            leftMargin: 20 * appScaleSize
            topMargin: 18 * appScaleSize
        }

        width: parent.width - 40 * appScaleSize

        visible: false
        isSelectable: false
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
