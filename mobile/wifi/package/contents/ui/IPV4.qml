/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */


import org.kde.kcm 1.2 as KCM
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import jingos.display 1.0
Rectangle {
    id: root

    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: root.width - 40 * appScaleSize
    property int preferHeigh: 34 * appScaleSize
    property int selectIndex: 0
    property bool isConfigChanged: false

    color: settingMinorBackground

    Component.onCompleted: {
        if (currentModel.Method == "Automatic") {
            selectIndex = 0
        } else if (currentModel.Method == "Manual") {
            selectIndex = 1
        }
    }

    Item {
        id: topItem

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
            height: backIcon.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 6 * appScaleSize

            Kirigami.JIconButton {
                id: backIcon

                width: (22 + 8) * appScaleSize
                height: (22 + 8) * appScaleSize

                source: isDarkTheme ? "qrc:/image/arrow_left_dark.png" : "qrc:/image/arrow_left.png"
                onClicked: {
                    wifi_root.popView()
                }
            }

            Kirigami.Label {
                id: title

                anchors {
                    left: backIcon.right
                    leftMargin: 10 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                color: majorForeground
                font.pixelSize: 20 * appFontSize
                font.bold: true
                text: currentModel.Name +" "+ i18n("Configure IPv4")
            }

            Kirigami.JButton {
                id: confirmIcon

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                backgroundColor:"transparent"
                enabled: isConfigChanged
                fontColor: confirmIcon.enabled ? Kirigami.JTheme.highlightColor : Kirigami.JTheme.disableForeground
                font.pixelSize: 17 * appFontSize
                text: i18n("Save")
                onClicked: {
                    if (defaultIpv4Method === "Automatic") {
                        currentModel.Method = "Automatic"
                        currentModel.UpdateConnect = "update"
                        currentMethod = "Automatic"
                    } else if (defaultIpv4Method === "Manual") {
                        currentMethod = "Manual"
                        currentModel.Method = "Manual"
                        currentModel.IpAddress = ipAddress.inputName
                        currentModel.SubnetMask = netMask.inputName
                        currentModel.GateWay = gateWay.inputName
                        currentModel.Router = router.inputName
                        currentModel.UpdateConnect = "update"
                        currentIpAddress = ipAddress.inputName
                        currentSubnetMask = netMask.inputName

                    }
                    wifi_root.popView()
                }
            }
        }


    }

    Rectangle {
        id: routerSetting

        anchors {
            top: topItem.bottom
            topMargin: 31 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }

        width: preferWidth
        height: listView.height

        radius: 10 * appScaleSize
        color: cardBackground

        ListView {
            id: listView

            width: parent.width
            height: childrenRect.height

            model: listMode
            interactive: false

            delegate: SelectItem {
                anchors.horizontalCenter: parent.horizontalCenter

                width: parent.width

                imgPath: "qrc:/image/select_blue.png"
                arrowVisible: index == selectIndex
                titleName: i18n(model.displayName)
                showBottomLine: index == listView.count - 1 ? false : true

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        isConfigChanged = true
                        selectIndex = index
                        wifi_root.selectIpv4Method(model.displayName)
                        wifi_root.selectDnsMethod(model.displayName)
                    }
                }
            }
        }

        SwitchItem {
            anchors {
                top: listView.bottom
                topMargin: 24 * appScaleSize
            }

            radius: 10 * appScaleSize
            color: cardBackground
            visible: false
            switchVisible: false
            titleName: "Client ID "
            showBottomLine: false
        }
    }

    ListModel {
        id: listMode

        ListElement {
            displayName: "Automatic"
            value: 0
        }

        ListElement {
            displayName: "Manual"
            value: 1
        }
    }

    Rectangle{
        anchors {
            top: routerSetting.bottom
            left: routerSetting.left
            right: routerSetting.right
            topMargin: 24 * appScaleSize
        }

        width: preferWidth
        height: childrenRect.height
        color: cardBackground

        radius: 10 * appScaleSize
        visible: selectIndex == 1

        Column {
            id: columnSetting

            width: preferWidth

            spacing: 10 * appScaleSize

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                }

                height: 22 * appScaleSize

                verticalAlignment:Text.AlignBottom
                font.pixelSize: 12 * appFontSize
                color:minorForeground
                text: i18n("Manual IP")
            }

            Item {
                width: parent.width
                height: childrenRect.height

                Column {
                    width: parent.width

                    InputItem {
                        id: ipAddress

                        titleName: i18n("IpAddress")
                        hintText: "0.0.0.0"
                        inputName: currentModel.IpAddress
                        onTextChanged:{
                            if(text != currentModel.IpAddress)
                            isConfigChanged = true
                        }
                    }

                    InputItem {
                        id: netMask

                        titleName: i18n("NetMask")
                        hintText: "255.255.0.0"
                        inputName: currentModel.SubnetMask
                        onTextChanged:{
                            if(text != currentModel.SubnetMask)
                            isConfigChanged = true
                        }
                    }

                    InputItem {
                        id: gateWay

                        titleName: i18n("GateWay")
                        hintText: "0.0.0.0"
                        inputName: currentModel.GateWay
                        showBottomLine: true
                        onTextChanged:{
                            if(text != currentModel.GateWay)
                            isConfigChanged = true
                        }
                    }

                    InputItem {
                        id: router

                        titleName: i18n("Router")
                        hintText: "0.0.0.0"
                        inputName: currentModel.Router
                        showBottomLine: false

                        onTextChanged:{
                            if(text != currentModel.Router)
                            isConfigChanged = true
                        }
                    }
                }
            }
        }
    }
}
