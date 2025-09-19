#-------------------------------------------------
#
# LAN Messenger project file
#
#-------------------------------------------------

QT += core gui network xml widgets sql

unix: QT += multimedia
macx: QT += multimedia

win32: TARGET = lmc
unix: TARGET = lan-messenger
macx: TARGET  = "LAN-Messenger"
TEMPLATE = app

RESOURCES = resource.qrc

SOURCES += \
    usertreewidget.cpp \
    udpnetwork.cpp \
    transferwindow.cpp \
    transferlistview.cpp \
    tcpnetwork.cpp \
    lmc_strings.cpp \
    soundplayer.cpp \
    shared.cpp \
    settingsdialog.cpp \
    settings.cpp \
    network.cpp \
    netstreamer.cpp \
    messagingproc.cpp \
    messaging.cpp \
    message.cpp \
    mainwindow.cpp \
    main.cpp \
    lmc.cpp \
    imagepickeraction.cpp \
    imagepicker.cpp \
    historywindow.cpp \
    history.cpp \
    helpwindow.cpp \
    filemodelview.cpp \
    datagram.cpp \
    crypto.cpp \
    chatwindow.cpp \
    broadcastwindow.cpp \
    aboutdialog.cpp \
    xmlmessage.cpp \
    chathelper.cpp \
    theme.cpp \
    messagelog.cpp \
    updatewindow.cpp \
    webnetwork.cpp \
    userinfowindow.cpp \
    chatroomwindow.cpp \
    userselectdialog.cpp \
    subcontrols.cpp \
    trace.cpp \
    filemessagingproc.cpp \
    qmessagebrowser.cpp

HEADERS  += \
    usertreewidget.h \
    uidefinitions.h \
    udpnetwork.h \
    transferwindow.h \
    transferlistview.h \
    tcpnetwork.h \
    lmc_strings.h \
    soundplayer.h \
    shared.h \
    settingsdialog.h \
    settings.h \
    resource.h \
    network.h \
    netstreamer.h \
    messaging.h \
    message.h \
    mainwindow.h \
    lmc.h \
    imagepickeraction.h \
    imagepicker.h \
    historywindow.h \
    historytreewidget.h \
    helpwindow.h \
    filemodelview.h \
    chatwindow.h \
    chatdefinitions.h \
    broadcastwindow.h \
    history.h \
    stdlocation.h \
    definitions.h \
    datagram.h \
    crypto.h \
    aboutdialog.h \
    xmlmessage.h \
    chathelper.h \
    theme.h \
    messagelog.h \
    updatewindow.h \
    webnetwork.h \
    userinfowindow.h \
    chatroomwindow.h \
    userselectdialog.h \
    subcontrols.h \
    trace.h \
    qmessagebrowser.h

FORMS += \
    transferwindow.ui \
    settingsdialog.ui \
    mainwindow.ui \
    historywindow.ui \
    helpwindow.ui \
    chatwindow.ui \
    broadcastwindow.ui \
    aboutdialog.ui \
    updatewindow.ui \
    userinfowindow.ui \
    chatroomwindow.ui \
    userselectdialog.ui

TRANSLATIONS += \
	en_US.ts \
	ml_IN.ts \
	fr_FR.ts \
	de_DE.ts \
	tr_TR.ts \
	es_ES.ts \
	ko_KR.ts \
	bg_BG.ts \
	ro_RO.ts \
	ar_SA.ts \
	sl_SI.ts \
        pt_BR.ts \
        ru_RU.ts \
        it_IT.ts \
        sv_SE.ts

win32: RC_FILE = lmcwin32.rc
macx: ICON = lmc.icns

win32-msvc* {
    QMAKE_LFLAGS_RELEASE += /MAP
    QMAKE_CFLAGS_RELEASE += /Zi
    QMAKE_CFLAGS_RELEASE += /FAcs
    QMAKE_CXXFLAGS_RELEASE += /Zi
    QMAKE_CXXFLAGS_RELEASE += /FAcs
    QMAKE_LFLAGS_RELEASE += /debug /opt:ref
}

win32: {
    CONFIG -= debug_and_release debug_and_release_target
    LMCAPP_PATH = $$replace(OUT_PWD, lmc, lmcapp)
    LIBS += -L$$LMCAPP_PATH -llmcapp
}
unix:!symbian: {
    CONFIG(debug, debug|release) {
        DESTDIR = ../debug
    } else {
        DESTDIR = ../release
    }
    LIBS += -L$$PWD/../../lmcapp/lib/ -llmcapp
}

INCLUDEPATH += $$PWD/../../lmcapp/include
DEPENDPATH += $$PWD/../../lmcapp/include

win32-msvc*: LIBS += advapi32.lib # for GetUserNameW(...) in Helper::getLogonName(..)
win32: LIBS += -L$$PWD/../../openssl/lib/ -llibeay32
unix:!symbian: LIBS += -L$$PWD/../../openssl/lib/ -lcrypto

INCLUDEPATH += $$PWD/../../openssl/include
DEPENDPATH += $$PWD/../../openssl/include
