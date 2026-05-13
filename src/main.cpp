#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QPalette>
#include "taskmanager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Стиль, дружественный к кастомизации
    QQuickStyle::setStyle("Fusion");

    // Глобальная светлая палитра для всех окон и попапов
    QPalette lightPalette;
    lightPalette.setColor(QPalette::Window, QColor("#FFFFFF"));
    lightPalette.setColor(QPalette::WindowText, QColor("#2C3E50"));
    lightPalette.setColor(QPalette::Base, QColor("#FFFFFF"));
    lightPalette.setColor(QPalette::AlternateBase, QColor("#F7F9FB"));
    lightPalette.setColor(QPalette::Text, QColor("#2C3E50"));
    lightPalette.setColor(QPalette::Button, QColor("#F0F2F5"));
    lightPalette.setColor(QPalette::ButtonText, QColor("#2C3E50"));
    lightPalette.setColor(QPalette::Highlight, QColor("#3498DB"));
    lightPalette.setColor(QPalette::HighlightedText, QColor("#FFFFFF"));
    app.setPalette(lightPalette);

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