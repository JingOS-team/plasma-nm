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

    property int selectIndex: 1
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

            model: typeMode
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
                    color: index == 1 ? majorForeground : minorForeground
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
                        if(selectIndex != 2){
                            return;
                        }
                        selectIndex = index
                        popup.visible = false
                        popup.itemSelect(index, model.displayName)
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
                topMargin: 8
                leftMargin: 20
                rightMargin: 20
            }

            width: parent.width
            height: tipText.height + 17

            Text {
                id: tipText

                width:parent.width

                wrapMode: Text.WordWrap
                font.pixelSize: 12 * appFontSize
                color: minorForeground
                text: i18n("Allow More Data On 5G provides higher-quality video when connected to 5G cellular networks. \n\nStandard allows automatic updates and background tasks on cellular,but limits video quality. \n\nLow Data Mode helps reduce WLAN and cellular data usage by pausing automatic updates and background tasks.")
            }
        }
    }
    ListModel {
        id: typeMode

        ListElement {
            displayName: "Allow More Data On 5G"
        }
        ListElement {
            displayName: "Standard"
        }
        ListElement {
            displayName: "Low Data Mode"
        }
    }
}
