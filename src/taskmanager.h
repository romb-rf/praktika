#pragma once
#include <QObject>
#include <QVector>
#include <QTimer>
#include "task.h"
#include "jsonstorage.h"

class TaskManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)

public:
    static TaskManager* instance();
    explicit TaskManager(QObject *parent = nullptr);

    Q_INVOKABLE QJsonArray tasksForQuadrant(int quadrant) const;
    Q_INVOKABLE QJsonObject taskById(const QString &id) const;
    Q_INVOKABLE void addTask(const QJsonObject &taskJson);
    Q_INVOKABLE void editTask(const QString &id, const QJsonObject &taskJson);
    Q_INVOKABLE void removeTask(const QString &id);
    Q_INVOKABLE void toggleComplete(const QString &id);
    Q_INVOKABLE void moveTaskToQuadrant(const QString &id, int newQuadrant);
    Q_INVOKABLE QJsonArray inboxTasks() const;

    QString searchQuery() const;
    void setSearchQuery(const QString &query);

signals:
    void dataChanged();
    void searchQueryChanged();

private slots:
    void saveToDisk();

private:
    QVector<Task> m_tasks;
    JsonStorage m_storage;
    QTimer m_saveTimer;
    QString m_searchQuery;

    void scheduleSave();
    void loadFromDisk();
    void handleRecurrenceIfNeeded(const Task &completedTask);
};