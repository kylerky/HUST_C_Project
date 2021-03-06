import QtQuick 2.7
import QtQml.Models 2.3
Button {
    property alias nameText: nameText
    property alias principalText: principalText
    property alias teleText: telephoneText
    property int schoolIndex: 0
    contentItem: Rectangle {
        clip: true
        color: Qt.rgba(0,0,0,0)
        Text {
            id: resultTypeIndicator
            color: Qt.rgba(255,255,255,0.5)
            font.pointSize: 30
            text: qsTr("School")
        }
        Row {
            spacing: resultTypeIndicator.width*0.5
            anchors.left: parent.left
            anchors.leftMargin: resultTypeIndicator.width*0.4
            height: parent.height
            Text {
                id: nameText
                font.pointSize: 24
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: principalText
                font.pointSize: 24
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: telephoneText
                font.pointSize: 24
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    cursorShape: Qt.PointingHandCursor
    onClicked: {
        var school = treeModel.index(schoolIndex, 0);

        leftSideViewSelection.setCurrentIndex(school, ItemSelectionModel.ClearAndSelect);
    }
}
