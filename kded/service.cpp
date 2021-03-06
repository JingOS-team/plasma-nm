/*
    Copyright 2009 Dario Freddi <drf54321@gmail.com>
    Copyright 2009 Will Stephenson <wstephenson@kde.org>
    Copyright 2011-2012 Lamarque V. Souza <lamarque@kde.org>
    Copyright 2013-2014 Jan Grulich <jgrulich@redhat.com>
    Copyright 2021 Liu Bangguo <liubangguo@jingos.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "service.h"

#include <KPluginFactory>

#include "connectivitymonitor.h"
#include "secretagent.h"
#include "notification.h"
#include "monitor.h"

#include <QDBusMetaType>
#include <QDBusServiceWatcher>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusReply>

#include <QQmlApplicationEngine>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QUrl>
#include <QQmlContext>
#include <QDebug>
#include "cellularmonitor.h"
#include "networkservice.h"

K_PLUGIN_CLASS_WITH_JSON(NetworkManagementService, "networkmanagement.json")

class NetworkManagementServicePrivate
{
    public:
    SecretAgent *agent = nullptr;
    Notification *notification = nullptr;
    Monitor *monitor = nullptr;
    ConnectivityMonitor *connectivityMonitor = nullptr;
    NetworkService *networkservice = nullptr;
};

NetworkManagementService::NetworkManagementService(QObject * parent, const QVariantList&)
    : KDEDModule(parent), d_ptr(new NetworkManagementServicePrivate)
{
    Q_D(NetworkManagementService);

    connect(this, &KDEDModule::moduleRegistered, this, &NetworkManagementService::init);

    d->agent = new SecretAgent(this);
    connect(d->agent, &SecretAgent::secretsError, this, &NetworkManagementService::secretsError);
}

NetworkManagementService::~NetworkManagementService()
{
    delete d_ptr;
}

void NetworkManagementService::init()
{
    Q_D(NetworkManagementService);

    if (!d->notification) {
        d->notification = new Notification(this);
    }

    if (!d->monitor) {
        d->monitor = new Monitor(this);
    }

    if (!d->connectivityMonitor) {
        d->connectivityMonitor = new ConnectivityMonitor(this);
    }

    if (!d->networkservice) {
        d->networkservice = new NetworkService(this);
    }

    qmlRegisterType<CellularMonitor>("org.kde.jingos.kded", 0, 2, "CellularMonitor");
    
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
}

#include "service.moc"
