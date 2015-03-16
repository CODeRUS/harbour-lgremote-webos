import QtQuick 2.1
import Sailfish.Silica 1.0

MouseArea {
    id: root

    width: 100
    height: 80

    property bool down: pressed && containsMouse

    property alias title: label.text
    property alias titleSize: label.font.pixelSize
    property alias bold: label.font.bold
    property alias icon: image.imageSource
    property alias color: background.color
    property int borderWidth: root.down ? 0 : 2

    Rectangle {
        id: background
        anchors.fill: root
        border.width: root.borderWidth
        border.color: Theme.highlightDimmerColor
        color: Theme.rgba(Theme.highlightBackgroundColor, root.down ? 1.0 : Theme.highlightBackgroundOpacity)
    }

    Label {
        id: label
        anchors.centerIn: root
        color: root.down ? Theme.highlightColor : Theme.primaryColor
    }

    ColoredImage {
        id: image
        anchors.centerIn: root
        highlighted: root.down
        highlightColor: Theme.highlightColor
        height: Math.min(root.height, root.width) / 5 * 3
        //width: (sourceSize.width * height) / sourceSize.height
    }
}
