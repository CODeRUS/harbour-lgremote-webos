import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: page

    Flickable {
        anchors.fill: page
        contentHeight: content.height

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About")
                width: page.width
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: qsTr("webOS TV Remote control\nonly for webOS Smart TV")
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Label {
                text: qsTr("version %1").arg(settings.version)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Label {
                text: qsTr("by coderus in 0x7DE")
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: settings.bannerPath
                asynchronous: true
                cache: true
            }

            Label {
                text: qsTr("Send your donations via")
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Button {
                text: "PayPal EUR"
                width: 300
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ovi.coderus%40gmail%2ecom&lg=en&lc=US&item_name=Donation%20for%20coderus%20webOS%20TV%20Remote&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHostedGuest")
                }
            }

            Button {
                text: "PayPal USD"
                width: 300
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ovi.coderus%40gmail%2ecom&lg=en&lc=US&item_name=Donation%20for%20coderus%20webOS%20TV%20Remote&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHostedGuest")
                }
            }

            Button {
                text: qsTr("Activate product")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    codeField.visible = true
                    codeField.forceActiveFocus()
                }
            }

            TextField {
                id: codeField
                width: parent.width
                placeholderText: qsTr("Enter your PayPal e-mail")
                label: qsTr("PayPal e-mail")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    settings.checkActivation(text)
                    page.forceActiveFocus()
                    codeField.visible = false
                }
                visible: false
            }
        }

        VerticalScrollDecorator {}
    }
}
