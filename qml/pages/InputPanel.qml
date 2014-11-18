import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property int maxMargin
    property MainSocket socket
    property var inputList: []
    onInputListChanged: {
        inputModel.clear()
        for (var i = 0; i < inputList.length; i++) {
            inputModel.append(inputList[i])
        }
    }
    topMargin: height - content.height

    Column {
        id: content
        width: parent.width

        Repeater {
            width: parent.width
            delegate: Component {
                ControlButton {
                    width: parent.width
                    height: Theme.itemSizeSmall
                    title: model.label
                    onClicked: {
                        socket.sendCommand("", "request", "ssap://tv/switchInput", {"inputId": model.id})
                        panel.active = false
                    }
                }
            }
            model: ListModel {
                id: inputModel
            }
        }
    }
}
