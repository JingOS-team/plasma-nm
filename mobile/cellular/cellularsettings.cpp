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

#include "cellularsettings.h"

#include <KPluginFactory>
#include <KLocalizedString>
#include <KAboutData>

#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/ModemDevice>

#include <KLocalizedString>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Setting>
#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/GsmSetting>


K_PLUGIN_CLASS_WITH_JSON(CellularSettings, "metadata.json")

CellularSettings::CellularSettings(QObject* parent, const QVariantList& args) 
    : KQuickAddons::ConfigModule(parent, args)
    , m_handler(new Handler(this))
{
    KLocalizedString::setApplicationDomain("kcm_cellular");

    KAboutData* about = new KAboutData("kcm_cellular", i18n("Cellular"),
                                       "0.1", QString(), KAboutLicense::LGPL);
    about->addAuthor(i18n("Tobias Fella"), QString(), "fella@posteo.de");
    setAboutData(about);

    if(WITH_MODEMMANAGER_SUPPORT == 1){
    }else{
    }

    connect(ModemManager::notifier(), &ModemManager::Notifier::modemAdded, this, &CellularSettings::modemAdded);
    connect(ModemManager::notifier(), &ModemManager::Notifier::modemRemoved, this, &CellularSettings::modemRemoved);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::deviceAdded, this, &CellularSettings::deviceAdded, Qt::UniqueConnection);
    initializeModemDevice();
}
void CellularSettings::deviceAdded(const QString &device)
{
}

CellularSettings::~CellularSettings()
{
}

QString CellularSettings::getApn(const QString connectionPath)
{
    QString m_apn = "";
    NetworkManager::Connection::Ptr connection = NetworkManager::findConnection(connectionPath);
    if(connection){
        NetworkManager::ConnectionSettings::Ptr connectionSettings = connection->settings();
         NetworkManager::GsmSetting::Ptr gsmSetting = connectionSettings->setting(NetworkManager::Setting::Gsm).staticCast<NetworkManager::GsmSetting>();
        m_apn = gsmSetting->apn();
    }
    return m_apn;
}

void CellularSettings::initializeModemDevice()
{
    ModemManager::ModemDevice::List list = ModemManager::modemDevices();
    if (list.length() == 0){
    }
    ModemManager::ModemDevice::Ptr device;
    foreach (const ModemManager::ModemDevice::Ptr &md, list) {
        ModemManager::Modem::Ptr m = md->modemInterface();
        m_modem = m;
        if (!m->isEnabled())
            continue;
        // TODO powerState ???
        if (m->state() <= MM_MODEM_STATE_REGISTERED)
            continue; // needs inspection
        device = md;
        if (device) {
              qDebug() << device->uni() << device->modemInterface()->uni();
        }
    }


    for (const NetworkManager::Device::Ptr &dev : NetworkManager::networkInterfaces()) {
        if (!dev->managed()) {
            continue;
        }
        if (dev->type() == NetworkManager::Device::Modem) {
            NetworkManager::ModemDevice::Ptr modemDev = dev.objectCast<NetworkManager::ModemDevice>();
            ModemManager::ModemDevice::Ptr modem = ModemManager::findModemDevice(modemDev->udi());
            if (modem) {
                ModemManager::Modem::Ptr modemNetwork = modem->interface(ModemManager::ModemDevice::ModemInterface).objectCast<ModemManager::Modem>();

                if (modemNetwork) {
                }
            }else{
            }
        }
    }
}

// void CellularSettings::getSupportedModes()
// {
//     // ModemManager::SupportedModesType supportedModes();
// }

void CellularSettings::modemAdded(const QString &modemUni)
{
    // NetworkManager::Connection::Ptr connection = NetworkManager::findConnection(modemUni);
    // NetworkManager::GsmSetting::Ptr gsmSetting = connection->settings()->setting(NetworkManager::Setting::Gsm).staticCast<NetworkManager::GsmSetting>();
}

void CellularSettings::modemRemoved(const QString &udi)
{
}

void CellularSettings::addConnection(const QString name, const QString mcc, const QString mnc, const QString apn)
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

void CellularSettings::activateConnection(const QString& connection, const QString& device, const QString& specificObject)
{
    qDebug()<<"activateConnection"<<" connection "<<connection<<" device "<<device<<" specificObject "<<specificObject;
    m_handler->activateConnection(connection,device,specificObject);
}

void CellularSettings::deactivateConnection(const QString& connection, const QString& device)
{
     qDebug()<<"deactivateConnection"<<" connection "<<connection<<" device "<<device;
     m_handler->deactivateConnection(connection,device);
}

void CellularSettings::removeConnection(const QString& connection)
{
    qDebug()<<"removeConnection "<<connection;
    m_handler->removeConnection(connection);
}

QString CellularSettings::getAccessPointName(const QString mcc, const QString mnc)
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
    qDebug()<<"getAccessPointName mcc:"<<mcc<<" mnc:"<<mnc << "type: "<<type;
    return type;
}


#include "cellularsettings.moc"
