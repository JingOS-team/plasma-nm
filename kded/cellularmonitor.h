/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */
#ifndef CELLULARMONITOR_H
#define CELLULARMONITOR_H


#include <ModemManagerQt/manager.h>
#include <ModemManagerQt/modem.h>
#include "handler.h"

class CellularMonitor : public QObject
{
    Q_OBJECT
public:
    CellularMonitor(QObject *parent = nullptr);
    virtual ~CellularMonitor() override;
    Q_INVOKABLE void activateConnection(const QString &connection, const QString &device, const QString &specificParameter);
    Q_INVOKABLE void deactivateConnection(const QString &connection, const QString &device);
    Q_INVOKABLE void addConnection(const QString name, const QString mcc, const QString mnc, const QString apn);
    Q_INVOKABLE void removeConnection(const QString & connection);
    Q_INVOKABLE QString getAccessPointName(const QString mcc, const QString mnc);

Q_SIGNALS:
    void gsmConnectionAdded(QString connectionPath) const;
    void gsmDeviceAdded(const QString &devicePath);

public Q_SLOTS:
    void modemAdded(const QString &modemUni);
    void modemRemoved(const QString &udi);
    void onConnectionAdded(const QString &connection);
    void onConnectionRemoved(const QString &connection);

private:
    ModemManager::Modem::Ptr m_modem;
    Handler *m_handler;
};

#endif // CELLULARMONITOR_H
