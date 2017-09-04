import QtQuick 2.7
import QtQuick.Controls 2.2

Button {
    property alias cursorShape: mouseArea.cursorShape
    property alias propagateComposedEvents: mouseArea.propagateComposedEvents

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        onPressed:  mouse.accepted = false
    }
}
