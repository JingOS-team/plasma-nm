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
    property alias inputName: textField.text
    property bool showBottomLine: true
    property bool rightPartVisible: true
    property string hintText: ""
    property bool ipValid: true

    signal textChanged(var text)

    width: parent.width
    height: 45 * appScaleSize

    RegExpValidator {
        id: ipValidator
        regExp: /^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/
    }

    Kirigami.Label {
        anchors.left: parent.left
        anchors.leftMargin: 20 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter

        color: majorForeground
        text: titleName
        font.pixelSize: 14 * appFontSize
    }
    
    TextField {
        id: textField

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 20 * appScaleSize
        }

        placeholderText: hintText
        horizontalAlignment: Text.AlignRight
        text: inputName
        validator: ipValid ? ipValidator : ""
        wrapMode: Text.WordWrap
        font.pixelSize: 14 * appFontSize

        background: Rectangle {
            color: "transparent"
        }

        onTextChanged:{
            root.textChanged(inputName)
        }

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

    Kirigami.Separator {
        visible: showBottomLine

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 20 * appScaleSize
            rightMargin: 20 * appScaleSize
            bottom: parent.bottom
        }
        
        height: 1
        color: dividerForeground
    }
}
