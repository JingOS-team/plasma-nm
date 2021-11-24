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
import org.kde.plasma.extras 2.0 as PlasmaExtras
import jingos.display 1.0

Rectangle {
    id: root

    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: root.width - 40 * appScaleSize
    property int preferHeigh: 45 * appScaleSize
    property bool isConnected: currentModel.ConnectionState == PlasmaNM.Enums.Activated
    property var currentName: currentModel.Name
    property bool isOperator: false
    property bool isConnecttingFailed: false
    property bool isConnectting: networkStatus.networkStatus == "Connecting"
                                  && editorProxyModel.currentConnectedName != currentName
                                  && isOperator
    property bool isConnectedSuccess: isOperator && editorProxyModel.currentConnectedName
                                      == currentName
    property bool nameEquals: editorProxyModel.currentConnectedName == currentName
    property var currentItemType: currentModel.ItemType
    property var devicePath: currentModel.DevicePath
    property var connectionPath: currentModel.ConnectionPath
    property var connectiontedPath: editorProxyModel.currentConnectedPath
    property var specificPath: currentModel.SpecificPath
    property var wifiName: currentModel.Name
    property var mSsid: currentModel.Ssid

    color: settingMinorBackground

    Connections {
        target:networkStatus

        onNetworkStatusChanged:{
            if(status == "Connected" && editorProxyModel.currentConnectedName == currentName){
                wifi_root.popView()
            }
        }
    }

    Connections {
        target: handler

        onPasswordErrorChanged:{
            isOperator = false
            isConnecttingFailed = true
        }
    }

    onIsConnecttingChanged: {
        if (!isConnectting) {
            isConnecttingFailed = true
        }
    }

    Component.onCompleted: {
        defaultIpv4Method = currentModel.Method ? currentModel.Method : "Automatic"
        defaultDnsMethod = currentModel.Method ? currentModel.Method : "Automatic"
        currentMethod = currentModel.Method ? currentModel.Method : "Automatic"
        isOperator = false
        isConnecttingFailed = false
    }

    Item {
        id: topItem
        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
            top: parent.top
            topMargin:  JDisplay.statusBarHeight
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
                    currenProxyModel.sourceModel.sourceModel.isAllowUpdate = true
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
                text: wifiName
            }
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            top: topItem.bottom
            bottom: root.bottom
            topMargin: 11 * appScaleSize
            bottomMargin: 20 * appScaleSize
            horizontalCenter: root.horizontalCenter
        }

        width: preferWidth

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            spacing: 24 * appScaleSize

            Row {
                width: preferWidth
                height: preferHeigh

                visible: isConnecttingFailed ? false : isConnected ? false : currentItemType == 1 ? true : currentItemType == 2 & isConnectting ? true : false
                
                Rectangle {
                    id: connectWifi

                    anchors.fill: parent

                    radius: 10 * appScaleSize
                    color: cardBackground

                    SwitchItem {
                        id: connectItem

                        titleName: (!isConnectedSuccess
                                    & isConnectting) ? i18n("On Connection") : i18n("Connect")
                        titleColor: isConnectedSuccess ? highlightColor : isConnectting ? "#FFA8A8AC" : highlightColor
                        isConnecting: isConnectedSuccess ? false : isConnectting
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                isOperator = true
                                isConnecttingFailed = false
                                handler.activateConnection(connectionPath,
                                                           devicePath,
                                                           specificPath)
                            }
                        }
                    }
                }
            }

            Row {
                width: preferWidth
                height: preferHeigh

                visible:isConnectedSuccess | !isConnectting

                Rectangle {
                    id: forgetWifi

                    anchors.fill: parent

                    radius: 10 * appScaleSize
                    color: cardBackground

                    SwitchItem {
                        id: networkStateItem

                        titleName: isConnectedSuccess ? i18n("Forget This Network") : (currentModel.ItemType == 1) | isConnected ? i18n("Forget This Network") : i18n("Join This Network")
                        titleColor: highlightColor
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {

                                if (networkStateItem.titleName == i18n("Forget This Network")) {
                                    deleteDialog.visible = true
                                } else if (networkStateItem.titleName == i18n("Join This Network")) {
                                    isOperator = true
                                    passwordPop.ssid = mSsid
                                    passwordPop.inputText = ""
                                    passwordPop.devicePath = devicePath
                                    passwordPop.specificPath = specificPath
                                    passwordPop.text = i18n("Enter the password for”%1”",currentName);
                                    isConnecttingFailed = false
                                    if(currentModel && currentModel.SecurityType){
                                        if(currentModel.SecurityType == -1 | currentModel.SecurityType == 0){
                                            kcm.addNoSecurityConnection(connectionPath,
                                                            devicePath,
                                                            specificPath)
                                                        return;
                                        }
                                    }
                                    passwordPop.visible = true
                                }
                            }
                        }
                    }
                }
            }

            Row {
                width: preferWidth
                height: preferHeigh

                visible: currentModel.ItemType == 1

                Rectangle {
                    anchors.fill: parent

                    radius: 10 * appScaleSize
                    color: cardBackground

                    SwitchItem {
                        titleName: i18n("Auto-Join")
                        switchChecked: currentModel.Autoconnect

                        onAutoConnectChecked: {
                            if (checked !== currentModel.Autoconnect) {
                                currentModel.Autoconnect = checked
                            }
                        }
                    }
                }
            }

            Column {
                width: preferWidth

                spacing: 4 * appScaleSize
                visible: false
                
                Rectangle {
                    width: preferWidth
                    height: preferHeigh
                    
                    radius: 10 * appScaleSize
                    color: cardBackground

                    SwitchItem {
                        titleName: i18n("Low Kata Mode ")
                        switchChecked: false
                    }
                }

                Kirigami.Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 563 * appScaleSize

                    wrapMode: Text.WordWrap
                    font.pixelSize: 12 * appFontSize
                    color: minorForeground
                    text: i18n("Low Data Mode helps reduce your pad data usage over your cellular network or specific WLAN networks you select.When Low Data Mode is turned on,automatic updates and background tasks,such as Photos syncing,are paused.")
                }
            }
            Rectangle{
                width: preferWidth
                height: childrenRect.height

                radius: 10 * appScaleSize
                color: cardBackground
                //visible: isConnected
                
                Column {
                    width: preferWidth

                    Text {
                        id: mLable

                        anchors {
                            left: parent.left
                            leftMargin: 20 * appScaleSize
                        }

                        height: 22 * appScaleSize

                        verticalAlignment:Text.AlignBottom
                        text: i18n("IPV4 Address")
                        color: minorForeground
                        font.pixelSize: 12 * appFontSize
                    }

                    Item {
                        width: preferWidth
                        height: currentItemType == 1 ? childrenRect.height : preferHeigh

                        SelectItem {
                            id: ipTitle

                            anchors.top: parent.top

                            width: preferWidth

                            titleName: i18n("Configure IP")
                            //showBottomLine: true
                            //visible: isConnected == 1
                            arrowVisible: true
                            showBottomLine: currentItemType == 1 
                            selectName: i18n(currentMethod)

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    wifi_root.gotoPage("ipv4_view")
                                }
                            }
                        }

                        SelectItem {
                            id: ipAddress
                            
                            anchors.top: ipTitle.bottom

                            width: parent.width

                            titleName: i18n("IP Address")
                            selectName: currentIpAddress
                            arrowVisible: false
                            visible: currentItemType == 1
                        }

                        SelectItem {
                            id: subnetMask

                            anchors.top: ipAddress.bottom
                                
                            width: parent.width

                            titleName: i18n("Subnet Mask")
                            selectName: currentSubnetMask
                            arrowVisible: false
                            visible: currentItemType == 1
                            showBottomLine: false
                        }

                        /*SelectItem {
                            id: router
                            visible:false
                            anchors.top: isConnected? subnetMask.bottom : parent.top
                                
                            width: parent.height

                            titleName: i18n("Router")
                            selectName: i18n(currentMethod)
                            arrowVisible: true
                            showBottomLine: false

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    wifi_root.gotoPage("ipv4_view")
                                }
                            }
                        }*/
                    }
                }
            }

            Row {
                width: preferWidth
                height: preferHeigh

                visible: false

                Rectangle {
                    anchors.fill: parent

                    radius: 10 * appScaleSize
                    color: cardBackground

                    SwitchItem {
                        titleName: i18n("Renew Lease")
                        titleColor: highlightColor
                        switchVisible: false

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (isConnected) {
                                    handler.deactivateConnection(
                                                currentModel.ConnectionPath,
                                                currentModel.DevicePath)
                                }
                            }
                        }
                    }
                }
            }

            Rectangle{
                width: preferWidth
                height: childrenRect.height

                radius: 10 * appScaleSize
                color: cardBackground

                Column {
                    width: preferWidth
                    spacing: 4 * appScaleSize

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 20 * appScaleSize
                        }
                        
                        height: 22 * appScaleSize

                        verticalAlignment:Text.AlignBottom
                        text: i18n("DNS")
                        color: minorForeground
                        font.pixelSize: 12 * appFontSize
                    }

                    Item {
                        width: preferWidth
                        height: preferHeigh


                        SelectItem {
                            titleName: i18n("Configure DNS")
                            selectName: i18n(currentMethod)
                            arrowVisible: true
                            showBottomLine: false
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                wifi_root.gotoPage("dns_view")
                            }
                        }
                    }
                }
            }

            Column {
                width: preferWidth

                spacing: 4 * appScaleSize
                visible: false
                
                Text {

                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                    }

                    text: i18n("Http Proxy")
                    color: minorForeground
                    font.pixelSize: 12 * appFontSize
                }

                Rectangle {
                    width: preferWidth
                    height: preferHeigh

                    radius: 10 * appScaleSize

                    SelectItem {
                        titleName: i18n("Configure Proxy")
                        selectName: i18n("Off")
                        arrowVisible: true
                        showBottomLine: false
                    }
                }
            }
        }
    }

    Kirigami.JDialog {
        id: deleteDialog

        title: i18n("Forget WLAN Network")
        inputEnable: false
        text: i18n("Your device will no longer join this WLAN network.")
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("Forget")
        rightButtonTextColor: highlightColor

        onRightButtonClicked: {
            if (nameEquals) {
                connectionPath = connectiontedPath
            }
            handler.removeConnection(connectionPath)
            handler.requestScan()
            wifi_root.popView()
            deleteDialog.visible = false
        }
        
        onLeftButtonClicked: {
            deleteDialog.visible = false
        }
    }
}
