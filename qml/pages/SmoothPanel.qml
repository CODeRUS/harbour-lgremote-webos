import QtQuick 2.1
import Sailfish.Silica 1.0

Rectangle {
    id: panel
    property int topMargin: 200
    property bool active: false
    onActiveChanged: {
        if (active) {
            startShowAnimation()
        }
        else {
            startStopAnimation()
        }
    }
    default property alias _content: mover.children

    function startShowAnimation() {
        showAnimation.start()
    }

    function startStopAnimation() {
        hideAnimation.start()
    }

    anchors.fill: parent
    opacity: 0.0
    enabled: opacity > 0.0

    color: "#80000000"

    SequentialAnimation {
        id: showAnimation
        NumberAnimation {
            target: panel
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 200
        }
        NumberAnimation {
            target: mover
            property: "y"
            from: Screen.height
            to: panel.topMargin
            duration: 100
        }
    }

    SequentialAnimation {
        id: hideAnimation
        NumberAnimation {
            target: panel
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 200
        }
        NumberAnimation {
            target: mover
            property: "y"
            from: panel.topMargin
            to: Screen.height
            duration: 1
        }
    }

    MouseArea {
        anchors.fill: panel
        enabled: panel.active
        onClicked: panel.active = false
    }

    MouseArea {
        id: mover
        width: panel.width
        height: panel.height - panel.topMargin
        y: Screen.height
        clip: true
    }
}
