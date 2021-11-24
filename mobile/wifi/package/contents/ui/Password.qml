/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */


import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.15

Popup {
    id: popup

    height: 231 * appScaleSize
    width: 477 * appScaleSize

    padding: 0
    parent: forgetWifi

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        anchors.fill: parent

        radius: 15 * appScaleSize
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            radius: 20
            samples: 25
            color: "#1A000000"
            verticalOffset: 20
            spread: 0
        }

        Rectangle {
            id: title
            
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 32 * appScaleSize
                rightMargin: 32 * appScaleSize
                leftMargin: 32 * appScaleSize
            }

            height: 32 * appScaleSize

            Kirigami.Label {
                anchors.left: parent.left

                text: "Enter Password"
            }

            Kirigami.JIconButton {
                anchors.right: confirm.left
                anchors.rightMargin: 32 * appScaleSize

                width: 34 * appScaleSize
                height: 34 * appScaleSize

                source: "qrc:/image/pwd_cancel.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        popup.visible = false
                        //clear password text
                        password.clear();
                    }
                }
            }

            Kirigami.JIconButton {
                id: confirm

                anchors.right: parent.right

                width: 34 * appScaleSize
                height: 34 * appScaleSize

                enabled: password.length > 8
                source: "qrc:/image/pwd_confirm.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        appletProxyModel.sourceModel.saveAndActived(
                                    appletProxyModel.index(currentIndex, 0),
                                    password.text)
                        popup.visible = false
                    }
                }
            }
        }

        Rectangle {
            anchors {
                left: title.left
                right: title.right
                top: title.bottom
                topMargin: 30 * appScaleSize
            }

            width: 415 * appScaleSize
            height: 69 * appScaleSize

            TextField {
                id: password

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width

                placeholderText: "input password"
                focus: true
                font.pointSize: theme.defaultFont.pointSize + 10

                background: Rectangle {
                    color: "transparent"
                }
            }

            Kirigami.Separator {
                anchors.bottom: parent.bottom

                height: 1
                width: parent.width
                
                color: "#FFF0F0F0"
            }
        }
    }
}
