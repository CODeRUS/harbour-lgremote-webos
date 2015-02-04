import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property MainSocket socket
    property var channelsList: []
    property string currentChannelId
    onChannelsListChanged: {
        channelsFilterModel.update()
    }
    topMargin: 100

    Rectangle {
        id: background
        anchors.fill: listView
        border.width: 2
        border.color: Theme.highlightDimmerColor
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        property string searchPattern
        onSearchPatternChanged: {
            channelsFilterModel.update()
        }
        clip: true
        currentIndex: -1
        header: SearchField {
            width: parent.width
            placeholderText: qsTr("Channels search")

            onTextChanged: {
                listView.searchPattern = text
            }
        }
        delegate: Component {
            id: channelsDelegate
            BackgroundItem {
                id: item
                height: Theme.itemSizeSmall
                width: ListView.view.width

                Item {
                    anchors {
                        fill: parent
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                    }

                    Label {
                        id: numLabel
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        text: Theme.highlightText(model.channelNumber, listView.searchPattern, Theme.highlightColor)
                        font.bold: currentChannelId == model.channelId
                    }

                    Label {
                        id: nameLabel
                        anchors {
                            left: numLabel.right
                            leftMargin: Theme.paddingLarge
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }
                        text: Theme.highlightText(model.channelName, listView.searchPattern, Theme.highlightColor)
                        wrapMode: Text.NoWrap
                        truncationMode: TruncationMode.Fade
                        font.bold: currentChannelId == model.channelId
                    }
                }

                onClicked: {
                    socket.sendOpenChannel(model.channelId)
                }
            }
        }
        model: ListModel {
            id: channelsFilterModel

            function update() {
                clear()
                if (channelsList == undefined) {
                    return
                }

                for (var i = 0; i < channelsList.length; i++) {
                    if (listView.searchPattern == ""
                            || channelsList[i].channelName.indexOf(listView.searchPattern) >= 0
                            || channelsList[i].channelNumber.indexOf(listView.searchPattern) >= 0) {
                        append(channelsList[i])
                    }
                }
            }
        }

        ViewPlaceholder {
            text: qsTr("You have no channels")
        }

        VerticalScrollDecorator {}
    }
}
