#include <sailfishapp.h>
#include <QGuiApplication>
#include <QtQuick/QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDateTime>
#include <QTextStream>

#include "networkobserver.h"
#include "settings.h"

const char* msgTypeToString(QtMsgType type)
{
    switch (type) {
    case QtDebugMsg:
        return "D";
    case QtWarningMsg:
        return "W";
    case QtCriticalMsg:
        return "C";
    case QtFatalMsg:
        return "F";
        //abort();
    default:
        return "D";
    }
}

QString simpleLog(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    Q_UNUSED(context);
    return QString("[%1 %2] %3\n").arg(msgTypeToString(type))
                                     .arg(QDateTime::currentDateTime().toString("hh:mm:ss"))
                                     .arg(message);
}

void printLog(const QString &message)
{
    QTextStream(stdout) << message;
}

void stdoutHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    printLog(simpleLog(type, context, msg));
    if (type == QtFatalMsg)
        abort();
}

int main(int argc, char *argv[])
{
    qInstallMessageHandler(stdoutHandler);

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationDisplayName("LG Remote");
    app->setApplicationName("LG Remote");
    app->setApplicationVersion("0.1.4");
    app->setOrganizationName("harbour-lgremote-webos");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setTitle("LG Remote");

    QFile versionFile("/etc/sailfish-release");
    versionFile.open(QFile::ReadOnly);
    QString versionData(versionFile.readAll());
    versionFile.close();
    int versionp1 = versionData.split("VERSION_ID=").last().split(".").at(1).toInt();
    if (versionp1 > 0) {
        view->engine()->addImportPath("/usr/share/harbour-lgremote-webos/import/u9");
    }
    else {
        view->engine()->addImportPath("/usr/share/harbour-lgremote-webos/import/u8");
    }

    QScopedPointer<NetworkObserver> network(new NetworkObserver(app.data()));
    view->rootContext()->setContextProperty("network", network.data());

    QScopedPointer<Settings> settings(new Settings(app.data()));
    view->rootContext()->setContextProperty("settings", settings.data());

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->showFullScreen();

    return app->exec();
}

