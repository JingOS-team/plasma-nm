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
    property var selectName
    property bool showBottomLine: true
    property bool arrowVisible: false
    property bool rightPartVisible: true
    property string imgPath: "qrc:/image/arrow_right.png"

    width: parent.width
    height: 69 * appScale

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 31 * appScale
        anchors.verticalCenter: parent.verticalCenter
        text: titleName
        font.pointSize: defaultFontSize
    }

    Item {
        anchors {
            right: parent.right
            rightMargin: 31 * appScale
        }

        height: parent.height

        visible: rightPartVisible
        
        Image {
            id: rightArrow

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            sourceSize.width: 34 * appScale
            sourceSize.height: 34 * appScale

            visible: arrowVisible
            source: imgPath
        }

        Kirigami.Label {
            anchors.right: arrowVisible ? rightArrow.left : parent.right
            anchors.verticalCenter: parent.verticalCenter

            text: selectName
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

        visible: showBottomLine
        border.color: "#FFE5E5EA"
    }
}
