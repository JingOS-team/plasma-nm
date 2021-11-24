/*
 *   Copyright 2020 Tobias Fella <fella@posteo.de>
 *   Copyright 2021 Liu Bangguo <liubangguo@jingos.com>
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

import QtQuick 2.6
import QtQuick.Controls 2.10
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.15 as Kirigami
import org.kde.kcm 1.2
import MeeGo.QOfono 0.2
import jingos.display 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: cellular_root
    
    property real appScaleSize: JDisplay.dp(1.0)
    property real appFontSize: JDisplay.sp(1.0)
    property bool isSimExist: false
    property bool isScanFinished: false
    property var currentConnectionPath: ""
    property var currentDevicePath: ""
    property var currentOperatorPath: ""
    property bool isConnected: ofonoContextConnection.active

    property var curentModemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    property var currentContenxt: "/ril_0/context1/"+ofonoSimManager.subscriberIdentity

    property var majorForeground: Kirigami.JTheme.majorForeground
    property var minorForeground: Kirigami.JTheme.minorForeground
    property var settingMinorBackground: Kirigami.JTheme.settingMinorBackground
    property var cardBackground: Kirigami.JTheme.cardBackground
    property var highlightColor: Kirigami.JTheme.highlightColor
    property var dividerForeground: Kirigami.JTheme.dividerForeground
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"
    property var serviceProviderName: ofonoSimManager.serviceProviderName
    property var selectionName: netreg.name ? netreg.name : serviceProviderName
    property var isAirplaneMode :stSource.data["StatusPanel"]["flight mode"]


    PlasmaCore.DataSource {
        id: stSource
        engine: "statuspanel"
        connectedSources: ["StatusPanel"]
    }

    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }

    PlasmaNM.GsmProxyModel {
        id: gsmProxyModel

        sourceModel: connectionModel
    }
    
    PlasmaNM.Handler {
        id: handler

        onActivateConnectionFailed: {
            
        }
    }

    PlasmaNM.Configuration {
        id: configuration
    }

    OfonoContextConnection{
        id:ofonoContextConnection

        contextPath: connectionManager.contexts[0]

        onActiveChanged:{
            isConnected = active
        }
    }
    
    OfonoManager {
        id: ofonoManager
        onAvailableChanged: {

        }
        onModemAdded: {

        }

    }

    OfonoSimManager {
        id: ofonoSimManager
         modemPath: curentModemPath
         onServiceProviderNameChanged:{
             serviceProviderName = spn
         }
    }

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
            netreg.registration()
        }
        onNetworkOperatorsChanged : {

        }
        modemPath: curentModemPath

        onModemPathChanged: {
            //console.log("Strength changed to " + netreg.strength)
        }
        onStrengthChanged: {
            //console.log("Strength changed to " + netreg.strength)
        }
        onScanFinished:{
            isScanFinished = true
        }
        onScanError:{
            isScanFinished = true
        }
        onNameChanged:{
            selectionName = name
        }
    }

    OfonoModem {
        id: ofonoModem

        modemPath: curentModemPath

        onOnlineChanged: {
            if(online == true)
            {
                timer.start()
            }
        }
    }

    OfonoConnMan {
        id:connectionManager

        modemPath: curentModemPath
        onRoamingAllowedChanged:{
        }
    }

    OfonoRadioSettings {
        id: ofonoRadioSettings

        modemPath: curentModemPath
    }

    OfonoNetworkOperator {
        id: networkOperator
        operatorPath: netreg.currentOperatorPath
        onRegisterComplete:{
        }
    }


    OfonoNetworkOperatorListModel {
        id:networkOperatorListModel

        modemPath: curentModemPath
    }

    Component {
        id: home_view
        Home {}
    }

    Component {
        id: options_view
        DataOptions {}
    }

    Component {
        id: hotspot_view
        Hotspot {}
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
        } else if (name == "options_view"){
            stack.push(options_view)
        } else if (name == "hotspot_view"){
            stack.push(hotspot_view)
        }
    }

    function popView() {
        stack.pop()
    }
    
    Timer {
        id: timer

        interval: 2000
        repeat: false
        running: false

        onTriggered: {
            var type = kcm.getAccessPointName(netreg.mcc,netreg.mnc)
            kcm.addConnection(currentContenxt,"","",type)
            ofonoContextConnection.accessPointName = type
            ofonoContextConnection.name = "Internet"
            ofonoContextConnection.type = "internet"
        }
    }
}
