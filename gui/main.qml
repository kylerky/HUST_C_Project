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
    color: "black"

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
                Layout.preferredWidth: parent.width*0.15
                Layout.fillHeight: true

                Row {
                    id: treeBar
                    height: parent.height*0.04
                    width: parent.width

                    Text {
                        text: "hello"
                        height:parent.height
                        width:parent.width*0.8
                    }

                    Button {
                        id: treeBarBtn
                        cursorShape: Qt.PointingHandCursor
                        height:parent.height
                        width:parent.width*0.2
                        onClicked: {
                            treeModel.insertSchoolRows(0, 1, treeModel.getRootIndex());
                        }
                    }
                }

                Rectangle {
                    height: parent.height - treeBar.height
                    width: parent.width
                    color: "black"
                    TreeView {
                        anchors.fill: parent
                        TreeModel {
                            id: treeModel
                            onRowsInserted: {
                                console.log("rows inserted");
                            }
                            onDataChanged: {
                                console.log("changed");
                            }
                        }

                        Layout.fillHeight: true
                        Layout.preferredWidth: Screen.width * 0.1

                        model: treeModel
                        TableViewColumn {
                            role: "schoolName"
                            title: "Name"
                        }

                        rowDelegate: Rectangle {
                            border.width: 1
                            border.color: "black"
                            width: parent.width
                            height: 100
                            color: "grey"
                        }

                        itemDelegate: Button {
                            //anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            Text {
                                //anchors.fill: parent

                                color: "grey"
                                text: "hi"
                            }
                            onClicked: {
                                console.log("begin to set data");
                                console.log(treeModel.insertClassRows(0, 1, treeModel.index(model.index, 0, treeModel.getRootIndex())));
                                console.log("finish")
                            }


                        }
                    }

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
