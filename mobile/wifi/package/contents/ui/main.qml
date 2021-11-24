/*
    Copyright 2016 Jan Grulich <jgrulich@redhat.com>
    Copyright 2021 Wang Rui <wangrui@jingos.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0

Item {
    id: wifi_root

    property int rootWidth: parent.width
    property int rootHeigh: parent.height
    property real appScaleSize: JDisplay.dp(1.0)
    property real appFontSize: JDisplay.sp(1.0)
    property int defaultFontSize: theme.defaultFont.pointSize + 2
    property var currentModel
    property int currentIndex: 0
    property bool apletType: true
    property var currenProxyModel: apletType ? appletProxyModel : editorProxyModel
    property bool isRefreshing: false
    property var defaultIpv4Method: "Automatic"
    property var defaultDnsMethod: "Automatic"
    property PlasmaNM.NetworkModel networkModel: null
    property var currentMethod: currentModel.Method
    property var currentIpAddress: currentModel.IpAddress
    property var currentSubnetMask:currentModel.SubnetMask

    property var majorForeground: Kirigami.JTheme.majorForeground
    property var minorForeground: Kirigami.JTheme.minorForeground
    property var settingMinorBackground: Kirigami.JTheme.settingMinorBackground
    property var cardBackground: Kirigami.JTheme.cardBackground
    property var highlightColor: Kirigami.JTheme.highlightColor
    property var dividerForeground: Kirigami.JTheme.dividerForeground
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"


    signal selectIpv4Method(var displayName)
    signal selectDnsMethod(var displayName)

    width: parent.width
    height: parent.height

    onSelectIpv4Method: {
        defaultIpv4Method = displayName
    }

    onSelectDnsMethod: {
        defaultDnsMethod = displayName
    }

    onVisibleChanged: {
        if(visible == true)
        {
            scanTimer.triggered()
            scanTimer.restart()
        }
        else{
            scanTimer.stop()
        }

    }

    Connections {
        target: kcm

        onCurrentIndexChanged:{
            if(index == 1){
                popAllView();
            }
        }
    }

    Connections {
        target: parent

        onPause: {
            scanTimer.stop()
        }

        onResume: {
            scanTimer.triggered()
            scanTimer.restart()
        }
    }
    
    PlasmaNM.KcmIdentityModel {
        id: connectionModel
    }

    PlasmaNM.EditorProxyModel {
        id: editorProxyModel

        sourceModel: connectionModel
    }

    PlasmaNM.Handler {
        id: handler

        onPasswordErrorChanged:{
            console.log("onPasswordErrorChanged,name "+name);
            errorDialog.visible = true
            errorDialog.text = i18n("Incorrect password for \"%1\"",name)

            handler.removeConnection(connectionPath)
            appletProxyModel.sourceModel = connectionModel
        }

        onReplyFinishedError:{
            console.log("onReplyFinishedError,type:"+type+" name:"+name+" errorMsg:"+errorMsg)
            if(type == "RemoveConnection"){
                errorDialog.title = i18n("Failed to delete")
                errorDialog.text = i18n("Forget the failure, please make sure the network module is normal.")
                errorDialog.visible = true
            } else if (type == "AddAndActivateConnection" | type == "ActivateConnection"){
                errorDialog.title = i18n("Failed to join")
                errorDialog.text = i18n("Join failed, please make sure the network equipment and related configuration are normal.")
                errorDialog.visible = true
            } else if (type == "UpdateConnection"){
                errorDialog.title = i18n("Save failed")
                errorDialog.text = i18n("Please make sure the configuration information is correct.")
                errorDialog.visible = true
            }

            
        }
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }


    PlasmaNM.AppletProxyModel {
        id: appletProxyModel

        sourceModel: connectionModel
    }

    Component.onCompleted: {
        kcm.setHandler(handler);
        currenProxyModel.sourceModel.sourceModel.isAllowUpdate = true
    }

    StackView {
        id: stack

        anchors.fill: parent

        Component.onCompleted: {
            stack.push(home_view)
        }
    }

    function gotoConnectedItemPage(json) {
        stack.push(connectedItem_view, json)
    }

    function gotoPage(name) {
        if (name == "home_view") {
            stack.push(home_view)
        } else if (name == "connectedItem_view") {
            stack.push(connectedItem_view)
        } else if (name == "dns_view") {
            stack.push(dns_view)
        } else if (name == "ipv4_view") {
            stack.push(ipv4_view)
        } else if (name == "otherNetwork_view") {
            stack.push(otherNetwork_view)
        }
    }

    function popView() {
        stack.pop()
    }

    function popAllView() {
        while (stack.depth > 1) {
            stack.pop()
        }
    }

    Component {
        id: home_view

        Home {}
    }

    Component {
        id: connectedItem_view

        ConnectedItem {}
    }

    Component {
        id: dns_view

        DNS {}
    }

    Component {
        id: ipv4_view

        IPV4 {}
    }

    Component {
        id: otherNetwork_view

        OtherNetwork {}
    }

    Kirigami.JDialog {
        id: errorDialog
        
        title: i18n("Failed to join")
        centerButtonText: i18n("OK")

        onCenterButtonClicked: {
            errorDialog.visible = false
        }
    }
    
    Kirigami.JDialog {
        id: passwordPop

        property var devicePath
        property var specificPath
        property var ssid

        title: i18n("Enter Password")
        inputEnable: true
        showPassword: true
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("OK")
        validator: RegExpValidator {regExp: /^[\u4e00-\u9fa5 -~]+$/ }

        onInputTextChanged:{
            if(inputText.length > 7 ){
                rightButtonEnable = true
            }else{
                rightButtonEnable = false
            }
            if(inputText.length > 32){
                passwordPop.inputText = inputText.substring(0,32)
            }
        }

        onRightButtonClicked: {

            if(passwordPop.inputText.length > 7){
                if (networkStatus.networkStatus == "Connecting") {
                handler.removeConnection(
                            editorProxyModel.currentConnectingdPath)
                }
                var findAccessPoint = currenProxyModel.sourceModel.sourceModel.getAccessPointBySsid(passwordPop.ssid,passwordPop.specificPath)
                
                handler.addAndActivateConnection(passwordPop.devicePath,
                                                findAccessPoint,
                                                passwordPop.inputText)
                passwordPop.visible = false
            }
        }
        
        onLeftButtonClicked: {
            passwordPop.inputText = ""
            passwordPop.visible = false
        }
    }

    Timer {
        id: scanTimer

        interval: 5000
        repeat: true
        running: !handler.isCanning

        onTriggered: {
            handler.requestScan()
            rotateTimer.start()
            isRefreshing = true
        }
    }

    Timer {
        id: rotateTimer

        interval: 2000
        repeat: false
        running: true

        onTriggered: {
            rotateTimer.stop()
            isRefreshing = false
        }
    }
}
