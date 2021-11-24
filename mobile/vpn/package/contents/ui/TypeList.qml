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

Kirigami.JArrowPopup {
    id: popup

    property int selectIndex: 0
    signal itemSelect(int index, var displayName)

    height: listView.height + topPadding + bottomPadding
    width: 240 * appScaleSize

    leftPadding:0
    rightPadding:0

    blurBackground.arrowX: width * 0.8
    blurBackground.arrowWidth: 16 * appScaleSize
    blurBackground.arrowHeight: 11 * appScaleSize
    blurBackground.arrowPos: Kirigami.JRoundRectangle.ARROW_TOP

    
    contentItem: Item {

        ListView {
            id: listView

            width: parent.width
            height: childrenRect.height

            model: typeMode
            interactive: false

            delegate: Item {

                width: parent.width
                height: 45 * appScaleSize

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    text: model.displayName
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                }

                Image {
                    anchors {
                        right: parent.right
                        rightMargin: 17 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScaleSize
                    height: 22 * appScaleSize

                    visible: index == selectIndex
                    source: "../image/icon_confirm.png"
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScaleSize
                        rightMargin: 17 * appScaleSize
                        bottom: parent.bottom
                    }

                    height: 1

                    visible: index != listView.count - 1
                    color: dividerForeground
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
