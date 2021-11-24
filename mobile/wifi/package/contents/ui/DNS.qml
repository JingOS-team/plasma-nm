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
    property int preferHeigh: 45 * appScaleSize
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
                text: currentModel.Name + i18n(" DNS")
            }

            Kirigami.JButton {
                id: confirmIcon

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                enabled : isConfigChanged

                backgroundColor:"transparent"
                fontColor: confirmIcon.enabled ? Kirigami.JTheme.highlightColor : Kirigami.JTheme.disableForeground
                font.pixelSize: 17 * appFontSize
                text: i18n("Save")

                onClicked: {
                    if (defaultDnsMethod === "Automatic") {
                        currentMethod = "Automatic"
                        currentModel.Method = "Automatic"
                        currentModel.NameServer = ""
                        currentModel.DNSSearch = ""
                        currentModel.UpdateConnect = "update"
                    } else if (defaultDnsMethod === "Manual") {
                        currentMethod = "Manual"
                        currentModel.Method = "Manual"
                        currentModel.NameServer = dnsServer.inputName
                        currentModel.DNSSearch = dnsSearch.inputName
                        currentModel.UpdateConnect = "update"
                    }
                    wifi_root.popView()
                }
            }
        }

    }

    Rectangle {
        anchors {
            top: topItem.bottom
            topMargin: 31 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }

        width: preferWidth
        height: listView.height

        color: cardBackground
        radius: 10 * appScaleSize
        
        ListView {
            id: listView

            width: parent.width
            height: childrenRect.height

            model: listMode
            interactive: false

            delegate: SelectItem {
                anchors.horizontalCenter: parent.horizontalCenter
                
                imgPath: "qrc:/image/select_blue.png"
                arrowVisible: index == selectIndex
                titleName: i18n(model.displayName)
                showBottomLine: index == listView.count - 1 ? false : true

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        wifi_root.selectIpv4Method(model.displayName)
                        wifi_root.selectDnsMethod(model.displayName)
                        isConfigChanged = true
                        selectIndex = index
                        if(index == 0 ){
                            dnsServer.inputName =  currentModel.NameServer
                            dnsSearch.inputName = currentModel.DNSSearch
                        }
                    }
                }
            }
        }

        Rectangle{
            id: dnsServerColumn

            anchors {
                top: listView.bottom
                topMargin: 24 * appScaleSize
            }

            width: preferWidth
            height: childrenRect.height
            color: cardBackground

            radius: 10 * appScaleSize

            Column {

                width: preferWidth

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                    }

                    height: 22 * appScaleSize

                    verticalAlignment:Text.AlignBottom
                    text: i18n("DNS Servers")
                    color: minorForeground
                    font.pixelSize: 12 * appFontSize
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 10 * appScaleSize
                    color: cardBackground

                    NormalInputItem {
                        id: dnsServer

                        inputName: currentModel.NameServer
                        showBottomLine: false
                        isReadOnly: wifi_root.defaultDnsMethod == "Automatic"
                        hintText:"0.0.0.0"

                        onTextChanged:{
                            if(txt != currentModel.NameServer){
                                isConfigChanged = true
                            }
                            
                        }
                    }
                }
            }
        }

        Rectangle{
            anchors {
                top: dnsServerColumn.bottom
                topMargin: 24 * appScaleSize
            }

            width: preferWidth
            height: childrenRect.height

            radius: 10 * appScaleSize
            visible: selectIndex == 1
            color: cardBackground

            Column {

                width: preferWidth

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                    }
                    
                    height: 22 * appScaleSize

                    verticalAlignment:Text.AlignBottom
                    text: i18n("Search Domains")
                    color: minorForeground
                    font.pixelSize: 12 * appFontSize
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 10 * appScaleSize
                    color: cardBackground

                    NormalInputItem {
                        id: dnsSearch

                        inputName: currentModel.DNSSearch
                        hintText: "domain.com"
                        showBottomLine: false
                        ipValid: false
                    }
                }
            }
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
}
