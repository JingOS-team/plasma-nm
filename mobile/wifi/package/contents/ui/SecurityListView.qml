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

    property var securityModel
    property int selectIndex: 2

    height: listView.height
    width: 369 * appScale

    padding: 0
    
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
            verticalOffset: 0
            spread: 0
        }

        ListView {
            id: listView

            width: parent.width
            height: childrenRect.height

            model: securityModel

            delegate: SelectItem {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                height: 69 * appScale

                titleName: model.displayName
                imgPath: "qrc:/image/select_blue.png"
                arrowVisible: index == selectIndex
                showBottomLine: index == listView.count - 1 ? false : true
                
                MouseArea {
                    anchors.fill: parent
                    
                    onClicked: {
                        selectIndex = index
                        securitySelect.itemSelect(model.displayName)
                        popup.visible = false
                    }
                }
            }
        }
    }
}
