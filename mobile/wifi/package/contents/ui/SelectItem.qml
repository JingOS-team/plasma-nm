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
import org.kde.kirigami 2.10 as Kirigami

Item {
    id: root

    property var titleName
    property var selectName
    property bool showBottomLine: true
    property bool arrowVisible: false
    property bool rightPartVisible: true
    property string imgPath: "qrc:/image/arrow_right.png"

    width: parent.width
    height: 45 * appScaleSize

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 20 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter
        text: titleName
        font.pixelSize: 14 * appFontSize
        color: majorForeground
    }

    Item {
        anchors {
            right: parent.right
            rightMargin: 20 * appScaleSize
        }

        height: parent.height

        visible: rightPartVisible
        
        Image {
            id: rightArrow

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            width: 22 * appScaleSize
            height: 22 * appScaleSize

            visible: arrowVisible
            source: imgPath
        }

        Kirigami.Label {
            anchors.right: arrowVisible ? rightArrow.left : parent.right
            anchors.verticalCenter: parent.verticalCenter

            text: selectName
            font.pixelSize: 14 * appFontSize
            color: majorForeground
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
        height: 1
        color: dividerForeground
    }
}
