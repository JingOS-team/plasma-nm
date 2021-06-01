/*
 *   Copyright 2021 Wang Rui <wangrui@jingos.com>
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.15 as Kirigami
import org.kde.kcm 1.2

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

        color: "#FFF6F9FF"
    }

    Text {
        id: title

        anchors {
            top: parent.top
            left: parent.left
            topMargin: 48 * appScale
            leftMargin: 20 * appScale
        }

        height: 22 * appScale
        
        font.pixelSize: 20
        font.bold: true
        text: i18n("WLAN") 
    }

    Rectangle {
        id: wifiSetting

        anchors {
            top: title.bottom
            topMargin: 18 * appScale
            left: parent.left
            right: parent.right
            rightMargin: 20 * appScale
            leftMargin: 20 * appScale
        }

        height: childrenRect.height

        radius: 10 * appScale
        color: "white"

        Item {
            id: wanMain

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: 45 * appScale

            Kirigami.Label {
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScale
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("WLAN")
                font.pixelSize: 17
            }

            Kirigami.JSwitch {
                id: mSwitch
                
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScale
                anchors.verticalCenter: parent.verticalCenter

                implicitWidth: 43 * appScale
                implicitHeight: 26 * appScale

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
                    leftMargin: 31 * appScale
                    rightMargin: 31 * appScale
                    bottom: parent.bottom
                }

                visible: mSwitch.checked & networkStatus.networkStatus
                         == "Connecting" | networkStatus.networkStatus == "Connected"
                color: "#FFE5E5EA"
                height: 1
            }
        }

        Repeater {
            id: repeater

            model: editorProxyModel

            WifiLoadingItem {
                id: wifiItem

                anchors.top: wanMain.bottom
                    
                height: Type == 14 & (networkStatus.networkStatus == "Connecting"
                                      | networkStatus.networkStatus == "Connected")
                        & mSwitch.checked ? 45 * appScale : 0

                titleName: Name
                showBottomLine: false
                loadingType: Type == 14 ? ConnectionState : PlasmaNM.Enums.Activated
                lockIconVisible: (model.SecurityType == -1 | model.SecurityType == 0) ? false : true
                
                visible: Type == 14 & (ConnectionState == PlasmaNM.Enums.Activated
                                       | ConnectionState == PlasmaNM.Enums.Activating)
                wifiIconPath: {
                    if (model.Signal >= 90) {
                        return "qrc:/image/signal_full.png"
                    } else if (model.Signal >= 75) {
                        return "qrc:/image/signal_high.png"
                    } else if (model.Signal >= 50) {
                        return "qrc:/image/signal_medium.png"
                    } else if (model.Signal >= 20) {
                        return "qrc:/image/signal_low.png"
                    } else if (model.Signal >= 0) {
                        return "qrc:/image/signal_weak.png"
                    }
                }
                
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        apletType = false
                        wifi_root.currentModel = model
                        wifi_root.currentIndex = index
                        wifi_root.gotoPage("connectedItem_view")
                    }
                }
            }
        }
    }

    Column {
        id: column

        anchors {
            top: wifiSetting.bottom
            bottom: home.bottom
            topMargin: 24 * appScale
            bottomMargin: 24 * appScale
            left: parent.left
            right: parent.right
            rightMargin: 20 * appScale
            leftMargin: 20 * appScale
        }

        visible: enabledConnections.wirelessEnabled

        Item {
            width: parent.width
            height: 36 * appScale

            visible: false
            Kirigami.Label {
                id: otherLabel

                anchors {
                    left: parent.left
                    leftMargin: 30 * appScale
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 12
                text: i18n("Nearby network")
                color: "#4D000000"
            }

            Image {
                id: loadingState
                
                anchors {
                    left: otherLabel.right
                    leftMargin: 10 * appScale
                    verticalCenter: parent.verticalCenter
                }

                width: 22 * appScale
                height: 22 * appScale

                visible: isRefreshing
                source: "qrc:/image/loading.png"

                RotationAnimation {
                    id: scanAnim

                    target: loadingState
                    loops: Animation.Infinite
                    running: true
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
            radius: 10 * appScale
            color: "white"
            ListView {
                id: listView

                property string currentConnectionName
                property string currentConnectionPath
                property int contentYOnFlickStarted

                width: parent.width
                height: listView.count != savedNetworkCount ? savedNetworkCount > 0 ? listView.count == 0 ?  0 : listView.count < 7 ? 68 + listView.count * 45 * appScale : 370 * appScale
                        : listView.count < 8 ? 34 + listView.count * 45 * appScale : 370 * appScale : savedNetworkCount * 45 * appScale + 34

                /*height: listView.count
                        != 0 ? listView.count
                               < 8 ?  listView.count * 69 * appScale :  8 * 69 * appScale
                                     + (isDisconnected ? 69 * appScale : 0) : 0
                */
                ScrollBar.vertical: ScrollBar {}

                clip: true
                model: appletProxyModel

                section.property: "KcmConnectionState"
                section.delegate: Item {
                    id: sectionRect

                    anchors {
                        left: parent.left
                    }

                    width: parent.width - 40 * appScale
                    height: 34

                    Text {
                        id: sectionText

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            leftMargin: 20 * appScale
                            bottomMargin: 6 * appScale
                        }

                        text: i18n(section)
                        color: "#4D000000"
                        font.pixelSize: 12
                    }

                    Image {
                        id: loadingState2
                        
                        anchors {
                            left: sectionText.right
                            leftMargin: 10 * appScale
                            bottom: parent.bottom
                            bottomMargin: 2 * appScale
                            //verticalCenter: parent.verticalCenter
                        }

                        width: 22 * appScale
                        height: 22 * appScale

                        visible: isRefreshing
                        source: "qrc:/image/loading.png"

                        RotationAnimation {
                            id: scanAnim

                            target: loadingState2
                            loops: Animation.Infinite
                            running: true
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
                        if (model.Signal >= 90) {
                            return "qrc:/image/signal_full.png"
                        } else if (model.Signal >= 70) {
                            return "qrc:/image/signal_high.png"
                        } else if (model.Signal >= 50) {
                            return "qrc:/image/signal_medium.png"
                        } else if (model.Signal >= 20) {
                            return "qrc:/image/signal_low.png"
                        } else if (model.Signal >= 0) {
                            return "qrc:/image/signal_weak.png"
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
                titleNameColor: "#FF3C4BE8"
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
            currentModel.UpdateItem = currentSelectSsid
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
