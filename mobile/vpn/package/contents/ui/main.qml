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

Rectangle {
    id: vpn_root

    property real appScale: 1
    property int appFontSize: theme.defaultFont.pointSize
    property var currentModel

    anchors.fill: parent

    color: "#FFF6F9FF"

    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }

    PlasmaNM.VpnProxyModel {
        id: vpnProxyModel

        sourceModel: connectionModel
    }

    StackView {
        id: stack

        anchors.fill: parent

        Component.onCompleted: {
            stack.push(home_view)
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
}
