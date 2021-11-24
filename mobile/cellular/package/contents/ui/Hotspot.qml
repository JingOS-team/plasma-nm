/*
 *   Copyright 2020 Tobias Fella <fella@posteo.de>
 *   Copyright 2021 Liu Bangguo <liubangguo@jingos.com>
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

import QtQuick 2.6
import QtQuick.Controls 2.10
import org.kde.kirigami 2.15 as Kirigami

Rectangle {
    anchors.fill: parent

    color: "#FFF6F9FF"

    Item {
        id: title

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 48 * appScaleSize
            leftMargin: 14 * appScaleSize
            rightMargin: 20 * appScaleSize
        }

        width: parent.width
        height: 22 * appScaleSize

        Image {
            id: icon_back

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            width: 22 * appScaleSize
            height: 22 * appScaleSize

            source: isDarkTheme ? "../image/icon_back_dark.png" : "../image/icon_back.png"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    popView()
                }
            }
        }

        Text {
            anchors.left: icon_back.right
            anchors.leftMargin: 10 * appScaleSize
            anchors.verticalCenter: parent.verticalCenter

            font.bold: true
            font.pixelSize: 20
            text: i18n("Personal Hotspot")
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            top: title.bottom
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
            topMargin: 18 * appScaleSize
        }

        width: parent.width - 40 * appScaleSize
        height: 45 * 2 + 1

        color: cardBackground
        radius: 10 * appScaleSize

        Rectangle {
            id: switch_item

            width: parent.width
            height: 45 * appScaleSize //parent.height

            color: "transparent"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("Allow Others to Join")
                font.pixelSize: 14
                color: majorForeground
            }

            Kirigami.JSwitch {
                id: hotspot_swith

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 20 * appScaleSize
                }

                checkable: true

                onCheckedChanged: {
                    if(hotspot_swith.checked){
                        handler.createHotspot()
                    } else {
                        handler.stopHotspot()
                    }
                }
            }
        }

        Kirigami.Separator {
            id: separator1

            anchors {
                top: switch_item.bottom
                left: parent.left
                right: parent.right
                rightMargin: 20 * appScaleSize
                leftMargin: 20 * appScaleSize
            }

            width: parent.width
            height: 1

            color: dividerForeground
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: separator1.bottom
            }

            height: 45 * appScaleSize

            color: "transparent"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("WLAN Password")
                font.pixelSize: 14
                color: majorForeground
            }

            Text {
                anchors {
                    right: options_right.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("lysswi")
                font.pixelSize: 14
                color: "#99000000"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                    }
                }
            }

            Image {
                id: options_right

                anchors {
                    right: parent.right
                    rightMargin: 17 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                width: 22 * appScaleSize
                height: 22 * appScaleSize

                source: "../image/icon_right.png"
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                    }
                }
            }
        }
    }

}
