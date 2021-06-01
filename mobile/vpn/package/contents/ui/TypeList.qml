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

    property int selectIndex: 0
    signal itemSelect(int index, var displayName)

    height: listView.height
    width: 240 * appScale

    padding: 0

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        anchors.fill: parent

        radius: 10 * appScale
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            radius: 15
            samples: 25
            color: "#1A000000"
            verticalOffset: 0
            spread: 0
        }

        ListView {
            id: listView

            width: parent.width
            height: childrenRect.height

            model: typeMode

            delegate: Item {

                width: parent.width
                height: 45 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    text: model.displayName
                    font.pixelSize: 14
                    color: "black"
                }

                Image {
                    anchors {
                        right: parent.right
                        rightMargin: 17 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScale
                    height: 22 * appScale

                    visible: index == selectIndex
                    source: "../image/icon_confirm.png"
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScale
                        rightMargin: 17 * appScale
                        bottom: parent.bottom
                    }

                    height: 1

                    visible: index != listView.count - 1
                    color: "#FFE5E5EA"
                }

                MouseArea {
                    anchors.fill: parent
                    
                    onClicked: {
                        selectIndex = index
                        popup.visible = false
                        popup.itemSelect(index, model.displayName)
                    }
                }
            }
        }
    }
    ListModel {
        id: typeMode

        ListElement {
            displayName: "L2TP"
        }
        ListElement {
            displayName: "PPTP"
        }
        ListElement {
            displayName: "OpenVPN"
        }
    }
}
