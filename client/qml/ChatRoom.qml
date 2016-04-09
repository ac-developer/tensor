import QtQuick 2.0
import QtQuick.Controls 1.0
import Matrix 1.0

Rectangle {
    id: root

    property Connection currentConnection: null
    property var currentRoom: null

    function getPreviousContent() {
        currentRoom.getPreviousContent()
    }

    function scrollToBottom() {
        chatView.positionViewAtEnd();
    }

    function setRoom(room) {
        console.log("setRoom", room)
        currentRoom = room
        messageModel.changeRoom(room)
        scrollToBottom()
    }

    function setConnection(conn) {
        currentConnection = conn
        messageModel.setConnection(conn)
    }

    function sendLine(text) {
        if(!currentRoom || !currentConnection) return
        currentConnection.postMessage(currentRoom, "m.text", text)
    }

    MessageEventModel {
        id: messageModel
    }

    ScrollView {
    anchors.fill: parent

        ListView {
            id: chatView
            anchors.fill: parent
            //width: 200; height: 250

            model: messageModel
            delegate: messageDelegate
            flickableDirection: Flickable.VerticalFlick
            pixelAligned: true
            property bool wasAtEndY: true

            function aboutToBeInserted() {
                wasAtEndY = atYEnd;
                console.log("aboutToBeInserted! atYEnd=" + atYEnd);
            }

            function rowsInserted() {
                if( wasAtEndY )
                {
                    root.scrollToBottom();
                } else  {
                    console.log("was not at end, not scrolling");
                }
            }

            Component.onCompleted: {
                console.log("onCompleted");
                model.rowsAboutToBeInserted.connect(aboutToBeInserted);
                model.rowsInserted.connect(rowsInserted);
                //positionViewAtEnd();
            }

            section {
                property: "date"
                delegate: Rectangle {
                    width:parent.width
                    height: childrenRect.height
                    Label { text: section.toLocaleString("dd.MM.yyyy") }
                }
            }

            onContentYChanged: {
                if( (this.contentY - this.originY) < 5 )
                {
                    console.log("get older content!");
                    root.getPreviousContent()
                }

            }
        }
    }

    Component {
        id: messageDelegate

        Row {
            id: message
            width: parent.width

            Label {
                id: timelabel
                text: time.toLocaleString(Qt.locale("de_DE"), "'<'hh:mm:ss'>'")
                color: "grey"
            }
            Label {
                width: 120; elide: Text.ElideRight;
                text: eventType == "message" ? author : "***"
                horizontalAlignment: if( eventType != "message" ) { Text.AlignRight }
                color: if( eventType != "message" ) { "lightgrey" } else { "black" }
            }
            TextEdit { selectByMouse: true; readOnly: true; font: timelabel.font;
                    text: content; wrapMode: Text.Wrap; width: parent.width - (x - parent.x) - spacing
                    color: if( eventType != "message" ) { "lightgrey" } else { "black" }
                    ToolTipArea { tip { text: toolTip; color: "#999999"; zParent: message } }
            }
            spacing: 3
        }
    }
}