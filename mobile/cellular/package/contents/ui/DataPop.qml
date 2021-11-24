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

Kirigami.JArrowPopup {
    id: popup

    property int selectIndex: -1
    property var currentType
    signal itemSelect(int index, var displayName)

    height: listView.height + bottomItem.height + topPadding + bottomPadding
    width: 240 * appScaleSize
    leftPadding:0
    rightPadding:0

    blurBackground.arrowX: width * 0.8
    blurBackground.arrowWidth: 16 * appScaleSize
    blurBackground.arrowHeight: 11 * appScaleSize
    blurBackground.arrowPos: Kirigami.JRoundRectangle.ARROW_TOP


    contentItem: Item {

        ListView {
            id: listView

            anchors.top: autoItem.bottom

            width: parent.width
            height: childrenRect.height

            model: selectionMode
            interactive: false 

            delegate: Item {

                width: parent.width
                height: 45 * appScaleSize

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    text: i18n(model.displayName)
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                }

                Image {
                    anchors {
                        right: parent.right
                        rightMargin: 17 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScaleSize
                    height: 22 * appScaleSize

                    //visible: index == selectIndex
                    visible:currentType == displayName
                    source: "../image/icon_confirm.png"
                }

                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20 * appScaleSize
                        rightMargin: 17 * appScaleSize
                        bottom: parent.bottom
                    }

                    height: 1

                    visible: index != listView.count - 1
                    color: dividerForeground
                }

                MouseArea {
                    anchors.fill: parent
                    
                    onClicked: {
                        selectIndex = index
                        popup.visible = false
                        popup.itemSelect(index, model.displayName)
                        ofonoRadioSettings.technologyPreference = model.name
                    }
                }
                
                Component.onCompleted:{
                    console.log("000==  "+ofonoRadioSettings.technologyPreference+" --  "+model.name)
                    if(ofonoRadioSettings.technologyPreference == model.name){
                        selectIndex = index
                        console.log("000== 222  selectIndex: "+selectIndex)
                    }
                }
            }
        }

        Item {
            id: bottomItem

            anchors {
                top: listView.bottom
                left: parent.left
                right: parent.right
                topMargin: 8 * appScaleSize
                leftMargin: 20 * appScaleSize
                rightMargin: 20 * appScaleSize
            }

            width: parent.width
            height: tipText.height + 17

            Text {
                id: tipText
                width:parent.width

                wrapMode: Text.WordWrap
                font.pixelSize: 12 * appFontSize
                color: minorForeground
                text: i18n("5G On uses 5G whenever it is available,even when it may reduce battery life. \n\n5G Auto uses 5G only when it will not significantly reduce battery life")
            }
        }
    }
    
    ListModel {
        id: selectionMode

        /*ListElement {
            displayName: "5G On"
        }
        ListElement {
            displayName: "5G Auto"
        }
        ListElement {
            displayName: "4G"
        }*/
    }

    Component.onCompleted: {
        var echnologiesList = ofonoRadioSettings.availableTechnologies
        for(var i = 0;i < echnologiesList.length; i++){//gsm umts lte
            var name = echnologiesList[i];
            var dName;
            if(name == "gsm"){
                dName = "2G";
            }else if(name == "umts"){
                dName = "3G";
            }else if(name == "lte"){
                dName = "4G";
            }else if(name == "nr"){
                dName = "5G";
            } else {
                dName = name;
            }
            selectionMode.append({"name":name,"displayName":dName})
        }
    }
}
