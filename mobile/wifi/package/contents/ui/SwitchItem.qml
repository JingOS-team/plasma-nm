/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
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
    property var titleColor: majorForeground
    property bool isConnecting: false

    signal autoConnectChecked(bool checked)

    width: parent.width
    height: 45 * appScaleSize

    color: "transparent"

    Image {
        id: loadingState

        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            verticalCenter: parent.verticalCenter
        }

        width: 22 * appScaleSize
        height: 22 * appScaleSize

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
        anchors.leftMargin: isConnecting ? 10 * appScaleSize : 20 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        text: titleName
        font.pixelSize: 14 * appFontSize
        color: titleColor
    }

    Kirigami.JSwitch {
        id: mSwitch

        anchors.right: parent.right
        anchors.rightMargin: 20 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        width: 43 * appScaleSize
        height: 26 * appScaleSize

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
            leftMargin: 20 * appScaleSize
            rightMargin: 20 * appScaleSize
            bottom: parent.bottom
        }

        visible: showBottomLine
        color: dividerForeground
        height: 1
    }
}
