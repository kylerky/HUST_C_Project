import QtQuick 2.7

Button {
    property alias nameText: nameText
    property alias idText: idText
    property alias genderText: genderText
    property alias ageText: ageText
    property alias amountText: amountText
    contentItem: Rectangle {
        clip: true
        color: Qt.rgba(0,0,0,0)
        Text {
            id: resultTypeIndicator
            color: Qt.rgba(255,255,255,0.5)
            font.pointSize: 30
            text: qsTr("Donor")
        }
        Grid {
            columns: 3
            columnSpacing: resultTypeIndicator.width*0.5
            anchors.left: parent.left
            anchors.leftMargin: resultTypeIndicator.width*0.4
            anchors.fill: parent
            Text {
                id: nameText
                font.pointSize: 24
            }
            Text {
                id: idText
                font.pointSize: 24
            }
            Text {
                id: genderText
                font.pointSize: 24
            }
            Rectangle {
                color: Qt.rgba(0,0,0,0)
                height: ageTextRow.height
                width: ageTextRow.width

                Row {
                    id: ageTextRow
                    spacing: ageLabel.width*0.1
                    Text {
                        id: ageLabel
                        color: Qt.rgba(255,255,255,0.5)
                        font.pointSize: 22
                        text: qsTr("age")
                    }
                    Text {
                        id: ageText
                        font.pointSize: 24
                    }
                }
            }
            Rectangle {
                color: Qt.rgba(0,0,0,0)
                height: amountTextRow.height
                width: amountTextRow.width

                Row {
                    id: amountTextRow
                    spacing: amountLabel.width*0.1
                    Text {
                        id: amountLabel
                        color: Qt.rgba(255,255,255,0.5)
                        font.pointSize: 22
                        text: qsTr("amount")
                    }
                    Text {
                        id: amountText
                        font.pointSize: 24
                    }
                }
            }
        }
    }
    cursorShape: Qt.PointingHandCursor
}
