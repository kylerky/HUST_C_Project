import QtQuick 2.7

Button {
    property alias schoolText: schoolText
    property alias instructorText: instructorText
    property alias numberText: numberText
    property alias gradeText: gradeText
    property alias cntText: studentCntText
    contentItem: Rectangle {
        clip: true
        color: Qt.rgba(0,0,0,0)
        Text {
            id: resultTypeIndicator
            color: Qt.rgba(255,255,255,0.5)
            font.pointSize: 30
            text: qsTr("Class")
        }
        Grid {
            columns: 3
            columnSpacing: resultTypeIndicator.width*0.5
            anchors.left: parent.left
            anchors.leftMargin: resultTypeIndicator.width*0.4
            anchors.fill: parent
            Text {
                id: schoolText
                font.pointSize: 24
            }
            Text {
                id: instructorText
                font.pointSize: 24
            }
            Text {
                id: numberText
                font.pointSize: 24
            }
            Rectangle {
                color: Qt.rgba(0,0,0,0)
                height: gradeTextRow.height
                width: gradeTextRow.width

                Row {
                    id: gradeTextRow
                    spacing: gradeLabel.width*0.1
                    Text {
                        id: gradeLabel
                        color: Qt.rgba(255,255,255,0.5)
                        font.pointSize: 22
                        text: qsTr("grade")
                    }
                    Text {
                        id: gradeText
                        font.pointSize: 24
                    }
                }
            }
            Rectangle {
                color: Qt.rgba(0,0,0,0)
                height: cntTextRow.height
                width: cntTextRow.width

                Row {
                    id: cntTextRow
                    spacing: cntLabel.width*0.1
                    Text {
                        id: cntLabel
                        color: Qt.rgba(255,255,255,0.5)
                        font.pointSize: 22
                        text: qsTr("count")
                    }
                    Text {
                        id: studentCntText
                        font.pointSize: 24
                    }
                }
            }
        }
    }
    cursorShape: Qt.PointingHandCursor
}
