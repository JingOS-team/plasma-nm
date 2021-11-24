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

    property int selectIndex: 0
    property bool isToggledOff: false
    signal itemSelect(int index, var displayName)
    property var mPaddind: topPadding + bottomPadding

    height: jswith.checked ? (autoItem.height + mPaddind) : listView.height + autoItem.height + mPaddind
    width: 240 * appScaleSize
    leftPadding:0
    rightPadding:0

    blurBackground.arrowX: width * 0.8
    blurBackground.arrowWidth: 16 * appScaleSize
    blurBackground.arrowHeight: 11 * appScaleSize
    blurBackground.arrowPos: Kirigami.JRoundRectangle.ARROW_TOP

    Connections {
        target: netreg

        onSanFinished:{
            isScanFinished = true
        }
    }
    
    contentItem: Item {

        Item {
            id: autoItem

            width: parent.width
            height: 45 * appScaleSize

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                text: i18n("Automatic") 
                font.pixelSize: 14 * appFontSize
                color: minorForeground
            }

            Kirigami.JSwitch {
                id: jswith
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 20 * appScaleSize
                }

                checked: netreg.mode == "auto"
                visible: isScanFinished ? true : !isToggledOff ? true : false

                onToggled: {
                    if(jswith.checked){
                        isToggledOff = false
                        netreg.registration()
                    } else {
                        isToggledOff = true
                        isScanFinished = false
                        netreg.scan()
                    }
                }
            }

            Image {
                id: loadingState
                
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 20 * appScaleSize
                }

                width: 22 * appScaleSize
                height: 22 * appScaleSize

                visible: !jswith.visible
                source: "../image/loading.png"

                RotationAnimation {
                    target: loadingState
                    loops: Animation.Infinite
                    running: true
                    from: 0
                    to: 360
                    duration: 3000
                }
            }
        }

        ListView {
            id: listView

            anchors.top: autoItem.bottom

            width: parent.width
            height: visible ? childrenRect.height : 0 

            model: networkOperatorListModel
            visible:!jswith.checked && isScanFinished
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

                    text: i18n(model.name)
                    font.pixelSize: 14 * appFontSize
                    color: model.status == "forbidden" ? minorForeground : majorForeground
                    
                }

                Image {
                    anchors {
                        right: parent.right
                        rightMargin: 17 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScaleSize
                    height: 22 * appScaleSize

                    visible: index == selectIndex
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
                        if(model.status == "forbidden"){
                            return;
                        }
                        selectIndex = index
                        popup.visible = false
                        popup.itemSelect(index, model.name)
                        networkOperator.operatorPath = model.operatorPath
                        networkOperator.registerOperator()
                        //networkOperator.registerOperator()
                    }
                }

                Component.onCompleted:{
                    if(networkOperator.name == model.name){
                        selectIndex = index
                    }
                }
            }
        }
    }
    ListModel {
        id: selectionMode

        /*ListElement {
            displayName: "China Mobile"
        }
        ListElement {
            displayName: "CHN-Uincom"
        }
        ListElement {
            displayName: "China Telecom"
        }*/
    }
}
