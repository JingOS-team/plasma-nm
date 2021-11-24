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
import jingos.display 1.0

Item {
    id: addConfig_root

    anchors.fill: parent

    Item {
        id: title

        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
            top: parent.top
            topMargin: JDisplay.statusBarHeight
        }
        height: 62 * appScaleSize

        Item {
            width: parent.width
            height: icon_back.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 6 * appScaleSize

            Kirigami.JIconButton {
                id: icon_back

                width: (22 + 8) * appScaleSize
                height: (22 + 8) * appScaleSize

                source: isDarkTheme ? Qt.resolvedUrl("../image/icon_back_dark.png") : Qt.resolvedUrl("../image/icon_back.png")
                onClicked: {
                    popView()
                }
            }

            Text {
                anchors.left: icon_back.right
                anchors.leftMargin: 10 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                color: majorForeground
                font.bold: true
                font.pixelSize: 20 * appFontSize
                text: i18n("Add Configuration")
            }

            Kirigami.JButton {
                id: img_confirm

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                backgroundColor:"transparent"

                enabled: editConfig.addEnable

                fontColor: img_confirm.enabled ? Kirigami.JTheme.highlightColor : Kirigami.JTheme.disableForeground
                font.pixelSize: 17 * appFontSize
                text: i18n("Done")

                onClicked: {
                    editConfig.addVPNConfig()
                    popView()
                }
            }
        }


    }

    EditConfig {
        id: editConfig

        anchors {
            left: parent.left
            top: title.bottom
            leftMargin: 20 * appScaleSize
            topMargin: 11 * appScaleSize
        }
        
        width: parent.width - 40 * appScaleSize

        isSelectable: true
    }
}
