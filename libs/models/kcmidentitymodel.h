/*
    Copyright 2016-2018 Jan Grulich <jgrulich@redhat.com>
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

#ifndef PLASMA_NM_KCM_IDENTITY_MODEL_H
#define PLASMA_NM_KCM_IDENTITY_MODEL_H

#include <QIdentityProxyModel>
#include <QModelIndex>

class Q_DECL_EXPORT KcmIdentityModel : public QIdentityProxyModel
{
Q_OBJECT

public:
    explicit KcmIdentityModel(QObject *parent = nullptr);
    ~KcmIdentityModel() override;

    enum KcmItemRole {
        KcmConnectionIconRole = Qt::UserRole + 100,
        KcmConnectionTypeRole,
        KcmVpnConnectionExportable,
        KcmConnectionStateRole
    };

    QHash< int, QByteArray > roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;

    QModelIndex mapToSource(const QModelIndex &proxyIndex) const override;
    int rowCount(const QModelIndex &parent) const override;
};

#endif // PLASMA_NM_KCM_IDENTITY_MODEL_H
