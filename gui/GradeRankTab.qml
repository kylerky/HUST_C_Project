import QtQuick 2.7
import QtQml.Models 2.3
Button {
    property alias gradeText: gradeText
    property alias countText: countText
    property alias totalText: totalText
    property alias percentText: percentText
    property alias amountText: amountText
    contentItem: Rectangle {
        clip: true
        color: Qt.rgba(0,0,0,0)
        Text {
            id: resultTypeIndicator
            color: Qt.rgba(255,255,255,0.5)
            font.pointSize: 30
            text: qsTr("Grade")
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: resultTypeIndicator.width*0.4
            anchors.verticalCenter: parent.verticalCenter

            id: gradeText
            font.pointSize: 24
        }
        Text {
            anchors.left: gradeText.right
            anchors.leftMargin: resultTypeIndicator.width*0.5
            anchors.verticalCenter: parent.verticalCenter

            id: countText
            font.pointSize: 24
        }
        Text {
            anchors.left: countText.right
            id: slantText
            font.pointSize: 55
            text: qsTr("/")
            color: Qt.rgba(255,255,255,0.5)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.left: slantText.right
            id: totalText
            font.pointSize: 24
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.left: totalText.right
            anchors.leftMargin: resultTypeIndicator.width*0.5
            anchors.verticalCenter: parent.verticalCenter

            font.pointSize: 24
            id: percentText
        }
        Text {
            anchors.left: percentText.right
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
}
