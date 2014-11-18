#ifndef NETWORKOBSERVER_H
#define NETWORKOBSERVER_H

#define QT_DEBUG_TM_NETWORK_OBSERVER

#include <QObject>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTimer>

class NetworkObserver : public QObject
{
    Q_OBJECT
public:
    explicit NetworkObserver(QObject *parent = 0);
    virtual ~NetworkObserver();

public Q_SLOTS:
    void startSearch();
    void stopSearch();
    void searchIp(const QString &ip);

Q_SIGNALS:
    void discovered(const QVariantMap &result);
    void timeout();

private:
    QNetworkAccessManager *nam;
    QTimer *timeoutTimer;
    QStringList discoveredDevices;

protected:
    void handleMessage( const QByteArray& message );

protected Q_SLOTS:
    void onUdpSocketReadyRead();
    void checkDeviceInfo(const QString &server);
};

#endif // NETWORKOBSERVER_H
