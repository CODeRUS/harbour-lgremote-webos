import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property MainSocket socket
    property var appList: []
    onAppListChanged: {
        appsModel.clear()
        for (var i = 0; i < appList.length; i++) {
            appsModel.append(appList[i])
        }
    }

    Rectangle {
        id: background
        anchors.fill: gridView
        border.width: 2
        border.color: Theme.highlightDimmerColor
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    }

    SilicaGridView {
        id: gridView
        anchors.fill: parent
        cellWidth: width / 4
        cellHeight: width / 4
        clip: true
        model: ListModel {
            id: appsModel
        }

        delegate: Component {
            BackgroundItem {
                id: item
                height: GridView.view.cellHeight
                width: GridView.view.cellWidth

                Column {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingSmall
                    }
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: height
                        height: item.height - label.height - Theme.paddingMedium
                        source: model.icon
                        smooth: true
                        cache: true
                        asynchronous: true
                    }
                    Label {
                        id: label
                        width: parent.width
                        text: model.title
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }

                onClicked: {
                    socket.launchApp(model.id)
                    panel.active = false
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
