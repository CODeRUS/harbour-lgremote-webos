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

    Component.onCompleted: {
        mainSocket.active = true
        network.stopSearch()
    }

    property string deviceIp
    property string deviceName
    property string modelNumber
    property string manufacturer

    property string pointerAddress

    Connections {
        target: appWindow
        onPauseAction: {
            pointerSocket.sendInput("button", "PAUSE")
        }
        onPlayAction: {
            pointerSocket.sendInput("button", "PLAY")
        }
        onVolumeUpAction: {
            pointerSocket.sendInput("button", "VOLUMEUP")
        }
        onVolumeDownAction: {
            pointerSocket.sendInput("button", "VOLUMEDOWN")
        }
        onKeypressEnter: {
            mainSocket.sendCommand("", "request", "ssap://com.webos.service.ime/sendEnterKey")
        }
        onKeypressBackspace: {
            mainSocket.sendCommand("", "request", "ssap://com.webos.service.ime/deleteCharacters", {"count": 1})
        }
        onKeypressText: {
            mainSocket.sendCommand("", "request", "ssap://com.webos.service.ime/insertText", {"text": text, "replace": false})
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
                keypressText(text)
            }
            text = ""
        }
        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace) {
                keypressBackspace()
                event.accepted = true;
            }
            else if (event.key == Qt.Key_Return) {
                keypressEnter()
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
        //visible: !invisibleInput.focus
        //         && !touchpad.active
        //         && !channels.active
        //         && !actions.active

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
                onClicked: pointerSocket.sendInput("button", "VOLUMEDOWN")
            }

            ProgressCircleBase {
                progressColor: Theme.highlightColor
                backgroundColor: Theme.highlightDimmerColor

                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                value: mainSocket.volume / 50

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
                    onClicked: mainSocket.sendCommand("", "request", "ssap://audio/setMute", {"mute": !mainSocket.muting})
                }
            }

            ControlButton {
                height: parent.height
                width: content.smallItemSize
                title: "+"
                titleSize: height / 2
                color: down ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
                borderWidth: 0
                onClicked: pointerSocket.sendInput("button", "VOLUMEUP")
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

        onTurnOff: {
            mainSocket.sendCommand("", "request", "ssap://system/turnOff")
        }

        onSwitchInput: {
            inputs.active = true
        }
    }

    TextPanel {
        id: toast
        maxMargin: content.height + content.anchors.topMargin
        textField.placeholderText: qsTr("Enter message...")

        onInputComplete: mainSocket.sendCommand("", "request", "ssap://system.notifications/createToast", {"message": text})
    }

    TextPanel {
        id: browser
        maxMargin: content.height + content.anchors.topMargin
        textField.placeholderText: qsTr("Enter url...")

        onInputComplete: mainSocket.browserUrl(text)
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





