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

#ifndef PLASMA_NM_VPN_PROXY_MODEL_H
#define PLASMA_NM_VPN_PROXY_MODEL_H

#include "networkmodelitem.h"

#include <QSortFilterProxyModel>
#include <NetworkManagerQt/ActiveConnection>
#include <NetworkManagerQt/VpnSetting>
#include <NetworkManagerQt/VpnConnection>

class Q_DECL_EXPORT VpnProxyModel : public QSortFilterProxyModel
{
Q_OBJECT

    Q_PROPERTY(QAbstractItemModel * sourceModel READ sourceModel WRITE setSourceModel)
    Q_PROPERTY(QString vpnConnectedName READ vpnConnectedName  WRITE setVpnConnectedName NOTIFY connectedNameChanged);

public:
    explicit VpnProxyModel(QObject *parent = nullptr);
    ~VpnProxyModel() override;
    QString vpnConnectedName() const { return m_connectedName; };
    Q_INVOKABLE void setVpnConnectedName(const QString connectedName);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

Q_SIGNALS:
    void connectedNameChanged(QString name) const;

private Q_SLOTS:
    void addActiveConnection(const QString & path);
    void activeConnectionRemoved(const QString & path);
    void addActiveConnection(const NetworkManager::ActiveConnection::Ptr & ac);
    void onVpnConnectionStateChanged(NetworkManager::VpnConnection::State state, NetworkManager::VpnConnection::StateChangeReason reason); 

private:
    mutable QString m_connectedName = "";
};

#endif // PLASMA_NM_EDITOR_PROXY_MODEL_H
