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
    property bool isloading: true
    property bool lockIconVisible: false
    property string wifiIconPath: "qrc:/image/signal_full.png"

    signal clicked()
    width: parent.width
    height: 45 * appScaleSize
   
    radius: bgRadius
    //color: bgColor
    color: bkmouse.pressed ? Kirigami.JTheme.pressBackground : bgColor

    Image {
        id: connectedState

        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            verticalCenter: parent.verticalCenter
        }

        width: 20 * appScaleSize
        height: 20 * appScaleSize

        visible: !isloading
        source: "qrc:/image/select_blue.png"
        
    }

    Image {
        id: loadingState

        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            verticalCenter: parent.verticalCenter
        }

        width: 22 * appScaleSize
        height: 22 * appScaleSize

        visible: !connectedState.visible
        source: "qrc:/image/loading.png"

        RotationAnimation {
            id: scanAnim

            target: loadingState
            loops: Animation.Infinite
            running: isloading
            from: 0
            to: 360
            duration: 3000
        }
    }

    Kirigami.Label {
        anchors.left: loadingState.visible ? loadingState.right : connectedState.right
        anchors.leftMargin: 10 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        text: titleName
        color: titleNameColor
        font.pixelSize: 14 * appFontSize
    }

    MouseArea {
        id:bkmouse
        anchors.fill: parent


        onClicked: {
            wanMain.clicked();
            //wifiItem.itemClicked()
        }
    }

    Image {
        id: wifiDetail

        anchors.right: parent.right
        anchors.rightMargin: 18 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScaleSize
        height: 22 * appScaleSize

        source: "qrc:/image/wifi_detail.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                wanMain.clicked()
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

        source: wifiIconPath
    }

    Kirigami.Icon {
        id: wifiLock

        anchors.right: wifiIcon.left
        anchors.rightMargin: 3 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        width: 22 * appScaleSize
        height: 22 * appScaleSize

        visible: lockIconVisible
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
        color: dividerForeground
    }
}
