import QtQuick 2.7
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQml.Models 2.3
import "createSearchResults.js" as SearchResult
import "createRankResults.js" as RankResult
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
        interval: 300000
        repeat: true
        running: false
        onTriggered: {
            treeModel.writeTree();
        }
    }

    function updateData() {
        updateIndices();
        updateAnalyses();
    }
    function updateAnalyses() {
        var results;
        if (mainFrame.currentIndex === 1 && analysesSection.needUpdate) {
            RankResult.destroyAll();
            results = Analyze.get(treeModel.getList());
            for (var i = 0; i !== results.schools.length; ++i) {
                if (Number(results.schools[i].index) === 0) continue;
                var school = results.schools[i];
                RankResult.createSchoolRank(
                                            schoolAmountRank,
                                            schoolAmountRank.width,
                                            analysesSectionBar.height*2.6,
                                            school.name,
                                            school.count,
                                            Number(school.amount)/100,
                                            school.index
                                            );
            }

            for (var i = 0; i !== results.grades.length; ++i) {
                var grade = results.grades[i];
                RankResult.createGradeResult(
                                             gradePercentRank,
                                             gradePercentRank.width,
                                             analysesSectionBar.height*2.6,
                                             grade.grade,
                                             grade.count,
                                             grade.total,
                                             (Number(grade.percentage)*100).toFixed(2).toString()+"%",
                                             Number(grade.amount)/100
                                            );
            }

            analysesSection.needUpdate = false;
        }

    }
    function updateIndices() {
        if (mainFrame.currentIndex === 2 && indices.needUpdate) {
            SearchResult.destroyAll();
            indices.build_index(treeModel.getList());
            indices.needUpdate = false;
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
                    model: [qsTr("Edit"), qsTr("Analyze"), qsTr("Search")]

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
                                var index = leftSideView.currentIndex;
                                if (index.row === 0
                                        && treeModel.type(index) === 2)
                                    return;

                                treeModel.removeRow(index.row, treeModel.parent(index));
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
                                if (leftSideView.currentIndex === treeModel.index(0,0) || leftSideView.currentIndex.row < 0) {
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
                            selection: ItemSelectionModel {
                                id: leftSideViewSelection
                                model: leftSideView.model
                                onCurrentIndexChanged: {
                                    var list = treeModel.getDonors(current);
                                    tableModel.setList(list);
                                    treeModel.writeItem(previous);
                                }
                            }

                            selectionMode: SelectionMode.SingleSelection
                            TreeModel {
                                id: treeModel
                                onDataChanged: {
                                    indices.needUpdate = true;
                                    analysesSection.needUpdate = true;
                                }
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
                                color: styleData.selected?"#616161":"#8e8e8e"
                                width: parent.width
                                height: treeTextMetrics.height*1.2
                            }

                            itemDelegate: Button {
                                clip: true
                                cursorShape: Qt.PointingHandCursor
                                Material.background: styleData.selected?"#616161":"#8e8e8e"
                                Material.elevation: 0

                                contentItem: Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0,0,0,0)
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
                                            propagateComposedEvents: true
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
                                                leftSideViewSelection.setCurrentIndex(styleData.index, ItemSelectionModel.ClearAndSelect);

                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    leftSideViewSelection.setCurrentIndex(styleData.index, ItemSelectionModel.ClearAndSelect);
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
                                                text.push(Number(tableModel.data(index, TableModel.AmountRole))/100);
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
                                onDataChanged: {
                                    indices.needUpdate = true;
                                    analysesSection.needUpdate = true;
                                }
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
                                id: tableHeader
                                height: tableHeaderText.height*1.2
                                color: "#dcdcdc"

                                Text {
                                    id: tableHeaderText
                                    text: styleData.value
                                }
                            }
                            rowDelegate: Rectangle {
                                color: styleData.selected ? "#b3b3b3" :  styleData.alternate?"#f5f5f6":"#ffffff"
                                height: tableTextMetrics.height
                                MouseArea {
                                    anchors.fill: parent
                                    propagateComposedEvents: true
                                    enabled: true
                                    onClicked: mouse.accepted = false;
                                    onPressed: {
                                        if (styleData.row == undefined) {
                                            donorsTable.selection.clear();
                                        }
                                        mouse.accepted = false;
                                    }
                                    onReleased: mouse.accepted = false;
                                    onDoubleClicked: mouse.accepted = false;
                                    onPositionChanged: mouse.accepted = false;
                                    onPressAndHold: mouse.accepted = false;
                                }

                            }

                            itemDelegate: Item {
                                id: treeItem

                                Text {
                                    text: styleData.role !== "amount"? styleData.value : Number(styleData.value)/100
                                    color: "black"
                                }
                            }
                        }

                        Rectangle {
                            id: editArea
                            color: "#e1e2e1"
                            height: Math.min(parent.height*0.2, screen.height*0.15)
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
                                                row = tableModel.count-1;
                                            }

                                            tableModel.touchData(row, inputs[0], "name");
                                            tableModel.touchData(row, inputs[1], "id");
                                            tableModel.touchData(row, inputs[2].charCodeAt(0), "gender");
                                            tableModel.touchData(row, Number(inputs[3]), "age");
                                            tableModel.touchData(row, Number(inputs[4])*100, "amount");

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
                        anchors.fill: parent
                        color: Qt.rgba(0,0,0,0)
                        Material.foreground: "#6e6e6e"

                        Component.onCompleted: {
                            RankResult.createComponents();
                        }

                        onVisibleChanged: updateAnalyses();
                        Rectangle {
                            color: Qt.rgba(0,0,0,0)
                            height: parent.height
                            width: parent.width*0.9
                            anchors.centerIn: parent
                            property bool needUpdate: true
                            id: analysesSection
                            TabBar {
                                id: analysesSectionBar
                                width: parent.width
                                Repeater {
                                    model: [
                                        qsTr("School"),
                                        qsTr("Grade")
                                    ]
                                    TabButton {
                                        text: modelData
                                    }
                                }

                            }
                            StackLayout {
                                anchors.top: analysesSectionBar.bottom
                                width: parent.width
                                height: parent.height - analysesSectionBar.height
                                currentIndex: analysesSectionBar.currentIndex
                                Flickable {
                                    maximumFlickVelocity: 800
                                    clip: true
                                    anchors.fill: parent
                                    contentWidth: parent.width
                                    contentHeight: schoolAmountRank.height
                                    ScrollBar.vertical: ScrollBar{}
                                    Column {
                                        id: schoolAmountRank
                                        width: parent.width
                                    }
                                }
                                Flickable {
                                    maximumFlickVelocity: 800
                                    clip: true
                                    anchors.fill: parent
                                    contentWidth: parent.width
                                    contentHeight: gradePercentRank.height
                                    Column {
                                        id: gradePercentRank
                                        width: parent.width
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Material.foreground: "#6e6e6e"
                        color: Qt.rgba(0,0,0,0)
                        id: searchFrame
                        IndexMap {
                            property bool needUpdate: true
                            id: indices
                        }

                        onVisibleChanged: {
                            updateIndices();
                        }

                        Rectangle {
                            color: Qt.rgba(0,0,0,0)
                            id: searchArea
                            width: parent.width
                            height: searchBox.height

                            Component.onCompleted: {
                                SearchResult.createComponents();
                            }

                            TextField {
                                Material.foreground: "#ffffff"
                                anchors.left: parent.left
                                anchors.leftMargin: parent.width*0.05
                                id: searchBox
                                width: parent.width*0.7
                                font.pointSize: 24
                            }
                            Button {
                                anchors.left: searchBox.right
                                anchors.leftMargin: parent.width*0.05
                                cursorShape: Qt.PointingHandCursor
                                text: "search"
                                font.pointSize: 24
                                onClicked: {
                                    SearchResult.destroyAll();

                                    var input = searchBox.text.replace(/(\s+$)|(^\s+)/g, "");
                                    searchBox.text = input;
                                    var results;
                                    var checkedBtn = searchModeGroup.checkedButton;
                                    if (checkedBtn.identifier === 0) {
                                        results = indices.search(input);
                                    } else if (checkedBtn.identifier >= 1 && checkedBtn.identifier <= 4) {
                                        var directions = [0, 1, -1];
                                        var field_enum = [0, IndexMap.Age, IndexMap.Amount, IndexMap.Count, IndexMap.Grade];
                                        var value = Number(input);
                                        if (checkedBtn.identifier === 2) value *= 100;

                                        results = indices.find(value, field_enum[checkedBtn.identifier], directions[checkedBtn.typeId]);
                                    } else if (checkedBtn.identifier === 5) {
                                        var patterns = ['f', 'm', 'x']
                                        results = indices.searchGender(patterns[checkedBtn.typeId].charCodeAt(0));
                                    }

                                    for (var i = 0; i !== results.length; ++i) {
                                        if (Number(results[i].meta.schoolIndex) === 0) continue;
                                        switch (results[i].meta.type) {
                                        case IndexMap.DonorType:
                                            SearchResult.createDonorResult(
                                                                           searchAllResultBox,
                                                                           searchAllResultBox.width,
                                                                           searchResultBar.height*2.4,
                                                                           results[i].name,
                                                                           results[i].id,
                                                                           results[i].gender,
                                                                           results[i].age,
                                                                           results[i].amount/100,
                                                                           results[i].meta.schoolIndex,
                                                                           results[i].meta.classIndex,
                                                                           results[i].meta.donorIndex
                                                                           );
                                            SearchResult.createDonorResult(
                                                                           searchDonorResultBox,
                                                                           searchDonorResultBox.width,
                                                                           searchResultBar.height*2.4,
                                                                           results[i].name,
                                                                           results[i].id,
                                                                           results[i].gender,
                                                                           results[i].age,
                                                                           results[i].amount/100,
                                                                           results[i].meta.schoolIndex,
                                                                           results[i].meta.classIndex,
                                                                           results[i].meta.donorIndex
                                                                           );

                                            break;
                                        case IndexMap.ClassType:
                                            SearchResult.createClassResult(
                                                                           searchAllResultBox,
                                                                           searchAllResultBox.width,
                                                                           searchResultBar.height*2.4,
                                                                           results[i].school,
                                                                           results[i].instructor,
                                                                           results[i].number,
                                                                           results[i].grade,
                                                                           results[i].count,
                                                                           results[i].meta.schoolIndex,
                                                                           results[i].meta.classIndex
                                                                           );
                                            SearchResult.createClassResult(
                                                                           searchClassResultBox,
                                                                           searchClassResultBox.width,
                                                                           searchResultBar.height*2.4,
                                                                           results[i].school,
                                                                           results[i].instructor,
                                                                           results[i].number,
                                                                           results[i].grade,
                                                                           results[i].count,
                                                                           results[i].meta.schoolIndex,
                                                                           results[i].meta.classIndex
                                                                           );

                                            break;
                                        case IndexMap.SchoolType:
                                            SearchResult.createSchoolResult(
                                                                            searchAllResultBox,
                                                                            searchAllResultBox.width,
                                                                            searchResultBar.height*1.4,
                                                                            results[i].name,
                                                                            results[i].principal,
                                                                            results[i].tele,
                                                                            results[i].meta.schoolIndex
                                                                           );
                                            SearchResult.createSchoolResult(
                                                                            searchSchoolResultBox,
                                                                            searchSchoolResultBox.width,
                                                                            searchResultBar.height*1.4,
                                                                            results[i].name,
                                                                            results[i].principal,
                                                                            results[i].tele,
                                                                            results[i].meta.schoolIndex
                                                                           );
                                            break;
                                        default:
                                            break;
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            id: searchModeRow
                            Material.foreground: "#6e6e6e"
                            anchors.top: searchArea.bottom
                            anchors.topMargin: searchBox.height*0.5
                            spacing: textSearchModeBtn.width*0.2
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width*0.1
                            move: Transition {
                                NumberAnimation {
                                    properties: "x, width"
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            ButtonGroup {
                                id: searchModeGroup
                                onClicked: {
                                    checkedButton = button;
                                }
                            }

                            Button {
                                id: textSearchModeBtn
                                checked: true
                                text: qsTr("Text")
                                property int identifier: 0
                                cursorShape: Qt.PointingHandCursor
                                ButtonGroup.group: searchModeGroup
                                font.pointSize: 16
                            }
                            Rectangle{
                                color: Qt.rgba(0,0,0,0)
                                height: parent.height
                                width: textSearchModeBtn.width*0.05
                            }

                            Repeater {
                                model: [qsTr("Age"), qsTr("Amount")]
                                TripleButton {
                                    property int identifier: 1 + index
                                    cursorShape: Qt.PointingHandCursor
                                    ButtonGroup.group: searchModeGroup
                                    font.pointSize: 16
                                    Component.onCompleted: {
                                        text = Qt.binding(
                                                    function() {
                                                        var suffix;
                                                        switch (typeId) {
                                                        case 0:
                                                            suffix = "=";
                                                            break;
                                                        case 1:
                                                            suffix = "\u279A";
                                                            break;
                                                        case 2:
                                                            suffix = "\u2798";
                                                            break;
                                                        default:
                                                            suffix = "";
                                                            break;
                                                        }
                                                        return modelData+suffix;
                                                    }
                                                   );
                                    }
                                }
                            }
                            TripleButton {
                                property int identifier: 5
                                text: qsTr("Gender") + suffix
                                cursorShape: Qt.PointingHandCursor
                                ButtonGroup.group: searchModeGroup
                                font.pointSize: 16
                                Component.onCompleted: {
                                        text = Qt.binding(
                                                    function() {
                                                        var suffix;
                                                        switch (typeId) {
                                                        case 0:
                                                            suffix = ": f";
                                                            break;
                                                        case 1:
                                                            suffix = ": m";
                                                            break;
                                                        case 2:
                                                            suffix = ": x";
                                                            break;
                                                        default:
                                                            suffix = ""
                                                            break;
                                                        }
                                                        return "Gender"+suffix;
                                                    }
                                                   );
                                    }
                            }
                            Rectangle{
                                color: Qt.rgba(0,0,0,0)
                                height: parent.height
                                width: textSearchModeBtn.width*0.05
                            }


                            Repeater {
                                 model: [qsTr("Student Number"), qsTr("Grade")]
                                 TripleButton {
                                     property int identifier: 3 + index
                                     cursorShape: Qt.PointingHandCursor
                                     ButtonGroup.group: searchModeGroup
                                     font.pointSize: 16
                                     Component.onCompleted: {
                                         text = Qt.binding(
                                                     function() {
                                                         var suffix;
                                                         switch (typeId) {
                                                         case 0:
                                                             suffix = "=";
                                                             break;
                                                         case 1:
                                                             suffix = "\u279A";
                                                             break;
                                                         case 2:
                                                             suffix = "\u2798";
                                                             break;
                                                         default:
                                                             suffix = ""
                                                             break;
                                                         }
                                                         return modelData+suffix;
                                                     }
                                                    );
                                     }
                                 }
                            }
                        }

                        Column {
                            anchors.top: searchModeRow.bottom
                            anchors.topMargin: searchBox.height*0.5
                            width: parent.width*0.8
                            height: parent.height-searchBox.height*1.5-searchModeRow.height
                            anchors.leftMargin: parent.width*0.1
                            anchors.left: parent.left
                            TabBar {
                                id: searchResultBar
                                width: parent.width
                                Repeater {
                                    model: [
                                        qsTr("All"),
                                        qsTr("School"),
                                        qsTr("Class"),
                                        qsTr("Donor")
                                    ]
                                    TabButton {
                                        text: modelData
                                    }
                                }

                            }

                            StackLayout {
                                width: parent.width
                                height: parent.height-searchResultBar.height-statusBar.height*1.4
                                currentIndex: searchResultBar.currentIndex
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0,0,0,0)
                                    Flickable {
                                        maximumFlickVelocity: 800
                                        clip: true
                                        anchors.top: parent.top
                                        anchors.topMargin: searchResultBar.height*0.3
                                        anchors.fill: parent
                                        contentWidth: parent.width
                                        contentHeight: searchAllResultBox.height
                                        ScrollBar.vertical: ScrollBar{}
                                        Column {
                                            id: searchAllResultBox
                                            width: parent.width
                                        }

                                    }
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0,0,0,0)
                                    Flickable {
                                        maximumFlickVelocity: 800
                                        clip: true
                                        anchors.top: parent.top
                                        anchors.topMargin: searchResultBar.height*0.3
                                        anchors.fill: parent
                                        contentWidth: parent.width
                                        contentHeight: searchSchoolResultBox.height
                                        ScrollBar.vertical: ScrollBar{}
                                        Column {
                                            id: searchSchoolResultBox
                                            width: parent.width

                                        }

                                    }
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0,0,0,0)
                                    Flickable {
                                        maximumFlickVelocity: 800
                                        clip: true
                                        anchors.top: parent.top
                                        anchors.topMargin: searchResultBar.height*0.3
                                        anchors.fill: parent
                                        contentWidth: parent.width
                                        contentHeight: searchClassResultBox.height
                                        ScrollBar.vertical: ScrollBar{}
                                        Column {
                                            id: searchClassResultBox
                                            width: parent.width

                                        }

                                    }
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0,0,0,0)
                                    Flickable {
                                        maximumFlickVelocity: 800
                                        clip: true
                                        anchors.top: parent.top
                                        anchors.topMargin: searchResultBar.height*0.3
                                        anchors.fill: parent
                                        contentWidth: parent.width
                                        contentHeight: searchDonorResultBox.height
                                        ScrollBar.vertical: ScrollBar{}
                                        Column {
                                            id: searchDonorResultBox
                                            width: parent.width
                                        }

                                    }
                                }
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
                                    for (var i = 0; i !== treeSchoolPopupLayoutTextField.count; ++i) {
                                        var elem = treeSchoolPopupLayoutTextField.itemAt(i);
                                        inputs.push(elem.text.replace(/(\s+$)|(^\s+)/g, ""));
                                        elem.text = inputs[i];
                                    }

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
                                    updateData();
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
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var inputs = [];
                                    for (var i = 0; i !== treeClassPopupLayoutTextField.count; ++i) {
                                        var elem = treeClassPopupLayoutTextField.itemAt(i);
                                        inputs.push(elem.text.replace(/(\s+$)|(^\s+)/g, ""));
                                        elem.text = inputs[i];
                                    }

                                    var pass = true;

                                    for (var i = 0; i !== inputs.length; ++i) {
                                        var reg = new RegExp(treeClassPopupLayoutTextField.model[i].reg);
                                        if (!reg.test(inputs[i])) {
                                            pass = false;
                                            treeClassPopupLayoutTextField.itemAt(i).state = "invalid";
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
                                    updateData();
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
                                cursorShape: Qt.PointingHandCursor
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

            id: sortTablePopup

            x: parent.width*0.3
            y: parent.height*0.05
            width: parent.width*0.6
            height: parent.height*0.95
            modal: true
            focus: true
            padding: width*0.04

            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            Column {
                id: sortTablePopupLayout
                anchors.fill: parent
                Repeater {
                    id: sortTablePopupLayoutRepeater
                    model: [
                        qsTr("name"),
                        qsTr("id"),
                        qsTr("gender"),
                        qsTr("age"),
                        qsTr("amount")
                    ]

                    Button {
                        cursorShape: Qt.PointingHandCursor
                        Material.background: "#ffffff"
                        contentItem: Rectangle {
                            color: Qt.rgba(0,0,0,0)
                            anchors.fill: parent
                            Text {
                                anchors.centerIn: parent
                                font.pointSize: 24
                                text: modelData
                                color: "#696969"
                            }
                        }

                        width: sortTablePopupLayout.width
                        height: sortTablePopupLayout.height/6
                        onClicked: {
                            if (tableModel.count !== 0)
                                tableModel.sort_table(modelData, !sortSwitch.on);
                            sortTablePopup.close();
                        }
                    }
                }
                Button {
                    id: sortSwitch
                    property bool on: false
                    contentItem: Rectangle {
                        color: Qt.rgba(0,0,0,0)
                        anchors.fill: parent
                        Text {
                            anchors.centerIn: parent
                            font.pointSize: 24
                            text: sortSwitch.on ? qsTr("descend") + "\u2798" : qsTr("ascend") + "\u279A"
                            color: "#696969"
                        }
                    }
                    width: sortTablePopupLayout.width
                    height: sortTablePopupLayout.height/6
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        sortSwitch.on = !sortSwitch.on;
                    }
                }
            }

    }

    footer: Row {
        clip: true
        id: statusBar
        width: parent.width

        Rectangle {
            color: "#4f4f4f"
            height: status.height*1.5
            width: parent.width
            Text {
                id: status
                text: "status"
                color: "grey"
                font.pointSize: 10
                anchors.verticalCenter: parent.verticalCenter
            }
            Button {
                Material.background: "#4f4f4f"
                Material.elevation: 0
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "sort"
                font.pointSize: 12
                onClicked: {
                    sortTablePopup.open();
                }
            }
        }
    }
}
