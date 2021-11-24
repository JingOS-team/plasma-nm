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
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import jingos.display 1.0

Rectangle {
    id: vpn_root

    property real appScaleSize: JDisplay.dp(1.0)
    property real appFontSize: JDisplay.sp(1.0)
    property var currentModel
    property bool isVpnConnected: vpnProxyModel.vpnConnectedName != "" ?  true : false

    property var majorForeground: Kirigami.JTheme.majorForeground
    property var minorForeground: Kirigami.JTheme.minorForeground
    property var settingMinorBackground: Kirigami.JTheme.settingMinorBackground
    property var cardBackground: Kirigami.JTheme.cardBackground
    property var highlightColor: Kirigami.JTheme.highlightColor
    property var dividerForeground: Kirigami.JTheme.dividerForeground
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"
    property var m_gateWayText: ""

    anchors.fill: parent

    color: settingMinorBackground

    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }

    PlasmaNM.VpnProxyModel {
        id: vpnProxyModel

        sourceModel: connectionModel
        
        onConnectedNameChanged:{
            isVpnConnected = name != "" ? true : false
        }
    }

    StackView {
        id: stack

        anchors.fill: parent

        Component.onCompleted: {
            stack.push(home_view)
        }
    }

    Connections {
        target: kcm

        onCurrentIndexChanged:{
            if(index == 1){
                popAllView()
            }
        }
    }

    function gotoPage(name, json) {
        if (name == "home_view") {
            stack.push(home_view)
        } else if (name == "detail_view") {
            stack.push(detail_view, json)
        } else if (name == "config_view") {
            stack.push(config_view)
        }
    }

    Component {
        id: home_view

        Home {}
    }

    Component {
        id: detail_view

        VPNDetails {}
    }

    Component {
        id: config_view

        AddConfig {}
    }

    function popView() {
        stack.pop()
    }

    function popAllView() {
        while (stack.depth > 1) {
            stack.pop()
        }
    }
}
