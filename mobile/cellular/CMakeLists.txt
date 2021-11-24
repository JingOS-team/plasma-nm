project (kcm_cellular)

set (cellularsettings_SRCS cellularsettings.cpp
    ../../libs/handler.cpp 
    ../../libs/debug.cpp
)

qt5_add_resources(RESOURCES resources.qrc)
add_library(kcm_cellular MODULE ${cellularsettings_SRCS} ${RESOURCES})

target_link_libraries(kcm_cellular
    Qt5::Quick
    Qt5::Qml
    KF5::I18n
    KF5::CoreAddons
    KF5::QuickAddons
    KF5::ModemManagerQt
    KF5::NetworkManagerQt

    KF5::ConfigCore
    plasmanm_editor
    ${NETWORKMANAGER_LIBRARIES}
    KF5::Notifications
    KF5::Service
    KF5::WindowSystem
    KF5::Wallet
)

kcoreaddons_desktop_to_json(kcm_cellular "package/metadata.desktop")

install(FILES package/metadata.desktop RENAME cellularsettings.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
install(TARGETS kcm_cellular DESTINATION ${PLUGIN_INSTALL_DIR}/kcms)
kpackage_install_package(package kcm_cellular kcms)
