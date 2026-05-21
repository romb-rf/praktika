#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include "taskmanager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Стиль Basic — идеален для полной кастомизации в QML
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;
    qmlRegisterSingletonInstance<TaskManager>("EisenNotion", 1, 0, "TaskManager", TaskManager::instance());

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}