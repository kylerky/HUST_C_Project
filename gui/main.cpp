#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>
#include <QString>
#include <QLockFile>
#include <QDir>
#include "tablemodel.hpp"
#include "treeitem.hpp"
#include "treemodel.hpp"
#include "launcherrmsg.hpp"

int main(int argc, char *argv[]) {
    QQuickStyle::setStyle("Material");
    QGuiApplication app(argc, argv);

    qmlRegisterType<HUST_C::TreeModel>("hust.kyle", 1, 0, "TreeModel");
    qmlRegisterType<HUST_C::TableModel>("hust.kyle", 1, 0, "TableModel");

    QQmlApplicationEngine engine;

    QLockFile lockFile("donation.lock");
    lockFile.setStaleLockTime(0);

    if (!lockFile.tryLock(100))
        HUST_C::ErrorMsg::errMsg = "Another instance of the application is running, will close this one.";
    else {
        QDir dir("donation_data");
        if (!dir.exists()) {
            if (!QDir().mkdir("donation_data")) {
                HUST_C::ErrorMsg::errMsg = "Cannot create directory \"donation_data\"";
            }
        }
    }

    if (HUST_C::ErrorMsg::errMsg.empty())
        engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    else {
        qmlRegisterType<HUST_C::LaunchErrMsg>("hust.kyle", 1, 0, "LaunchErrMsg");
        engine.load(QUrl(QStringLiteral("qrc:/error.qml")));
    }

    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
