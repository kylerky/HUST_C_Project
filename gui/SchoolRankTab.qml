import QtQuick 2.7
import QtQml.Models 2.3
Button {
    property alias nameText: nameText
    property alias countText: countText
    property alias amountText: amountText
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
        Text {
            anchors.left: parent.left
            anchors.leftMargin: resultTypeIndicator.width*0.4
            anchors.verticalCenter: parent.verticalCenter

            id: nameText
            font.pointSize: 24
        }
        Text {
            anchors.left: nameText.right
            anchors.leftMargin: resultTypeIndicator.width*0.5
            anchors.verticalCenter: parent.verticalCenter

            id: countText
            font.pointSize: 24
        }
        Text {
            anchors.left: countText.right
            anchors.leftMargin: resultTypeIndicator.width*0.2

            id: contributeText
            font.pointSize: 20
            text: qsTr("contribute")
            color: Qt.rgba(255,255,255,0.5)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.left: contributeText.right
            anchors.leftMargin: resultTypeIndicator.width*0.2

            id: amountText
            font.pointSize: 24
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    cursorShape: Qt.PointingHandCursor
    onClicked: {
        var school = treeModel.index(schoolIndex, 0);

        leftSideViewSelection.setCurrentIndex(school, ItemSelectionModel.ClearAndSelect);
    }
}
