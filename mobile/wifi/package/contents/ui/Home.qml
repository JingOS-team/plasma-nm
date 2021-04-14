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

    Kirigami.Label {
        id: title

        anchors {
            top: parent.top
            left: parent.left
            topMargin: 68 * appScale
            leftMargin: 72 * appScale
        }

        font.pointSize: defaultFontSize + 9
        font.bold: true
        text: "WLAN"
    }

    Rectangle {
        id: wifiSetting

        anchors {
            top: title.bottom
            topMargin: 42 * appScale
            left: parent.left
            right: parent.right
            rightMargin: 72 * appScale
            leftMargin: 72 * appScale
        }

        height: childrenRect.height

        radius: 15 * appScale
        color: "white"

        Item {
            id: wanMain

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: 69 * appScale

            Kirigami.Label {
                anchors.left: parent.left
                anchors.leftMargin: 31 * appScale
                anchors.verticalCenter: parent.verticalCenter

                text: "WLAN"
                font.pointSize: defaultFontSize
            }

            Kirigami.JSwitch {
                id: mSwitch
                
                anchors.right: parent.right
                anchors.rightMargin: 18 * appScale
                anchors.verticalCenter: parent.verticalCenter

                width: 68 * appScale
                height: 40 * appScale

                checked: enabledConnections.wirelessEnabled

                onCheckedChanged: {
                    if (checked) {
                        if (!enabledConnections.wirelessEnabled) {
                            handler.enableWireless(checked)
                            handler.requestScan()
                        }
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
                border.color: "#FFE5E5EA"
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
                        & mSwitch.checked ? 69 * appScale : 0

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
            topMargin: 28 * appScale
            bottomMargin: 28 * appScale
            left: parent.left
            right: parent.right
            rightMargin: 72 * appScale
            leftMargin: 72 * appScale
        }

        visible: enabledConnections.wirelessEnabled

        Item {
            width: parent.width
            height: 56 * appScale

            Kirigami.Label {
                id: otherLabel

                anchors {
                    left: parent.left
                    leftMargin: 30 * appScale
                    verticalCenter: parent.verticalCenter
                }

                font.pointSize: defaultFontSize - 4
                text: "Nearby network"
                color: "#4D000000"
            }

            Image {
                id: loadingState
                
                anchors {
                    left: otherLabel.right
                    leftMargin: 10 * appScale
                    verticalCenter: parent.verticalCenter
                }

                width: 34 * appScale
                height: 34 * appScale

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
            height: listView.height + otherItem.height

            radius: 15 * appScale
            color: "white"

            ListView {
                id: listView

                property string currentConnectionName
                property string currentConnectionPath
                property int contentYOnFlickStarted

                width: parent.width
                height: listView.count
                        != 0 ? listView.count
                               < 8 ? 104 * appScale + listView.count * 69
                                     * appScale : 104 + 7.2 * 69 * appScale
                                     + (isDisconnected ? 69 * appScale : 0) : 0

                ScrollBar.vertical: ScrollBar {}

                clip: true
                model: appletProxyModel

                section.property: "KcmConnectionState"
                section.delegate: Rectangle {
                    id: sectionRect

                    anchors {
                        left: parent.left
                        leftMargin: 15 * appScale
                    }

                    width: parent.width - 30 * appScale
                    height: 52 * appScale

                    Text {
                        id: sectionText

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            leftMargin: 16 * appScale
                            bottomMargin: 9 * appScale
                        }

                        text: section
                        color: "#4D000000"
                        font.pointSize: defaultFontSize - 4
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

                    width: parent.width

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
                            kcm.addNoSecurityConnection(model.ConnectionPath,
                                                        model.DevicePath,
                                                        model.SpecificPath)
                            return;
                        }

                        if (model.ItemType == 1 | model.SecurityType == 0) {
                            wifi_root.currentModel = model
                            wifi_root.currentIndex = index
                            handler.activateConnection(model.ConnectionPath,
                                                       model.DevicePath,
                                                       model.SpecificPath)
                        } else if (ItemType == 2) {
                            currentSelectSsid = model.Ssid
                            wifi_root.currentModel = model
                            wifi_root.currentIndex = index
                            apletType = true

                            passwordPop.wifiName = model.Name
                            passwordPop.devicePath = model.DevicePath
                            passwordPop.specificPath = model.SpecificPath
                            passwordPop.echoMode = TextInput.Password

                            var jx = mapToItem(listView, mouseX, mouseY)
                            var jh = mapToItem(home, mouseX, mouseY)
                            passwordPop.x = wifiItem.x + 16 * appScale

                            if (jh.y + passwordPop.height + 10 < rootHeigh) {
                                passwordPop.y = jx.y
                            } else {
                                passwordPop.y = jx.y - passwordPop.height
                            }
                            passwordPop.visible = true
                        }
                    }
                }
            }

            WifiItem {
                id: otherItem

                anchors.top: listView.bottom

                width: parent.width

                titleName: "Add other…"
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

    JInputDialog {
        id: passwordPop

        parent: listView
        title: "Enter Password"
        focus: true
        echoMode: TextInput.Password

        onCancelButtonClicked: {
            passwordPop.visible = false
        }

        onOkButtonClicked: {
            if (networkStatus.networkStatus == "Connecting") {
                handler.removeConnection(
                            editorProxyModel.currentConnectingdPath)
            }
            handler.addAndActivateConnection(passwordPop.devicePath,
                                             passwordPop.specificPath,
                                             passwordPop.inputText)
            passwordPop.visible = false
        }

        onEnteredClick: {
            if (networkStatus.networkStatus == "Connecting") {
                handler.removeConnection(
                            editorProxyModel.currentConnectingdPath)
            }
            
            handler.addAndActivateConnection(passwordPop.devicePath,
                                             passwordPop.specificPath,
                                             passwordPop.inputText)
            passwordPop.visible = false
        }
    }
}
