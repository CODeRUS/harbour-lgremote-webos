import QtQuick 2.1
import Sailfish.Silica 1.0


Page {
    id: page

    function discover() {
        discoveredTargets.clear()
        network.startSearch();
        timeoutTimer.restart()
    }

    Component.onCompleted: {
        discover()
    }

    Connections {
        target: network
        onDiscovered: {
            discoveredTargets.append({"name": result.name,
                                        "ip": result.ip,
                               "modelNumber": result.modelNumber,
                              "manufacturer": result.manufacturer})
        }
    }

    ListModel {
        id: discoveredTargets
    }

    Component {
        id: discoveredDelegate
        BackgroundItem {
            id: innerItem
            height: Theme.itemSizeLarge

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }

                Row {
                    spacing: Theme.paddingLarge

                    Label {
                        color: innerItem.down ? Theme.highlightColor : Theme.primaryColor
                        text: model.name
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        color: innerItem.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        text: model.modelNumber
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Label {
                    color: innerItem.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: model.manufacturer
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    color: innerItem.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: model.ip
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            onClicked: {
                console.log("Selected ip: " + model.ip)
                pageStack.replace(Qt.resolvedUrl("MainPage.qml"), {"model": model})
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Discover by ip")
                onClicked: {
                    ipField.visible = true
                    ipField.forceActiveFocus()
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: discover()
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Discover webOS TV")
            }

            TextField {
                id: ipField
                width: parent.width
                placeholderText: "192.168.1.123"
                label: qsTr("IP address")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    network.searchIp(text)
                    page.forceActiveFocus()
                    ipField.visible = false
                }
                visible: false
            }

            Repeater {
                id: repeater
                width: parent.width
                model: discoveredTargets
                delegate: discoveredDelegate
            }
        }

        VerticalScrollDecorator {}
    }

    Label {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Taking too long? Check if you have compatible webOS Smart TV, it's powered and switched on")
        visible: discoveredTargets.count == 0 && !timeoutTimer.running
    }

    Timer {
        id: timeoutTimer
        interval: 10000
        repeat: false
        running: true
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: visible
        visible: discoveredTargets.count == 0
    }

    Label {
        anchors.top: busyIndicator.bottom
        visible: busyIndicator.running
        text: qsTr("Searching devices...")
        anchors.horizontalCenter: busyIndicator.horizontalCenter
    }
}


