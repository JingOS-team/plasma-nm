/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

#ifndef PLASMA_NM_GSM_PROXY_MODEL_H
#define PLASMA_NM_GSM_PROXY_MODEL_H

#include "networkmodelitem.h"

#include <QSortFilterProxyModel>
#include <NetworkManagerQt/ActiveConnection>

class Q_DECL_EXPORT GsmProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit GsmProxyModel(QObject *parent = nullptr);
    ~GsmProxyModel() override;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
};

#endif // PLASMA_NM_EDITOR_PROXY_MODEL_H
