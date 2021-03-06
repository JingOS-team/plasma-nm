/*
    Copyright 2017 Jan Grulich <jgrulich@redhat.com>
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

#ifndef PLASMA_NM_CONFIGURATION_H
#define PLASMA_NM_CONFIGURATION_H

#include <QObject>

#include <NetworkManagerQt/Manager>

class Q_DECL_EXPORT Configuration : public QObject
{
    Q_PROPERTY(bool unlockModemOnDetection READ unlockModemOnDetection WRITE setUnlockModemOnDetection)
    Q_PROPERTY(bool manageVirtualConnections READ manageVirtualConnections WRITE setManageVirtualConnections)
    Q_PROPERTY(bool airplaneModeEnabled READ airplaneModeEnabled WRITE setAirplaneModeEnabled)
    Q_PROPERTY(QString hotspotName READ hotspotName WRITE setHotspotName)
    Q_PROPERTY(QString hotspotPassword READ hotspotPassword WRITE setHotspotPassword)
    Q_PROPERTY(QString hotspotConnectionPath READ hotspotConnectionPath WRITE setHotspotConnectionPath)
    Q_PROPERTY(QString modemConnectionPath READ modemConnectionPath WRITE setModemConnectionPath)
    Q_PROPERTY(QString modemDevicePath READ modemDevicePath WRITE setModemDevicePath)
    Q_PROPERTY(QString modemOperatorPath READ modemOperatorPath WRITE setModemOperatorPath)

    //Readonly constant property, as this value should only be set by the platform
    Q_PROPERTY(bool showPasswordDialog READ showPasswordDialog CONSTANT)
    Q_OBJECT
public:
    static bool unlockModemOnDetection();
    static void setUnlockModemOnDetection(bool unlock);

    static bool manageVirtualConnections();
    static void setManageVirtualConnections(bool manage);

    static bool airplaneModeEnabled();
    static void setAirplaneModeEnabled(bool enabled);

    static QString hotspotName();
    static void setHotspotName(const QString &name);

    static QString hotspotPassword();
    static void setHotspotPassword(const QString &password);

    static QString hotspotConnectionPath();
    static void setHotspotConnectionPath(const QString &path);

    static QString modemConnectionPath();
    static void setModemConnectionPath(const QString &path);

    static QString modemDevicePath();
    static void setModemDevicePath(const QString &path);

    static QString modemOperatorPath();
    static void setModemOperatorPath(const QString &path);

    static bool showPasswordDialog();
};

#endif // PLAMA_NM_CONFIGURATION_H

