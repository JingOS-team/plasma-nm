/*
 * Copyright 2020  Dimitris Kardarakos <dimkard@posteo.net>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// #include <KQuickAddons/ConfigModule>
#ifndef VPN_H
#define VPN_H


#include <KQuickAddons/ConfigModule>
#include <QObject>
#include "handler.h"
#include <NetworkManagerQt/VpnSetting>
#include <NetworkManagerQt/VpnConnection>
#include <NetworkManagerQt/Device>
#include <NetworkManagerQt/Manager>


class VPN : public KQuickAddons::ConfigModule
{
    Q_OBJECT
public:
    VPN(QObject *parent, const QVariantList &args);
    Q_INVOKABLE void addVPNConnection(const QString type, const QString dec, const QString userName, const QString passWord, const QString gateWay, const QString domain, const QString key, const QString caPath, const QString certPath, const QString keyPath, const QString authPath);
    Q_INVOKABLE void updateVPNConnection(const QString type, const QString dec, const QString userName, const QString passWord, const QString gateWay, const QString domain, const QString key, const QString caPath, const QString certPath, const QString keyPath, const QString authPath);
    Q_INVOKABLE void activateVPNConnection(const QString &connection, const QString &device, const QString &specificParameter);
    Q_INVOKABLE void removeVPNConnection(const QString & connection);
    Q_INVOKABLE void deactivateVPNConnection(const QString &connection, const QString &device);
    Q_INVOKABLE void onDetailClicked(const QString connectionPath, const QString devicePath);
    Q_INVOKABLE QString getConnectionType();
    Q_INVOKABLE QString getServerName();
    Q_INVOKABLE QString getDomainName();
    Q_INVOKABLE QString getIpAdress();
    Q_INVOKABLE QString getUserName();
    Q_INVOKABLE QString getPassword();
    Q_INVOKABLE QString getPreSharedKey();
    Q_INVOKABLE QString getDescription();
    Q_INVOKABLE QString getCACertificate();
    Q_INVOKABLE QString getUserCertificate();
    Q_INVOKABLE QString getPrivateKeyCertificate();
    Q_INVOKABLE QString getStaticKeyCertificate();
    Q_INVOKABLE QString getUserName(const QString connectionPath);
    Q_INVOKABLE QString getServerName(const QString connectionPath);

    Q_INVOKABLE void saveValue(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant getValue(const QString &key);

    
Q_SIGNALS:
    void vpnConnectedFaild(NetworkManager::VpnConnection::State state);
    void vpnConnectedSuccess(NetworkManager::VpnConnection::State state);
    void passwordReplyFinished(const QString pwd);
    
private Q_SLOTS:
    void replyFinished(QDBusPendingCallWatcher *watcher);
    void addActiveConnection(const QString & path);
    void addActiveConnection(const NetworkManager::ActiveConnection::Ptr & ac);
    void onVpnConnectionStateChanged(NetworkManager::VpnConnection::State state, NetworkManager::VpnConnection::StateChangeReason reason); 

private:
    Handler *m_handler;
    QString m_connectionPath;
    QString m_pwd;
    NetworkManager::VpnSetting::Ptr m_vpnSetting;
    NetworkManager::Device::Ptr m_device;
    NetworkManager::ConnectionSettings::Ptr m_connectionSettings;
    QSettings m_settings;
};

#endif
