import QtQuick 2.1
import harbour.lgremote.webos.websockets 1.0

WebSocket {
    id: mainSocket
    active: false

    signal pointerSocketReceived(string url)
    signal pairingReceived
    signal keyboardInput(bool haveFocus)

    signal connected
    signal disconnected

    property var applications
    property var appsList: []
    property var externalinput
    property var inputList: []

    property var channelsTv: []

    property bool muting: false
    onMutingChanged: soundMuted = muting
    property int volume: 0
    onVolumeChanged: soundVolume = volume

    property string currentAppId
    onCurrentAppIdChanged: {
        currentApplicationId = currentAppId
        currentApplication = applications[currentAppId] == undefined ? externalinput[currentAppId].label : applications[currentAppId].title
    }

    property string channelNumber
    onChannelNumberChanged: currentChannelNumber = channelNumber

    property string channelName
    onChannelNameChanged: currentChannelName = channelName

    property string channelId


    onStatusChanged: {
        if (status == WebSocket.Open) {
            connected()
        }
        else if (status == WebSocket.Closed) {
            msgId = 0
            disconnected()
        }
    }

    onTextMessageReceived: {
        var msg = JSON.parse(message)

        //messagesModel.append({name: message, socket: "m", direction: "<"})
        console.log("<:m " + message)

        if (msg.type == "registered") {
            mainSocket.registered = true
            mainSocket.pairing = false
            var authKey = msg.payload["client-key"]
            settings.setAuthKey(deviceIp, authKey)

            //socket.sendCommand("muting_", "subscribe", "ssap://audio/getMute")
            mainSocket.sendCommand("volume_", "subscribe", "ssap://audio/getVolume")
            //mainSocket.sendCommand("status_", "subscribe", "ssap://audio/getStatus")

            //mainSocket.sendCommand("http_header_", "request", "ssap://com.webos.service.sdx/getHttpHeaderForServiceRequest")
            mainSocket.sendCommand("sw_info_", "request", "ssap://com.webos.service.update/getCurrentSWInformation")

            mainSocket.sendCommand("services_", "request", "ssap://api/getServiceList")

            //mainSocket.sendCommand("apps_", "subscribe", "ssap://com.webos.applicationManager/listApps")
            mainSocket.sendCommand("launcher_", "subscribe", "ssap://com.webos.applicationManager/listLaunchPoints")
            mainSocket.sendCommand("keyboard_", "subscribe", "ssap://com.webos.service.ime/registerRemoteKeyboard")
            mainSocket.sendCommand("events_", "subscribe", "ssap://com.webos.service.tv.keymanager/listInterestingEvents", {"subscribe": true})
            mainSocket.sendCommand("foreground_app_", "subscribe", "ssap://com.webos.applicationManager/getForegroundAppInfo")
            mainSocket.sendCommand("channels_", "subscribe", "ssap://tv/getChannelList")
            mainSocket.sendCommand("channel_", "subscribe", "ssap://tv/getCurrentChannel")
            mainSocket.sendCommand("input_", "subscribe", "ssap://tv/getExternalInputList")

            mainSocket.sendCommand("get_pointer_", "request", "ssap://com.webos.service.networkinput/getPointerInputSocket")
        }
        else if (msg.type == "response") {
            if (msg.id.indexOf("register_") == 0) {
                if (msg.payload.pairingType == "PIN") {
                    mainSocket.pairing = true
                    pairingReceived()
                }
            }
            else if (msg.id.indexOf("get_pointer_") == 0) {
                console.log("pointer data received: " + msg.payload.returnValue)
                if (msg.payload.returnValue) {
                    console.log("pointer socket: " + msg.payload.socketPath)
                    pointerSocketReceived(msg.payload.socketPath)
                }
            }
            else if (msg.id.indexOf("muting_") == 0) {
                mainSocket.muting = msg.payload.mute
            }
            else if (msg.id.indexOf("volume_") == 0) {
                mainSocket.volume = msg.payload.volume
                mainSocket.muting = msg.payload.muted
                //volSlider.value = msg.payload.volume
            }
            else if (msg.id.indexOf("sw_info_") == 0) {
                //infoText.text = JSON.stringify(msg.payload)
            }
            else if (msg.id.indexOf("apps_") == 0) {
                /*var appList = msg.payload.apps
                var apps = {}
                for (var i = 0; i < appList.length; i++) {
                    if (appList[i].id != undefined) {
                        apps[appList[i].id] = appList[i]
                    }
                }
                applications = apps
                if (currentAppId.length > 0) {
                    currentApplication = applications[currentAppId].title
                }*/
            }
            else if (msg.id.indexOf("launcher_") == 0) {
                var launchPoints = msg.payload.launchPoints
                appsList = launchPoints
                var apps = {}
                for (var i = 0; i < appsList.length; i++) {
                    if (appsList[i].id != undefined) {
                        apps[appsList[i].id] = appsList[i]
                    }
                }
                applications = apps
                if (currentAppId.length > 0) {
                    currentApplication = applications[currentAppId].title
                }
            }
            else if (msg.id.indexOf("foreground_app_") == 0) {
                currentAppId = msg.payload.appId
                //var sessionId = Qt.btoa(currentAppId + ":undefined")
                //mainSocket.sendCommand("", "request", "ssap://system.launcher/getAppState", {"id": currentAppId, "sessionId": sessionId})
            }
            else if (msg.id.indexOf("keyboard_") == 0) {
                if (msg.payload.focusChanged || msg.payload.subscribed) {
                    keyboardFocus = msg.payload.currentWidget.focus
                }
            }
            else if (msg.id.indexOf("channels_") == 0) {
                channelsTv = msg.payload.channelList
            }
            else if (msg.id.indexOf("channel_") == 0) {
                channelName = msg.payload.channelName
                channelNumber = msg.payload.channelNumber
                channelId = msg.payload.channelId
            }
            else if (msg.id.indexOf("input_") == 0) {
                inputList = msg.payload.devices
                var devices = {}
                for (var i = 0; i < inputList.length; i++) {
                    if (inputList[i].id != undefined) {
                        devices[inputList[i].appId] = inputList[i]
                    }
                }
                externalinput = devices
                if (currentAppId.length > 0 && devices[currentAppId] != undefined) {
                    currentApplication = devices[currentAppId].label
                }
            }
            else {
                return
            }
        }
    }

    onErrorStringChanged: {
        console.log("mainSocket: " + errorString)
    }

    property bool pairing: false
    property bool registered: false
    property bool ready: registered && status == WebSocket.Open

    property bool keyboardFocus: false

    property int msgId: 0

    function getMsgId() {
        msgId = msgId + 1
        return msgId
    }

    function sendLogMessage(message) {
        if (mainSocket.status == WebSocket.Open) {
            //messagesModel.append({name: message, socket: "m", direction: ">"})
            console.log(">:m " + message)
            mainSocket.sendTextMessage(message)
        }
    }

    function sendCommand(prefix, msgtype, uri, payload) {
        var msg = {}
        msg["id"] = prefix + mainSocket.getMsgId()
        msg["type"] = msgtype
        msg["uri"] = uri
        if (payload) {
            msg["payload"] = payload
        }

        mainSocket.sendLogMessage(JSON.stringify(msg))
    }

    function sendPin(pincode) {
        mainSocket.sendCommand("pin_", "request", "ssap://pairing/setPin", {"pin": pincode})
    }

    function sendEnter() {
        mainSocket.sendCommand("", "request", "ssap://com.webos.service.ime/sendEnterKey")
    }

    function launcher(appId) {
        mainSocket.sendCommand("", "request", "ssap://system.launcher/launch", {"id": appId})
    }

    function closeApp(appId) {
        mainSocket.sendCommand("", "request", "ssap://system.launcher/close", {"id": appId, "sessionId": Qt.btoa(appId + ":undefined")})
    }

    function launchApp(appId) {
        mainSocket.sendCommand("", "request", "ssap://com.webos.applicationManager/launch", {"id": appId})
    }

    function launchWithPayload(payload) {
        mainSocket.sendCommand("", "request", "ssap://com.webos.applicationManager/launch", payload)
    }

    function browserUrl(url) {
        launchWithPayload({"id": "com.webos.app.browser", "target": url})
    }

    function openYoutube(video) {
        launchWithPayload({"id": "youtube.leanback.v4", "params": { "contentTarget": ("http://www.youtube.com/tv?v=" + video) }})
    }

    function sendPause() {
        mainSocket.sendCommand("pause_", "request", "ssap://media.controls/pause")
    }

    function sendPlay() {
        mainSocket.sendCommand("play_", "request", "ssap://media.controls/play")
    }

    function sendStop() {
        mainSocket.sendCommand("stop_", "request", "ssap://media.controls/stop")
    }

    function sendVolumeUp() {
        mainSocket.sendCommand("volumeup_", "request", "ssap://audio/volumeUp")
    }

    function sendVolumeDown() {
        mainSocket.sendCommand("volumedown_", "request", "ssap://audio/volumeDown")
    }

    function toggleMute() {
        mainSocket.sendCommand("", "request", "ssap://audio/setMute", {"mute": !mainSocket.muting})
    }

    function sendBackspace(count) {
        mainSocket.sendCommand("", "request", "ssap://com.webos.service.ime/deleteCharacters", {"count": count == undefined ? 1 : count})
    }

    function sendText(text, replace) {
        mainSocket.sendCommand("", "request", "ssap://com.webos.service.ime/insertText", {"text": text, "replace": replace == true})
    }

    function sendTurnOff() {
        mainSocket.sendCommand("", "request", "ssap://system/turnOff")
    }

    function sendShowToast(text) {
        mainSocket.sendCommand("", "request", "ssap://system.notifications/createToast", {"message": text})
    }

    function sendOpenChannel(channelId) {
        socket.sendCommand("", "request", "ssap://tv/openChannel", {"channelId": channelId})
    }

    function sendSwitchInput(inputId) {
        socket.sendCommand("", "request", "ssap://tv/switchInput", {"inputId": inputId})
    }
}
