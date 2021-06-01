/*
    Copyright 2013-2018 Jan Grulich <jgrulich@redhat.com>
    Copyright 2021      Wang Rui <wangrui@jingos.com>

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

#include "vpnproxymodel.h"
#include "uiutils.h"
#include <NetworkManagerQt/ActiveConnection>

VpnProxyModel::VpnProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    sort(0, Qt::DescendingOrder);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::activeConnectionAdded, this, QOverload<const QString&>::of(&VpnProxyModel::addActiveConnection));
}

VpnProxyModel::~VpnProxyModel()
{
}

bool VpnProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    const QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    // slaves are always filtered-out
    const bool isSlave = sourceModel()->data(index, NetworkModel::SlaveRole).toBool();
    const bool isDuplicate = sourceModel()->data(index, NetworkModel::DuplicateRole).toBool();
    if (isSlave || isDuplicate) {
        return false;
    }

    const NetworkManager::ConnectionSettings::ConnectionType type = (NetworkManager::ConnectionSettings::ConnectionType) sourceModel()->data(index, NetworkModel::TypeRole).toUInt();
    if(type == NetworkManager::ConnectionSettings::Vpn && sourceModel()->data(index, NetworkModel::ConnectionStateRole).toUInt() == NetworkManager::ActiveConnection::Activated){
        QString m_name = sourceModel()->data(index, NetworkModel::NameRole).toString();
        if(m_connectedName.isEmpty() | m_name != m_connectedName){
            m_connectedName = m_name;
            Q_EMIT connectedNameChanged(m_connectedName);
        }
    }
    
    if (type != NetworkManager::ConnectionSettings::Vpn) {
        return false;
    }

    const QString pattern = filterRegExp().pattern();
    if (!pattern.isEmpty()) {  // filtering on data (connection name), wildcard-only
        QString data = sourceModel()->data(index, Qt::DisplayRole).toString();
        if (data.isEmpty()) {
            data = sourceModel()->data(index, NetworkModel::NameRole).toString();
        }
        return data.contains(pattern, Qt::CaseInsensitive);
    }

    return true;
}

bool VpnProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    const QDateTime leftDate = sourceModel()->data(left, NetworkModel::TimeStampRole).toDateTime();
    const QDateTime rightDate = sourceModel()->data(right, NetworkModel::TimeStampRole).toDateTime();

    if (leftDate > rightDate) {
        return false;
    } else if (leftDate < rightDate) {
        return true;
    }
    return true;
}

void VpnProxyModel::setVpnConnectedName(const QString connectedName)
{
    m_connectedName = connectedName;
    Q_EMIT connectedNameChanged(m_connectedName);
}

void VpnProxyModel::addActiveConnection(const QString &path)
{
    NetworkManager::ActiveConnection::Ptr ac = NetworkManager::findActiveConnection(path);
    if (ac && ac->isValid()) {
        addActiveConnection(ac);
    }
}

void VpnProxyModel::addActiveConnection(const NetworkManager::ActiveConnection::Ptr &ac)
{
    if (ac->vpn()) {
        NetworkManager::VpnConnection::Ptr vpnConnection = ac.objectCast<NetworkManager::VpnConnection>();
        connect(vpnConnection.data(), &NetworkManager::VpnConnection::stateChanged, this, &VpnProxyModel::onVpnConnectionStateChanged);
    }
}

void VpnProxyModel::onVpnConnectionStateChanged(NetworkManager::VpnConnection::State state, NetworkManager::VpnConnection::StateChangeReason reason)
{
    if (state == NetworkManager::VpnConnection::Failed | state == NetworkManager::VpnConnection::Disconnected) {
        setVpnConnectedName("");
    }
}
