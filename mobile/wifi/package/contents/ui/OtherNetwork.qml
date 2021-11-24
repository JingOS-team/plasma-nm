/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */


import org.kde.kcm 1.2
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import jingos.display 1.0

Rectangle {
    id: root
    property int defaultFontSize: theme.defaultFont.pointSize
    property int preferWidth: 934 * appScaleSize
    property int preferHeigh: 45 * appScaleSize
    property int selectIndex: 0
    property var securityType: "WPA/WPA2"
    property bool isTypeNone: false

    width: wifi_root.width
    height: wifi_root.height

    color: settingMinorBackground

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

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

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
                text: i18n("Other Network")
            }
            Kirigami.JButton {
                id: confirmIcon

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                enabled: networkNameInput.inputName.length > 0
                         & (passwordInput.inputName.length > 7 | securityType == "None")


                backgroundColor:"transparent"
                fontColor: confirmIcon.enabled ? Kirigami.JTheme.highlightColor : Kirigami.JTheme.disableForeground
                font.pixelSize: 17 * appFontSize
                text: i18n("Join")
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
            topMargin: 11 * appScaleSize
            leftMargin: 20 * appScaleSize
            rightMargin: 20 * appScaleSize
        }

        spacing: 24 * appScaleSize

        Rectangle {
            width: parent.width
            height: preferHeigh

            radius: 10 * appScaleSize
            color: cardBackground

            NormalInputItem {
                id: networkNameInput

                ipValid: false
                titleName: i18n("Name")
                showBottomLine: false
                isTitleNameShow: true
                inputFocus: true
		maxLength: 32
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

            radius: 10 * appScaleSize
            color: cardBackground

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
		    maxLength: 32
                    hintText: i18n("input username")
                }

                NormalInputItem {
                    id: passwordInput

                    ipValid: false
                    visible: !isTypeNone
                    titleName: i18n("Password")
                    showBottomLine: false
                    isTitleNameShow: true
		    maxLength: 32
                    hintText: i18n("input password")
                    inputEchoMode: TextInput.Password
                    clearEnable: true
                    hanValid: false

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
        y: 35 * appScaleSize

        parent: securitySelect
        securityModel: listMode
    }
}
