#include "settings.h"
#include <QProcess>

Settings::Settings(QObject *parent) :
    QObject(parent)
{
    nam = new QNetworkAccessManager(this);

    QSettings settings;
    settings.sync();
    QString code = settings.value("code", "demo").toString();
    checkActivation(code);

    QProcess *app = new QProcess(this);
    app->start("/bin/rpm", QStringList() << "-qa" << "--queryformat" << "%{version}" <<  "harbour-lgremote-webos");
    QObject::connect(app, SIGNAL(readyRead()), this, SLOT(onVersionReply()));
}

QString Settings::bannerPath() const
{
    return _bannerPath;
}

QString Settings::version() const
{
    return _version;
}

void Settings::checkActivation(const QString &code)
{
    QSettings settings;
    settings.setValue("code", code);
    settings.sync();

    QString url(QByteArray::fromBase64("aHR0cHM6Ly9jb2RlcnVzLm9wZW5yZXBvcy5uZXQvd2hpdGVzb2Z0L2xncmVtb3RlLyUx="));
    QObject::connect(nam->get(QNetworkRequest(QUrl(url.arg(code)))), SIGNAL(finished()), this, SLOT(onActivationReply()));
}

void Settings::onActivationReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (reply) {
        _bannerPath = QString::fromUtf8(reply->readAll());
        Q_EMIT bannerPathChanged();
    }
}

void Settings::onVersionReply()
{
    QProcess *app = qobject_cast<QProcess*>(sender());
    if (app) {
        _version = app->readAll();
        Q_EMIT versionChanged();
    }
}

QString Settings::getAuthMessage(const QString &ip) const
{
    QSettings settings;
    settings.sync();
    QString settingsKey = ip;
    QString authKey = settings.value(settingsKey.replace(".", "_"), QString()).toString();
    QString msg = QString(AUTH_TEMPLATE).arg("0").arg(authKey);
    return msg;
}

void Settings::setAuthKey(const QString &ip, const QString &key)
{
    QSettings settings;
    QString settingsKey = ip;
    settings.setValue(settingsKey.replace(".", "_"), key);
    settings.sync();
}
