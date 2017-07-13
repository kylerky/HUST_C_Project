import QtQuick 2.7
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import QtQml.Models 2.3
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
                        id: treeBarLargeBtn
                        text: qsTr("School")+qsTr("/")+qsTr("Classes")
                        width: parent.width - treeBarAddBtn.width
                        height: parent.height
                    }

                    Button {
                        id: treeBarAddBtn
                        cursorShape: Qt.PointingHandCursor
                        height:parent.height
                        width:parent.width*0.2
                        onClicked: {
                            console.log(leftSideView.currentIndex);
                            if (leftSideView.currentIndex === treeModel.index(0,0) || leftSideView.currentIndex === treeModel.parent(treeModel.index(0,0)))
                                return treeModel.insertRows(1, 1);
                            return treeModel.insertRows(0, 1, leftSideView.currentIndex);
                        }
                    }
                }

                Rectangle {
                    height: parent.height - treeBar.height
                    width: parent.width
                    color: "black"

                    TreeView {
                        id: leftSideView
                        anchors.fill: parent
                        Component.onCompleted: {
                            treeModel.insertRows(0, 1, leftSideView.currentIndex);
                            treeModel.setSchoolData(treeModel.index(0,0,treeModel.rowIndex), qsTr("School"), "name");
                        }

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

                        TextMetrics {
                            id: treeTextMetrics
                            text: "hi"
                            font.pointSize: 14
                        }

                        headerDelegate: Rectangle {
                            height: 0
                        }

                        rowDelegate: Rectangle {
                            color: "grey"

                            width: parent.width
                            height: treeTextMetrics.height*1.2
                        }

                        itemDelegate: Button {
                            //anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            Rectangle {
                                anchors.fill: parent
                                color: styleData.selected?"blue":"grey"
                                Text {
                                    //anchors.fill: parent
                                    text: "hi"+styleData.row+model.schoolName
                                    font.pointSize: treeTextMetrics.font.pointSize
                                }
                                Button {
                                    visible: false
                                }
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
