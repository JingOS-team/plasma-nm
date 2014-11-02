/*
    Copyright 2013 Lukas Tinkl <ltinkl@redhat.com>
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

#ifndef PLASMA_NM_BSSIDCOMBOBOX_H
#define PLASMA_NM_BSSIDCOMBOBOX_H

#include <QComboBox>

#include <NetworkManagerQt/Device>
#include <NetworkManagerQt/AccessPoint>

class Q_DECL_EXPORT BssidComboBox : public QComboBox
{
    Q_OBJECT
public:
    explicit BssidComboBox(QWidget *parent = 0);

    QString bssid() const;
    bool isValid() const;

Q_SIGNALS:
    void bssidChanged();

public Q_SLOTS:
    void init(const QString & bssid, const QString &ssid);

private Q_SLOTS:
    void editTextChanged(const QString &);
    void currentIndexChanged(int);

private:
    void addBssidsToCombo(const QList<NetworkManager::AccessPoint::Ptr> & aps);

    QString m_initialBssid;
    bool m_dirty;
};

#endif // PLASMA_NM_BSSIDCOMBOBOX_H
