/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#include "gsmproxymodel.h"
#include "uiutils.h"
#include <NetworkManagerQt/ActiveConnection>

GsmProxyModel::GsmProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    sort(0, Qt::DescendingOrder);
}

GsmProxyModel::~GsmProxyModel()
{
}

bool GsmProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    const QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    // slaves are always filtered-out
    const bool isSlave = sourceModel()->data(index, NetworkModel::SlaveRole).toBool();
    const bool isDuplicate = sourceModel()->data(index, NetworkModel::DuplicateRole).toBool();
    if (isSlave || isDuplicate) {
        return false;
    }

    const NetworkManager::ConnectionSettings::ConnectionType type = (NetworkManager::ConnectionSettings::ConnectionType) sourceModel()->data(index, NetworkModel::TypeRole).toUInt();
    
    if (type != NetworkManager::ConnectionSettings::Gsm) {
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

bool GsmProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
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
