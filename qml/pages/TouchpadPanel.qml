import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property PointerSocket socket
    topMargin: 100

    Column {
        width: parent.width

        Row {
            id: controls
            ControlButton {
                width: 80
                height: 80
                icon: "image://theme/icon-m-rotate-left"
                onClicked: socket.sendInput("button", "BACK")
            }

            ControlButton {
                width: 80
                height: 80
                icon: "image://theme/icon-m-close"
                onClicked: socket.sendInput("button", "EXIT")
            }

            ControlButton {
                width: panel.width - 320
                height: 80
                icon: "image://theme/icon-m-home"
                onClicked: socket.sendInput("button", "HOME")
            }

            ControlButton {
                width: 80
                height: 80
                icon: "image://theme/icon-m-page-up"
                onClicked: socket.sendScroll(1)
                onPressed: scrollDownTimer.start()
                onReleased: scrollDownTimer.stop()

                Timer {
                    id: scrollDownTimer
                    repeat: true
                    interval: 600
                    onTriggered: socket.sendScroll(1)
                }
            }

            ControlButton {
                width: 80
                height: 80
                icon: "image://theme/icon-m-page-down"
                onClicked: socket.sendScroll(-1)
                onPressed: scrolUpTimer.start()
                onReleased: scrolUpTimer.stop()

                Timer {
                    id: scrolUpTimer
                    repeat: true
                    interval: 600
                    onTriggered: socket.sendScroll(-1)
                }
            }
        }

        MultiPointTouchArea {
            id: mTouchArea
            width: parent.width
            height: panel.height - panel.topMargin - controls.height
            enabled: socket.connected
            maximumTouchPoints: 2
            minimumTouchPoints: 1
            touchPoints: [
                TouchPoint { id: point1 },
                TouchPoint { id: point2 }
            ]
            property double pressTime
            property real lastDelta
            onPressed: {
                if (point1.pressed && !point2.pressed) {
                    var date = new Date()
                    pressTime = date.getTime()
                }
            }
            onReleased: {
                if (!point1.pressed && !point2.pressed) {
                    var date = new Date()
                    var releaseTime = date.getTime()
                    if (releaseTime - pressTime < 600
                            && (point1.x - point1.startX < 2.0)
                            && (point1.y - point1.startY < 2.0)) {
                        socket.sendClick()
                    }
                }
            }

            onUpdated: {
                if (point2.pressed) {
                    var stop = (point1.y + point2.y) / 2
                    var previous = (point1.previousY + point2.previousY) / 2
                    var delta = stop - previous
                    lastDelta -= delta
                    if (Math.abs(lastDelta) > 10) {
                        socket.sendScroll(Math.round(lastDelta / 10))
                        lastDelta = 0.0
                    }
                }
                else {
                    lastDelta = 0.0
                    if (point1.pressed) {
                        var accel = appWindow.configuration.value
                        var dx = (point1.x - point1.previousX) * accel
                        var dy = (point1.y - point1.previousY) * accel
                        socket.sendMove(dx, dy)
                    }
                    else {

                    }
                }
            }

            Rectangle {
                id: background
                anchors.fill: parent
                border.width: 2
                border.color: Theme.highlightDimmerColor
                color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
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
                text: qsTr("Drag one finger to move cursor, two fingers to scroll, tap to click")
            }
        }
    }
}
