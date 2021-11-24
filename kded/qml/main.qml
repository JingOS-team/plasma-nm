/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.6
import QtQuick.Controls 2.10
import org.kde.kirigami 2.15 as Kirigami
import MeeGo.QOfono 0.2
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.jingos.kded 0.2 

Item {
    id: root

    property var curentModemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    property var currentContenxt: "/ril_0/context1/"+ofonoSimManager.subscriberIdentity
    property var currentConnectionPath: ""
    property var initConnectionPath: ""
    property bool isConnected: false
    property var tryCount: 0

    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }

    PlasmaNM.GsmProxyModel {
        id: gsmProxyModel

        sourceModel: connectionModel
    }

    PlasmaNM.Configuration {
        id: configuration
    }
    
    ListView{
        id:listView
        model:gsmProxyModel
        delegate: Item{
            Component.onCompleted:{
                if(model.Type == 6){
                    initConnectionPath = model.ConnectionPath
                }
            }
        }
     }

    CellularMonitor {
        id: cellularMonitor

        onGsmConnectionAdded:{
            currentConnectionPath = connectionPath
            configuration.modemConnectionPath = connectionPath
        }
        onGsmDeviceAdded:{
            configuration.modemDevicePath = devicePath
        }
    }

    OfonoManager {
        id: ofonoManager
        onAvailableChanged: {
        }
    }

    OfonoSimManager {
        id: ofonoSimManager

        modemPath: curentModemPath

        onSubscriberIdentityChanged:{
            currentContenxt = "/ril_0/context1/"+imsi
            if(listView.count > 0){
                if(currentConnectionPath != ""){
                    cellularMonitor.removeConnection(currentConnectionPath)
                    timer.running = false
                    timer.running = true
                }else{
                    if(initConnectionPath != ""){
                        cellularMonitor.removeConnection(currentConnectionPath)
                        timer.running = false
                        timer.running = true
                    }
                }
            }
        }
    }

     OfonoSimListModel {
        id: simListModel

        onSimAdded:{
            tryCount = 0
            ofonoModem.online = true

            if(listView.count > 0){
                cellularMonitor.removeConnection(initConnectionPath)
                configuration.modemConnectionPath = ""
                currentConnectionPath = ""
            }

            timer.running = true
        }

        onSimRemoved:{
            if(currentConnectionPath != ""){
                cellularMonitor.removeConnection(currentConnectionPath)
            }else{
                if(initConnectionPath != ""){
                    cellularMonitor.removeConnection(initConnectionPath)
                }
            }
            currentConnectionPath = ""
            configuration.modemConnectionPath = ""
            configuration.modemDevicePath = ""
        }
    }

    OfonoModem {
        id: ofonoModem

        modemPath: curentModemPath

        onOnlineChanged: {
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

        onScanFinished:{
            isScanFinished = true
        }
        onScanError:{
            isScanFinished = true
        }

    }

    OfonoContextConnection{
        id:ofonoContextConnection

        contextPath: connectionManager.contexts[0]
    }

    OfonoConnMan {
        id:connectionManager

        modemPath: curentModemPath
        onRoamingAllowedChanged:{
        }
    }

    PlasmaNM.Handler {
        id: handler
    }

    Component.onCompleted:{
        currentConnectionPath = configuration.modemConnectionPath
        tryCount = 0 
    }
    
    
    Timer {
        id: timer

        interval: 2000
        repeat: false
        running: false

        onTriggered: {
            /*if(listView.count > 0 ){
                return;
            }*/
            if(!ofonoModem.online){
                ofonoModem.online = true
            }
            if(ofonoSimManager.mobileCountryCode != "" && ofonoSimManager.mobileNetworkCode != ""){
                var type = cellularMonitor.getAccessPointName(ofonoSimManager.mobileCountryCode,ofonoSimManager.mobileNetworkCode)
                cellularMonitor.addConnection(currentContenxt,"","",type)
                if(ofonoSimManager.mobileCountryCode == "460" && ofonoSimManager.mobileNetworkCode == "11"){
                    ofonoContextConnection.username = "vnet@mycdma.cn"
                    ofonoContextConnection.password = "vnet.mobi"
                }   
                ofonoContextConnection.accessPointName = type
                ofonoContextConnection.name = "Internet"
                ofonoContextConnection.type = "internet"
            }else{
                if(tryCount == 15){
                  timer.running = false  
                   cellularMonitor.addConnection(currentContenxt,"","","")
                    ofonoContextConnection.accessPointName = ""
                    ofonoContextConnection.name = "Internet"
                    ofonoContextConnection.type = "internet"
                }else{
                    timer.running = true
                    tryCount ++;
                }
                
            }
            
        }
    }
    
}
