import QtQuick 2.7

Button {
    property int typeId: -1
    onCheckedChanged: {
        if (!checked)
            typeId = -1;
    }

    onClicked: {
        typeId = (typeId+1)%3;
    }
}
