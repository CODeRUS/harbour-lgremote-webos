import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.lgremote.webos.websockets 1.0
import "pages"
;import Sailfish.Media 1.0
;import org.nemomobile.policy 1.0
;import org.nemomobile.configuration 1.0

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

    initialPage: Component { DiscoverPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

        property var configuration: ConfigurationValue {
            key: "/apps/harbour-lgremote-webos/touchpadAcceleration"
            defaultValue: 1.0
        }

            MediaKey {
                enabled: keysResource.acquired
                key: Qt.Key_VolumeUp
                onPressed: {
                    volumeUpAction()
                    upTimer.interval = 400
                    upTimer.start()
                }
                onReleased: upTimer.stop()
                Timer {
                    id: upTimer
                    repeat: true
                    onTriggered: {
                        interval = 60
                        volumeUpAction()
                    }
                }
            }
            MediaKey {
                enabled: keysResource.acquired
                key: Qt.Key_VolumeDown
                onPressed: {
                    volumeDownAction()
                    downTimer.interval = 400
                    downTimer.start()
                }
                onReleased: downTimer.stop()
                Timer {
                    id: downTimer
                    repeat: true
                    onTriggered: {
                        interval = 60
                        volumeDownAction()
                    }
                }
            }
            Permissions {
                id: permissions
                enabled: appWindow.applicationActive && appWindow.coverActionActive
                applicationClass: "player"
                Resource {
                    id: keysResource
                    type: Resource.ScaleButton
                    optional: true
                }
            }
}
