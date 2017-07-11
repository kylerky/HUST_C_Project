#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "treemodel.hpp"
#include "treeitem.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<HUST_C::TreeModel>("hust.kyle", 1, 0, "TreeModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
