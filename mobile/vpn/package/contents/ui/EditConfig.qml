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
        height: 45 * appScale

        color: "white"
        radius: 10 * appScale

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
                    leftMargin: 20 * appScale
                    verticalCenter: parent.verticalCenter
                }

                height: 22 * appScale

                text: i18n("Type")
                font.pixelSize: 14
            }

            Item {
                anchors {
                    right: parent.right
                    rightMargin: 8 * appScale
                    verticalCenter: parent.verticalCenter
                }

                width: childrenRect.width
                height: 40 * appScale

                Text {
                    anchors {
                        right: icon_down.left
                        rightMargin: 2 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#99000000"
                    text: currentType
                }

                Image {
                    id: icon_down

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScale
                    height: 22 * appScale

                    source: "../image/icon_right.png"
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        typeList.parent = icon_down
                        typeList.x = -(typeList.width) + icon_down.width + 13 * appScale
                        typeList.y = icon_down.height
                        typeList.visible = true
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
            topMargin: 24 * appScale
        }

        width: parent.width
        height: column.height

        radius: 15 * appScale
        color: "white"

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
                    topMargin: 24 * appScale
                }

                width: column.width
                height: 45 * appScale

                color: "white"
                radius: 10 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Description")
                }

                TextField {
                    id: tf_des

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: parent.right
                        rightMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
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
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                color: "#FFE5E5EA"
            }

            Rectangle {
                id: gateWayRect

                width: column.width
                height: 45 * appScale

                color: "white"
                radius: 10 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Gateway")
                }
                TextField {
                    id: tf_gateWay

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScale
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
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
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: domainRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: domainRect
                width: column.width
                height: 45 * appScale
                color: "white"
                radius: 10 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("NT Domain")
                }

                TextField {
                    id: tf_domain

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScale
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                    placeholderText: i18n("Not Required")

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
            topMargin: 24 * appScale
        }

        width: parent.width
        height: column.height

        radius: 10 * appScale
        color: "white"

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
                    topMargin: 13 * appScale
                    leftMargin: 20 * appScale
                }

                width: authen_area.width
                height: 36 * appScale

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    font.pixelSize: 12
                    text: i18n("Authentication")
                    color: "#4D000000"
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                }

                width: authen_column.width
                height: 45 * appScale

                visible: false
                color: "transparent"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    height: 26 * appScale

                    text: i18n("User Authentication")
                    font.pixelSize: 14
                }

                Text {
                    anchors {
                        right: icon_right.left
                        rightMargin: 2 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#99000000"
                    text: i18n("Username")
                }

                Image {
                    id: icon_right

                    anchors {
                        right: parent.right
                        rightMargin: 13 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22 * appScale
                    height: 22 * appScale

                    source: "../image/icon_right.png"
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: false
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: caRect

                width: authen_column.width
                height: 45 * appScale

                visible: false
                color: "white"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("CA Certificate")
                }

                Text {
                    id: tf_ca

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: selectFileImage1.right
                        rightMargin: 40 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                }

                Image {
                    id: selectFileImage1

                    anchors {
                        right: parent.right
                        rightMargin: 30
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23
                    height: 23

                    source: "../image/folder-black.png"

                    MouseArea {

                        anchors.fill: parent
                        onClicked: {
                            selsectType = "ca"
                            fileDialog.visible = true
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: certRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: certRect

                width: authen_column.width
                height: 45 * appScale

                visible: false
                color: "white"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("User Certificate")
                }

                Text {
                    id: tf_cert

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: selectFileImage2.right
                        rightMargin: 40 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                }

                Image {
                    id: selectFileImage2

                    anchors {
                        right: parent.right
                        rightMargin: 30
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23
                    height: 23

                    source: "../image/folder-black.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selsectType = "cert"
                            fileDialog.visible = true
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: keyRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: keyRect

                width: authen_column.width
                height: 45 * appScale

                visible: false
                color: "white"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Private Key")
                }
                Text {

                    id: tf_key

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: selectFileImage3.right
                        rightMargin: 40 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                }

                Image {
                    id: selectFileImage3

                    anchors {
                        right: parent.right
                        rightMargin: 30
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23
                    height: 23

                    source: "../image/folder-black.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selsectType = "key"
                            fileDialog.visible = true
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: authRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: authRect

                width: authen_column.width
                height: 45 * appScale

                visible: false
                color: "white"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Static Key")
                }
                Text {
                    id: tf_auth

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: selectFileImage4.right
                        rightMargin: 40 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                }

                Image {
                    id: selectFileImage4

                    anchors {
                        right: parent.right
                        rightMargin: 30
                        verticalCenter: parent.verticalCenter
                    }

                    width: 23
                    height: 23

                    source: "../image/folder-black.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selsectType = "auth"
                            fileDialog.visible = true
                        }
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: userNameRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: userNameRect

                width: authen_column.width
                height: 45 * appScale

                color: "white"
                radius: 10 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Username")
                }

                TextField {
                    id: tf_userName

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: parent.right
                        rightMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
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
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1

                visible: passwordRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: passwordRect

                width: authen_column.width
                height: 45 * appScale

                color: "white"
                radius: 10 * appScale

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Password")
                }

                Image {
                    id: img_pwd

                    anchors {
                        right: img_clear.left
                        rightMargin: 8 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22
                    height: 22

                    source: tf_passWord.echoMode == TextInput.Password ? "../image/pwd_hidden.png" : "../image/pwd_visible.png"
                    
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (tf_passWord.echoMode == TextInput.Password) {
                                tf_passWord.echoMode = TextInput.Normal
                            } else {
                                tf_passWord.echoMode = TextInput.Password
                            }
                        }
                    }
                }

                Image {
                    id: img_clear

                    anchors {
                        right: parent.right
                        rightMargin: 17 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    width: 22
                    height: 22

                    visible: tf_passWord.text.length > 0
                    source: "../image/icon_clear.png"

                    MouseArea {

                        anchors.fill: parent
                        onClicked: {
                            tf_passWord.text = ""
                        }
                    }
                }

                TextField {
                    id: tf_passWord

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        right: img_pwd.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: 20 * appScale
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                    echoMode: TextInput.Password
                    placeholderText: i18n("Ask Every Time")

                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 20 * appScale
                    rightMargin: 20 * appScale
                }

                width: column.width
                height: 1
                
                visible: preKeyRect.visible
                color: "#FFE5E5EA"
            }

            Rectangle {
                id: preKeyRect

                width: authen_column.width
                height: 45 * appScale

                color: "white"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 20 * appScale
                        verticalCenter: parent.verticalCenter
                    }

                    font.pixelSize: 14
                    color: "black"
                    text: i18n("Pre-shared key")
                }

                TextField {
                    id: tf_prekey

                    anchors {
                        left: parent.left
                        leftMargin: 136 * appScale
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20 * appScale
                    }

                    font.pixelSize: 14
                    color: "#FF000000"
                    placeholderText: i18n("Required")

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

    FileDialog {
        id: fileDialog

        visible: false
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
            Qt.quit()
        }

        onRejected: {
            Qt.quit()
        }
    }

    function initL2tp() {
        desRect.visible = true
        gateWayRect.visible = true
        domainRect.visible = true
        domainRect.height = 45 * appScale
        caRect.visible = false
        certRect.visible = false
        keyRect.visible = false
        userNameRect.visible = true
        passwordRect.visible = true
        preKeyRect.visible = true
        authRect.visible = false
        tf_passWord.echoMode = TextInput.Password
    }

    function initPPTP() {
        desRect.visible = true
        gateWayRect.visible = true
        domainRect.visible = true
        domainRect.height = 45 * appScale
        caRect.visible = false
        certRect.visible = false
        keyRect.visible = false
        userNameRect.visible = true
        passwordRect.visible = true
        preKeyRect.visible = false
        authRect.visible = false
        tf_passWord.echoMode = TextInput.Password
    }

    function initOpenVPN() {
        desRect.visible = true
        gateWayRect.visible = true
        domainRect.visible = false
        domainRect.height = 0
        caRect.visible = true
        certRect.visible = true
        keyRect.visible = true
        userNameRect.visible = false
        passwordRect.visible = true
        preKeyRect.visible = false
        authRect.visible = true
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
