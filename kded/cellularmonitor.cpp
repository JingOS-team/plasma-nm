/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
#include "cellularmonitor.h"

#include <KPluginFactory>
#include <KLocalizedString>
#include <KAboutData>

#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/ModemDevice>

#include <KLocalizedString>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/Device>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Setting>
#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/GsmSetting>


CellularMonitor::CellularMonitor(QObject* parent) 
    : QObject(parent)
    , m_handler(new Handler(this))
{
    connect(NetworkManager::settingsNotifier(), &NetworkManager::SettingsNotifier::connectionAdded, this, &CellularMonitor::onConnectionAdded, Qt::UniqueConnection);
    connect(NetworkManager::settingsNotifier(), &NetworkManager::SettingsNotifier::connectionRemoved, this, &CellularMonitor::onConnectionRemoved, Qt::UniqueConnection);
}

CellularMonitor::~CellularMonitor()
{
}

void CellularMonitor::modemAdded(const QString &modemUni)
{
}

void CellularMonitor::modemRemoved(const QString &udi)
{
}

void CellularMonitor::addConnection(const QString name, const QString mcc, const QString mnc, const QString apn)
{
    NetworkManager::ConnectionSettings::Ptr connectionSettings;
    connectionSettings = NetworkManager::ConnectionSettings::Ptr(new NetworkManager::ConnectionSettings(NetworkManager::ConnectionSettings::Gsm));
    connectionSettings->setId(name);
    connectionSettings->setUuid(NetworkManager::ConnectionSettings::createNewUuid());
    NMVariantMapMap csMapMap = connectionSettings->toMap();

    NetworkManager::GsmSetting::Ptr gsmSetting = connectionSettings->setting(NetworkManager::Setting::Gsm).staticCast<NetworkManager::GsmSetting>();
    gsmSetting->setApn(apn);
    QVariantMap gsmMap = gsmSetting->toMap();
    gsmSetting->setPasswordFlags(NetworkManager::Setting::NotRequired);
    gsmSetting->setPinFlags(NetworkManager::Setting::NotRequired);
    csMapMap.insert(NetworkManager::Setting::typeAsString(NetworkManager::Setting::Gsm), gsmMap);
    m_handler->addConnection(csMapMap);
}

void CellularMonitor::activateConnection(const QString& connection, const QString& device, const QString& specificObject)
{
     m_handler->activateConnection(connection,device,specificObject);
}

void CellularMonitor::deactivateConnection(const QString& connection, const QString& device)
{
    m_handler->deactivateConnection(connection,device);
}

void CellularMonitor::removeConnection(const QString& connection)
{
    m_handler->removeConnection(connection);
}

QString CellularMonitor::getAccessPointName(const QString mcc, const QString mnc)
{
    QString type = "";
    if(mcc == "460" && mnc == "00"){
        type = "cmnet";
    }else if(mcc == "460" && mnc == "01"){
        type = "3gnet";
    }else if(mcc == "460" && mnc == "02"){
        type = "cmnet";
    }else if(mcc == "460" && mnc == "11"){
        type = "ctnet";
    }
    return type;
}

void CellularMonitor::onConnectionAdded(const QString &connection)
{
    NetworkManager::Connection::Ptr newConnection = NetworkManager::findConnection(connection);
    if (newConnection) {
        NetworkManager::ConnectionSettings::Ptr connectionSettings = newConnection->settings();
        NetworkManager::GsmSetting::Ptr gsmSetting = connectionSettings->setting(NetworkManager::Setting::Gsm).staticCast<NetworkManager::GsmSetting>();
        if(gsmSetting){
            Q_EMIT gsmConnectionAdded(connection);
            for (const NetworkManager::Device::Ptr &dev : NetworkManager::networkInterfaces()) {
                    if(dev->type() == NetworkManager::Device::Modem){
                        Q_EMIT gsmDeviceAdded(dev->uni());
                }
            }
        }
    }
}

void CellularMonitor::onConnectionRemoved(const QString &connection)
{
}
