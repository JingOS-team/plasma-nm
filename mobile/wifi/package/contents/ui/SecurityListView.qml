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

    property var securityModel
    property int selectIndex: 2

    height: 45 * appScaleSize * 4 + topPadding + bottomPadding
    width: 240 * appScaleSize
    leftPadding:0
    rightPadding:0
    //topPadding:0
    //bottomPadding:0

    focus: true

    blurBackground.arrowX: width * 0.75
    blurBackground.arrowWidth: 16 * appScaleSize
    blurBackground.arrowHeight: 11 * appScaleSize
    blurBackground.arrowPos: Kirigami.JRoundRectangle.ARROW_TOP
    

    contentItem: Item {

        ListView {
            id: listView

            anchors.fill:parent

            clip: true
            interactive: false
            model: securityModel
            snapMode:ListView.SnapToItem

            delegate: SelectItem {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                
                height: 45 * appScaleSize

                titleName: model.displayName
                imgPath: "qrc:/image/select_blue.png"
                arrowVisible: index == selectIndex
                showBottomLine: index == listView.count - 1 ? false : true
                
                MouseArea {
                    anchors.fill: parent
                    
                    onClicked: {
                        selectIndex = index
                        securitySelect.itemSelect(model.displayName)
                        popup.visible = false
                    }
                }
            }
        }
    }
}
