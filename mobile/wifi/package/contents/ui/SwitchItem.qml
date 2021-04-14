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

import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2
import org.kde.kirigami 2.15 as Kirigami

Rectangle {
    id: root

    property var titleName
    property bool showBottomLine: false
    property bool switchVisible: true
    property bool switchChecked: true
    property var titleColor: "#FF000000"
    property bool isConnecting: false

    signal autoConnectChecked(bool checked)

    width: parent.width
    height: 69 * appScale

    color: "transparent"

    Image {
        id: loadingState

        anchors {
            left: parent.left
            leftMargin: 31 * appScale
            verticalCenter: parent.verticalCenter
        }

        width: 34 * appScale
        height: 34 * appScale

        visible: isConnecting
        source: "qrc:/image/loading.png"

        RotationAnimation {
            id: scanAnim

            target: loadingState
            loops: Animation.Infinite
            running: true
            from: 0
            to: 360
            duration: 3000
        }
    }

    Kirigami.Label {
        anchors.left: isConnecting ? loadingState.right : parent.left
        anchors.leftMargin: isConnecting ? 10 * appScale : 31 * appScale
        anchors.verticalCenter: parent.verticalCenter

        text: titleName
        font.pointSize: defaultFontSize
        color: titleColor
    }

    Kirigami.JSwitch {
        id: mSwitch

        anchors.right: parent.right
        anchors.rightMargin: 18 * appScale
        anchors.verticalCenter: parent.verticalCenter

        width: 68 * appScale
        height: 40 * appScale

        visible: switchVisible
        checked: switchChecked

        onCheckedChanged: {
            root.autoConnectChecked(checked)
        }
    }

    Kirigami.Separator {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 31 * appScale
            rightMargin: 31 * appScale
            bottom: parent.bottom
        }

        visible: showBottomLine
        border.color: "#FFE5E5EA"
    }
}
