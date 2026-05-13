#include "jsonstorage.h"

JsonStorage::JsonStorage(QObject *parent) : QObject(parent) {}

QString JsonStorage::filePath() const {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(dir);
    return dir + "/tasks.json";
}

QJsonArray JsonStorage::loadTasks() const {
    QFile file(filePath());
    if (!file.open(QIODevice::ReadOnly)) {
        return {};
    }
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonObject root = doc.object();
    // Проверка версии (пока просто игнорируем, если старая)
    if (root.contains("version") && root["version"].toInt() == currentVersion) {
        return root["tasks"].toArray();
    }
    // Если файл старого формата (просто массив) – загружаем как есть
    if (doc.isArray()) {
        return doc.array();
    }
    return {};
}

void JsonStorage::saveTasks(const QJsonArray &tasksArray) {
    QFile file(filePath());
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning("Cannot open tasks.json for writing");
        return;
    }
    QJsonObject root;
    root["version"] = currentVersion;
    root["tasks"] = tasksArray;
    QJsonDocument doc(root);
    file.write(doc.toJson());
}