project (kcm_wifi)

set (wifisettings_SRCS
     ../../libs/handler.cpp 
     ../../libs/debug.cpp
     wifisettings.cpp)

qt5_add_resources(RESOURCES resources.qrc)
add_library(kcm_wifi MODULE ${wifisettings_SRCS} ${RESOURCES})

target_link_libraries(kcm_wifi
PUBLIC
    KF5::NetworkManagerQt
    plasmanm_editor
    ${NETWORKMANAGER_LIBRARIES}
    
PRIVATE
    Qt5::DBus
    Qt5::Gui
    Qt5::Quick
    Qt5::Qml
    KF5::I18n
    KF5::NetworkManagerQt
    KF5::Plasma
    KF5::QuickAddons
    KF5::Notifications
    KF5::WindowSystem
    KF5::Service
    KF5::Wallet
)

kcoreaddons_desktop_to_json(kcm_wifi "wifisettings.desktop")

install(FILES wifisettings.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
install(TARGETS kcm_wifi DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_wifi kcms)



