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
import org.kde.kirigami 2.10 as Kirigami

Rectangle {
    id: wanMain

    property var bgColor: "transparent"
    property var titleNameColor: "#000000"
    property var bgRadius: 0
    property var titleName
    property var showBottomLine: false
    property int loadingType: 1
    property bool lockIconVisible: false
    property string wifiIconPath: "qrc:/image/signal_full.png"

    width: parent.width
    height: 45 * appScale
   
    radius: bgRadius
    color: bgColor

    Image {
        id: connectedState

        anchors {
            left: parent.left
            leftMargin: 20 * appScale
            verticalCenter: parent.verticalCenter
        }

        width: 20 * appScale
        height: 20 * appScale

        visible: loadingType == 2
        source: "qrc:/image/select_blue.png"
    }

    Image {
        id: loadingState

        anchors {
            left: parent.left
            leftMargin: 20 * appScale
            verticalCenter: parent.verticalCenter
        }

        width: 22 * appScale
        height: 22 * appScale

        visible: !connectedState.visible
        source: "qrc:/image/loading.png"

        RotationAnimation {
            id: scanAnim

            target: loadingState
            loops: Animation.Infinite
            running: loadingType == 1
            from: 0
            to: 360
            duration: 3000
        }
    }

    Kirigami.Label {
        anchors.left: loadingState.visible ? loadingState.right : connectedState.right
        anchors.leftMargin: 10 * appScale
        anchors.verticalCenter: parent.verticalCenter

        text: titleName
        color: titleNameColor
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            wifiItem.itemClicked()
        }
    }

    Image {
        id: wifiDetail

        anchors.right: parent.right
        anchors.rightMargin: 14 * appScale
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScale
        height: 22 * appScale

        source: "qrc:/image/wifi_detail.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                wifiItem.detailClicked()
            }
        }
    }

    Image {
        id: wifiIcon

        anchors.right: wifiDetail.left
        anchors.rightMargin: 3 * appScale
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScale
        height: 22 * appScale

        source: wifiIconPath
    }

    Image {
        id: wifiLock

        anchors.right: wifiIcon.left
        anchors.rightMargin: 3 * appScale
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScale
        height: 22 * appScale

        visible: lockIconVisible
        source: "qrc:/image/wifi_lock.png"
    }

    Kirigami.Separator {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 20 * appScale
            rightMargin: 20 * appScale
            bottom: parent.bottom
        }

        visible: showBottomLine
        color: "#FFE5E5EA"
    }
}
