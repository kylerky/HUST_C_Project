import QtQuick 2.7
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import "."
import hust.kyle 1.0

ApplicationWindow {
    id: root

    visible: true
    width: Screen.width*0.8
    height: Screen.height*0.75

    x: (Screen.width-width)/2
    y: (Screen.height-height)/2

    Row {
        anchors.fill: parent

        Rectangle{
            id: modesBar
            height: parent.height
            width: modesBtnWrapper.width
            color: "#5e5e5e"
            Column {
                id: modesBtnWrapper
                property int currentIndex: 0

                ButtonGroup {

                    buttons: modesBtnWrapper.children
                    checkedButton: modesBtnWrapper.children[0]
                    onClicked: {
                        checkedButton = button;
                        modesBtnWrapper.currentIndex = button.identifier;
                    }
                }

                Repeater {
                    model: [qsTr("Edit"), qsTr("Analyze"), qsTr("Graph")]

                    Button {
                        cursorShape: Qt.PointingHandCursor
                        text: modelData
                        background: Rectangle {
                            color: checked?"grey":hovered?"#6c6c6c":"#5e5e5e"
                        }
                        property int identifier: index
                        height: width
                        width: Screen.width*0.07
                    }
                }
            }
        }


        RowLayout {

            spacing: 0

            width: parent.width-modesBar.width
            height: parent.height
            Column {
                anchors.fill: parent
                onWindowChanged: {
                    console.log(height);
                }


                Rectangle {
                    height: parent.height*0.1
                    color: "blue"
                }

                TreeView {
                    TreeModel {
                        id: treemodel
                        onRowsInserted: {
                            console.log("rows inserted");
                        }
                    }

                    Layout.fillHeight: true
                    Layout.preferredWidth: Screen.width * 0.1

                    model: treemodel

                }
            }

            StackLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width - Screen.width*0.1


                id: mainFrame

                currentIndex: modesBtnWrapper.currentIndex

                TableView {

                    width: parent.width

                    model: ListModel {
                        ListElement {
                            name: "a"
                            num: "1"
                        }
                        ListElement {
                            name: "b"
                            num: "2"
                        }
                        ListElement {
                            name: "c"
                            num: "3"
                        }
                    }

                    TableViewColumn {
                        role: "name"
                        title: "Name"
                    }

                    TableViewColumn {
                        role: "num"
                        title: "Number"
                    }

                }

                Rectangle {
                    width: parent.width
                    color: "red"
                }

            }
        }
    }

    footer: Row {
        id: statusBar
        width: parent.width

        Rectangle {
            color: "#4f4f4f"
            height: status.height*1.25
            width: parent.width
            Text {
                id: status
                text: "status"
                color: "grey"
                font.pointSize: 10
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
