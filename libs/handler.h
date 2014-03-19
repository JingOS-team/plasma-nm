/*
    Copyright 2013 Jan Grulich <jgrulich@redhat.com>

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

#ifndef PLASMA_NM_HANDLER_H
#define PLASMA_NM_HANDLER_H

#include <NetworkManagerQt/Connection>

#include "plasmanm_export.h"
#include "config.h"

#if !WITH_MODEMMANAGER_SUPPORT
typedef QMap<QDBusObjectPath, NMVariantMapMap> NMDBusObjectVariantMapMap;
Q_DECLARE_METATYPE(NMDBusObjectVariantMapMap)
#endif

class PLASMA_NM_EXPORT Handler : public QObject
{
Q_OBJECT

public:
    explicit Handler(QObject* parent = 0);
    virtual ~Handler();

public Q_SLOTS:
    /**
     * Activates given connection
     * @connection - d-bus path of the connection you want to activate
     * @device - d-bus path of the device where the connection should be activated
     * @specificParameter - d-bus path of the specific object you want to use for this activation, i.e access point
     */
    void activateConnection(const QString & connection, const QString & device, const QString & specificParameter);
    /**
     * Adds and activates a new wireless connection
     * @device - d-bus path of the wireless device where the connection should be activated
     * @specificParameter - d-bus path of the accesspoint you want to connect to
     * @password - pre-filled password which should be used for the new wireless connection
     * @autoConnect - boolean value whether this connection should be activated automatically when it's available
     *
     * Works automatically for wireless connections with WEP/WPA security, for wireless connections with WPA/WPA
     * it will open the connection editor for advanced configuration.
     * */
    void addAndActivateConnection(const QString & device, const QString & specificParameter, const QString & password = QString());
    /**
     * Deactivates given connection
     * @connection - d-bus path of the connection you want to deactivate
     * @device - d-bus path of the connection where the connection is activated
     */
    void deactivateConnection(const QString & connection, const QString & device);
    /**
     * Disconnects all connections
     */
    void disconnectAll();
    void enableAirplaneMode(bool enable);
    void enableBt(bool enable);
    void enableNetworking(bool enable);
    void enableWireless(bool enable);
    void enableWimax(bool enable);
    void enableWwan(bool enable);
    /**
     * Opens connection editor for given connection
     * @uuid - uuid of the connection you want to edit
     */
    void editConnection(const QString & uuid);
    /**
     * Removes given connection
     * @connection - d-bus path of the connection you want to edit
     */
    void removeConnection(const QString & connection);
    void openEditor();
    void requestScan();

private Q_SLOTS:
    void editDialogAccepted();

private:
    bool m_tmpBluetoothEnabled;
    bool m_tmpWimaxEnabled;
    bool m_tmpWirelessEnabled;
    bool m_tmpWwanEnabled;
    QString m_tmpConnectionUuid;
    QString m_tmpDevicePath;
    QString m_tmpSpecificPath;

    bool isBtEnabled();
};

#endif // PLASMA_NM_HANDLER_H