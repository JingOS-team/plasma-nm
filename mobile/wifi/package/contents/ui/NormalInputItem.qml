/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */


import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2
import org.kde.kirigami 2.10 as Kirigami

Item {
    id: root

    property alias inputName: textField.text
    property bool showBottomLine: true
    property string hintText: ""
    property bool ipValid: true
    property bool hanValid: true
    property bool isTitleNameShow: false
    property var titleName: ""
    property bool inputFocus: false
    property var inputEchoMode: TextInput.Normal
    property bool clearEnable: false
    property bool isReadOnly: false
    property int maxLength: 64//max default value

    signal enteredClick
    signal textChanged(var txt)

    width: parent.width
    height: 45 * appScaleSize

    RegExpValidator {
        id: ipValidator
        regExp: /^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/
    }

    RegExpValidator {
        id:  normalValidator
        regExp: /^[\u4e00-\u9fa5 -~]+$/ 
    }

    Text {
        id: label

        anchors {
            left: parent.left
            leftMargin: 20 * appScaleSize
            verticalCenter: parent.verticalCenter
        }

        width: 89 * appScaleSize

        color: majorForeground
        text: titleName
        font.pixelSize: 14 * appFontSize
        visible: isTitleNameShow
    }

    TextField {
        id: textField

        anchors {
            left: isTitleNameShow ? label.right : parent.left
            leftMargin: isTitleNameShow ? 0 : 20 * appScaleSize
            right: clearEnable ? img_pwd.left : parent.right
            rightMargin: 20 * appScaleSize
            verticalCenter: parent.verticalCenter
        }
        
        focus:inputFocus
        leftPadding:0
        placeholderText: hintText
        text: inputName
        wrapMode: TextInput.WordWrap
        echoMode: inputEchoMode
        passwordMaskDelay: 500
        maximumLength: maxLength
        validator: ipValid ? ipValidator : hanValid ? "" : normalValidator
        font.pixelSize: 14 * appFontSize
        readOnly: isReadOnly
        activeFocusOnPress:!isReadOnly
        passwordCharacter:  String.fromCharCode(0x2022, 16)

        background: Rectangle {
            color: "transparent"
        }

        cursorDelegate: Rectangle {
            id: cursorBg

            anchors.verticalCenter: parent.verticalCenter

            width: units.devicePixelRatio * 2
            height: parent.height / 2

            color: "#FF3C4BE8"

            Timer {
                id: timer

                interval: 700
                repeat: true
                running: textField.focus

                onTriggered: {
                    if (timer.running) {
                        cursorBg.visible = !cursorBg.visible
                    } else {
                        cursorBg.visible = false
                    }
                }
            }

            Connections {
                target: textField
                onFocusChanged: cursorBg.visible = focus
            }
        }

        onAccepted: {
            root.enteredClick()
        }

        onTextChanged:{
            root.textChanged(textField.text)
        }

        onReadOnlyChanged:{
            if(readOnly){
                textField.focus = false   
            }else{
                textField.focus = false     
                textField.forceActiveFocus()
            }
        }
    }

    Image{
        id: img_pwd

        anchors {
            right:img_clear.left
            rightMargin: 8 * appScaleSize
            verticalCenter:parent.verticalCenter
        }
        
        width: 22 * appScaleSize
        height: 22 * appScaleSize

        visible: clearEnable  
        source: textField.echoMode == TextInput.Password ? "qrc:/image/pwd_hidden.png" : "qrc:/image/pwd_visible.png"
        MouseArea{
            
            anchors.fill: parent
            onClicked: {
                if(textField.echoMode == TextInput.Password){
                    textField.echoMode = TextInput.Normal
                }else{
                    textField.echoMode = TextInput.Password
                }
            }
            
        }
    
    }

    Image{
        id: img_clear

        anchors {
            right:parent.right
            rightMargin: 20 * appScaleSize
            verticalCenter:parent.verticalCenter
        }
        
        width: 22 * appScaleSize
        height: 22 * appScaleSize
        source: "qrc:/image/txt_close.png"

        visible: clearEnable && textField.text.length > 0
        MouseArea{
            
            anchors.fill: parent
            onClicked: {
                textField.text = ""
            }
        }
    }

    Kirigami.Separator {
        visible: showBottomLine

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 20 * appScaleSize
            rightMargin: 20 * appScaleSize
            bottom: parent.bottom
        }

        height: 1
        color: dividerForeground
    }
    
    Component.onCompleted: {
        textField.forceActiveFocus()
    }
}
