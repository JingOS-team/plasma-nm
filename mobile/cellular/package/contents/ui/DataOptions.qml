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
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.15 as Kirigami

Rectangle {
    anchors.fill: parent

    color: settingMinorBackground

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

        Kirigami.JIconButton {
            id: icon_back

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

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

            font.bold: true
            font.pixelSize: 20 * appFontSize
            text: i18n("Cellular Data Options")
            color: majorForeground
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
        height: switch_item.visible ?  45 * appScaleSize * 3 : 45 * appScaleSize * 2

        color: cardBackground
        radius: 10 * appScaleSize

        Rectangle {
            id: switch_item

            width: parent.width
            height: isConnected ? 45 * appScaleSize : 0 //parent.height
            visible: isConnected

            color: "transparent"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("Data Roaming")
                font.pixelSize: 14 * appFontSize
                color: majorForeground
            }

            Kirigami.JSwitch {
                id: jswitch

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 20 * appScaleSize
                }

                checked: connectionManager.roamingAllowed

                onToggled: {
                    connectionManager.roamingAllowed = jswitch.checked
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
            visible:switch_item.visible
        }

        Rectangle {
            id: options_layout

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

                text: i18n("Data")
                font.pixelSize: 14 * appFontSize
                color: majorForeground
            }

            Text {
                id: dataStateText

                anchors {
                    right: options_right.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }
                text: getDisplayName(netreg.technology) 
                font.pixelSize: 14 * appFontSize
                color: isDarkTheme ? "#8CF7F7F7" : "#99000000"

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
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if(dataPop.visible == true){
                        dataPop.visible = false
                        return;
                    }
                    dataPop.currentType = getDisplayName(netreg.technology)
                    dataPop.parent = options_right
                    dataPop.y = 22 * appScaleSize
                    dataPop.x = - dataPop.width + 42 * appScaleSize
                    dataPop.visible = true
                }
            }
        }

        Kirigami.Separator {
            id: separator2

            anchors {
                top: options_layout.bottom
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
            id: hotspot_layout

            anchors {
                left: parent.left
                right: parent.right
                top: separator2.bottom
            }

            height: 45 * appScaleSize

            color: "transparent"

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("Data Mode")
                font.pixelSize: 14 * appFontSize
                color: majorForeground
            }
            
            Text {
                id: modeStateText

                anchors {
                    right: model_right.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("Standard")
                font.pixelSize: 14 * appFontSize
                color: isDarkTheme ? "#8CF7F7F7" : "#99000000"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                    }
                }
            }

            Image {
                id: model_right

                anchors {
                    right: parent.right
                    rightMargin: 17 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                width: 22 * appScaleSize
                height: 22 * appScaleSize

                source: "../image/icon_right.png"
            }
            
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if(dataModePop.visible == true){
                        dataModePop.visible = false
                        return;
                    }
                    dataModePop.parent = model_right
                    dataModePop.y = 22 * appScaleSize
                    dataModePop.x = - dataModePop.width + 42 * appScaleSize
                    dataModePop.visible = true
                }
            }
        }
    }

    DataPop{
        id: dataPop
        onItemSelect: {
            dataStateText.text = i18n(displayName)
        }
    }

    DataModePop {
        id: dataModePop
        onItemSelect: {
            modeStateText.text = i18n(displayName)
        }
    }

    function getDisplayName(name){//gsm umts lte
        if(name == "gsm"){
            return "2G";
        }else if(name == "umts"){
            return "3G";
        }else if(name == "lte"){
            return "4G";
        }
    }
}
