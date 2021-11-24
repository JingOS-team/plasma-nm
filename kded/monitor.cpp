/*
    Copyright 2014 Jan Grulich <jgrulich@redhat.com>
    Copyright 2021 Liu Bangguo <liubangguo@jingos.com>

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

#include "monitor.h"

#include "qofono-qt5/qofonomodem.h"
#include "qofono-qt5/qofonomanager.h"

#include <KSharedConfig>
#include <KConfigGroup>

#include <QDBusConnection>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/AccessPoint>
#include <NetworkManagerQt/WiredDevice>
#include <NetworkManagerQt/WirelessDevice>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Setting>
#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/Utils>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/WiredSetting>
#include <NetworkManagerQt/WirelessSetting>
#include <NetworkManagerQt/ActiveConnection>
#include <NetworkManagerQt/Ipv4Setting>

Monitor::Monitor(QObject* parent)
    : QObject(parent)
{
#if WITH_MODEMMANAGER_SUPPORT
    m_modemMonitor = new ModemMonitor(this);
#endif
    m_bluetoothMonitor = new BluetoothMonitor(this);

    QDBusConnection::sessionBus().registerService("org.kde.plasmanetworkmanagement");
    QDBusConnection::sessionBus().registerObject("/org/kde/plasmanetworkmanagement", this, QDBusConnection::ExportScriptableContents);

    m_flightMode = readFlightModeFromFile();
    if(m_flightMode) enableFlightMode(m_flightMode);
}

Monitor::~Monitor()
{
    delete m_bluetoothMonitor;
#if WITH_MODEMMANAGER_SUPPORT
    delete m_modemMonitor;
#endif
}

bool Monitor::bluetoothConnectionExists(const QString &bdAddr, const QString &service)
{
    return m_bluetoothMonitor->bluetoothConnectionExists(bdAddr, service);
}

void Monitor::addBluetoothConnection(const QString &bdAddr, const QString &service, const QString &connectionName)
{
    m_bluetoothMonitor->addBluetoothConnection(bdAddr, service, connectionName);
}

#if WITH_MODEMMANAGER_SUPPORT
void Monitor::unlockModem(const QString& modem)
{
    qDebug() << "unlocking " << modem;
    m_modemMonitor->unlockModem(modem);
}
#endif


void Monitor::enableWireless(const bool enable)
{
    NetworkManager::setWirelessEnabled(enable);
}

void Monitor::enableBluetooth(const bool enable)
{
    m_bluetoothMonitor->appendEnable(enable);
}

void Monitor::enableFlightMode(const bool enable)
{
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/PlasmaShell"),
                                                  QStringLiteral("org.kde.PlasmaShell"),
                                                  QStringLiteral("flightModeChanged"));
    msg << enable;
    QDBusConnection::sessionBus().send(msg);


    QSharedPointer<QOfonoModem> ofonoModemPtr = QOfonoModem::instance(QOfonoManager::instance().data()->defaultModem());
    ofonoModemPtr.data()->setOnline(!enable);

    //写配置文件
    m_flightMode = enable;
    writeFlightModeToFile(m_flightMode);
}


void Monitor::writeFlightModeToFile(bool enable)
{
    KSharedConfigPtr profilesConfig = KSharedConfig::openConfig("jingnetworkprofilesrc", KConfig::SimpleConfig);
    // Let's start: AC profile before anything else
    KConfigGroup netstatusProfile(profilesConfig, "NetStatus");
    netstatusProfile.writeEntry< bool >("flightMode", enable);

    profilesConfig->sync();
}

bool Monitor::readFlightModeFromFile()
{
    KSharedConfigPtr profilesConfig = KSharedConfig::openConfig("jingnetworkprofilesrc", KConfig::SimpleConfig);
    // Let's start: AC profile before anything else
    KConfigGroup flightProfile(profilesConfig, "NetStatus");
    bool enable = flightProfile.readEntry< bool >("flightMode", false);
    return enable;
}
