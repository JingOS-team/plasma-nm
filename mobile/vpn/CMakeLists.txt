project (kcm_vpn)

set(vpn_SRCS # Specify source files for the library
    vpn.cpp
    ../../libs/handler.cpp 
    ../../libs/debug.cpp
)

qt5_add_resources(RESOURCES resources.qrc)
add_library(kcm_vpn MODULE ${vpn_SRCS} ${RESOURCES})

target_link_libraries(kcm_vpn
PUBLIC
    KF5::NetworkManagerQt
    plasmanm_editor
    ${NETWORKMANAGER_LIBRARIES}
PRIVATE
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
    Qt5::DBus
    KF5::NetworkManagerQt
    KF5::Notifications
    KF5::Service
    KF5::WindowSystem
    KF5::Wallet
)

kcoreaddons_desktop_to_json(kcm_vpn "vpn.desktop") # Convert our desktop file to json

install(TARGETS kcm_vpn DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms) # Install the library to the kcm vpn
install(FILES vpn.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR}) # Install the desktop file
kpackage_install_package(package kcm_vpn kcms) # Finally install our QML kpackage.
