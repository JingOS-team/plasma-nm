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

import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.15

Popup {
    id: popup

    height: 231 * appScale
    width: 477 * appScale

    padding: 0
    parent: forgetWifi

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        anchors.fill: parent

        radius: 15 * appScale
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            radius: 20
            samples: 25
            color: "#1A000000"
            verticalOffset: 20
            spread: 0
        }

        Rectangle {
            id: title
            
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 32 * appScale
                rightMargin: 32 * appScale
                leftMargin: 32 * appScale
            }

            height: 32 * appScale

            Kirigami.Label {
                anchors.left: parent.left

                text: "Enter Password"
            }

            Kirigami.JIconButton {
                anchors.right: confirm.left
                anchors.rightMargin: 32 * appScale

                width: 34 * appScale
                height: 34 * appScale

                source: "qrc:/image/pwd_cancel.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        popup.visible = false
                    }
                }
            }

            Kirigami.JIconButton {
                id: confirm

                anchors.right: parent.right

                width: 34 * appScale
                height: 34 * appScale

                enabled: password.length > 8
                source: "qrc:/image/pwd_confirm.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        appletProxyModel.sourceModel.saveAndActived(
                                    appletProxyModel.index(currentIndex, 0),
                                    password.text)
                        popup.visible = false
                    }
                }
            }
        }

        Rectangle {
            anchors {
                left: title.left
                right: title.right
                top: title.bottom
                topMargin: 30 * appScale
            }

            width: 415 * appScale
            height: 69 * appScale

            TextField {
                id: password

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width

                placeholderText: "input password"
                focus: true
                font.pointSize: theme.defaultFont.pointSize + 10

                background: Rectangle {
                    color: "transparent"
                }
            }

            Kirigami.Separator {
                anchors.bottom: parent.bottom

                height: 1
                width: parent.width
                
                color: "#FFE5E5EA"
            }
        }
    }
}
