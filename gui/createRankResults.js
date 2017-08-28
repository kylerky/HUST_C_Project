var rankReady = [false, false];
var schoolRankComponent;
var gradeRankComponent;

var schoolObjs = [];
var gradeObjs = [];

function createComponents() {
    schoolRankComponent = Qt.createComponent("SchoolRankTab.qml");
    if (schoolRankComponent.status === Component.Ready)
        finishCreation(schoolRankComponent, 0);
    else
        schoolRankComponent.statusChanged.connect(finishCreation.bind(null, schoolRankComponent));

    gradeRankComponent = Qt.createComponent("GradeRankTab.qml");
    if (gradeRankComponent.status === Component.Ready)
        finishCreation(gradeRankComponent, 1);
    else
        gradeRankComponent.statusChanged.connect(finishCreation.bind(null, gradeRankComponent));
}

function finishCreation(component, indicator) {
    if (component.status === Component.Ready) {
        rankReady[indicator] = true;
    } else if (component.status === Component.Error) {
        // Error Handling
        console.error("Error loading component:", component.errorString());
    }
}

function createSchoolRank(parent, width, height, name, count, amount, schoolIndex) {
    if (!rankReady[0]) return false;

    var obj = schoolRankComponent.createObject(parent, {
                                                     "height": height,
                                                     "width": width,
                                                     "nameText.text": name,
                                                     "countText.text": count.toString(),
                                                     "amountText.text": amount.toString(),
                                                     "schoolIndex": schoolIndex
                                                    });
    if (obj == null) {
        console.error("Error createing object");
    } else {
        schoolObjs.push(obj);
    }
}


function createGradeResult(parent, width, height, grade, count, total, percent, amount) {
    if (!rankReady[1]) return false;

    var obj = gradeRankComponent.createObject(parent, {
                                                    "height": height,
                                                    "width": width,
                                                    "gradeText.text": grade.toString(),
                                                    "countText.text": count.toString(),
                                                    "totalText.text": total.toString(),
                                                    "percentText.text": percent,
                                                    "amountText.text": amount.toString()
                                                    });
    if (obj == null) {
        console.error("Error createing object");
    } else {
        gradeObjs.push(obj);
    }
}


function destroyAll() {
    var obj
    obj = gradeObjs.pop();
    while (obj != undefined) {
        obj.destroy();
        obj = gradeObjs.pop();
    }

    obj = schoolObjs.pop();
    while (obj != undefined) {
        obj.destroy();
        obj = schoolObjs.pop();
    }
}
