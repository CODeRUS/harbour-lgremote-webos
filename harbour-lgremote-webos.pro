TARGET = harbour-lgremote-webos

QT += network xml xmlpatterns
CONFIG += sailfishapp

SOURCES += \
    src/main.cpp \
    src/networkobserver.cpp \
    src/settings.cpp

HEADERS += \
    src/networkobserver.h \
    src/settings.h

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

wslibs9.files = \
    websockets9/libQt5WebSockets.so \
    websockets9/libQt5WebSockets.so.5 \
    websockets9/libQt5WebSockets.so.5.3 \
    websockets9/libQt5WebSockets.so.5.3.3
wslibs9.path = /usr/share/harbour-lgremote-webos/lib

wsqml9.files = websockets9/harbour
wsqml9.path = /usr/share/harbour-lgremote-webos/import

images.files = images
images.path = /usr/share/harbour-lgremote-webos

INSTALLS += wslibs9 wsqml9 images

OTHER_FILES += \
    qml/cover/CoverPage.qml \
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
