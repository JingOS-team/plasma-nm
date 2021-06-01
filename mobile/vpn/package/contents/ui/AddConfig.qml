/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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

import org.kde.kcm 1.2 as KCM
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.10
import QtQuick.Dialogs 1.0

Item {
    id: addConfig_root

    anchors.fill: parent

    Item {
        id: title

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 48 * appScale
            leftMargin: 14 * appScale
            rightMargin: 20 * appScale
        }

        width: parent.width
        height: 22 * appScale

        Image {
            id: icon_back

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            width: 22 * appScale
            height: 22 * appScale

            source: "../image/icon_back.png"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    popView()
                }
            }
        }

        Text {
            anchors.left: icon_back.right
            anchors.leftMargin: 10 * appScale
            anchors.verticalCenter: parent.verticalCenter

            font.bold: true
            font.pixelSize: 20
            text: i18n("Add Configuration")
        }

        Kirigami.JIconButton {
            id: img_confirm

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            width: 53 * appScale + 10
            height: 21 * appScale + 10

            enabled: editConfig.addEnable

            Text {
                anchors.centerIn: parent

                text: i18n("Done")
                color: img_confirm.enabled ? "#FF3C4BE8" : "#2E000000"
                font.pixelSize: 17
            }

            onClicked: {
                editConfig.addVPNConfig()
                popView()
            }
        }
    }

    EditConfig {
        id: editConfig

        anchors {
            left: parent.left
            top: title.bottom
            leftMargin: 20 * appScale
            topMargin: 18 * appScale
        }
        
        width: parent.width - 40 * appScale
    }
}
