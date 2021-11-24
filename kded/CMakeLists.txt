add_definitions(-DTRANSLATION_DOMAIN=\"plasmanetworkmanagement-kded\")

include_directories(${CMAKE_SOURCE_DIR}/libs/editor/widgets)

if (WITH_MODEMMANAGER_SUPPORT)
    set(kded_networkmanagement_SRCS
        ../libs/debug.cpp
        ../libs/handler.cpp
	../libs/declarative/networkstatus.cpp
	../libs/declarative/enabledconnections.cpp
	../libs/declarative/connectionicon.cpp
        bluetoothmonitor.cpp
        connectivitymonitor.cpp
        notification.cpp
        modemmonitor.cpp
        monitor.cpp
        passworddialog.cpp
        pindialog.cpp
        secretagent.cpp
        service.cpp
        cellularmonitor.cpp
	networkservice.cpp
    )
    ki18n_wrap_ui(kded_networkmanagement_SRCS
        pinwidget.ui
        passworddialog.ui
    )
else()
    set(kded_networkmanagement_SRCS
        ../libs/debug.cpp
        bluetoothmonitor.cpp
        connectivitymonitor.cpp
        notification.cpp
        monitor.cpp
        passworddialog.cpp
        secretagent.cpp
        service.cpp
    )
    ki18n_wrap_ui(kded_networkmanagement_SRCS
        passworddialog.ui
    )
endif()

qt5_add_resources(RESOURCES resources.qrc)
add_library(kded_networkmanagement MODULE ${kded_networkmanagement_SRCS} ${RESOURCES})

set_target_properties(kded_networkmanagement PROPERTIES OUTPUT_NAME networkmanagement)
kcoreaddons_desktop_to_json(kded_networkmanagement networkmanagement.desktop)

#install(FILES networkmanagement.desktop  DESTINATION ${KDE_INSTALL_KSERVICES5DIR})

target_link_libraries(kded_networkmanagement
    plasmanm_internal
    plasmanm_editor
    plasmanm_qmlplugins
    KF5::ConfigCore
    KF5::DBusAddons
    KF5::I18n
    KF5::Notifications
    KF5::Service
    KF5::Solid
    KF5::Wallet
    KF5::WindowSystem
    
    Qt5::Core
    Qt5::Qml
    KF5::CoreAddons
    Qt5::Quick
    KF5::ModemManagerQt
    KF5::NetworkManagerQt
)

if (WITH_MODEMMANAGER_SUPPORT)
    target_link_libraries(kded_networkmanagement KF5::ModemManagerQt)
endif()

install(TARGETS kded_networkmanagement DESTINATION ${KDE_INSTALL_PLUGINDIR}/kf5/kded)

install(FILES networkmanagement.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFY5RCDIR})
