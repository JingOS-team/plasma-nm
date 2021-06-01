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

import org.kde.kcm 1.2
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Item {
    id: root

    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: 934 * appScale
    property int preferHeigh: 45 * appScale
    property int selectIndex: 0
    property var securityType: "WPA/WPA2"
    property bool isTypeNone: false

    focus: true

    Rectangle {
        width: wifi_root.width
        height: wifi_root.height

        color: "#FFF6F9FF"

        Item {
            id: topItem

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 14 * appScale
                topMargin: 48 * appScale
            }

            height: 20 * appScale
            width: parent.width

            Image {
                id: backIcon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                width: 22 * appScale
                height: 22 * appScale

                source: "qrc:/image/arrow_left.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        wifi_root.popView()
                    }
                }
            }

            Kirigami.Label {
                id: title

                anchors {
                    left: backIcon.right
                    leftMargin: 10 * appScale
                    verticalCenter: parent.verticalCenter
                }

                font.pixelSize: 20
                font.bold: true
                text: i18n("Other Network")
            }

            Kirigami.JIconButton {
                id: confirmIcon

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 31 * appScale

                width: 40 * appScale + 10
                height: 22 * appScale + 10

                enabled: networkNameInput.inputName.length > 0
                         & (passwordInput.inputName.length > 7 | securityType == "None")

                Text{
                    anchors.centerIn: parent
                    
                    font.pixelSize: 17
                    text: i18n("Join")
                    color: confirmIcon.enabled ? "#FF3C4BE8" : "#2E000000"
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        var isSuccess = kcm.addOtherConnection(
                                    networkNameInput.inputName,
                                    userNameInput.inputName,
                                    passwordInput.inputName, securityType)
                        if (isSuccess) {
                            wifi_root.popView()
                        }
                    }
                }
            }
        }

        Column {
            anchors {
                top: topItem.bottom
                left: parent.left
                right: parent.right
                topMargin: 31 * appScale
                leftMargin: 20 * appScale
                rightMargin: 20 * appScale
            }

            spacing: 24 * appScale

            Rectangle {
                width: parent.width
                height: preferHeigh

                radius: 10 * appScale
                color: "white"

                NormalInputItem {
                    id: networkNameInput

                    ipValid: false
                    titleName: i18n("Name")
                    showBottomLine: false
                    isTitleNameShow: true
                    inputFocus: true
                    hintText: i18n("Network Name")

                    onEnteredClick: {
                        if (confirmIcon.enabled) {
                            var isSuccess = kcm.addOtherConnection(
                                        networkNameInput.inputName,
                                        userNameInput.inputName,
                                        passwordInput.inputName, securityType)
                            if (isSuccess) {
                                wifi_root.popView()
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: rect

                width: parent.width
                height: childrenRect.height

                radius: 10 * appScale

                Column {
                    width: rect.width

                    SelectItem {
                        id: securitySelect

                        signal itemSelect(var type)

                        titleName: i18n("Security")
                        arrowVisible: true
                        showBottomLine: !isTypeNone
                        selectName: "WPA/WPA2"
                        
                        onItemSelect: {
                            securityType = type
                            securitySelect.selectName = type
                            isTypeNone = type === "None" ? true : false
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                securityListView.visible = true
                            }
                        }
                    }

                    NormalInputItem {
                        id: userNameInput

                        ipValid: false
                        visible: !isTypeNone & securityType == "WEP"
                        titleName: i18n("UserName")
                        showBottomLine: true
                        isTitleNameShow: true
                        hintText: i18n("input username")
                    }

                    NormalInputItem {
                        id: passwordInput

                        ipValid: false
                        visible: !isTypeNone
                        titleName: i18n("Password")
                        showBottomLine: false
                        isTitleNameShow: true
                        hintText: i18n("input password")
                        inputEchoMode: TextInput.Password
                        clearEnable: true

                        onEnteredClick: {
                            if (confirmIcon.enabled) {
                                kcm.addOtherConnection(
                                            networkNameInput.inputName,
                                            userNameInput.inputName,
                                            passwordInput.inputName,
                                            securityType)
                                wifi_root.popView()
                            }
                        }
                    }
                }
            }
        }

        ListModel {
            id: listMode

            ListElement {
                displayName: "None"
                value: 0
            }

            ListElement {
                displayName: "WEP"
                value: 1
            }

            ListElement {
                displayName: "WPA/WPA2"
                value: 3
            }

            ListElement {
                displayName: "WPA3"
                value: 4
            }
        }

        SecurityListView {
            id: securityListView
            
            x: parent.width - securityListView.width
            y: -30 * appScale

            parent: passwordInput
            securityModel: listMode
        }
    }
}
