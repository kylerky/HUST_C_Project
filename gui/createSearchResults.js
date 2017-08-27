var ready = [false, false, false];
var classComponent;
var schoolComponent;
var donorComponent;

var classObjs = [];
var donorObjs = [];
var schoolObjs = [];

function createComponents() {
    classComponent = Qt.createComponent("ClassResultTab.qml");
    if (classComponent.status === Component.Ready)
        finishCreation(classComponent, 0);
    else
        classComponent.statusChanged.connect(finishCreation.bind(null, classComponent, classReady));

    schoolComponent = Qt.createComponent("SchoolResultTab.qml");
    if (schoolComponent.status === Component.Ready)
        finishCreation(schoolComponent, 1);
    else
        schoolComponent.statusChanged.connect(finishCreation.bind(null, schoolComponent, schoolReady));

    donorComponent = Qt.createComponent("DonorResultTab.qml");
    if (donorComponent.status === Component.Ready)
        finishCreation(donorComponent, 2);
    else
        donorComponent.statusChanged.connect(finishCreation.bind(null, donorComponent, donorReady));
}

function finishCreation(component, indicator) {
    if (component.status === Component.Ready) {
        ready[indicator] = true;
    } else if (component.status === Component.Error) {
        // Error Handling
        console.error("Error loading component:", component.errorString());
    }
}

function createClassResult(parent, width, height, school, instructor, number, grade, count, schoolIndex, classIndex) {
    if (!ready[0]) return false;

    var index = 1;
    var obj = classComponent.createObject(parent, {
                                                     "height": height,
                                                     "width": width,
                                                     "schoolText.text": school,
                                                     "instructorText.text": instructor,
                                                     "numberText.text": number,
                                                     "gradeText.text": grade.toString(),
                                                     "cntText.text": count.toString(),
                                                     "schoolIndex": schoolIndex,
                                                     "classIndex": classIndex
                                                    });
    if (obj == null) {
        console.error("Error createing object");
    } else {
        classObjs.push(obj);
    }
}


function createSchoolResult(parent, width, height, name, principal, tele, schoolIndex) {
    if (!ready[1]) return false;

    var obj = schoolComponent.createObject(parent, {
                                                    "height": height,
                                                    "width": width,
                                                    "nameText.text": name,
                                                    "principalText.text": principal,
                                                    "teleText.text": tele,
                                                    "schoolIndex": schoolIndex
                                                    });
    if (obj == null) {
        console.error("Error createing object");
    } else {
        schoolObjs.push(obj);
    }
}

function createDonorResult(parent, width, height, name, id, gender, age, amount, schoolIndex, classIndex, donorIndex) {
    if (!ready[2]) return false;

    var obj = donorComponent.createObject(parent, {
                                                    "height": height,
                                                    "width": width,
                                                    "nameText.text": name,
                                                    "idText.text": id,
                                                    "ageText.text": age.toString(),
                                                    "genderText.text": gender,
                                                    "amountText.text": amount.toString(),
                                                    "schoolIndex": schoolIndex,
                                                    "classIndex": classIndex,
                                                    "donorIndex": donorIndex
                                                    });
    if (obj == null) {
        console.error("Error createing object");
    } else {
        donorObjs.push(obj);
    }
}

function destroyAll() {
    var obj = classObjs.pop();
    while (obj != undefined) {
        obj.destroy();
        obj = classObjs.pop();
    }

    obj = donorObjs.pop();
    while (obj != undefined) {
        obj.destroy();
        obj = donorObjs.pop();
    }

    obj = schoolObjs.pop();
    while (obj != undefined) {
        obj.destroy();
        obj = schoolObjs.pop();
    }
}
