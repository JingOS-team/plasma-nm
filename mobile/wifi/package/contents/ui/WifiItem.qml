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
    id: wanMain

    property var bgColor: "transparent"
    property var titleNameColor: majorForeground
    property var bgRadius: 0
    property var titleName
    property var showBottomLine: false
    property string wifiIconPath: "qrc:/image/signal_full.png"
    property bool iconVisible: true
    property bool detailIconVisible: true
    property bool lockIconVisible: true

    // width: parent.width
    height: 45 * appScaleSize

    radius: bgRadius
    color: bgMouse.pressed ? Kirigami.JTheme.pressBackground : bgColor

    Kirigami.Label {
        anchors.left: parent.left
        anchors.leftMargin: 20 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        text: titleName
        color: titleNameColor
        font.pixelSize: 14 * appFontSize
    }

    MouseArea {
        id:bgMouse
        anchors.fill: parent

        onClicked: {
            wifiItem.itemClicked(mouse.x, mouse.y)
        }
    }

    Image {
        id: wifiDetail

        anchors.right: parent.right
        anchors.rightMargin: 18 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScaleSize
        height: 22 * appScaleSize

        visible: iconVisible & detailIconVisible
        source: "qrc:/image/wifi_detail.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                wifiItem.detailClicked()
            }
        }
    }

    Kirigami.Icon {
        id: wifiIcon

        anchors.right: wifiDetail.left
        anchors.rightMargin: 3 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScaleSize
        height: 22 * appScaleSize

        visible: iconVisible
        source: wifiIconPath
    }

    Kirigami.Icon {
        id: wifiLock

        anchors.right: wifiIcon.left
        anchors.rightMargin: 3 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScaleSize
        height: 22 * appScaleSize

        visible: iconVisible & lockIconVisible
        source: "qrc:/image/wifi_lock.png"
        color: isDarkTheme ? majorForeground : "transparent"
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
        height: 1
        color: dividerForeground
    }

    Item{
        anchors.left:wifiIcon.right
        anchors.right:parent.right
        height:parent.height

        MouseArea {
            anchors.fill: parent

            onClicked: {
                wifiItem.detailClicked()
            }
        }
    }
}
