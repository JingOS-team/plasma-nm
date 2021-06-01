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

import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2
import org.kde.kirigami 2.10 as Kirigami

Item {
    id: root

    property alias inputName: textFiled.text
    property bool showBottomLine: true
    property string hintText: ""
    property bool ipValid: true
    property bool isTitleNameShow: false
    property var titleName: ""
    property bool inputFocus: false
    property var inputEchoMode: TextInput.Normal
    property bool clearEnable: false

    signal enteredClick
    signal textChanged(var txt)

    width: parent.width
    height: 45 * appScale

    RegExpValidator {
        id: ipValidator
        regExp: /^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/
    }

    Text {
        id: label

        anchors {
            left: parent.left
            leftMargin: 20 * appScale
            verticalCenter: parent.verticalCenter
        }

        width: 89 * appScale

        text: titleName
        font.pixelSize: 14
        visible: isTitleNameShow
    }

    TextField {
        id: textFiled

        anchors {
            left: isTitleNameShow ? label.right : parent.left
            leftMargin: isTitleNameShow ? 0 : 20 * appScale
            right: clearEnable ? img_pwd.left : parent.right
            rightMargin: 20 * appScale
            verticalCenter: parent.verticalCenter
        }
        
        placeholderText: hintText
        text: inputName
        wrapMode: TextInput.WordWrap
        echoMode: inputEchoMode
        passwordMaskDelay: 500
        validator: ipValid ? ipValidator : ""
        font.pixelSize: 14

        background: Rectangle {
            color: "transparent"
        }

        onAccepted: {
            root.enteredClick()
        }

        onTextChanged:{
            root.textChanged(textFiled.text)
        }
    }

    Image{
        id: img_pwd

        anchors {
            right:img_clear.left
            rightMargin: 8 * appScale
            verticalCenter:parent.verticalCenter
        }
        
        width: 22
        height: 22

        visible: clearEnable  
        source: textFiled.echoMode == TextInput.Password ? "qrc:/image/pwd_hidden.png" : "qrc:/image/pwd_visible.png"
        MouseArea{
            
            anchors.fill: parent
            onClicked: {
                if(textFiled.echoMode == TextInput.Password){
                    textFiled.echoMode = TextInput.Normal
                }else{
                    textFiled.echoMode = TextInput.Password
                }
            }
            
        }
    
    }

    Image{
        id: img_clear

        anchors {
            right:parent.right
            rightMargin: 20 * appScale
            verticalCenter:parent.verticalCenter
        }
        
        width: 22
        height: 22
        source: "qrc:/image/txt_close.png"

        visible: clearEnable && textFiled.text.length > 0
        MouseArea{
            
            anchors.fill: parent
            onClicked: {
                textFiled.text = ""
            }
        }
    }

    Kirigami.Separator {
        visible: showBottomLine

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 20 * appScale
            rightMargin: 20 * appScale
            bottom: parent.bottom
        }

        height: 1
        color: "#FFE5E5EA"
    }
    
    Component.onCompleted: {
        textFiled.forceActiveFocus()
    }
}
