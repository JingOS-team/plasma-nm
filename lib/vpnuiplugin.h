/*
Copyright 2008 Will Stephenson <wstephenson@kde.org>
Copyright 2013 Lukáš Tinkl <ltinkl@redhat.com>

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

#ifndef VPNUIPLUGIN_H
#define VPNUIPLUGIN_H

#include <QObject>
#include <QVariant>
#include <QMessageBox>

#include <QtNetworkManager/settings/vpn.h>

#include <kdemacros.h>

#include "settingwidget.h"

/**
 * Plugin for UI elements for VPN configuration
 */
class KDE_EXPORT VpnUiPlugin : public QObject
{
    Q_OBJECT
public:
    enum ErrorType {NoError, NotImplemented, Error};

    VpnUiPlugin(QObject * parent = 0, const QVariantList& = QVariantList());
    virtual ~VpnUiPlugin();

    virtual SettingWidget * widget(NetworkManager::Settings::VpnSetting *setting, QWidget * parent = 0) = 0;
    virtual SettingWidget * askUser(NetworkManager::Settings::VpnSetting *setting, QWidget * parent = 0) = 0;

#if 0
    /**
     * Suggested file name to save the exported connection configuration.
     * Try not to use space, parenthesis, or any other Unix unfriendly file name character.
     */
    virtual QString suggestedFileName(Knm::Connection *connection) const = 0;
    /**
     * File extension to be used in KFileDialog when selecting the file to import.
     * The format is: *.<extension> [*.<extension> ...]. For instance: '*.pcf'
     */
    virtual QString supportedFileExtensions() const = 0;

    /**
     * If the plugin does not support fileName's extension it must just return an empty QVariantList.
     * If it supports the extension and import has failed it must set mError with VpnUiPlugin::Error
     * and mErrorMessage with a custom error message before returning an empty QVariantList.
     */
    virtual QVariantList importConnectionSettings(const QString &fileName) = 0;
    virtual bool exportConnectionSettings(Knm::Connection * connection, const QString &fileName) = 0;
#endif

    virtual QMessageBox::StandardButtons suggestedAuthDialogButtons() const;
    ErrorType lastError() const;
    QString lastErrorMessage();
protected:
    ErrorType mError;
    QString mErrorMessage;
};

#endif // VPNUIPLUGIN_H