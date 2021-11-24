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
import MeeGo.QOfono 0.2

Rectangle {
    id: root

    property var currentApn: ""
    anchors.fill: parent
    
    color: settingMinorBackground

    OfonoSimListModel {
        id: simListModel

        onSimAdded:{
            isSimExist = true

        }

        onSimRemoved:{
            isSimExist = false
            isConnected = false
            jswitch.checked = false
            selectionPop.visible = false

        }
    }

    Item {
        anchors.fill: parent

        visible: isSimExist
        
        Text {
            id: cellular_title

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 20 * appScaleSize
                topMargin: 48 * appScaleSize
            }

            width: parent.width / 3
            height: 22 * appScaleSize

            text: i18n("Cellular")
            font.pixelSize: 20 * appFontSize
            font.weight: Font.Bold
            color: majorForeground

            MouseArea{
                anchors.fill: parent
                onClicked:{

                }
            }
        }

        Rectangle {
            id: top_area

            anchors {
                left: parent.left
                top: cellular_title.bottom
                leftMargin: 20 * appScaleSize
                right: parent.right
                rightMargin: 20 * appScaleSize
                topMargin: 18 * appScaleSize
            }

            width: parent.width - 40 * appScaleSize
            height: 45 * appScaleSize * 2

            color: cardBackground
            radius: 10 * appScaleSize

            Rectangle {
                id: switch_item

                width: parent.width
                height: 45 * appScaleSize

                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    text: i18n("Cellular Data")
                    font.pixelSize: 14 * appFontSize
                    color: !isAirplaneMode ? majorForeground : minorForeground
                }

                Kirigami.JSwitch {
                    id: jswitch
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScaleSize
                    }
                    checkable: !isAirplaneMode
                    checked: isConnected

                    onToggled: {
                        if(jswitch.checked){
                            currentConnectionPath = configuration.modemConnectionPath
                            currentDevicePath = configuration.modemDevicePath
                            currentOperatorPath = configuration.modemOperatorPath
                            
                            kcm.activateConnection(currentConnectionPath,currentDevicePath,currentOperatorPath)
                            
                        }else{
                            kcm.deactivateConnection(currentConnectionPath,currentDevicePath)
                        }
                        
                        //ofonoModem.online = jswitch.checked
                        //contextConnection.active = jswitch.checked
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

                    text: i18n("Cellular Data Options")
                    font.pixelSize: 14 * appFontSize
                    color: !isAirplaneMode ? majorForeground : minorForeground
                }

                Item{
                    anchors.right: parent.right

                    width: parent.width / 4
                    height: parent.height

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
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if(isAirplaneMode){
                            return;
                        }
                        gotoPage("options_view")
                    }
                }
            }
        }

        Text{
            id: text_tip

            anchors{
                top: top_area.bottom
                left:parent.left
                topMargin: 8 *appScaleSize
                leftMargin: 40 *appScaleSize
            }

            font.pixelSize: 12 * appFontSize
            color: !isAirplaneMode ? majorForeground : minorForeground
            text: i18n("Turn off cellular data to restrict all data to WLAN,including email,web browsing,and push notifications.")
        }

        Rectangle {
            id: selection_rect
            anchors {
                left: parent.left
                top: text_tip.bottom
                leftMargin: 20 * appScaleSize
                right: parent.right
                rightMargin: 20 * appScaleSize
                topMargin: 21 * appScaleSize
            }

            height: 68 * appScaleSize
            radius: 10
            color: cardBackground

            Text {
                id: text_selection

                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: 12 * appScaleSize
                    leftMargin: 20 * appScaleSize
                }

                text: i18n(cellular_root.selectionName)
                font.pixelSize: 12 * appFontSize
                color: !isAirplaneMode ? majorForeground : minorForeground
            }

            Item {
                anchors.top: text_selection.bottom
                    
                height: 45 * appScaleSize
                width: parent.width

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    text: i18n("Network Selection")
                    font.pixelSize: 14 * appFontSize
                    color: !isAirplaneMode ? majorForeground : minorForeground
                }

                Text {
                    id: selectText

                    anchors {
                        right: selection_right.left
                        verticalCenter: parent.verticalCenter
                    }

                    text: i18n(cellular_root.selectionName)
                    font.pixelSize: 14 * appFontSize
                    color: !isAirplaneMode ? majorForeground : minorForeground
                }

                Image {
                    id: selection_right

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
                        if(isAirplaneMode){
                            return;
                        }
                        if(selectionPop.visible == true){
                            selectionPop.visible = false
                            return;
                        }

                        selectionPop.parent = selection_right
                        selectionPop.y = 22 * appScaleSize
                        selectionPop.x = - selectionPop.width + 42 * appScaleSize
                        selectionPop.visible = true

                    }
                }
            }
        }

        SelectionPop {
            id: selectionPop

            onItemSelect: {
                selectText.text = i18n(displayName)
            }
        }

        ListView{
            id:listView
            
            anchors.top: selection_rect.bottom
            anchors.topMargin: 25
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.leftMargin:20
            anchors.rightMargin:20

            width:parent.width
            height:childrenRect.height

            model:gsmProxyModel
            visible:false

            delegate: Rectangle{
                property var currentConnectionState: model.ConnectionState

                width: parent.width
                height:model.Type == 6 ? 90 : 0
                color: cardBackground

                visible:model.Type == 6

                Text{
                    id:iname

                    color: minorForeground
                    anchors.verticalCenter:parent.verticalCenter
                    text: "Name:  "+model.Name+"\n\rConnectionPath:  "+model.ConnectionPath+"\n\rDevicePath:  "+model.DevicePath+"\n\SpecificPath:  "+model.SpecificPath+"\n\rApn:  "+currentApn
                }

                MouseArea{
                    anchors.fill:parent
                    onClicked:{
                        handler.activateConnection(model.ConnectionPath,
                                                        model.DevicePath,
                                                        model.SpecificPath)
                    }
                }
                Component.onCompleted:{
                    if(model.Type == 6){
                        currentApn =  kcm.getApn(model.ConnectionPath)
                        currentConnectionPath = model.ConnectionPath
                        currentDevicePath = model.DevicePath
                        currentOperatorPath = model.SpecificPath
                    }
                    
                }
                onCurrentConnectionStateChanged:{
                    if(model.Type == 6 ){
                        if(currentConnectionState == 2){
                            //isConnected = true
                        }else if(currentConnectionState == 4){
                            //isConnected = false
                        }
                    }
                
                }
            }
        }

    }

    Item {
        id: no_sim

        anchors.fill: parent

        visible: !isSimExist

        Text {
            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 20 * appScaleSize
                topMargin: 48 * appScaleSize
            }

            width: parent.width / 3
            height: 22 * appScaleSize

            text: i18n("Cellular")
            font.pixelSize: 20 * appFontSize
            font.weight: Font.Bold
            color: majorForeground
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.3

            width:60
            height:92

            Kirigami.Icon {
                id: img_sim

                anchors.horizontalCenter: parent.horizontalCenter

                width: 60 * appScaleSize
                height: 60 * appScaleSize

                source: "qrc:/image/no_sim.png"
                color: isDarkTheme ? majorForeground : "transparent"
            }

            Text{
                anchors{
                    top: img_sim.bottom
                    topMargin: 15 * appScaleSize
                    horizontalCenter: parent.horizontalCenter
                }

                text:i18n("No SIM")
                font.pixelSize:17 * appFontSize
                color: isDarkTheme ? "#4DF7F7F7" : "#4D3C3C43"
            }
        }
        
    }

}
