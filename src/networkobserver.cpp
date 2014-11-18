#include "networkobserver.h"

#include <QtNetwork/QUdpSocket>
#include <QtCore/QStringList>
#include <QNetworkInterface>
#include <QNetworkAddressEntry>
#include <QNetworkRequest>
// C
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#ifndef Q_WS_WIN
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#endif

#include <QDebug>
#include <QTimer>
#include <QXmlQuery>
#include <QXmlResultItems>

#define SSDP_BROADCAST_ADDRESS "239.255.255.250"
#define SSDP_PORT_NUMBER 1900
#define SSDP_PORT "1900"
#define WEBOSSCREEN "urn:lge-com:service:webos-second-screen:1"

static const int SSDPPortNumber = SSDP_PORT_NUMBER;
static const char SSDPBroadCastAddress[] = SSDP_BROADCAST_ADDRESS;

NetworkObserver::NetworkObserver(QObject *parent) :
    QObject(parent)
{
    nam = new QNetworkAccessManager(this);
    timeoutTimer = new QTimer(this);
    timeoutTimer->setSingleShot(false);
    timeoutTimer->setInterval(30000);
    QObject::connect(timeoutTimer, SIGNAL(timeout()), this, SIGNAL(timeout()));
}

NetworkObserver::~NetworkObserver()
{
}

void NetworkObserver::startSearch()
{
    if (timeoutTimer->isActive()) {
        timeoutTimer->stop();
    }
    discoveredDevices.clear();

    // send a HTTP M-SEARCH message to 239.255.255.250:1900
    const char mSearchMessage[] =
        "M-SEARCH * HTTP/1.1\r\n"
        "HOST: "SSDP_BROADCAST_ADDRESS":"SSDP_PORT"\r\n"
        "ST: "WEBOSSCREEN"\r\n"
        "MAN: \"ssdp:discover\"\r\n"
        "MX: 30\r\n" // max number of seconds to wait for response
        "\r\n";
    const int mSearchMessageLength = sizeof(mSearchMessage) / sizeof(mSearchMessage[0]);

    foreach (QNetworkInterface iface, QNetworkInterface::allInterfaces()) {
        foreach (QNetworkAddressEntry addr, iface.addressEntries()) {
            QUdpSocket *socket = new QUdpSocket(this);
            QObject::connect(socket, SIGNAL(readyRead()), SLOT(onUdpSocketReadyRead()));
            QObject::connect(this, SIGNAL(timeout()), socket, SLOT(deleteLater()));
            if (addr.ip().protocol() == QUdpSocket::IPv4Protocol && socket->bind(addr.ip(), SSDPPortNumber + 1 ,QUdpSocket::ShareAddress)) {
                //qDebug() << addr.ip().toString();
                socket->joinMulticastGroup(QHostAddress(SSDPBroadCastAddress));
                socket->writeDatagram( mSearchMessage, mSearchMessageLength, QHostAddress(SSDPBroadCastAddress), SSDPPortNumber );
            }
            else {
                socket->deleteLater();
            }
        }
    }

    timeoutTimer->start();
}

void NetworkObserver::stopSearch()
{
    if (timeoutTimer->isActive()) {
        timeoutTimer->stop();
    }
    Q_EMIT timeout();
}

void NetworkObserver::searchIp(const QString &ip)
{
    QString location("http://%1:1939/");
    checkDeviceInfo(location.arg(ip));
}

void NetworkObserver::handleMessage(const QByteArray &message)
{
    const QStringList lines = QString::fromUtf8( message ).split( "\r\n" );

    // first read first line and see if contains a HTTP 200 OK message or
    // "HTTP/1.1 200 OK"
    // "NOTIFY * HTTP/1.1"
    const QString firstLine = lines.first();
    if( ! firstLine.contains("HTTP")
        || (! firstLine.contains("NOTIFY")
            && ! firstLine.contains("200 OK")) )
        return;

    // read all lines and try to find the location field
    foreach( const QString& line, lines )
    {
        const int separatorIndex = line.indexOf( ':' );
        const QString key = line.left( separatorIndex ).toUpper();
        const QString value = line.mid( separatorIndex+1 ).trimmed();

        if( key == QLatin1String("LOCATION") )
        {
            checkDeviceInfo(value);
        }
    }
}

void NetworkObserver::onUdpSocketReadyRead()
{
    QUdpSocket *socket = qobject_cast<QUdpSocket*>(sender());
    if (socket) {
        const int pendingDatagramSize = socket->pendingDatagramSize();

        QByteArray message(pendingDatagramSize, 0);
        const int bytesRead = socket->readDatagram( message.data(), pendingDatagramSize );
        if( bytesRead == -1 )
            return;

        handleMessage(message);
    }
}

void NetworkObserver::checkDeviceInfo(const QString &server)
{
    if (discoveredDevices.contains(server)) {
        return;
    }
    else {
        discoveredDevices.append(server);
    }

    QXmlQuery query;
    query.setNetworkAccessManager(nam);
    query.setFocus(QUrl(server));

    QString queryTemplate("declare default element namespace \"urn:schemas-upnp-org:device-1-0\"; /root/device/%1/string()");

    query.setQuery(queryTemplate.arg("friendlyName"));
    QString friendlyName;
    query.evaluateTo(&friendlyName);
    friendlyName = friendlyName.trimmed();

    query.setQuery(queryTemplate.arg("manufacturer"));
    QString manufacturer;
    query.evaluateTo(&manufacturer);
    manufacturer = manufacturer.trimmed();

    query.setQuery(queryTemplate.arg("modelNumber"));
    QString modelNumber;
    query.evaluateTo(&modelNumber);
    modelNumber = modelNumber.trimmed();

    qDebug() << server << friendlyName << manufacturer << modelNumber;
    QVariantMap result;
    result["ip"] = QUrl(server).host();
    result["name"] = friendlyName;
    result["manufacturer"] = manufacturer;
    result["modelNumber"] = modelNumber;
    Q_EMIT discovered(result);
}
