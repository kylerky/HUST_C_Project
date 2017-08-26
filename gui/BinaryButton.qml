import QtQuick 2.7

Button {
    property int descend: -1
    onCheckedChanged: {
        if (!checked) descend = -1;
    }

    onClicked: {
        descend = (descend+1)%2;
    }
}
