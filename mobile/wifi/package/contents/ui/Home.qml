/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */


import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.15 as Kirigami
import org.kde.kcm 1.2
import jingos.display 1.0
SimpleKCM {
    id: home
    
    property int defaultFontSize: theme.defaultFont.pointSize
    property bool isDisconnected: enabledConnections.wirelessEnabled
                                  & networkStatus.networkStatus == "Disconnected"
    property var currentSelectSsid
    property var savedNetworkCount: 0

    signal selectedUuidChanged(string uuid)

    anchors.fill: parent

    width: wifi_root.width
    height: wifi_root.height

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    Rectangle {
        anchors.fill: parent

        color: settingMinorBackground
    }


    Item {
        id: title
        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
            top: parent.top
            topMargin:  JDisplay.statusBarHeight
        }

        height: 62 * appScaleSize
        Text {
            color: majorForeground
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 6 * appScaleSize
            font.pixelSize: 20 * appFontSize
            font.bold: true
            text: i18n("WLAN")
        }
    }

    Rectangle {
        id: wifiSetting

        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            rightMargin: 20 * appScaleSize
            leftMargin: 20 * appScaleSize
        }

        height: childrenRect.height

        radius: 10 * appScaleSize
        color: cardBackground

        Item {
            id: wanMain

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: 45 * appScaleSize

            Kirigami.Label {
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                color: majorForeground
                text: i18n("WLAN")
                font.pixelSize: 14 * appFontSize
            }

            Kirigami.JSwitch {
                id: mSwitch
                
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                implicitWidth: 43 * appScaleSize
                implicitHeight: 26 * appScaleSize

                checked: enabledConnections.wirelessEnabled

                onCheckedChanged: {
                    if (checked) {
                        if (!enabledConnections.wirelessEnabled) {
                            handler.enableWireless(checked)
                            handler.requestScan()
                        }
                        savedNetworkCount =  currenProxyModel.sourceModel.sourceModel.getSavedCount()
                        column.visible = true
                    } else {
                        if (enabledConnections.wirelessEnabled) {
                            handler.enableWireless(checked)
                        }
                        column.visible = false
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                    bottom: parent.bottom
                }

                visible: mSwitch.checked & (networkStatus.networkStatus
                                            == "Connecting" | networkStatus.networkStatus == "Connected")
                color: dividerForeground
                height: 1
            }
        }

        Repeater {
            id: repeater

            model: editorProxyModel

            WifiLoadingItem {
                id: wifiItem

                anchors.top: wanMain.bottom

                height: (Type == 14 && (ConnectionState == PlasmaNM.Enums.Activated
                                        | ConnectionState == PlasmaNM.Enums.Activating)
                         && mSwitch.checked) ? 45 * appScaleSize : 0

                titleName: Name
                showBottomLine: false
                isloading: networkStatus.networkStatus == "Connecting"
                //loadingType: Type == 14 ? ConnectionState : PlasmaNM.Enums.Activated
                lockIconVisible: (model.SecurityType == -1 | model.SecurityType == 0) ? false : true
                
                visible: Type == 14 && (ConnectionState == PlasmaNM.Enums.Activated
                                        | ConnectionState == PlasmaNM.Enums.Activating)
                         && mSwitch.checked
                wifiIconPath: {
                    if (model.Signal > 75) {
                        return isDarkTheme ? "qrc:/image/signal_full_dark.png" : "qrc:/image/signal_full.png"
                    } else if (model.Signal > 50) {
                        return isDarkTheme ? "qrc:/image/signal_high_dark.png" : "qrc:/image/signal_high.png"
                    } else if (model.Signal > 25) {
                        return isDarkTheme ? "qrc:/image/signal_medium_dark.png" : "qrc:/image/signal_medium.png"
                    } else if (model.Signal > 0) {
                        return isDarkTheme ? "qrc:/image/signal_low_dark.png" : "qrc:/image/signal_low.png"
                    } else {
                        return isDarkTheme ? "qrc:/image/signal_weak_dark.png" : "qrc:/image/signal_weak.png"
                    }
                }

                onClicked:{
                    apletType = false
                    wifi_root.currentModel = model
                    wifi_root.currentIndex = index
                    wifi_root.gotoPage("connectedItem_view")
                }
                
                //                MouseArea {
                //                    anchors.fill: parent

                //                    onClicked: {
                //                        apletType = false
                //                        wifi_root.currentModel = model
                //                        wifi_root.currentIndex = index
                //                        wifi_root.gotoPage("connectedItem_view")
                //                    }
                //                }
            }
        }
    }

    Column {
        id: column

        anchors {
            top: wifiSetting.bottom
            bottom: home.bottom
            topMargin: 24 * appScaleSize
            bottomMargin: 24 * appScaleSize
            left: parent.left
            right: parent.right
            rightMargin: 20 * appScaleSize
            leftMargin: 20 * appScaleSize
        }

        visible: enabledConnections.wirelessEnabled

        Item {
            width: parent.width
            height: 36 * appScaleSize

            visible: false

            Kirigami.Label {
                id: otherLabel

                anchors {
                    left: parent.left
                    leftMargin: 30 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 12 * appFontSize
                text: i18n("Nearby network")
                color: minorForeground
            }

            Image {
                id: loadingState
                
                anchors {
                    left: otherLabel.right
                    leftMargin: 10 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                width: 22 * appScaleSize
                height: 22 * appScaleSize

                visible: isRefreshing
                source: "qrc:/image/loading.png"

                RotationAnimation {
                    id: scanAnim

                    target: loadingState
                    loops: Animation.Infinite
                    running: isRefreshing
                    from: 0
                    to: 360
                    duration: 3000
                }
            }
        }

        Rectangle {
            id: bottomRect
            
            width: parent.width
            //height: listView.height + otherItem.height
            height: childrenRect.height
            radius: 10 * appScaleSize
            color: cardBackground

            ListView {
                id: listView

                property string currentConnectionName
                property string currentConnectionPath
                property int contentYOnFlickStarted

                width: parent.width
                height: listView.count != savedNetworkCount ? savedNetworkCount > 0 ? listView.count == 0 ?  0 : listView.count < 7 ? 68 * appScaleSize + listView.count * 45 * appScaleSize : rootHeigh - 208 * appScaleSize - 70 * appScaleSize
                : listView.count < 8 ? 37 * appScaleSize + listView.count * 45 * appScaleSize : rootHeigh - 208 * appScaleSize - 70 * appScaleSize : savedNetworkCount * 45 * appScaleSize + 37 * appScaleSize
                /*height: listView.count
                        != 0 ? listView.count
                               < 8 ?  listView.count * 69 * appScaleSize :  8 * 69 * appScaleSize
                                     + (isDisconnected ? 69 * appScaleSize : 0) : 0
                */
                //ScrollBar.vertical: ScrollBar {}

                clip: true
                model: appletProxyModel

                section.property: "KcmConnectionState"
                section.delegate: Item {
                    id: sectionRect

                    anchors {
                        left: parent.left
                    }

                    width: parent.width - 40 * appScaleSize
                    height: 37 * appScaleSize

                    Text {
                        id: sectionText

                        anchors {
                            bottom: parent.bottom
                            bottomMargin: (loadingState2.height - sectionText.height) / 2
                            left: parent.left
                            leftMargin: 20 * appScaleSize
                        }
                        text: i18n(section)
                        color: minorForeground
                        font.pixelSize: 12 * appFontSize
                    }

                    Image {
                        id: loadingState2
                        
                        anchors {
                            left: sectionText.right
                            leftMargin: 10 * appScaleSize
                            bottom: parent.bottom
                            //verticalCenter: parent.verticalCenter
                        }

                        width: 22 * appScaleSize
                        height: 22 * appScaleSize

                        visible: isRefreshing
                        source: "qrc:/image/loading.png"

                        RotationAnimation {
                            id: scanAnim

                            target: loadingState2
                            loops: Animation.Infinite
                            running: isRefreshing
                            from: 0
                            to: 360
                            duration: 3000
                        }
                    }
                }

                Component.onCompleted: {
                    wifi_root.currentIndex = -1
                    if (listView.count <= 1) {
                        handler.requestScan()
                    }
                }

                onFlickStarted: {
                    contentYOnFlickStarted = contentY
                }

                onFlickEnded: {
                    if (contentYOnFlickStarted < 0) {
                        handler.requestScan()
                        rotateTimer.start()
                        isRefreshing = true
                    }
                }

                delegate: WifiItem {
                    id: wifiItem

                    property var specificPath: model.SpecificPath
                    property var devicePath: model.DevicePath
                    property var connectionPath: model.ConnectionPath

                    signal detailClicked
                    signal itemClicked(real mouseX, real mouseY)

                    width: listView.width

                    titleName: model.Name
                    showBottomLine: true
                    lockIconVisible: (model.SecurityType == -1
                                      | model.SecurityType == 0) ? false : true
                    wifiIconPath: {
                        if (model.Signal > 75) {
                            return isDarkTheme ? "qrc:/image/signal_full_dark.png" :"qrc:/image/signal_full.png"
                        } else if (model.Signal > 50) {
                            return  isDarkTheme ? "qrc:/image/signal_high_dark.png" : "qrc:/image/signal_high.png"
                        } else if (model.Signal > 25) {
                            return isDarkTheme ? "qrc:/image/signal_medium_dark.png" : "qrc:/image/signal_medium.png"
                        } else if (model.Signal > 0) {
                            return isDarkTheme ? "qrc:/image/signal_low_dark.png" : "qrc:/image/signal_low.png"
                        } else  {
                            return isDarkTheme ? "qrc:/image/signal_weak_dark.png" : "qrc:/image/signal_weak.png"
                        }
                    }

                    onSpecificPathChanged: {
                        if (currentSelectSsid == Ssid) {
                            passwordPop.specificPath = specificPath
                        }
                    }

                    onDevicePathChanged: {
                        if (currentSelectSsid == Ssid) {
                            passwordPop.devicePath = devicePath
                        }
                    }

                    onDetailClicked: {
                        currentSelectSsid = model.Ssid
                        apletType = true
                        currenProxyModel.sourceModel.sourceModel.isAllowUpdate = false
                        wifi_root.currentModel = model
                        wifi_root.currentIndex = index
                        wifi_root.gotoPage("connectedItem_view")
                    }

                    onItemClicked: {
                        if (model.SecurityType == -1) {
                            wifi_root.currentModel = model
                            wifi_root.currentIndex = index
                            kcm.addNoSecurityConnection(connectionPath,
                                                        devicePath,
                                                        specificPath)
                            return;
                        }

                        if (model.ItemType == 1 | model.SecurityType == 0) {
                            wifi_root.currentModel = model
                            wifi_root.currentIndex = index
                            handler.activateConnection(connectionPath,
                                                       devicePath,
                                                       specificPath)
                        } else if (ItemType == 2) {
                            currentSelectSsid = model.Ssid
                            wifi_root.currentModel = model
                            wifi_root.currentIndex = index
                            apletType = true

                            passwordPop.ssid = model.Ssid
                            passwordPop.inputText = ""
                            passwordPop.devicePath = model.DevicePath
                            passwordPop.specificPath = model.SpecificPath
                            passwordPop.text = i18n("Enter the password for”%1”",model.Name);
                            passwordPop.rightButtonEnable = false
                            passwordPop.visible = true
                        }
                    }
                }
            }

            WifiItem {
                id: otherItem
                
                anchors.top: listView.bottom

                width: parent.width

                titleName: i18n("Add other")+"..."
                titleNameColor: highlightColor
                iconVisible: false

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        wifi_root.gotoPage("otherNetwork_view")
                    }
                }
            }
        }
    }

    Connections {
        target: handler

        onAddConnectionFailed: {
            if(currentSelectSsid && currentSelectSsid != ""){
                currentModel.UpdateItem = currentSelectSsid
            }
        }
    }

    Connections {
        target: appletProxyModel.sourceModel.sourceModel

        onWirelessNetworkDisappearedChanged: {
            if (ssid == currentSelectSsid) {
                passwordPop.visible = false
            }
        }
    }
}
