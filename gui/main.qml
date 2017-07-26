import QtQuick 2.7
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQml.Models 2.3
import "."
import hust.kyle 1.0

ApplicationWindow {
    id: root

    visible: true
    width: Screen.width*0.8
    height: Screen.height*0.75
    Material.theme: Material.Dark


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
                Layout.preferredWidth: parent.width*0.2
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
                            else if (treeModel.type(leftSideView.currentIndex) === TreeModel.Class)
                                return treeModel.insertRows(leftSideView.currentIndex.row+1, 1, treeModel.parent(leftSideView.currentIndex));

                            return treeModel.insertRows(0, 1, leftSideView.currentIndex);
                        }
                    }
                }

                Rectangle {
                    height: parent.height
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


                        onCurrentIndexChanged: {
                            console.log("index changed");
                            tableModel.setList(treeModel.getDonors(leftSideView.currentIndex));
                        }

                        Layout.fillHeight: true
                        Layout.preferredWidth: Screen.width * 0.1

                        model: treeModel
                        TableViewColumn {
                            role: "Name"
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
                                Row{
                                    anchors.fill: parent
                                    Text {
                                        id: treeviewInfo
                                        width: parent.width*0.8
                                        //anchors.fill: parent
                                        text: "hi"+styleData.row+model.schoolName
                                        font.pointSize: treeTextMetrics.font.pointSize
                                    }
                                    Button {
                                        width: parent.width-treeviewInfo.width
                                        height: parent.height
                                        visible: true
                                        Component.onCompleted: {
                                            if (model.index === 0)
                                                visible = false;
                                        }
                                        onClicked: {
                                            switch(treeModel.type(leftSideView.currentIndex))
                                            {
                                            case TreeModel.Class:
                                                for (var i=0; i != treeClassPopupLayoutTextField.count; ++i)
                                                    treeClassPopupLayoutTextField.itemAt(i).text="";

                                                treeClassPopupLayoutTextField.itemAt(0).text = model.classSchool;
                                                treeClassPopupLayoutTextField.itemAt(1).text = model.classInstructor;
                                                treeClassPopupLayoutTextField.itemAt(2).text = model.classNumber;
                                                if (model.classGrade)
                                                    treeClassPopupLayoutTextField.itemAt(3).text = model.classGrade;
                                                if (model.classStudentCnt)
                                                    treeClassPopupLayoutTextField.itemAt(4).text = model.classStudentCnt;
                                                treeClassPopup.open();
                                                break;
                                            case TreeModel.School:
                                                for (var i=0; i != treeSchoolPopupLayoutTextField.count; ++i)
                                                    treeSchoolPopupLayoutTextField.itemAt(i).text="";
                                                treeSchoolPopupLayoutTextField.itemAt(0).text = model.schoolName;
                                                treeSchoolPopupLayoutTextField.itemAt(1).text = model.schoolPrincipal;
                                                treeSchoolPopupLayoutTextField.itemAt(2).text = model.schoolTele;
                                                treeSchoolPopup.open();
                                                break;
                                            }
                                        }
                                    }
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

                Column {

                    anchors.fill: parent
                    TableView {

                        backgroundVisible: false
                        selectionMode: SelectionMode.ExtendedSelection
                        width: parent.width
                        height: parent.height-editArea.height
                        model: TableModel {
                            id: tableModel
                        }

                        TableViewColumn {
                            role: "name"
                            title: "Name"
                        }

                        TableViewColumn {
                            role: "id"
                            title: "ID "
                        }

                    }

                    Rectangle {
                        id: editArea
                        color: "grey"
                        height: parent.height*0.2
                        width: parent.width
                            GridView {
                                interactive: false
                                anchors.centerIn: parent
                                clip: true
                                width: (parent.width-editAreaAddBtn.width)*0.95
                                height: parent.height
                                cellHeight:parent.height*0.5
                                cellWidth:parent.width*0.23

                                model: [qsTr("name"), qsTr("id"), qsTr("gender"), qsTr("age"), qsTr("amount")]
                                delegate: TextField {
                                    height:parent.height*0.5
                                    width:parent.width*0.23
                                    placeholderText: modelData
                                    font.pointSize: 20
                                    background: Rectangle {
                                        border.width: 0
                                    }
                                }
                            }

                            Rectangle {
                                anchors.right: parent.right
                                id: editAreaAddBtn
                                width: parent.width*0.2
                                height: parent.height
                                Column {
                                    anchors.fill: parent
                                    Button {
                                        text: "add"
                                        width: parent.width
                                        height: parent.height*0.5
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            console.log("list", "add");
                                            console.log(tableModel.insert(0));
                                            console.log(tableModel.touchData(0, "Patric", "name"));
                                            tableModel.touchData(0, "U201600000", "id");
                                        }
                                    }
                                    Button {
                                        text: "delete"
                                        width: parent.width
                                        height: parent.height*0.5
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                    }

                }


                Rectangle {
                    width: parent.width
                    color: "red"
                }

            }
        }
    }


    Popup {
            background: Rectangle {
                color: "#ffffff"
                border.width: 0
                Material.background: Material.Teal
                Material.elevation: 6

             }

            id: treeSchoolPopup
            x: parent.width*0.3
            y: parent.height*0.2
            width: parent.width*0.6
            height: parent.height*0.6
            modal: true
            focus: true
            padding: width*0.04


            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            ColumnLayout {
                id: treeSchoolPopupLayout
                anchors.fill: parent
                Repeater {
                    id: treeSchoolPopupLayoutTextField
                    model: [qsTr("name"), qsTr("principal"), qsTr("telephone")]

                    Rectangle {
                        width: treeSchoolPopupLayout.width
                        height: treeSchoolPopupLayout.height/4
                        property alias text: schoolInput.text

                        TextField {
                            id: schoolInput
                            placeholderText: modelData
                            background: Rectangle {
                                border.width: 0
                            }

                            anchors.fill: parent
                            font.pointSize: 20
                        }
                    }
                }
                Rectangle {
                    width: treeSchoolPopupLayout.width
                    height: treeSchoolPopupLayout.height/4
                    id: treeSchoolPopupBtn
                    Row {
                        anchors.centerIn: parent
                        width: parent.width*0.4
                        height: parent.height*0.7
                        Rectangle {
                            height: parent.height
                            width: parent.width/2


                            Button {
                                height: parent.height*0.8
                                width: parent.width*0.6
                                anchors.centerIn: parent
                                highlighted: true
                                Material.background: Material.Teal
                                text: qsTr("Edit")
                            }
                        }
                        Rectangle {
                            height: parent.height
                            width: parent.width/2
                            Button {
                                height: parent.height*0.8
                                width: parent.width*0.6
                                anchors.centerIn: parent
                                highlighted: true
                                Material.background: Material.Teal
                                text: qsTr("Cancel")
                                onClicked: {
                                    treeSchoolPopup.close();
                                }
                            }
                        }
                    }
                }
            }

    }


    Popup {
            background: Rectangle {
                color: "#ffffff"
                border.width: 0
                Material.background: Material.Teal
                Material.elevation: 6

             }

            id: treeClassPopup
            x: parent.width*0.3
            y: parent.height*0.05
            width: parent.width*0.6
            height: parent.height*0.95
            modal: true
            focus: true
            padding: width*0.04


            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            ColumnLayout {
                id: treeClassPopupLayout
                anchors.fill: parent
                Repeater {
                    id: treeClassPopupLayoutTextField
                    model: [qsTr("school"), qsTr("instructor"), qsTr("number"), qsTr("grade"), qsTr("student cnt")]

                    Rectangle {
                        width: treeClassPopupLayout.width
                        height: treeClassPopupLayout.height/6
                        property alias text: classInput.text

                        TextField {
                            id: classInput
                            placeholderText: modelData
                            background: Rectangle {
                                border.width: 0
                            }

                            anchors.fill: parent
                            font.pointSize: 20
                        }
                    }
                }
                Rectangle {
                    width: treeClassPopupLayout.width
                    height: treeClassPopupLayout.height/6
                    id: treeClassPopupBtn
                    Row {
                        anchors.centerIn: parent
                        width: parent.width*0.4
                        height: parent.height*0.7
                        Rectangle {
                            height: parent.height
                            width: parent.width/2
                            Button {
                                height: parent.height*0.8
                                width: parent.width*0.6
                                anchors.centerIn: parent
                                highlighted: true
                                Material.background: Material.Teal
                                text: qsTr("Edit")
                            }
                        }
                        Rectangle {
                            height: parent.height
                            width: parent.width/2
                            Button {
                                height: parent.height*0.8
                                width: parent.width*0.6
                                anchors.centerIn: parent
                                highlighted: true
                                Material.background: Material.Teal
                                text: qsTr("Cancel")

                                onClicked: {
                                    treeClassPopup.close();
                                }

                            }


                        }
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
