import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property PointerSocket socket
    topMargin: height - content.height

    Column {
        id: content

        width: parent.width

        Row {
            ControlButton {
                width: panel.width / 4
                icon: "../../images/icon-media-rewind.png"
                onClicked: socket.sendInput("button", "REWIND")
            }
            ControlButton {
                width: panel.width / 4
                icon: "../../images/icon-media-previous.png"
                onClicked: socket.sendInput("button", "GOTOPREV")
            }
            ControlButton {
                width: panel.width / 4
                icon: "../../images/icon-media-next.png"
                onClicked: socket.sendInput("button", "GOTONEXT")
            }
            ControlButton {
                width: panel.width / 4
                icon: "../../images/icon-media-fastforward.png"
                onClicked: socket.sendInput("button", "FASTFORWARD")
            }
        }

        Row {
            ControlButton {
                width: panel.width / 4
                icon: "../../images/icon-media-stop.png"
                onClicked: socket.sendInput("button", "STOP")
            }
            ControlButton {
                width: panel.width / 2
                icon: "../../images/icon-media-play.png"
                onClicked: socket.sendInput("button", "PLAY")
            }
            ControlButton {
                width: panel.width / 4
                icon: "../../images/icon-media-pause.png"
                onClicked: socket.sendInput("button", "PAUSE")
            }
        }

        Row {
            ControlButton {
                width: panel.width / 4
                color: Theme.rgba("red", down ? Theme.highlightBackgroundOpacity : 1.0)
                onClicked: socket.sendInput("button", "RED")
            }
            ControlButton {
                width: panel.width / 4
                color: Theme.rgba("green", down ? Theme.highlightBackgroundOpacity : 1.0)
                onClicked: socket.sendInput("button", "GREEN")
            }
            ControlButton {
                width: panel.width / 4
                color: Theme.rgba("orange", down ? Theme.highlightBackgroundOpacity : 1.0)
                onClicked: socket.sendInput("button", "YELLOW")
            }
            ControlButton {
                width: panel.width / 4
                color: Theme.rgba("blue", down ? Theme.highlightBackgroundOpacity : 1.0)
                onClicked: socket.sendInput("button", "BLUE")
            }
        }

        Row {
            ControlButton {
                width: panel.width / 3
                title: qsTr("HOME")
                onClicked: socket.sendInput("button", "HOME")
            }
            ControlButton {
                width: panel.width / 3
                icon: "../../images/icon-arrow-up.png"
                onClicked: socket.sendInput("button", "UP")
            }
            ControlButton {
                width: panel.width / 3
            }
        }

        Row {
            ControlButton {
                width: panel.width / 3
                icon: "../../images/icon-arrow-left.png"
                onClicked: socket.sendInput("button", "LEFT")
            }
            ControlButton {
                width: panel.width / 3
                title: qsTr("OK")
                onClicked: socket.sendInput("button", "ENTER")
            }
            ControlButton {
                width: panel.width / 3
                icon: "../../images/icon-arrow-right.png"
                onClicked: socket.sendInput("button", "RIGHT")
            }
        }

        Row {
            ControlButton {
                width: panel.width / 3
                title: qsTr("EXIT")
                onClicked: socket.sendInput("button", "EXIT")
            }
            ControlButton {
                width: panel.width / 3
                icon: "../../images/icon-arrow-down.png"
                onClicked: socket.sendInput("button", "DOWN")
            }
            ControlButton {
                width: panel.width / 3
                title: qsTr("BACK")
                onClicked: socket.sendInput("button", "BACK")
            }
        }
    }
}
