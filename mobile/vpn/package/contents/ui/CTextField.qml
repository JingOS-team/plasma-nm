/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
 
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.10

TextField {
    id: textField

    cursorDelegate: Rectangle {
        id: cursorBg

        anchors.verticalCenter: parent.verticalCenter

        width: units.devicePixelRatio * 2
        height: parent.height / 2

        color: "#FF3C4BE8"

        Timer {
            id: timer

            interval: 700
            repeat: true
            running: textField.focus

            onTriggered: {
                if (timer.running) {
                    cursorBg.visible = !cursorBg.visible
                } else {
                    cursorBg.visible = false
                }
            }
        }

        Connections {
            target: textField
            onFocusChanged: cursorBg.visible = focus
        }
    }
}
