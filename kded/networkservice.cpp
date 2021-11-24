/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
#include "networkservice.h"

NetworkService::NetworkService(QObject* parent)
    : QObject(parent)
{
    m_handler           = std::make_shared<Handler>();
    m_networkStatus     = std::make_shared<NetworkStatus>();
    m_proxyWifiModel    = std::make_shared<EditorProxyModel>();
    m_connectionIcon    = std::make_shared<ConnectionIcon>();
    m_enabledConnections = std::make_shared<EnabledConnections>();

    m_pIdentModel = new KcmIdentityModel();
    m_proxyWifiModel->setSourceModel(m_pIdentModel);

    QDBusConnection::sessionBus().registerService("org.kde.plasmanetworkservice");
    QDBusConnection::sessionBus().registerObject("/org/kde/plasmanetworkservice", this, QDBusConnection::ExportScriptableContents);


    connect(m_networkStatus.get(),&NetworkStatus::networkStatusChanged,this,&NetworkService::onNetworkStatusChanged);
    connect(m_proxyWifiModel.get(),&EditorProxyModel::connectedNameChanged,this,&NetworkService::onWifiNameChanged);
    connect(m_enabledConnections.get(),&EnabledConnections::wirelessEnabled,this,&NetworkService::onWifiEnableChanged);
    connect(m_connectionIcon.get(),&ConnectionIcon::connectionIconChanged,this,&NetworkService::onConnectionIconChanged);

}

NetworkService::~NetworkService()
{
    if(m_pIdentModel)
    {
        delete m_pIdentModel;
    }
}



void NetworkService::requestWifiScan()
{
    m_handler->requestScan();
}


void NetworkService::requestBlueToothScan()
{

}


void NetworkService::onWifiNameChanged()
{
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/PlasmaShell"),
                                                  QStringLiteral("org.kde.PlasmaShell"),
                                                  QStringLiteral("wifiNameChanged"));
    msg << m_proxyWifiModel->currentConnectedName();
    QDBusConnection::sessionBus().send(msg);
}

void NetworkService::onWifiEnableChanged()
{
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/PlasmaShell"),
                                                  QStringLiteral("org.kde.PlasmaShell"),
                                                  QStringLiteral("wifiEnableChanged"));
    msg << m_enabledConnections->isWirelessEnabled();
    QDBusConnection::sessionBus().send(msg);
}

void NetworkService::onConnectionIconChanged()
{
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/PlasmaShell"),
                                                  QStringLiteral("org.kde.PlasmaShell"),
                                                  QStringLiteral("connectionIconChanged"));
    msg << m_connectionIcon->connectionIcon();
    QDBusConnection::sessionBus().send(msg);
}

void NetworkService::onNetworkStatusChanged()
{
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/PlasmaShell"),
                                                  QStringLiteral("org.kde.PlasmaShell"),
                                                  QStringLiteral("networkStatusChanged"));
    msg << m_networkStatus->networkStatus();
    QDBusConnection::sessionBus().send(msg);
}

bool NetworkService::isWifiEnabled()
{
    return m_enabledConnections->isWirelessEnabled();
}

QString NetworkService::currentWifiName()
{
    return m_proxyWifiModel->currentConnectedName();
}

QString NetworkService::currentConnectionIcon()
{
    return m_connectionIcon->connectionIcon();
}

QString NetworkService::connectionStatus()
{
    return m_networkStatus->networkStatus();
}
