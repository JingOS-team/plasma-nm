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


#ifndef CELLULARSETTINGS_H
#define CELLULARSETTINGS_H


#include <KQuickAddons/ConfigModule>
#include <ModemManagerQt/manager.h>
#include <ModemManagerQt/modem.h>
#include "handler.h"

class CellularSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT
public:
    CellularSettings(QObject *parent, const QVariantList &args);
    virtual ~CellularSettings() override;
    void initializeModemDevice();
    Q_INVOKABLE QString getApn(const QString connectionPath);
    Q_INVOKABLE void activateConnection(const QString &connection, const QString &device, const QString &specificParameter);
    Q_INVOKABLE void deactivateConnection(const QString &connection, const QString &device);
    Q_INVOKABLE void addConnection(const QString name, const QString mcc, const QString mnc, const QString apn);
    Q_INVOKABLE void removeConnection(const QString & connection);
    Q_INVOKABLE QString getAccessPointName(const QString mcc, const QString mnc);

public Q_SLOTS:
    void modemAdded(const QString &modemUni);
    void modemRemoved(const QString &udi);
    void deviceAdded(const QString &device);

private:
    ModemManager::Modem::Ptr m_modem;
    Handler *m_handler;
};

#endif // CELLULARSETTINGS_H
