/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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

import org.kde.kcm 1.2 as KCM
import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.10
import QtQuick.Dialogs 1.0

Item {
    id: addConfig_root

    property var gateWayText: tf_gateWay.text
    property var userNameText: tf_userName.text
    property var desText: tf_des.text
    property bool addEnable: currentType
                             == "L2TP" ? tf_gateWay.text != "" && tf_des.text != ""
                                         && tf_userName.text != "" && tf_passWord.text != ""
                                         && tf_prekey.text != "" : currentType == "OpenVPN" ? tf_gateWay.text != "" && tf_des.text != "" && tf_ca.text != "" && tf_cert.text != "" && tf_key.text != "" && tf_auth.text != "" && tf_passWord.text != "" : tf_gateWay.text != "" && tf_des.text != "" && tf_userName.text != "" && tf_passWord.text != ""

    property var currentType: "L2TP"
    property var selsectType
    property bool isSelectable: true

     RegExpValidator {
        id: ipValidator
        regExp: /^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/
    }

    Connections {
        target: kcm

        onPasswordReplyFinished: {
            tf_passWord.text = pwd
        }
    }

    function initParams() {
        currentType = kcm.getConnectionType()
        if (currentType == "L2TP") {
            initL2tp()
        } else if (currentType == "PPTP") {
            initPPTP()
        } else if (currentType == "OpenVPN") {
            initOpenVPN()
        }

        tf_des.text = kcm.getDescription()
        tf_gateWay.text = kcm.getServerName()
        tf_domain.text = kcm.getDomainName()
        tf_userName.text = kcm.getUserName()
        tf_passWord.text = kcm.getPassword()
        tf_prekey.text = kcm.getPreSharedKey()
        tf_ca.text = kcm.getCACertificate()
        tf_cert.text = kcm.getUserCertificate()
        tf_key.text = kcm.getPrivateKeyCertificate()
        tf_auth.text = kcm.getStaticKeyCertificate()
    }

    Rectangle {
        id: type_area

        width: parent.width
        height: 45 * appScaleSize

        color: cardBackground
        radius: 10 * appScaleSize

        Rectangle {
            id: typeRect

            anchors {
                top: parent.top
            }

            width: parent.width
            height: parent.height

            color: "transparent"

            Text {
                id: slince_title

                anchors {
                    left: parent.left
                    leftMargin: 20 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                height: 22 * appScaleSize

                text: i18n("Type")
                font.pixelSize: 14 * appFontSize
                color: majorForeground
            }

            Item {
                anchors {
                    right: parent.right
                    rightMargin: 8 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }

                width: childrenRect.width
                height: 40 * appScaleSize

                Text {
                    anchors {
                        right: isSelectable ? icon_down.left : parent.right
                        rightMargin: isSelectable ? 2 * appScaleSize : 12 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: isDarkTheme ? "#8CF7F7F7" : "#99000000"
                    text: currentType
                }

                Image {
                    id: icon_down

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScaleSize
                    height: 22 * appScaleSize

                    visible: isSelectable
                    source: "../image/icon_right.png"
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if(isSelectable){
                            typeList.parent = icon_down
                            typeList.x = -(typeList.width) + icon_down.width + 13 * appScaleSize
                            typeList.y = icon_down.height
                            typeList.visible = true
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: content_area

        anchors {
            left: parent.left
            top: type_area.bottom
            topMargin: 24 * appScaleSize
        }

        width: parent.width
        height: column.height

        radius: 15 * appScaleSize
        color: cardBackground

        Column {
            id: column

            anchors {
                left: content_area.left
                top: content_area.top
            }

            width: content_area.width
            height: childrenRect.height

            Rectangle {
                id: desRect

                anchors {
                    left: parent.left
                    top: content_area.top
                    topMargin: 24 * appScaleSize
                }

                width: column.width
                height: 45 * appScaleSize

                color: cardBackground
                radius: 10 * appScaleSize

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Description")
                }

                CTextField {
                    id: tf_des

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: parent.right
                        rightMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    placeholderText: i18n("Required")

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                color: dividerForeground
            }

            Rectangle {
                id: gateWayRect

                width: column.width
                height: 45 * appScaleSize

                color: cardBackground
                radius: 10 * appScaleSize

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Gateway")
                }
                CTextField {
                    id: tf_gateWay

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScaleSize
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    placeholderText: i18n("Required")
                    validator: ipValidator

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: domainRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: domainRect
                width: column.width
                height: domainRect.visible ? 45 * appScaleSize : 0
                color: cardBackground
                radius: 10 * appScaleSize

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("NT Domain")
                }

                CTextField {
                    id: tf_domain

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScaleSize
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    placeholderText: i18n("Not Required")
                    validator: ipValidator

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }
    }

    Rectangle {
        id: authen_area

        anchors {
            left: parent.left
            top: content_area.bottom
            topMargin: 24 * appScaleSize
        }

        width: parent.width
        height: authen_column.height

        radius: 10 * appScaleSize
        color: cardBackground

        Column {
            id: authen_column

            anchors {
                left: authen_area.left
                top: authen_area.top
            }

            width: authen_area.width
            height: childrenRect.height

            Rectangle {
                anchors {
                    left: parent.left
                    top: authen_area.top
                    topMargin: 13 * appScaleSize
                    leftMargin: 20 * appScaleSize
                }

                width: authen_area.width
                height: 36 * appScaleSize

                color:  "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    font.pixelSize: 12 * appFontSize
                    text: i18n("Authentication")
                    color: minorForeground
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: caRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: caRect

                width: authen_column.width
                height: caRect.visible ? 45 * appScaleSize : 0

                visible: false
                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("CA Certificate")
                }

                Text {
                    id: tf_ca

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: selectFileImage1.right
                        rightMargin: 40 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    wrapMode:Text.WrapAnywhere
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                }

                Image {
                    id: selectFileImage1

                    anchors {
                        right: parent.right
                        rightMargin: 30 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23 * appScaleSize
                    height: 23 * appScaleSize

                    source: "../image/folder-black.png"

                    MouseArea {

                        anchors.fill: parent
                        onClicked: {
                            selsectType = "ca"
                            //fileDialog.visible = true
                            showFileDialog()
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: certRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: certRect

                width: authen_column.width
                height: certRect.visible ? 45 * appScaleSize : 0

                visible: false
                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("User Certificate")
                }

                Text {
                    id: tf_cert

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: selectFileImage2.right
                        rightMargin: 40 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    wrapMode:Text.WrapAnywhere
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                }

                Image {
                    id: selectFileImage2

                    anchors {
                        right: parent.right
                        rightMargin: 30 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23 * appScaleSize
                    height: 23 * appScaleSize

                    source: "../image/folder-black.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selsectType = "cert"
                            //fileDialog.visible = true
                            showFileDialog()
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: keyRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: keyRect

                width: authen_column.width
                height: keyRect.visible ? 45 * appScaleSize : 0

                visible: false
                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Private Key")
                }

                Text {
                    id: tf_key

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: selectFileImage3.right
                        rightMargin: 40 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    wrapMode:Text.WrapAnywhere
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                }

                Image {
                    id: selectFileImage3

                    anchors {
                        right: parent.right
                        rightMargin: 30 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23 * appScaleSize
                    height: 23 * appScaleSize

                    source: "../image/folder-black.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selsectType = "key"
                            //fileDialog.visible = true
                            showFileDialog()
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: authRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: authRect

                width: authen_column.width
                height: authRect.visible ? 45 * appScaleSize : 0
                

                visible: false
                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Static Key")
                }
                Text {
                    id: tf_auth

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: selectFileImage4.right
                        rightMargin: 40 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    wrapMode:Text.WrapAnywhere
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                }

                Image {
                    id: selectFileImage4

                    anchors {
                        right: parent.right
                        rightMargin: 30 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23 * appScaleSize
                    height: 23 * appScaleSize

                    source: "../image/folder-black.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selsectType = "auth"
                            //fileDialog.visible = true
                            showFileDialog()
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: userNameRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: userNameRect

                width: authen_column.width
                height: userNameRect.visible ? 45 * appScaleSize : 0

                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Username")
                }

                CTextField {
                    id: tf_userName

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: parent.right
                        rightMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    placeholderText: i18n("Required")

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1

                visible: passwordRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: passwordRect

                width: authen_column.width
                height: passwordRect.visible ? 45 * appScaleSize : 0

                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Password")
                }

                Image {
                    id: img_pwd

                    anchors {
                        right: img_clear.left
                        rightMargin: 8 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScaleSize
                    height: 22 * appScaleSize

                    source: tf_passWord.echoMode == TextInput.Password ? "../image/pwd_hidden.png" : "../image/pwd_visible.png"
                    
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (tf_passWord.echoMode == TextInput.Password) {
                                tf_passWord.echoMode = TextInput.Normal
                                tf_passWord.passwordMaskDelay = 0
                            } else {
                                tf_passWord.echoMode = TextInput.Password
                                tf_passWord.passwordMaskDelay = 500
                            }
                        }
                    }
                }

                Image {
                    id: img_clear

                    anchors {
                        right: parent.right
                        rightMargin: 17 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScaleSize
                    height: 22 * appScaleSize

                    visible: tf_passWord.text.length > 0
                    source: "../image/icon_clear.png"

                    MouseArea {

                        anchors.fill: parent
                        onClicked: {
                            tf_passWord.text = ""
                        }
                    }
                }

                CTextField {
                    id: tf_passWord

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        right: img_pwd.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: 20 * appScaleSize
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    echoMode: TextInput.Password
                    passwordCharacter:  String.fromCharCode(0x2022, 16)
                    passwordMaskDelay: 500
                    placeholderText: i18n("Ask Every Time")
                    validator: RegExpValidator {regExp: /^[\u4e00-\u9fa5 -~]+$/ }

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScaleSize
                    rightMargin: 20 * appScaleSize
                }

                width: column.width
                height: 1
                
                visible: preKeyRect.visible
                color: dividerForeground
            }

            Rectangle {
                id: preKeyRect

                width: authen_column.width
                height: preKeyRect.visible ? 45 * appScaleSize : 0

                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScaleSize
                        verticalCenter: parent.verticalCenter
                    }
                    width: 116*appScaleSize
                    wrapMode:Text.WrapAnywhere
                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    text: i18n("Pre-shared key")
                }

                CTextField {
                    id: tf_prekey

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScaleSize
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScaleSize
                    }

                    font.pixelSize: 14 * appFontSize
                    color: majorForeground
                    placeholderText: i18n("Required")
                    validator: RegExpValidator {regExp: /^[\u4e00-\u9fa5 -~]+$/ }

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }
    }

    TypeList {
        id: typeList

        onItemSelect: {
            currentType = displayName
            clearTxt()
            if (currentType == "L2TP") {
                initL2tp()
            } else if (currentType == "PPTP") {
                initPPTP()
            } else if (currentType == "OpenVPN") {
                initOpenVPN()
            }
        }
    }

    function showFileDialog(){
        fileDialogLoader.active = true
    }

    function hideFileDialog(){
        fileDialogLoader.active = false
    }

    Loader{
        id:fileDialogLoader
        active:false
        //width: parent.width
        sourceComponent: fileDialogComponent
    }

    Component{
        id:fileDialogComponent

        FileDialog {
            id: fileDialog

            visible:true
            title: "Please choose a file"
            folder: shortcuts.home

            onAccepted: {
                var urlText = fileDialog.fileUrl.toString()
                if (urlText.indexOf("file://") != -1) {
                    urlText = urlText.substr(urlText.indexOf("file://") + 7,
                                            urlText.length - 1)
                }
                if (selsectType == "ca") {
                    tf_ca.text = urlText
                } else if (selsectType == "cert") {
                    tf_cert.text = urlText
                } else if (selsectType == "key") {
                    tf_key.text = urlText
                } else if (selsectType == "auth") {
                    tf_auth.text = urlText
                }
                hideFileDialog()
            }

            onRejected: {
                hideFileDialog()
            }
        }
    }

    function initL2tp() {
        desRect.visible = true
        gateWayRect.visible = true
        domainRect.visible = true
        caRect.visible = false
        certRect.visible = false
        keyRect.visible = false
        userNameRect.visible = true
        passwordRect.visible = true
        preKeyRect.visible = true
        authRect.visible = false
        authen_area.height = 36 * appScaleSize + 45 * appScaleSize * 3
        tf_passWord.echoMode = TextInput.Password
    }

    function initPPTP() {
        desRect.visible = true
        gateWayRect.visible = true
        domainRect.visible = true
        caRect.visible = false
        certRect.visible = false
        keyRect.visible = false
        userNameRect.visible = true
        passwordRect.visible = true
        preKeyRect.visible = false
        authRect.visible = false
        authen_area.height = 36 * appScaleSize + 45 * appScaleSize * 2
        tf_passWord.echoMode = TextInput.Password
    }

    function initOpenVPN() {
        desRect.visible = true
        gateWayRect.visible = true
        domainRect.visible = false
        caRect.visible = true
        certRect.visible = true
        keyRect.visible = true
        userNameRect.visible = false
        passwordRect.visible = true
        preKeyRect.visible = false
        authRect.visible = true
        authen_area.height = 36 * appScaleSize + 45 * appScaleSize * 5
        tf_passWord.echoMode = TextInput.Password
    }

    function clearTxt() {
        tf_des.text = ""
        tf_gateWay.text = ""
        tf_userName.text = ""
        tf_passWord.text = ""
        tf_ca.text = ""
        tf_cert.text = ""
        tf_key.text = ""
        tf_prekey.text = ""
        tf_domain.text = ""
        tf_auth.text = ""
    }

    function addVPNConfig() {
        var urlText = tf_ca.text
        if (urlText.indexOf("file://") == -1) {
            urlText = "file://" + urlText
        }
        kcm.addVPNConnection(currentType, tf_des.text, tf_userName.text,
                             tf_passWord.text, tf_gateWay.text, tf_domain.text,
                             tf_prekey.text, tf_ca.text, tf_cert.text,
                             tf_key.text, tf_auth.text)
    }
    
    function updateVPNConfig() {
        var urlText = tf_ca.text
        if (urlText.indexOf("file://") == -1) {
            urlText = "file://" + urlText
        }
        kcm.updateVPNConnection(currentType, tf_des.text, tf_userName.text,
                                tf_passWord.text, tf_gateWay.text,
                                tf_domain.text, tf_prekey.text, tf_ca.text,
                                tf_cert.text, tf_key.text, tf_auth.text)
    }
}
