/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import org.kde.kirigami 2.15
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.15
import QtQuick.Controls.Styles 1.4

Popup {
    id: dailog

    property string title
    property alias inputText: textInput.text
    property alias echoMode: textInput.echoMode
    property var wifiName
    property var devicePath
    property var specificPath
    property var connectionPath

    signal cancelButtonClicked
    signal okButtonClicked
    signal enteredClick

    anchors.centerIn: applicationWindow().overlay

    height: units.gridUnit * 10.7
    width: units.gridUnit * 22.1

    parent: applicationWindow().overlay
    modal: true
    closePolicy: Popup.NoAutoClose
    Overlay.modal: Rectangle {
        color: "transparent"
    }

    contentItem: Item {
        anchors.fill: parent

        Text {
            id: titleText

            anchors.left: parent.left
            anchors.leftMargin: units.gridUnit * 1.4
            anchors.top: parent.top
            anchors.topMargin: units.gridUnit * 1.4
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            width: units.gridUnit * 12

            font.pointSize: defaultFontSize + 9
            color: "#000000"
            text: dailog.title
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: units.gridUnit * 1.4
            anchors.top: parent.top
            anchors.topMargin: units.gridUnit * 1.4

            spacing: units.gridUnit * 2.1

            JIconButton {
                width: 34 * appScale + 10
                height: 34 * appScale + 10

                source: "qrc:/image/pwd_cancel.png"

                onClicked: {
                    dailog.cancelButtonClicked()
                    dailog.close()
                    dailog.inputText = ""
                }
            }

            JIconButton {
                id: okButton
                
                width: 34 * appScale + 10
                height: 34 * appScale + 10

                enabled: textInput.length > 7
                source: enabled ? "qrc:/image/pwd_confirm.png" : "qrc:/image/pwd_disable.png"

                onClicked: {
                    dailog.okButtonClicked()
                    textInput.text = ""
                }
            }
        }

        Item {
            anchors.left: parent.left
            anchors.top: titleText.bottom
            anchors.topMargin: units.gridUnit * 2
            anchors.right: parent.right
            anchors.rightMargin: units.gridUnit * 2
            anchors.horizontalCenter: parent.horizontalCenter

            width: parent.width - units.gridUnit * 2.8
            height: units.gridUnit * 3.2

            JIconButton {
                id: visibleButton

                anchors.right: closeButton.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 18 * appScale

                height: 28 * appScale + 10
                width: 28 * appScale + 10

                source: echoMode == TextInput.Password ? "qrc:/image/pwd_hidden.png" : "qrc:/image/pwd_visible.png"

                onClicked: {
                    if (echoMode == TextInput.Password) {
                        echoMode = TextInput.Normal
                    } else {
                        echoMode = TextInput.Password
                    }
                }
            }

            JIconButton {
                id: closeButton

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                height: 28 * appScale + 10
                width: 28 * appScale + 10

                visible: textInput.text
                source: "qrc:/image/txt_close.png"

                onClicked: {
                    textInput.text = ""
                }
            }

            TextField {
                id: textInput

                width: 100

                anchors {
                    left: parent.left
                    right: visibleButton.left
                    leftMargin: units.gridUnit * 1.4
                    verticalCenter: parent.verticalCenter
                }
                
                font.pointSize: defaultFontSize + 8
                color: "#000000"
                focus: true
                passwordMaskDelay: 500
                
                onAccepted: {
                    if (okButton.enabled) {
                        dailog.enteredClick()
                        inputText = ""
                    }
                }

                background: Item {
                    width: parent.width
                    height: parent.height

                    Rectangle {
                        anchors.bottom: parent.bottom

                        width: parent.width
                        height: 1

                        color: "#EEE5E5EA"
                    }
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
                        running: textInput.focus

                        onTriggered: {
                            if (timer.running) {
                                cursorBg.visible = !cursorBg.visible
                            } else {
                                cursorBg.visible = false
                            }
                        }
                    }

                    Connections {
                        target: textInput
                        onFocusChanged: cursorBg.visible = focus
                    }
                }
            }
        }
    }

    background: Rectangle {
        id: bkground

        width: parent.width
        height: parent.height

        radius: 18
        color: "#FEFFFFFF"
        
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            radius: 40
            samples: 25
            color: "#1A000000"
            verticalOffset: 10
            spread: 0
        }
    }
    
    onClosed: {
        textInput.text = ""
    }
}
