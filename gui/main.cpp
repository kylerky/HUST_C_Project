#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>
#include <QString>
#include <QLockFile>
#include <QDir>
#include <iostream>
#include "tablemodel.hpp"
#include "treeitem.hpp"
#include "treemodel.hpp"
#include "launcherrmsg.hpp"
#include "indexmap.hpp"
#include "analyze.hpp"

namespace {
inline QObject *launch_err_singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new HUST_C::LaunchErrMsg();
}

inline QObject *analyze_singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new HUST_C::Analyze();
}
}

int main(int argc, char *argv[]) {
    QQuickStyle::setStyle("Material");
    QGuiApplication app(argc, argv);

    qmlRegisterType<HUST_C::TreeModel>("hust.kyle", 1, 0, "TreeModel");
    qmlRegisterType<HUST_C::TableModel>("hust.kyle", 1, 0, "TableModel");
    qmlRegisterType<HUST_C::IndexMap>("hust.kyle", 1, 0, "IndexMap");

    qmlRegisterSingletonType<HUST_C::Analyze>("hust.kyle", 1, 0, "Analyze", analyze_singletontype_provider);

    QQmlApplicationEngine engine;

    QLockFile lockFile("donation.lock");
    lockFile.setStaleLockTime(0);

    if (!QDir("donation_data").exists())
        if (!QDir().mkdir("donation_data"))
            HUST_C::ErrorMsg::errMsg = "Cannot create directory \"donation_data\"";


    if (HUST_C::ErrorMsg::errMsg.empty() && !QDir::setCurrent("donation_data"))
        HUST_C::ErrorMsg::errMsg = "Cannot enter directory \"donation_data\"";


    if (HUST_C::ErrorMsg::errMsg.empty() && !lockFile.tryLock(100))
        HUST_C::ErrorMsg::errMsg = "Another instance of the application is running, will close this one.";

    if (HUST_C::ErrorMsg::errMsg.empty())
        engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    else {
        qmlRegisterSingletonType<HUST_C::LaunchErrMsg>("hust.kyle", 1, 0, "LaunchErrMsg", launch_err_singletontype_provider);
        engine.load(QUrl(QStringLiteral("qrc:/error.qml")));
    }

    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
