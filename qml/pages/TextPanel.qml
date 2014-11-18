import QtQuick 2.1
import Sailfish.Silica 1.0

SmoothPanel {
    id: panel
    property int maxMargin
    topMargin: height - fieldClipping.height
    property alias textField: field

    signal inputComplete(string text)
    signal acceptableInput

    onActiveChanged: {
        if (active) {
            field.forceActiveFocus()
        }
    }

    function startShowAnimation() {
        panel.opacity = 1.0
        panel.y = panel.topMargin
    }

    function startStopAnimation() {
        panel.opacity = 0.0
        panel.y = Screen.height
    }

    Item {
        id: fieldClipping
        width: parent.width
        height: Theme.itemSizeSmall
        clip: true

        Rectangle {
            anchors.fill: parent
            border.width: 2
            border.color: Theme.highlightDimmerColor
            color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        }

        TextField {
            id: field
            width: parent.width
            textTopMargin: Theme.paddingLarge
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: {
                inputComplete(text)
                panel.active = false
            }
            background: Item {}
            onAcceptableInputChanged: if (field.acceptableInput) panel.acceptableInput()
        }
    }
}
