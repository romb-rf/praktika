#pragma once
#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>

class JsonStorage : public QObject {
    Q_OBJECT
public:
    explicit JsonStorage(QObject *parent = nullptr);

    QJsonArray loadTasks() const;
    void saveTasks(const QJsonArray &tasksArray);

private:
    QString filePath() const;
    static constexpr int currentVersion = 1;
};