import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.coderus.websockets 1.0
import "pages"

ApplicationWindow
{
    id: appWindow

    property bool soundMuted: false
    property int soundVolume: 0

    property string currentApplication
    property string currentApplicationId

    property string currentChannelNumber
    property string currentChannelName

    property bool coverActionActive: false

    property string coverIconLeft: "../../images/icon-cover-pause.png"
    property string coverIconRight: "../../images/icon-cover-play.png"

    function coverLeftClicked() {
        pauseAction()
    }

    function coverRightClicked() {
        playAction()
    }

    function getSocketStatus(status) {
        switch (status) {
        case WebSocket.Connecting: return "Connecting..."
        case WebSocket.Open:       return "Connected"
        case WebSocket.Closing:    return "Disconnecting..."
        case WebSocket.Closed:     return "Disconnected"
        case WebSocket.Error:      return "Connection Error"
        }
    }

    signal playAction
    signal pauseAction
    signal volumeUpAction
    signal volumeDownAction

    signal keypressEnter
    signal keypressBackspace
    signal keypressText(string text)

    initialPage: Component { DiscoverPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Component.onCompleted: {
        var volumeControlItem = Qt.createQmlObject(Qt.atob("aW1wb3J0IFF0UXVpY2sgMi4wOyBpbXBvcnQgU2FpbGZpc2guTWVkaWEgMS4wOyBpbXBvcnQgb3JnLm5lbW9tb2JpbGUucG9saWN5IDEuMDsgSXRlbSB7aWQ6IHJvb3Q7IHNpZ25hbCB2b2x1bWVVcDsgc2lnbmFsIHZvbHVtZURvd247IE1lZGlhS2V5IHtlbmFibGVkOiBrZXlzUmVzb3VyY2UuYWNxdWlyZWQ7IGtleTogUXQuS2V5X1ZvbHVtZVVwOyBvblByZXNzZWQ6IHJvb3Qudm9sdW1lVXAoKX0gTWVkaWFLZXkge2VuYWJsZWQ6IGtleXNSZXNvdXJjZS5hY3F1aXJlZDsga2V5OiBRdC5LZXlfVm9sdW1lRG93bjsgb25QcmVzc2VkOiByb290LnZvbHVtZURvd24oKX0gUGVybWlzc2lvbnMge2lkOiBwZXJtaXNzaW9uczsgZW5hYmxlZDogYXBwV2luZG93LmFwcGxpY2F0aW9uQWN0aXZlOyBhcHBsaWNhdGlvbkNsYXNzOiAicGxheWVyIjsgUmVzb3VyY2Uge2lkOiBrZXlzUmVzb3VyY2U7IHR5cGU6IFJlc291cmNlLlNjYWxlQnV0dG9uOyBvcHRpb25hbDogdHJ1ZX19fQ=="), appWindow)
        volumeControlItem.volumeUp.connect(appWindow.volumeUpAction)
        volumeControlItem.volumeDown.connect(appWindow.volumeDownAction)
    }
}
