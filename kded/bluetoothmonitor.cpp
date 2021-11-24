/*
    Copyright 2011 Lamarque Souza <lamarque@kde.org>
    Copyright 2013 Lukas Tinkl <ltinkl@redhat.com>
    Copyright 2013-2014 Jan Grulich <jgrulich@redhat.com>
    Copyright 2015 David Rosca <nowrep@gmail.com>
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

#include "bluetoothmonitor.h"
#include "debug.h"

#include <KLocalizedString>
#include <KMessageBox>

#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/BluetoothSetting>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/Utils>

BluetoothMonitor::BluetoothMonitor(QObject * parent)
    : QObject(parent)
{
    m_isBusy = false;

    connect(this,&BluetoothMonitor::enableEnd,this,&BluetoothMonitor::checkEnableList);
}

BluetoothMonitor::~BluetoothMonitor()
{
}

bool BluetoothMonitor::bluetoothConnectionExists(const QString &bdAddr, const QString &service)
{
    if (bdAddr.isEmpty() || service.isEmpty()) {
        return false;
    }

    NetworkManager::BluetoothSetting::ProfileType profile;

    if (service == QLatin1String("dun")) {
        profile = NetworkManager::BluetoothSetting::Dun;
    } else if (service == QLatin1String("nap")) {
        profile = NetworkManager::BluetoothSetting::Panu;
    } else {
        return false;
    }

    for (const NetworkManager::Connection::Ptr &con : NetworkManager::listConnections()) {
        if (con && con->settings() && con->settings()->connectionType() == NetworkManager::ConnectionSettings::Bluetooth) {
            NetworkManager::BluetoothSetting::Ptr btSetting = con->settings()->setting(NetworkManager::Setting::Bluetooth).staticCast<NetworkManager::BluetoothSetting>();
            if (btSetting->profileType() == profile && btSetting->bluetoothAddress() == NetworkManager::macAddressFromString(bdAddr)) {
                return true;
            }
        }
    }

    return false;
}

void BluetoothMonitor::addBluetoothConnection(const QString &bdAddr, const QString &service, const QString &connectionName)
{
    qCDebug(PLASMA_NM) << "Adding BT connection:" << bdAddr << service;

    if (bdAddr.isEmpty() || service.isEmpty() || connectionName.isEmpty()) {
        return;
    }

    if (service != QLatin1String("dun") && service != QLatin1String("nap")) {
        KMessageBox::sorry(nullptr, i18n("Only 'dun' and 'nap' services are supported."));
        return;
    }

    qCDebug(PLASMA_NM) << "Bdaddr == " << bdAddr;

    if (bluetoothConnectionExists(bdAddr, service)) {
        return;
    }

    if (service == QLatin1String("nap")) {
        NetworkManager::ConnectionSettings connectionSettings(NetworkManager::ConnectionSettings::Bluetooth, NM_BT_CAPABILITY_NAP);
        connectionSettings.setUuid(NetworkManager::ConnectionSettings::createNewUuid());
        connectionSettings.setId(connectionName);
        NetworkManager::BluetoothSetting::Ptr btSetting = connectionSettings.setting(NetworkManager::Setting::Bluetooth).staticCast<NetworkManager::BluetoothSetting>();
        btSetting->setBluetoothAddress(NetworkManager::macAddressFromString(bdAddr));
        btSetting->setProfileType(NetworkManager::BluetoothSetting::Panu);
        btSetting->setInitialized(true);

        NetworkManager::addConnection(connectionSettings.toMap());
    }
#if WITH_MODEMMANAGER_SUPPORT
    else if (service == QLatin1String("dun")) {
        QPointer<MobileConnectionWizard> mobileConnectionWizard = new MobileConnectionWizard(NetworkManager::ConnectionSettings::Bluetooth);
        connect(mobileConnectionWizard.data(), &MobileConnectionWizard::accepted,
                [bdAddr, connectionName, mobileConnectionWizard, this] () {
                    if (mobileConnectionWizard->getError() == MobileProviders::Success) {
                        qCDebug(PLASMA_NM) << "Mobile broadband wizard finished:" << mobileConnectionWizard->type() << mobileConnectionWizard->args();
                        if (mobileConnectionWizard->args().count() == 2) { //GSM or CDMA
                            qCDebug(PLASMA_NM) << "Creating new DUN connection for BT device:" << bdAddr;

                            QVariantMap tmp = qdbus_cast<QVariantMap>(mobileConnectionWizard->args().value(1));
                            NetworkManager::ConnectionSettings connectionSettings(NetworkManager::ConnectionSettings::Bluetooth, NM_BT_CAPABILITY_DUN);
                            connectionSettings.setUuid(NetworkManager::ConnectionSettings::createNewUuid());
                            connectionSettings.setId(connectionName);
                            NetworkManager::BluetoothSetting::Ptr btSetting = connectionSettings.setting(NetworkManager::Setting::Bluetooth).staticCast<NetworkManager::BluetoothSetting>();
                            btSetting->setBluetoothAddress(NetworkManager::macAddressFromString(bdAddr));
                            btSetting->setProfileType(NetworkManager::BluetoothSetting::Dun);
                            btSetting->setInitialized(true);

                            if (mobileConnectionWizard->type() == NetworkManager::ConnectionSettings::Gsm) {
                                connectionSettings.setting(NetworkManager::Setting::Gsm)->fromMap(tmp);
                                connectionSettings.setting(NetworkManager::Setting::Gsm)->setInitialized(true);
                            } else if (mobileConnectionWizard->type() == NetworkManager::ConnectionSettings::Cdma) {
                                connectionSettings.setting(NetworkManager::Setting::Cdma)->fromMap(tmp);
                                connectionSettings.setting(NetworkManager::Setting::Cdma)->setInitialized(true);
                            }

                            qCDebug(PLASMA_NM) << "Adding DUN connection" << connectionSettings;

                            NetworkManager::addConnection(connectionSettings.toMap());
                        }
                    }
                });
        connect(mobileConnectionWizard.data(), &MobileConnectionWizard::finished,
                [mobileConnectionWizard] () {
                    if (mobileConnectionWizard) {
                        mobileConnectionWizard->deleteLater();
                    }
                });
        mobileConnectionWizard->setModal(true);
        mobileConnectionWizard->show();
    }
#endif
}

void BluetoothMonitor::appendEnable(const bool enable)
{
    m_enableList.append(enable);

    if(m_isBusy) return;
    bool tEnable = m_enableList.last();
    m_enableList.clear();
    startEnableBluetooth(tEnable);
}


template<typename T>
void makeDBusCall(const QDBusMessage &message, QObject *context, std::function<void(QDBusPendingReply<T>)> func)
{
    QDBusPendingReply<T> reply = QDBusConnection::systemBus().asyncCall(message);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, context);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, context, [func] (QDBusPendingCallWatcher *watcher) {
        const QDBusPendingReply<T> reply = *watcher;
        if (!reply.isValid()) {
            qCWarning(PLASMA_NM) << reply.error().message();
            return;
        }
        func(reply);
        watcher->deleteLater();
    });
}

void setEnabled(QString path, bool enabled)
{
    QDBusMessage message = QDBusMessage::createMethodCall("org.bluez", path, "org.freedesktop.DBus.Properties", "Set");
    QList<QVariant> arguments;
    arguments << QLatin1String("org.bluez.Adapter1");
    arguments << QLatin1String("Powered");
    arguments << QVariant::fromValue(QDBusVariant(QVariant(enabled)));
    message.setArguments(arguments);
    QDBusConnection::systemBus().asyncCall(message);
}


void BluetoothMonitor::startEnableBluetooth(bool enable)
{
    m_isBusy = true;

    const QDBusMessage getObjects = QDBusMessage::createMethodCall("org.bluez", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects");

    makeDBusCall<QMap<QDBusObjectPath, NMVariantMapMap>>(getObjects, this, [enable, this](const auto reply) {
        for (const QDBusObjectPath &path : reply.value().keys()) {
            const QString objPath = path.path();
            const QStringList interfaces = reply.value().value(path).keys();

            if (!interfaces.contains("org.bluez.Adapter1")) {
                continue;
            }

            setEnabled(objPath, enable);
            m_isBusy = false;
            emit this->enableEnd();
        }
    });
}


void BluetoothMonitor::checkEnableList()
{
    if(m_enableList.count()==0)
    {
        return;
    }

    bool enable = m_enableList.last();
    m_enableList.clear();
    startEnableBluetooth(enable);
}




