import QtQuick 2.1
;import QtWebSockets 1.1

WebSocket {
    id: pointerSocket
    active: false
    property bool connected: status == WebSocket.Open
    onTextMessageReceived: {
        //
    }
    onErrorStringChanged: {
        console.log("pointerSocket: " + errorString)
    }

    function sendLogMessage(message) {
        pointerSocket.sendTextMessage(message)
    }

    function sendMove(dx, dy) {
        if (pointerSocket.status == WebSocket.Open) {
            pointerSocket.sendLogMessage('type:move\ndx:' + dx + '\ndy:' + dy + '\ndown:0\n\n')
        }
    }

    function sendScroll(dy) {
        if (pointerSocket.status == WebSocket.Open) {
            pointerSocket.sendLogMessage('type:scroll\ndx:0\ndy:' + dy + '\ndown:0\n\n')
        }
    }

    function sendClick() {
        if (pointerSocket.status == WebSocket.Open) {
            pointerSocket.sendLogMessage('type:click\n\n')
        }
    }

    function sendInput(btype, bname) {
        if (pointerSocket.status == WebSocket.Open) {
            console.log("send " + btype + ": " + bname)
            pointerSocket.sendLogMessage('type:' + btype + '\nname:' + bname + '\n\n')
        }
    }
}
