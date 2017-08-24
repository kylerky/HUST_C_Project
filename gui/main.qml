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
    Material.theme: Material.Light
    Material.primary: "#616161"
    Material.accent: "#d81b60"
    Material.background: "#e1e2e1"
    Material.foreground: "#f5f5f6"
    x: (Screen.width-width)/2
    y: (Screen.height-height)/2

    onClosing: {
        treeModel.writeTree();
        if (tableModel.rowCount() !== 0)
            treeModel.writeItem(leftSideView.currentIndex);
    }

    Timer {
        id: treeWriteTimer
        interval: 2000
        repeat: true
        running: false
        onTriggered: {
            treeModel.writeTree();
        }
    }

    Component.onCompleted: {
        treeModel.readAll();
        if (treeModel.rowCount() === 0) {
            treeModel.insertRows(0, 1, leftSideView.currentIndex);
            treeModel.setSchoolData(treeModel.index(0,0,treeModel.rowIndex), qsTr("School"), "name");
        }

        treeWriteTimer.start();
    }

    Row {
        anchors.fill: parent
        Rectangle{
            id: modesBar
            height: parent.height
            width: modesBtnWrapper.width
            color: "#373737"
            Column {
                id: modesBtnWrapper
                property int currentIndex: 0
                spacing: 0

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
                        Material.elevation: 0
                        property int identifier: index
                        height: width
                        width: Screen.width*0.07
                    }
                }
            }
        }


        Rectangle {
            width: parent.width-modesBar.width
            height: parent.height
            color: "#616161"
            RowLayout {

                spacing: 0
                anchors.fill: parent
                Column {
                    Layout.preferredWidth: parent.width*0.2
                    Layout.fillHeight: true
                    Row {
                        id: treeBar
                        height: parent.height*0.04
                        width: parent.width

                        Rectangle {
                            id: treeBarLargeBtn
                            color: "#616161"
                            Text {
                                text: qsTr("School")+qsTr("/")+qsTr("Classes")
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                            }
                            width: parent.width - treeBarAddBtn.width - treeBarDelBtn.width
                            height: parent.height
                        }

                        Button {
                            id: treeBarDelBtn
                            cursorShape: Qt.PointingHandCursor
                            height:parent.height
                            width:parent.width*0.2
                            text: "-"
                            background: Rectangle {
                                color: "#616161"
                            }
                            onClicked: {
                                if (leftSideView.currentIndex.row === 0
                                        && treeModel.type(leftSideView.currentIndex) === 2)
                                    return;

                                treeModel.removeRow(leftSideView.currentIndex.row);
                            }
                        }


                        Button {
                            id: treeBarAddBtn
                            cursorShape: Qt.PointingHandCursor
                            height:parent.height
                            width:parent.width*0.2
                            text: "+"
                            background: Rectangle {
                                color: "#616161"
                            }

                            onClicked: {
                                console.log(leftSideView.currentIndex);
                                if (leftSideView.currentIndex === treeModel.index(0,0) || leftSideView.currentIndex === treeModel.parent(treeModel.index(0,0))) {
                                    treeSchoolPopup.isAdd = true;
                                    treeSchoolPopup.open();
                                    return;
                                } else {
                                    treeClassPopup.isAdd = true;

                                    if (treeModel.type(leftSideView.currentIndex) === TreeModel.Class)
                                        treeClassPopup.dataAddType = 0;
                                    else
                                        treeClassPopup.dataAddType = 1;

                                    treeClassPopup.open();
                                    return;
                                }
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
                                var last = treeModel.getLastIndex();
                                treeModel.setLastIndex(leftSideView.currentIndex);
                                var list = treeModel.getDonors(leftSideView.currentIndex);
                                tableModel.setList(list);
                                treeModel.writeItem(last);
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
                                color: "#8e8e8e"

                                width: parent.width
                                height: treeTextMetrics.height*1.2
                            }

                            itemDelegate: Button {
                                cursorShape: Qt.PointingHandCursor
                                Rectangle {
                                    anchors.fill: parent
                                    color: styleData.selected?"#616161":"#8e8e8e"
                                    Row{
                                        anchors.fill: parent
                                        Text {
                                            id: treeviewInfo
                                            width: parent.width*0.8
                                            text: Number(model.type) === 2 ? model.schoolName : model.classNumber
                                            font.pointSize: treeTextMetrics.font.pointSize
                                        }
                                        Button {
                                            cursorShape: Qt.PointingHandCursor
                                            width: parent.width-treeviewInfo.width
                                            height: parent.height
                                            visible: true
                                            background: Rectangle {
                                                color: styleData.selected?"#616161":"#8e8e8e"
                                            }
                                            text: "edit"

                                            Component.onCompleted: {
                                                if (model !== null && model.index === 0)
                                                    visible = false;
                                            }
                                            onClicked: {
                                                switch(treeModel.type(leftSideView.currentIndex))
                                                {
                                                case TreeModel.Class:
                                                    treeClassPopup.isAdd = false;
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
                                                    treeSchoolPopup.isAdd = false;
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
                            id: donorsTable
                            backgroundVisible: false
                            selectionMode: SelectionMode.ExtendedSelection
                            width: parent.width
                            height: parent.height-editArea.height

                            Connections {
                                target: donorsTable.selection
                                onSelectionChanged: {
                                    if (donorsTable.selection.count === 1) {
                                        editArea.state = "edit";
                                        var text = [];

                                        donorsTable.selection.forEach(
                                            function(row) {
                                                var index = tableModel.index(row, 0);

                                                text.push(tableModel.data(index, TableModel.NameRole));
                                                text.push(tableModel.data(index, TableModel.IdRole));
                                                text.push(tableModel.data(index, TableModel.GenderRole));
                                                text.push(tableModel.data(index, TableModel.AgeRole));
                                                text.push(tableModel.data(index, TableModel.AmountRole));
                                            }
                                        );

                                        var cnt = 0;
                                        for (var i = 0; i !== donorsInputView.contentItem.children.length; ++i)
                                        {
                                            if (donorsInputView.contentItem.children[i].hasOwnProperty("text"))
                                            {
                                                donorsInputView.contentItem.children[i].text = text[cnt];
                                                ++cnt;
                                            }
                                        }
                                    }
                                    else
                                        editArea.state = "";
                                }
                            }

                            model: TableModel {
                                id: tableModel
                            }

                            TextMetrics {
                                id: tableTextMetrics
                                text: "hi"
                                font.pointSize: 14
                            }
                            TableViewColumn {
                                role: "name"
                                title: qsTr("Name")
                            }
                            TableViewColumn {
                                role: "id"
                                title: qsTr("ID")
                            }
                            TableViewColumn {
                                role: "gender"
                                title: qsTr("Gender")
                            }
                            TableViewColumn {
                                role: "age"
                                title: qsTr("Age")
                            }
                            TableViewColumn {
                                role: "amount"
                                title: qsTr("Amount")
                            }

                            headerDelegate: Rectangle {
                                height: tableHeader.height
                                color: "#dcdcdc"
                                Text {
                                    id: tableHeader
                                    text: styleData.value
                                    color: "#545454"
                                }
                            }
                            rowDelegate: Rectangle {
                                color: styleData.selected ? "#b3b3b3" :  styleData.alternate?"#f5f5f6":"#ffffff"
                                height: tableTextMetrics.height
                            }

                            itemDelegate: Item {
                                id: treeItem
                                Text {
                                    text: styleData.role !== "amount"? styleData.value : Number(styleData.value).toFixed(2)
                                    color: "black"
                                }
                            }
                        }

                        Rectangle {
                            id: editArea
                            color: "#e1e2e1"
                            height: parent.height*0.2
                            states: [
                                State {
                                    name: "edit"
                                    PropertyChanges {
                                        target: tableAddBtn;
                                        text: "edit";
                                    }
                                }
                            ]
                            width: parent.width
                            GridView {
                                id: donorsInputView

                                interactive: false
                                anchors.centerIn: parent
                                clip: true
                                width: (parent.width-editAreaAddBtn.width)*0.95
                                height: parent.height
                                cellHeight:parent.height*0.5
                                cellWidth:parent.width*0.23
                                model: [
                                    {
                                        placeholder: qsTr("name"),
                                        format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 19 characters'),
                                        regexp: /^\w{1,19}$/
                                    },
                                    {
                                        placeholder: qsTr("id"),
                                        format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 10 characters'),
                                        regexp: /^\w{1,10}$/
                                    },
                                    {
                                        placeholder: qsTr("gender"),
                                        format: qsTr('"f" for female, "m" for male, "x" for others'),
                                        regexp: /^[fmxs]$/
                                    },
                                    {
                                        placeholder: qsTr("age"),
                                        format: qsTr("should include 1-3 digits"),
                                        regexp: /^\d{1,3}$/
                                    },
                                    {
                                        placeholder: qsTr("amount"),
                                        format: qsTr("should be a real number"),
                                        regexp: /^[0-9.]+$/
                                    }
                                ]

                                delegate: Rectangle {
                                    states: [
                                        State {
                                            name: "invalid"
                                            PropertyChanges {
                                                target: studentInputErr;
                                                visible: true;
                                            }
                                            PropertyChanges {
                                                target: studentInput;
                                                color: "red";
                                            }
                                        }
                                    ]
                                    id: studentInputWrapper
                                    height:parent.height*0.5
                                    width:parent.width*0.23
                                    property alias text: studentInput.text
                                    Row {
                                        width: parent.width
                                        height: parent.height
                                        TextField {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width
                                            id: studentInput
                                            placeholderText: modelData.placeholder
                                            font.pointSize: 20
                                            selectByMouse: true
                                            background: Rectangle {
                                                border.width: 0
                                            }
                                            color: "black"
                                            onDisplayTextChanged: {
                                                var input = text.replace(/(\s+$)|(^\s+)/g, "");
                                                if (!modelData.regexp.test(input))
                                                    studentInputWrapper.state = "invalid";
                                                else
                                                    studentInputWrapper.state = "";
                                            }
                                        }
                                        Button {
                                            id: studentInputErr
                                            background: Rectangle {
                                                opacity: 0
                                            }

                                            contentItem: Text {
                                                text: "  \u24D8"
                                                color: "red"
                                            }
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            anchors.baseline: studentInput.baseline
                                            font.pointSize: 12
                                            visible: false

                                            ToolTip.text: modelData.format
                                            ToolTip.visible: hovered
                                            ToolTip.delay: 500
                                        }
                                    }
                                }

                            }

                            Rectangle {
                                color: "#e1e2e1"
                                anchors.right: parent.right
                                id: editAreaAddBtn
                                width: parent.width*0.2
                                height: parent.height
                                Column {
                                    anchors.fill: parent
                                    Button {
                                        contentItem: Text {
                                            id: tableAddBtn
                                            text: "add"
                                            color: "#696969"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: 24
                                        }

                                        width: parent.width
                                        height: parent.height*0.5
                                        cursorShape: Qt.PointingHandCursor
                                        font.pointSize: 20

                                        onClicked: {
                                            var inputs = [];
                                            var elems = [];
                                            for (var i = 0; i !== donorsInputView.contentItem.children.length; ++i)
                                            {
                                                if (donorsInputView.contentItem.children[i].hasOwnProperty("text"))
                                                {
                                                    var text = donorsInputView.contentItem.children[i].text.replace(/(\s+$)|(^\s+)/g, "");
                                                    inputs.push(text);
                                                    elems.push(donorsInputView.contentItem.children[i]);
                                                    donorsInputView.contentItem.children[i].text = text;
                                                }
                                            }

                                            var pass = true;

                                            for (var i = 0; i !== inputs.length; ++i) {
                                                if (!donorsInputView.model[i].regexp.test(inputs[i])) {
                                                    elems[i].state = "invalid";
                                                    pass = false;
                                                }
                                            }

                                            if (!pass)
                                                return;

                                            var row;
                                            if (editArea.state === "edit") {

                                                donorsTable.selection.forEach(
                                                    function(data) {
                                                        row = data;
                                                    }
                                                );
                                            } else {
                                                tableModel.insert(tableModel.count);
                                                row = talbeModel.count-1;
                                            }

                                            tableModel.touchData(row, inputs[0], "name");
                                            tableModel.touchData(row, inputs[1], "id");
                                            tableModel.touchData(row, inputs[2].charCodeAt(0), "gender");
                                            tableModel.touchData(row, Number(inputs[3]), "age");
                                            tableModel.touchData(row, Number(inputs[4]), "amount");

                                            donorsTable.positionViewAtRow(row, ListView.Contain);
                                        }
                                    }
                                    Button {
                                        contentItem: Text {
                                            text: "delete"
                                            color: "#696969"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: 24
                                        }
                                         width: parent.width
                                        height: parent.height*0.5
                                        cursorShape: Qt.PointingHandCursor
                                        font.pointSize: 20

                                        onClicked: {
                                            var cnt = 0;
                                            donorsTable.selection.forEach(
                                                function(row) {
                                                    tableModel.remove(row-cnt);
                                                    ++cnt;
                                                }
                                            )
                                        }
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
    }

    Popup {
            background: Rectangle {
                color: "#ffffff"
                border.width: 0
//                Material.background: Material.Teal
//                Material.elevation: 6

            }

            id: treeSchoolPopup
            x: parent.width*0.3
            y: parent.height*0.2
            width: parent.width*0.6
            height: parent.height*0.6
            modal: true
            focus: true
            padding: width*0.04

            property bool isAdd: false

            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            onClosed: {
                for (var i = 0; i < treeSchoolPopupLayoutTextField.count; ++i) {
                    treeSchoolPopupLayoutTextField.itemAt(i).text = "";
                    treeSchoolPopupLayoutTextField.itemAt(i).state = "";
                }
            }

            Column {
                id: treeSchoolPopupLayout
                anchors.fill: parent
                Repeater {
                    id: treeSchoolPopupLayoutTextField
                    model: [
                        {
                            placeholder: qsTr("name"),
                            format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 29 characters'),
                            reg: "^\\w{1,29}$"
                        },
                        {
                            placeholder: qsTr("principal"),
                            format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 19 characters'),
                            reg: "^\\w{1,19}$"
                        },
                        {
                            placeholder: qsTr("telephone"),
                            format: qsTr('should include only 0-9, "(", ")" and "-", at most 19 characters'),
                            reg: "^[()0-9-]{1,19}$"
                        }
                    ]

                    Rectangle {
                        width: treeSchoolPopupLayout.width
                        height: treeSchoolPopupLayout.height/4
                        property alias text: schoolInput.text
                        property alias state: schoolInput.state


                        FormatInput {
                            id: schoolInput
                            placeholderText: modelData.placeholder
                            width: parent.width
                            formatText: modelData.format
                            regexp: modelData.reg
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
//                                Material.background: Material.Teal
                                text: treeSchoolPopup.isAdd ? qsTr("Add") : qsTr("Edit")
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var inputs = [];
                                    for (var i = 0; i !== treeSchoolPopupLayoutTextField.count; ++i)
                                        inputs.push(treeSchoolPopupLayoutTextField.itemAt(i).text);

                                    var pass = true;

                                    for (var i = 0; i !== inputs.length; ++i) {
                                        var reg = new RegExp(treeSchoolPopupLayoutTextField.model[i].reg);
                                        if (!reg.test(inputs[i])) {
                                            pass = false;
                                            treeSchoolPopupLayoutTextField.itemAt(i).state = "invalid";
                                        }
                                    }

                                    if (!pass)
                                        return;

                                    var index;
                                    if (treeSchoolPopup.isAdd) {
                                        treeModel.insertRows(1, 1);
                                        index = treeModel.index(1, 0)
                                    } else {
                                        index = leftSideView.currentIndex;
                                    }

                                    treeModel.setSchoolData(index, inputs[0], "name");
                                    treeModel.setSchoolData(index, inputs[1], "principal");
                                    treeModel.setSchoolData(index, inputs[2], "tele");
                                    treeSchoolPopup.close();
                                }
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
//                                Material.background: Material.Teal
                                text: qsTr("Cancel")
                                cursorShape: Qt.PointingHandCursor
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

             }

            id: treeClassPopup

            property int dataAddType: 0
            property bool isAdd: false

            x: parent.width*0.3
            y: parent.height*0.05
            width: parent.width*0.6
            height: parent.height*0.95
            modal: true
            focus: true
            padding: width*0.04


            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            onClosed: {
                for (var i = 0; i < treeClassPopupLayoutTextField.count; ++i) {
                    treeClassPopupLayoutTextField.itemAt(i).text = "";
                    treeClassPopupLayoutTextField.itemAt(i).state = "";
                }

            }


            Column {
                id: treeClassPopupLayout
                anchors.fill: parent
                Repeater {
                    id: treeClassPopupLayoutTextField
                    model: [
                        {
                            placeholder: qsTr("school"),
                            format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 29 characters'),
                            reg: "^\\w{1,29}$"
                        },
                        {
                            placeholder: qsTr("instructor"),
                            format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 29 characters'),
                            reg: "^\\w{1,29}$"
                        },
                        {
                            placeholder: qsTr("number"),
                            format: qsTr('should include only a-z, A-Z, 0-9 and "_", at most 9 characters'),
                            reg: "^\\w{1,9}$"
                        },
                        {
                            placeholder: qsTr("grade"),
                            format: qsTr('should include only ONE digit'),
                            reg: "^\\d$"
                        },
                        {
                            placeholder: qsTr("student cnt"),
                            format: qsTr('should include 1 to 3 digits'),
                            reg: "^\\d{1,3}$"
                        }
                    ]

                    Rectangle {
                        width: treeClassPopupLayout.width
                        height: treeClassPopupLayout.height/6
                        property alias text: classInput.text
                        property alias state: classInput.state
                        FormatInput {
                            id: classInput
                            placeholderText: modelData.placeholder
                            width: parent.width
                            formatText: modelData.format
                            regexp: modelData.reg
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
//                                Material.background: Material.Teal
                                text: treeClassPopup.isAdd ? qsTr("Add") : qsTr("Edit")
                                onClicked: {
                                    var inputs = [];
                                    for (var i = 0; i !== treeClassPopupLayoutTextField.count; ++i)
                                        inputs.push(treeClassPopupLayoutTextField.itemAt(i).text);

                                    var pass = true;

                                    for (var i = 0; i !== inputs.length; ++i) {
                                        var reg = new RegExp(treeClassPopupLayoutTextField.model[i].reg);
                                        if (!reg.test(inputs[i])) {
                                            pass = false;
                                            treeSchoolPopupLayoutTextField.itemAt(i).state = "invalid";
                                        }
                                    }

                                    if (!pass)
                                        return;

                                    var index;
                                    if (treeClassPopup.isAdd) {
                                        switch (treeClassPopup.dataAddType) {
                                        case 0:
                                            treeModel.insertRows(leftSideView.currentIndex.row+1, 1, treeModel.parent(leftSideView.currentIndex));
                                            index = treeModel.index(leftSideView.currentIndex.row+1, 0, treeModel.parent(leftSideView.currentIndex));
                                            break;
                                        case 1:
                                            treeModel.insertRows(0, 1, leftSideView.currentIndex);
                                            index = treeModel.index(0, 0, leftSideView.currentIndex)
                                            break;
                                        }
                                    } else {
                                        index = leftSideView.currentIndex;
                                    }

                                    treeModel.setClassData(index, inputs[0], "school");
                                    treeModel.setClassData(index, inputs[1], "instructor");
                                    treeModel.setClassData(index, inputs[2], "number");
                                    treeModel.setClassData(index, Number(inputs[3]), "grade");
                                    treeModel.setClassData(index, Number(inputs[4]), "studentCnt");
                                    treeClassPopup.close();

                                }
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
//                                Material.background: Material.Teal
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
