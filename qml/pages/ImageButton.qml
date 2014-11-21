import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    property alias icon: image
    property bool down: pressed && containsMouse
    property bool highlighted: down
    property bool _showPress: highlighted || pressTimer.running

    onPressedChanged: {
        if (pressed) {
            pressTimer.start()
        }
    }
    onCanceled: pressTimer.stop()

    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall

    ColoredImage {
        id: image
        anchors.centerIn: parent
        opacity: parent.enabled ? 1.0 : 0.4

        highlighted: _showPress
    }

    Timer {
        id: pressTimer
        interval: 50
    }
}
