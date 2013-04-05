/*
Copyright 2008 Will Stephenson <wstephenson@kde.org>
Copyright 2013 Lukas Tinkl <ltinkl@redhat.com>

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

#ifndef VPNCAUTH_H
#define VPNCAUTH_H

#include <QDialog>

#include <QtNetworkManager/settings/vpn.h>

#include "settingwidget.h"

class VpncAuthDialogPrivate;

class VpncAuthDialog : public SettingWidget
{
    Q_OBJECT
    Q_DECLARE_PRIVATE(VpncAuthDialog)
public:
    VpncAuthDialog(NetworkManager::Settings::VpnSetting *setting, QWidget * parent = 0);
    ~VpncAuthDialog();
    virtual void readSecrets();
    virtual QVariantMap setting() const;

private slots:
    void showPasswordsChanged(bool);

private:
    VpncAuthDialogPrivate * d_ptr;
};

#endif // VPNCAUTH_H