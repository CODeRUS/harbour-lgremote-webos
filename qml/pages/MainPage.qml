import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: mainPage
    allowedOrientations: Orientation.Portrait

    property var model
    onModelChanged: {
        if (model != undefined) {
            deviceIp = model.ip
            deviceName = model.name
            modelNumber = model.modelNumber
            manufacturer = model.manufacturer
            var ws = "ws://" + deviceIp + ":3000"
            console.log("connecting to: " + ws)
            mainSocket.url = ws
        }
    }

    function openBrowser(text) {
        var isYoutube = text.indexOf("youtube.com/watch?v=") != -1
        if (isYoutube) {
            var videoId = text.indexOf("watch?v=")
            if (videoId != -1) {
                var res = text.substring(videoId + 8)
                mainSocket.openYoutube(res)
            }
            else {
                mainSocket.browserUrl(text)
            }
        }
        else {
            mainSocket.browserUrl(text)
        }
    }

    Component.onCompleted: {
        mainSocket.active = true
        network.stopSearch()

        var dbusAdaptor = Qt.createQmlObject(Qt.atob("aW1wb3J0IFF0UXVpY2sgMi4xOyBpbXBvcnQgb3JnLm5lbW9tb2JpbGUuZGJ1cyAxLjA7IERCdXNBZGFwdG9yIHtzZXJ2aWNlOiAiaGFyYm91ci5jb2RlcnVzLmxncmVtb3RlIjsgcGF0aDogIi9oYXJib3VyL2NvZGVydXMvbGdyZW1vdGUiOyBpZmFjZTogImhhcmJvdXIuY29kZXJ1cy5sZ3JlbW90ZSI7IHhtbDogUXQuYXRvYigiUEdsdWRHVnlabUZqWlNCdVlXMWxQU0pvWVhKaWIzVnlMbU52WkdWeWRYTXViR2R5WlcxdmRHVWlQanh0WlhSb2IyUWdibUZ0WlQwaWIzQmxia3hwYm1zaVBqeGhibTV2ZEdGMGFXOXVJRzVoYldVOUltOXlaeTVtY21WbFpHVnphM1J2Y0M1RVFuVnpMazFsZEdodlpDNU9iMUpsY0d4NUlpQjJZV3gxWlQwaWRISjFaU0l2UGp4aGNtY2daR2x5WldOMGFXOXVQU0pwYmlJZ2RIbHdaVDBpY3lJdlBqd3ZiV1YwYUc5a1Bqd3ZhVzUwWlhKbVlXTmxQZz09Iik7IHNpZ25hbCBvcGVuTGluayhzdHJpbmcgbGluayl9"), mainPage)
        dbusAdaptor.openLink.connect(mainPage.openBrowser)
    }

    property string deviceIp
    property string deviceName
    property string modelNumber
    property string manufacturer

    property string pointerAddress

    Connections {
        target: appWindow
        onPauseAction: {
            //pointerSocket.sendInput("button", "PAUSE")
            mainSocket.sendPause()
        }
        onPlayAction: {
            //pointerSocket.sendInput("button", "PLAY")
            mainSocket.sendPlay()
        }
        onVolumeUpAction: {
            mainSocket.sendVolumeUp()
            //pointerSocket.sendInput("button", "VOLUMEUP")
        }
        onVolumeDownAction: {
            mainSocket.sendVolumeDown()
            //pointerSocket.sendInput("button", "VOLUMEDOWN")
        }
    }

    PointerSocket {
        id: pointerSocket
        url: mainPage.pointerAddress
    }

    MainSocket {
        id: mainSocket

        onConnected: {
            var msg = settings.getAuthMessage(deviceIp)
            mainSocket.sendLogMessage(msg)
        }

        onDisconnected: {
            pageStack.replace(Qt.resolvedUrl("DiscoverPage.qml"))
        }

        onReadyChanged: coverActionActive = ready

        onPointerSocketReceived: {
            pointerAddress = url
        }

        onPairingReceived: {
            pin.active = true
        }

        onKeyboardFocusChanged: {
            toggleKeyboard(keyboardFocus)
        }
    }

    function toggleKeyboard(haveFocus) {
        console.log("toggleKeyboard: " + haveFocus)
        if (haveFocus) {
            invisibleInput.forceActiveFocus()
        }
        else {
            mainPage.forceActiveFocus()
        }
    }

    TextEdit {
        id: invisibleInput
        width: 0
        height: 0
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        onTextChanged: {
            if (text.length == 1) {
                mainSocket.sendText(text)
            }
            text = ""
        }
        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace) {
                mainSocket.sendBackspace()
                event.accepted = true;
            }
            else if (event.key == Qt.Key_Return) {
                mainSocket.sendEnter()
                event.accepted = true;
            }
        }
    }

    Column {
        id: content
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
        }
        property int smallItemSize: (width - (Theme.itemSizeExtraLarge * 2)) / 4

        spacing: Theme.paddingMedium

        Label {
            width: parent.width
            text: currentApplication
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            visible: currentApplicationId == "com.webos.app.livetv"
            text: mainSocket.channelName
        }

        Row {
            height: Theme.itemSizeExtraLarge

            ControlButton {
                height: parent.height
                width: content.smallItemSize
                title: "-"
                titleSize: height / 2
                color: down ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
                borderWidth: 0
                onClicked: mainSocket.sendVolumeDown() //pointerSocket.sendInput("button", "VOLUMEDOWN")
            }

            ProgressCircleBase {
                progressColor: Theme.highlightColor
                backgroundColor: Theme.highlightDimmerColor

                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                value: mainSocket.volume / 100

                Column {
                    anchors.centerIn: parent

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: mainSocket.volume
                    }

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../../images/" + (mainSocket.muting ? "volume-muted" : "volume") + ".png"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mainSocket.toggleMute()
                }
            }

            ControlButton {
                height: parent.height
                width: content.smallItemSize
                title: "+"
                titleSize: height / 2
                color: down ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
                borderWidth: 0
                onClicked: mainSocket.sendVolumeUp() //pointerSocket.sendInput("button", "VOLUMEUP")
            }

            ControlButton {
                height: parent.height
                width: content.smallItemSize
                title: "-"
                titleSize: height / 2
                color: down ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
                borderWidth: 0
                onClicked: pointerSocket.sendInput("button", "CHANNELUP")
            }

            Item {
                height: parent.height
                width: height

                Label {
                    anchors.centerIn: parent
                    text: qsTr("CH: %1").arg(mainSocket.channelNumber)
                }
            }

            ControlButton {
                height: parent.height
                width: content.smallItemSize
                title: "+"
                titleSize: height / 2
                color: down ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
                borderWidth: 0
                onClicked: pointerSocket.sendInput("button", "CHANNELDOWN")
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingSmall

            IconButton {
                icon.source: "image://theme/icon-m-mouse"
                onClicked: touchpad.active = true
            }

            IconButton {
                icon.source: "image://theme/icon-m-keyboard"
                onClicked: toggleKeyboard(true)
            }

            IconButton {
                icon.source: "image://theme/icon-m-events"
                onClicked: channels.active = true
            }

            ImageButton {
                icon.source: "../../images/icon-m-arrows.png"
                onClicked: actions.active = true
            }

            IconButton {
                icon.source: "image://theme/icon-m-levels"
                onClicked: apps.active = true
            }

            IconButton {
                icon.source: "image://theme/icon-m-favorite"
                onClicked: extra.active = true
            }
        }
    }

    TouchpadPanel {
        id: touchpad
        socket: pointerSocket
        topMargin: content.height + content.anchors.topMargin
    }

    ChannelsPanel {
        id: channels
        socket: mainSocket
        channelsList: mainSocket.channelsTv
        currentChannelId: mainSocket.channelId
        topMargin: content.height + content.anchors.topMargin
    }

    ActionsPanel {
        id: actions
        socket: pointerSocket
        //topMargin: content.height + content.anchors.topMargin
    }

    ApplicationsPanel {
        id: apps
        socket: mainSocket
        appList: mainSocket.appsList
        topMargin: content.height + content.anchors.topMargin
    }

    ExtraPanel {
        id: extra
        maxMargin: content.height + content.anchors.topMargin

        onToastMessage: {
            toast.active = true
        }

        onOpenBrowser: {
            browser.active = true
        }

        onOpenYoutube: {
            youtube.active = true
        }

        onTurnOff: {
            mainSocket.sendTurnOff()
        }

        onSwitchInput: {
            inputs.active = true
        }
    }

    TextPanel {
        id: toast
        maxMargin: content.height + content.anchors.topMargin
        textField.placeholderText: qsTr("Enter message...")

        onInputComplete: mainSocket.sendShowToast(text)
    }

    TextPanel {
        id: browser
        maxMargin: content.height + content.anchors.topMargin
        textField.placeholderText: qsTr("Enter url...")

        onInputComplete: {
            openBrowser(text)
        }
    }

    TextPanel {
        id: youtube
        maxMargin: content.height + content.anchors.topMargin
        textField.placeholderText: qsTr("Enter url or video id...")

        onInputComplete: {
            var videoId = text.indexOf("watch?v=")
            if (videoId == -1) {
                mainSocket.openYoutube(text)
            }
            else {
                var res = str.substring(videoId + 8)
                mainSocket.openYoutube(res)
            }
        }
    }

    TextPanel {
        id: pin
        maxMargin: content.height + content.anchors.topMargin
        textField.placeholderText: qsTr("Enter pin...")
        textField.inputMethodHints: Qt.ImhDigitsOnly
        textField.validator: RegExpValidator { regExp: /^[0-9]{3}$/; }
        onAcceptableInput: {
            if (pin.textField.acceptableInput) {
                mainSocket.sendPin(pin.textField.text)
                pin.active = false
            }
        }

        onInputComplete: mainSocket.sendPin(pin.textField.text)
    }

    InputPanel {
        id: inputs
        inputList: mainSocket.inputList
        maxMargin: content.height + content.anchors.topMargin
        socket: mainSocket
    }

    MouseArea {
        id: dimmer
        anchors.fill: parent
        enabled: invisibleInput.focus

        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            visible: parent.enabled
        }

        onClicked: {
            toggleKeyboard(false)
        }
    }
}





