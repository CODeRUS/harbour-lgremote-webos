#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>

#include "networkobserver.h"
#include "settings.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationDisplayName("LG Remote");
    app->setApplicationName("LG Remote");
    app->setApplicationVersion(QString(APP_VERSION));
    app->setOrganizationName("harbour-lgremote-webos");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setTitle("LG Remote");
    view->engine()->addImportPath("/usr/share/harbour-lgremote-webos/import");

    QScopedPointer<NetworkObserver> network(new NetworkObserver(app.data()));
    view->rootContext()->setContextProperty("network", network.data());

    QScopedPointer<Settings> settings(new Settings(app.data()));
    view->rootContext()->setContextProperty("settings", settings.data());

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->showFullScreen();

    return app->exec();
}

