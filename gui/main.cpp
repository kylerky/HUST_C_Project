#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "treemodel.hpp"
#include "treeitem.hpp"
#include "tablemodel.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<HUST_C::TreeModel>("hust.kyle", 1, 0, "TreeModel");
    qmlRegisterType<HUST_C::TableModel>("hust.kyle", 1, 0, "TableModel");


    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
