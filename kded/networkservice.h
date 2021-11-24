/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
#pragma once

#include <NetworkManagerQt/Device>
#include "handler.h"
#include "networkstatus.h"
#include "models/editorproxymodel.h"
#include "models/kcmidentitymodel.h"
#include "declarative/connectionicon.h"
#include "declarative/enabledconnections.h"

class Q_DECL_EXPORT NetworkService : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.plasmanetworkservice")

public:
    explicit NetworkService(QObject * parent);
    ~NetworkService() override;

    Q_SCRIPTABLE bool isWifiEnabled();
    Q_SCRIPTABLE QString connectionStatus();
    Q_SCRIPTABLE QString currentWifiName();
    Q_SCRIPTABLE QString currentConnectionIcon();

    void requestWifiScan();
    void requestBlueToothScan();

public Q_SLOTS:
    void onWifiNameChanged();
    void onWifiEnableChanged();
    void onNetworkStatusChanged();
    void onConnectionIconChanged();


private:
    KcmIdentityModel* m_pIdentModel;
    std::shared_ptr<Handler> m_handler;
    std::shared_ptr<NetworkStatus> m_networkStatus;

    std::shared_ptr<ConnectionIcon> m_connectionIcon;
    std::shared_ptr<EditorProxyModel> m_proxyWifiModel;
    std::shared_ptr<EnabledConnections> m_enabledConnections;
};
