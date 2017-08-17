import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle {
    id: root
    property alias placeholderText: input.placeholderText
    property alias formatText: inputFormat.text
    property alias placeholderColor: input.color
    property alias formatColor: inputFormat.color
    property alias placeholderFont: input.font
    property alias formatFont: inputFormat.font
    property alias text: input.text
    property string regexp: ""
    states: [
        State {
            name: "invalid"
            PropertyChanges {
                target: inputFormat;
                visible: true;
            }
            PropertyChanges {
                target: input;
                color: "red";
            }
        }

    ]
    TextField {
        id: input
        width: parent.width
        color: "black"
        background: Rectangle {
            border.width: 0
        }

        font.pointSize: 20
        onTextChanged: {
            var reg = new RegExp(root.regexp);
            var input = text.replace(/\s+$/g, "");
            if (reg.test(input))
                root.state = "";
            else
                root.state = "invalid";
        }
    }
    Text {
        id: inputFormat
        visible: false
        font.pointSize: 12
        color: "red"
        anchors.baseline: input.bottom
    }
}
