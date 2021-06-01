/*
 * Copyright 2020  Dimitris Kardarakos <dimkard@posteo.net>
 * Copyright 2021  Wang Rui <wangrui@jingos.com>
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

#include "vpn.h"
// #include "storagemodel.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <unistd.h>

#include <NetworkManagerQt/Setting>
#include <NetworkManagerQt/ActiveConnection>
#include "nm-l2tp-service.h"
#include "nm-pptp-service.h"
#include "nm-openvpn-service.h"

K_PLUGIN_CLASS_WITH_JSON(VPN, "vpn.json")

VPN::VPN(QObject *parent, const QVariantList &args)
: KQuickAddons::ConfigModule(parent, args)
 , m_handler(new Handler(this))
{
    KLocalizedString::setApplicationDomain("kcm_vpn");

    KAboutData *about = new KAboutData("kcm_vpn", i18n("VPN"), "1.0", QString(), KAboutLicense::GPL);
    about->addAuthor(i18n("Jake Wu"), QString(), "jake@jingos.com");
    setAboutData(about);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::activeConnectionAdded, this, QOverload<const QString&>::of(&VPN::addActiveConnection));
}

void VPN::addVPNConnection(const QString type, const QString dec, const QString userName, const QString passWord, const QString gateWay, const QString domain, const QString key, const QString caPath, const QString certPath, const QString keyPath, const QString authPath)
{
    NMStringMap data;
    NMStringMap secrets;
    NMVariantMapMap csMapMap;

    NetworkManager::ConnectionSettings::Ptr connectionSettings = NetworkManager::ConnectionSettings::Ptr(new NetworkManager::ConnectionSettings(NetworkManager::ConnectionSettings::Vpn));
    connectionSettings->setAutoconnect(true);
    connectionSettings->setUuid(NetworkManager::ConnectionSettings::createNewUuid()); 
    connectionSettings->setId(dec);
    csMapMap = connectionSettings->toMap();;
  
    NetworkManager::VpnSetting::Ptr m_tmpIpsecSetting = NetworkManager::VpnSetting::Ptr(new NetworkManager::VpnSetting);
    data = m_tmpIpsecSetting->data();
    secrets = m_tmpIpsecSetting->secrets();
    NetworkManager::VpnSetting vpnSetting;
    if(type == "L2TP"){
        vpnSetting.setServiceType(QLatin1String(NM_DBUS_SERVICE_L2TP));
        if(!userName.isEmpty()){
        data.insert(NM_L2TP_KEY_USER, userName);
        }
        if(!passWord.isEmpty()){
            secrets.insert(NM_L2TP_KEY_PASSWORD, passWord);
        }
        if(!gateWay.isEmpty()){
        data.insert(NM_L2TP_KEY_GATEWAY,gateWay);
        }
        data.insert(NM_L2TP_KEY_PASSWORD"-flags", QString::number(NetworkManager::Setting::None));

        if(!domain.isEmpty()){
            data.insert(NM_L2TP_KEY_DOMAIN, domain);
        }
        const QString yesString = QLatin1String("yes");
        const QString noString = QLatin1String("no");
        data.insert(NM_L2TP_KEY_IPSEC_ENABLE, yesString);
        data.insert(NM_L2TP_KEY_IPSEC_PSK,key);
    }else if(type == "PPTP"){
        vpnSetting.setServiceType(QLatin1String(NM_DBUS_SERVICE_PPTP));
        if(!userName.isEmpty()){
        data.insert(NM_PPTP_KEY_USER, userName);
        }
        if(!passWord.isEmpty()){
            secrets.insert(NM_PPTP_KEY_PASSWORD, passWord);
        }
        if(!gateWay.isEmpty()){
            data.insert(NM_PPTP_KEY_GATEWAY,gateWay);
        }
        data.insert(NM_PPTP_KEY_PASSWORD"-flags", QString::number(NetworkManager::Setting::None));
        data.insert(NM_PPTP_KEY_REQUIRE_MPPE,QLatin1String("yes"));
        if(!domain.isEmpty()){
            data.insert(NM_PPTP_KEY_DOMAIN, domain);
        }

    }else if(type == "OpenVPN"){
        vpnSetting.setServiceType(QLatin1String(NM_DBUS_SERVICE_OPENVPN));
        data.insert(QLatin1String(NM_OPENVPN_KEY_CONNECTION_TYPE), QLatin1String(NM_OPENVPN_CONTYPE_TLS));
        if(!caPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_CA), caPath);
        }
        if(!certPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_CERT), certPath);
        }
        if(!keyPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_KEY), keyPath);
        }
        if(!authPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_TA), authPath);
        }
        if(!passWord.isEmpty()){
            secrets.insert(NM_OPENVPN_KEY_CERTPASS, passWord);
        }
        if(!gateWay.isEmpty()){
            data.insert(NM_OPENVPN_KEY_REMOTE,gateWay);
        }
        data.insert(QLatin1String(NM_OPENVPN_KEY_TA_DIR), QString::number(1));
        data.insert(NM_OPENVPN_KEY_CERTPASS"-flags", QString::number(NetworkManager::Setting::None));
    }

    vpnSetting.setData(data);
    vpnSetting.setSecrets(secrets);

    QVariantMap vpnSettingMap = vpnSetting.toMap();
    csMapMap.insert(NetworkManager::Setting::typeAsString(NetworkManager::Setting::Vpn), vpnSettingMap);

    m_handler->addConnection(csMapMap);
}

void VPN::updateVPNConnection(const QString type, const QString dec, const QString userName, const QString passWord, const QString gateWay, const QString domain, const QString key, const QString caPath, const QString certPath, const QString keyPath, const QString authPath)
{
    NMStringMap data;
    NMStringMap secrets;
    NMVariantMapMap csMapMap;

    NetworkManager::ConnectionSettings::Ptr connectionSettings = NetworkManager::ConnectionSettings::Ptr(new NetworkManager::ConnectionSettings(NetworkManager::ConnectionSettings::Vpn));
    connectionSettings->setAutoconnect(true);
    connectionSettings->setUuid(NetworkManager::ConnectionSettings::createNewUuid()); 
    connectionSettings->setId(dec);
    csMapMap = connectionSettings->toMap();;
  
    NetworkManager::VpnSetting::Ptr m_tmpIpsecSetting = NetworkManager::VpnSetting::Ptr(new NetworkManager::VpnSetting);
    data = m_tmpIpsecSetting->data();
    secrets = m_tmpIpsecSetting->secrets();
    NetworkManager::VpnSetting vpnSetting;
    if(type == "L2TP"){
        vpnSetting.setServiceType(QLatin1String(NM_DBUS_SERVICE_L2TP));
        if(!userName.isEmpty()){
        data.insert(NM_L2TP_KEY_USER, userName);
        }
        if(!passWord.isEmpty()){
            secrets.insert(NM_L2TP_KEY_PASSWORD, passWord);
        }
        if(!gateWay.isEmpty()){
        data.insert(NM_L2TP_KEY_GATEWAY,gateWay);
        }
        data.insert(NM_L2TP_KEY_PASSWORD"-flags", QString::number(NetworkManager::Setting::None));

        if(!domain.isEmpty()){
            data.insert(NM_L2TP_KEY_DOMAIN, domain);
        }
        const QString yesString = QLatin1String("yes");
        const QString noString = QLatin1String("no");
        data.insert(NM_L2TP_KEY_IPSEC_ENABLE, yesString);
        data.insert(NM_L2TP_KEY_IPSEC_PSK,key);
    }else if(type == "PPTP"){
        vpnSetting.setServiceType(QLatin1String(NM_DBUS_SERVICE_PPTP));
        if(!userName.isEmpty()){
        data.insert(NM_PPTP_KEY_USER, userName);
        }
        if(!passWord.isEmpty()){
            secrets.insert(NM_PPTP_KEY_PASSWORD, passWord);
        }
        if(!gateWay.isEmpty()){
            data.insert(NM_PPTP_KEY_GATEWAY,gateWay);
        }
        data.insert(NM_PPTP_KEY_PASSWORD"-flags", QString::number(NetworkManager::Setting::None));
        data.insert(NM_PPTP_KEY_REQUIRE_MPPE,QLatin1String("yes"));
        if(!domain.isEmpty()){
            data.insert(NM_PPTP_KEY_DOMAIN, domain);
        }

    }else if(type == "OpenVPN"){
        vpnSetting.setServiceType(QLatin1String(NM_DBUS_SERVICE_OPENVPN));
        data.insert(QLatin1String(NM_OPENVPN_KEY_CONNECTION_TYPE), QLatin1String(NM_OPENVPN_CONTYPE_TLS));
        if(!caPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_CA), caPath);
        }
        if(!certPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_CERT), certPath);
        }
        if(!keyPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_KEY), keyPath);
        }
        if(!authPath.isEmpty()){
            data.insert(QLatin1String(NM_OPENVPN_KEY_TA), authPath);
        }
        if(!passWord.isEmpty()){
            secrets.insert(NM_OPENVPN_KEY_CERTPASS, passWord);
        }
        if(!gateWay.isEmpty()){
            data.insert(NM_OPENVPN_KEY_REMOTE,gateWay);
        }
        data.insert(QLatin1String(NM_OPENVPN_KEY_TA_DIR), QString::number(1));
        data.insert(NM_OPENVPN_KEY_CERTPASS"-flags", QString::number(NetworkManager::Setting::None));
    }

    vpnSetting.setData(data);
    vpnSetting.setSecrets(secrets);

    QVariantMap vpnSettingMap = vpnSetting.toMap();
    csMapMap.insert(NetworkManager::Setting::typeAsString(NetworkManager::Setting::Vpn), vpnSettingMap);
    NetworkManager::Connection::Ptr connection = NetworkManager::findConnection(m_connectionPath);
    m_handler->updateConnection(connection, csMapMap);
}

void VPN::activateVPNConnection(const QString &connection, const QString &device, const QString &specificParameter)
{
    m_handler->activateConnection(connection,device,specificParameter);
}

void VPN::removeVPNConnection(const QString & connection)
{
    m_handler->removeConnection(connection);
}

void VPN::deactivateVPNConnection(const QString &connection, const QString &device)
{
    m_handler->deactivateConnection(connection,device);
}

void VPN::onDetailClicked(const QString connectionPath,const QString devicePath)
{
    m_connectionPath = connectionPath;
    NetworkManager::Connection::Ptr m_connection = NetworkManager::findConnection(connectionPath);
    if (m_connection) {
        m_connectionSettings = m_connection->settings();
        m_vpnSetting =
            m_connectionSettings->setting(NetworkManager::Setting::Vpn).staticCast<NetworkManager::VpnSetting>();
    }
    NetworkManager::Device::Ptr device = NetworkManager::findNetworkInterface(devicePath);
    if(device){
        m_device = device;
    }
}


void VPN::replyFinished(QDBusPendingCallWatcher *watcher)
{
    QDBusPendingReply<NMVariantMapMap> reply = *watcher;
    const QString settingName = watcher->property("settingName").toString();
    if (reply.isValid()) {
        NMVariantMapMap secrets = reply.argumentAt<0>();
        for (const QString &key : secrets.keys()) {
            if (key == settingName) {
                NetworkManager::Setting::Ptr setting = m_connectionSettings->setting(NetworkManager::Setting::typeFromString(key));
                if (setting) {
                    setting->secretsFromMap(secrets.value(key));
                    NetworkManager::VpnSetting::Ptr vpnSetting = setting.staticCast<NetworkManager::VpnSetting>();
                    const NMStringMap dataMap = vpnSetting->data();
                    const NMStringMap secrets = vpnSetting->secrets();
                    QString type = m_vpnSetting->serviceType();
                    if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
                        m_pwd =  secrets.value(NM_L2TP_KEY_PASSWORD);
                    }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
                        m_pwd =  secrets.value(NM_PPTP_KEY_PASSWORD);
                    }else if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
                        m_pwd =  secrets.value(NM_OPENVPN_KEY_CERTPASS);
                    }
                    Q_EMIT passwordReplyFinished(m_pwd);
                }
            }
        }
    }
    watcher->deleteLater();
}

QString VPN::getConnectionType()
{
    const NMStringMap dataMap = m_vpnSetting->data();
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
        return "L2TP";
    }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
        return "PPTP";
    }else if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return "OpenVPN";
    }
    return "Unkown";
}
QString VPN::getIpAdress()
{
    if (m_device && m_device->ipV4Config().isValid()){
         if (!m_device->ipV4Config().addresses().isEmpty()) {
            QHostAddress addr = m_device->ipV4Config().addresses().first().ip();
            if (!addr.isNull()) {
                return addr.toString();
            }
        }
    }
    return "";
}

QString VPN::getUserName()
{
    const NMStringMap dataMap = m_vpnSetting->data(); 
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
        return dataMap[NM_L2TP_KEY_USER];
    }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
        return dataMap[NM_PPTP_KEY_USER];
    }else if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return dataMap[NM_OPENVPN_KEY_USERNAME];
    }
    return "";
}

QString VPN::getCACertificate()
{
    const NMStringMap dataMap = m_vpnSetting->data(); 
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return dataMap[NM_OPENVPN_KEY_CA];
    }
    return "";
}

QString VPN::getUserCertificate()
{
    const NMStringMap dataMap = m_vpnSetting->data(); 
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return dataMap[NM_OPENVPN_KEY_CERT];
    }
    return "";
}

QString VPN::getPrivateKeyCertificate()
{
    const NMStringMap dataMap = m_vpnSetting->data(); 
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return dataMap[NM_OPENVPN_KEY_KEY];
    }
    return "";
}

QString VPN::getStaticKeyCertificate()
{
    const NMStringMap dataMap = m_vpnSetting->data(); 
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return dataMap[NM_OPENVPN_KEY_TA];
    }
    return "";
}

QString VPN::getUserName(const QString connectionPath)
{
    NetworkManager::Connection::Ptr m_connection = NetworkManager::findConnection(connectionPath);
    if (m_connection) {
        m_vpnSetting =
            m_connection->settings()->setting(NetworkManager::Setting::Vpn).staticCast<NetworkManager::VpnSetting>();
            const NMStringMap dataMap = m_vpnSetting->data(); 
            QString type = m_vpnSetting->serviceType();
            if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
                return dataMap[NM_L2TP_KEY_USER];
            }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
                return dataMap[NM_PPTP_KEY_USER];
            }else if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
                return "openvpn";
        }
    }
    
    return "";
}

QString VPN::getServerName(const QString connectionPath)
{
    NetworkManager::Connection::Ptr m_connection = NetworkManager::findConnection(connectionPath);
    if (m_connection) {
        m_vpnSetting =
            m_connection->settings()->setting(NetworkManager::Setting::Vpn).staticCast<NetworkManager::VpnSetting>();
            const NMStringMap dataMap = m_vpnSetting->data();
            QString type = m_vpnSetting->serviceType();
            if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
                return dataMap[NM_L2TP_KEY_GATEWAY];
            }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
                return dataMap[NM_PPTP_KEY_GATEWAY];
            }else if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
                return dataMap[NM_OPENVPN_KEY_REMOTE];
            }
    }
    
    return "";
}

QString VPN::getServerName()
{
    const NMStringMap dataMap = m_vpnSetting->data();
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
        return dataMap[NM_L2TP_KEY_GATEWAY];
    }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
        return dataMap[NM_PPTP_KEY_GATEWAY];
    }else if(type == QLatin1String(NM_DBUS_SERVICE_OPENVPN)){
        return dataMap[NM_OPENVPN_KEY_REMOTE];
    }
    
    return dataMap[NM_L2TP_KEY_GATEWAY];
}

QString VPN::getDomainName()
{
    const NMStringMap dataMap = m_vpnSetting->data();
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
        return dataMap[NM_L2TP_KEY_DOMAIN];
    }else if(type == QLatin1String(NM_DBUS_SERVICE_PPTP)){
        return dataMap[NM_PPTP_KEY_DOMAIN];
    }
    return "";
}

QString VPN::getPassword()
{
    NetworkManager::Connection::Ptr m_connection = NetworkManager::findConnection(m_connectionPath);
    if (m_connection) {
        QDBusPendingReply<NMVariantMapMap> reply = m_connection->secrets( QLatin1String("vpn"));
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
        watcher->setProperty("connection", m_connection->name());
        watcher->setProperty("settingName", QLatin1String("vpn"));
        connect(watcher, &QDBusPendingCallWatcher::finished, this, &VPN::replyFinished);
    }
    
    return m_pwd;
}

QString VPN::getDescription()
{
    return m_connectionSettings->id();
}

QString VPN::getPreSharedKey()
{
    const NMStringMap dataMap = m_vpnSetting->data();
    QString type = m_vpnSetting->serviceType();
    if(type == QLatin1String(NM_DBUS_SERVICE_L2TP)){
        return dataMap[NM_L2TP_KEY_IPSEC_PSK];
    }
    return "";
}

void VPN::addActiveConnection(const QString &path)
{
    NetworkManager::ActiveConnection::Ptr ac = NetworkManager::findActiveConnection(path);
    if (ac && ac->isValid()) {
        addActiveConnection(ac);
    }
}

void VPN::addActiveConnection(const NetworkManager::ActiveConnection::Ptr &ac)
{
    if (ac->vpn()) {
        NetworkManager::VpnConnection::Ptr vpnConnection = ac.objectCast<NetworkManager::VpnConnection>();
        connect(vpnConnection.data(), &NetworkManager::VpnConnection::stateChanged, this, &VPN::onVpnConnectionStateChanged);
    }
}

void VPN::onVpnConnectionStateChanged(NetworkManager::VpnConnection::State state, NetworkManager::VpnConnection::StateChangeReason reason)
{
    if (state == NetworkManager::VpnConnection::Activated) {
        Q_EMIT vpnConnectedSuccess(state);
    } else if (state == NetworkManager::VpnConnection::Failed) {
        Q_EMIT vpnConnectedFaild(state);
    }
}

void VPN::saveValue(const QString &key, const QVariant &value)
{
    m_settings.setValue(key,value);
}

QVariant VPN::getValue(const QString &key)
{
    return m_settings.value(key);
}
#include "vpn.moc"
