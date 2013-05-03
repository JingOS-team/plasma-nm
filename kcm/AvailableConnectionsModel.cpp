/***************************************************************************
 *   Copyright (C) 2013 by Daniel Nicoletti <dantti12@gmail.com>           *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; see the file COPYING. If not, write to       *
 *   the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,  *
 *   Boston, MA 02110-1301, USA.                                           *
 ***************************************************************************/

#include "AvailableConnectionsModel.h"

#include <NetworkManagerQt/settings/connection.h>
#include <NetworkManagerQt/activeconnection.h>
#include <NetworkManagerQt/device.h>
#include <NetworkManagerQt/settings.h>
#include <NetworkManagerQt/settings/802-11-wireless.h>
#include <NetworkManagerQt/wirelessdevice.h>
#include <NetworkManagerQt/wimaxdevice.h>
#include <NetworkManagerQt/wimaxnsp.h>

#include <KDebug>

using namespace NetworkManager;

AvailableConnectionsModel::AvailableConnectionsModel(QObject *parent) :
    QStandardItemModel(parent)
{
}

void AvailableConnectionsModel::setDevice(const NetworkManager::Device::Ptr &device)
{
    if (m_device && m_device->uni() == device->uni()) {
        return;
    } else if (m_device) {
        m_device->disconnect(this);
    }
    m_device = device;
    removeRows(0, rowCount());

    if (device->type() == NetworkManager::Device::Wifi) {
        NetworkManager::WirelessDevice::Ptr wifi = device.dynamicCast<NetworkManager::WirelessDevice>();
        wifi->requestScan();
        connect(device.data(), SIGNAL(availableConnectionChanged()), SLOT(availableConnectionChanged()));
        foreach (const Settings::Connection::Ptr &connection, device->availableConnections()) {
            addConnection(connection);
        }

        connect(wifi.data(), SIGNAL(networkAppeared(QString)), SLOT(networkAppeared(QString)));
        connect(wifi.data(), SIGNAL(networkDisappeared(QString)), SLOT(networkDisappeared(QString)));
        foreach (const NetworkManager::WirelessNetwork::Ptr &network, wifi->networks()) {
            addNetwork(network);
        }
    } else if (device->type() == NetworkManager::Device::Wimax) {
        NetworkManager::WimaxDevice::Ptr wiMax = device.dynamicCast<NetworkManager::WimaxDevice>();
        connect(device.data(), SIGNAL(availableConnectionChanged()), SLOT(availableConnectionChanged()));
        foreach (const Settings::Connection::Ptr &connection, device->availableConnections()) {
            addConnection(connection);
        }

        connect(wiMax.data(), SIGNAL(nspAppeared(QString)), SLOT(nspAppeared(QString)));
        connect(wiMax.data(), SIGNAL(nspDisappeared(QString)), SLOT(nspDisappeared(QString)));
        foreach (const QString &nsp, wiMax->nsps()) {
            NetworkManager::WimaxNsp::Ptr nspPtr = wiMax->findNsp(nsp);
            if (nspPtr) {
                addNspNetwork(nspPtr);
            }
        }
    } else {
        connect(device.data(), SIGNAL(availableConnectionChanged()), SLOT(availableConnectionChanged()));
        foreach (const Settings::Connection::Ptr &connection, device->availableConnections()) {
            addConnection(connection);
        }
    }
}

void AvailableConnectionsModel::availableConnectionChanged()
{
    Device *device = qobject_cast<NetworkManager::Device*>(sender());
    if (device) {
        Settings::Connection::List connections = device->availableConnections();
        foreach (const Settings::Connection::Ptr &connection, connections) {
            qWarning() << "Connection" << connection->name();
            if (!findConnectionItem(connection->path())) {
                qWarning() << "New connection" << connection->name();
                addConnection(connection);
            }
        }

        int i = 0;
        while (i < rowCount()) {
            Kind kind = static_cast<Kind>(item(i)->data(RoleKind).toUInt());
            if (kind == Connection) {
                bool found = false;
                QString path = item(i)->data(RoleConectionPath).toString();
                foreach (const Settings::Connection::Ptr &connection, connections) {
                    if (connection->path() == path) {
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    qWarning() << "Remove connection" << path;
                    removeRow(i);
                    continue;
                }
            }
            ++i;
        }
    }
}

void AvailableConnectionsModel::connectionAdded(const QString &path)
{
    Settings::Connection::Ptr connection = Settings::findConnection(path);
    if (connection) {
        addConnection(connection);
    }
}

void AvailableConnectionsModel::connectionRemoved(const QString &path)
{
    QStandardItem *stdItem = findConnectionItem(path);
    if (stdItem) {
        removeRow(stdItem->row());
    }
}

void AvailableConnectionsModel::addConnection(const NetworkManager::Settings::Connection::Ptr &connection)
{
    QStandardItem *stdItem = findConnectionItem(connection->path());
    if (stdItem) {
        return;
    }

    stdItem = new QStandardItem;
    stdItem->setData(Connection, RoleKind);
    stdItem->setData(connection->path(), RoleConectionPath);
    stdItem->setText(connection->name());

    Settings::ConnectionSettings::Ptr settings = connection->settings();
    if (settings->connectionType() == Settings::ConnectionSettings::Wireless) {
        Settings::WirelessSetting::Ptr wirelessSetting;
        wirelessSetting = settings->setting(Settings::Setting::Wireless).dynamicCast<Settings::WirelessSetting>();
        stdItem->setData(wirelessSetting->ssid(), RoleNetworkID);
        stdItem->setData(wirelessSetting->macAddress(), RoleMacAddress);
        stdItem->setText(wirelessSetting->ssid());
    }

    appendRow(stdItem);
}

void AvailableConnectionsModel::networkAppeared(const QString &ssid)
{
    NetworkManager::WirelessDevice::Ptr wifi = m_device.dynamicCast<NetworkManager::WirelessDevice>();
    if (wifi) {
        WirelessNetwork::Ptr network = wifi->findNetwork(ssid);
        addNetwork(network);
    }
}

void AvailableConnectionsModel::networkDisappeared(const QString &ssid)
{
    QStandardItem *stdItem = findNetworkItem(ssid);
    if (stdItem) {
        removeRow(stdItem->row());
    }
}

void AvailableConnectionsModel::addNetwork(const WirelessNetwork::Ptr &network)
{
    QStandardItem *stdItem = findNetworkItem(network->ssid());
    connect(network.data(), SIGNAL(signalStrengthChanged(int)), SLOT(signalStrengthChanged(int)), Qt::UniqueConnection);
    if (!stdItem) {
        stdItem = new QStandardItem;
        stdItem->setData(network->ssid(), RoleNetworkID);
        stdItem->setData(Network, RoleKind);
        stdItem->setText(network->ssid());
        appendRow(stdItem);
    } else {
        stdItem->setData(Network | Connection, RoleKind);
    }
    bool isSecure = network->referenceAccessPoint()->capabilities() & AccessPoint::Privacy;
    stdItem->setData(isSecure, RoleSecurity);
    stdItem->setData(network->signalStrength(), RoleSignalStrength);
}

void AvailableConnectionsModel::signalStrengthChanged(int strength)
{
    WirelessNetwork *network = qobject_cast<WirelessNetwork*>(sender());
    QStandardItem *stdItem = findNetworkItem(network->ssid());
    if (stdItem) {
        stdItem->setData(strength, RoleSignalStrength);
    }
}

void AvailableConnectionsModel::nspAppeared(const QString &uni)
{
    NetworkManager::WimaxDevice::Ptr wimax = m_device.dynamicCast<NetworkManager::WimaxDevice>();
    if (wimax) {
        WimaxNsp::Ptr nsp = wimax->findNsp(uni);
        addNspNetwork(nsp);
    }
}

void AvailableConnectionsModel::nspDisappeared(const QString &name)
{
    QStandardItem *stdItem = findNetworkItem(name);
    if (stdItem) {
        removeRow(stdItem->row());
    }
}

void AvailableConnectionsModel::addNspNetwork(const WimaxNsp::Ptr &nsp)
{
    QStandardItem *stdItem = findNetworkItem(nsp->name());
    connect(nsp.data(), SIGNAL(signalQualityChanged(uint)), SLOT(signalQualityChanged(int)), Qt::UniqueConnection);
    if (!stdItem) {
        stdItem = new QStandardItem;
        stdItem->setData(nsp->name(), RoleNetworkID);
        stdItem->setData(Network, RoleKind);
        stdItem->setText(nsp->name());
        appendRow(stdItem);
    } else {
        stdItem->setData(Network | Connection, RoleKind);
    }
    stdItem->setData(true, RoleSecurity);
    stdItem->setData(nsp->signalQuality(), RoleSignalStrength);
}

void AvailableConnectionsModel::signalQualityChanged(uint quality)
{
    WimaxNsp *nsp = qobject_cast<WimaxNsp*>(sender());
    QStandardItem *stdItem = findNetworkItem(nsp->name());
    if (stdItem) {
        stdItem->setData(quality, RoleSignalStrength);
    }
}

QStandardItem *AvailableConnectionsModel::findConnectionItem(const QString &path)
{
    for (int i = 0; i < rowCount(); ++i) {
        QStandardItem *stdItem = item(i);
        if (stdItem->data(RoleKind).toUInt() & Connection &&
                stdItem->data(RoleConectionPath).toString() == path) {
            return stdItem;
        }
    }

    return 0;
}

QStandardItem *AvailableConnectionsModel::findNetworkItem(const QString &id)
{
    for (int i = 0; i < rowCount(); ++i) {
        QStandardItem *stdItem = item(i);
        if (stdItem->data(RoleNetworkID).toString() == id) {
            return stdItem;
        }
    }

    return 0;
}
