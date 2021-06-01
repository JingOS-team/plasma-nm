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

    property var titleName
    property alias inputName: textField.text
    property bool showBottomLine: true
    property bool rightPartVisible: true
    property string hintText: ""
    property bool ipValid: true

    width: parent.width
    height: 45 * appScale

    RegExpValidator {
        id: ipValidator
        regExp: /^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/
    }

    Kirigami.Label {
        anchors.left: parent.left
        anchors.leftMargin: 20 * appScale
        anchors.verticalCenter: parent.verticalCenter

        text: titleName
        font.pixelSize: 14
    }
    
    TextField {
        id: textField

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 20 * appScale
        }

        placeholderText: hintText
        horizontalAlignment: Text.AlignRight
        text: inputName
        validator: ipValid ? ipValidator : ""
        wrapMode: Text.WordWrap
        font.pixelSize: 14

        background: Rectangle {
            color: "transparent"
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
}
