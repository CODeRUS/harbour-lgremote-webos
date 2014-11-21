TARGET = harbour-lgremote-webos

QT += core network xml xmlpatterns
CONFIG += link_pkgconfig
CONFIG += sailfishapp
PKGCONFIG += sailfishapp

SOURCES += \
    src/main.cpp \
    src/networkobserver.cpp \
    src/settings.cpp

HEADERS += \
    src/networkobserver.h \
    src/settings.h

wslibs.files = \
    websockets/libQt5WebSockets.so \
    websockets/libQt5WebSockets.so.5 \
    websockets/libQt5WebSockets.so.5.3 \
    websockets/libQt5WebSockets.so.5.3.3 \
    websockets/README
wslibs.path = /usr/share/harbour-lgremote-webos/lib/u8

wsqml.files = websockets/harbour
wsqml.path = /usr/share/harbour-lgremote-webos/import/u8

wslibs9.files = \
    websockets9/libQt5WebSockets.so \
    websockets9/libQt5WebSockets.so.5 \
    websockets9/libQt5WebSockets.so.5.3 \
    websockets9/libQt5WebSockets.so.5.3.3 \
    websockets9/README
wslibs9.path = /usr/share/harbour-lgremote-webos/lib/u9

wsqml9.files = websockets9/harbour
wsqml9.path = /usr/share/harbour-lgremote-webos/import/u9

images.files = images
images.path = /usr/share/harbour-lgremote-webos

readme.files = LIB_README_FOR_QA
readme.path = /usr/share/harbour-lgremote-webos/lib

INSTALLS += wslibs wsqml wslibs9 wsqml9 images readme

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    rpm/harbour-lgremote-webos.changes.in \
    rpm/harbour-lgremote-webos.spec \
    harbour-lgremote-webos.desktop \
    harbour-lgremote-webos.png \
    qml/main.qml \
    qml/pages/DiscoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/TouchpadPanel.qml \
    qml/pages/ImageButton.qml \
    qml/pages/SmoothPanel.qml \
    qml/pages/ChannelsPanel.qml \
    qml/pages/ControlButton.qml \
    qml/pages/ActionsPanel.qml \
    qml/pages/ColoredImage.qml \
    qml/pages/ApplicationsPanel.qml \
    qml/pages/ExtraPanel.qml \
    qml/pages/TextPanel.qml \
    qml/pages/InputPanel.qml \
    qml/pages/PointerSocket.qml \
    qml/pages/MainSocket.qml

