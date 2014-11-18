import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property int maxMargin
    topMargin: height - content.height

    signal toastMessage
    signal openBrowser
    signal openYoutube
    signal turnOff
    signal switchInput

    Column {
        id: content
        width: parent.width

        ControlButton {
            width: parent.width
            height: Theme.itemSizeSmall
            title: qsTr("Send toast message")
            onClicked: {
                panel.active = false
                panel.toastMessage()
            }
        }

        ControlButton {
            width: parent.width
            height: Theme.itemSizeSmall
            title: qsTr("Open link in browser")
            onClicked: {
                panel.active = false
                panel.openYoutube()
            }
        }

        ControlButton {
            width: parent.width
            height: Theme.itemSizeSmall
            title: qsTr("Open Youtube video")
            onClicked: {
                panel.active = false
                panel.openBrowser()
            }
        }

        ControlButton {
            width: parent.width
            height: Theme.itemSizeSmall
            title: qsTr("Turn off TV")
            onClicked: {
                panel.active = false
                panel.turnOff()
            }
        }

        ControlButton {
            width: parent.width
            height: Theme.itemSizeSmall
            title: qsTr("Switch input")
            onClicked: {
                panel.active = false
                panel.switchInput()
            }
        }

        ControlButton {
            width: parent.width
            height: Theme.itemSizeSmall
            title: qsTr("About")
            onClicked: {
                panel.active = false
                pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }
}
