import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import hust.kyle 1.0

ApplicationWindow {
    id: root

    visible: true
    width: Screen.width*0.8
    height: Screen.height*0.75
    x: (Screen.width-width)/2
    y: (Screen.height-height)/2

    Dialog {
        width: root.width * 0.6
        height: root.height * 0.6

        x: parent.width * 0.2
        y: parent.height * 0.2

        id: dialog
        title: "Error"
        standardButtons: Dialog.Ok
        closePolicy: "CloseOnPressOutside"

        onAccepted: dialog.close();
        onClosed: Qt.quit();
        Component.onCompleted: dialog.open();

        font.pointSize: 22

        Text {
            text: LaunchErrMsg.what()
            font.pointSize: 20
        }
    }
}
