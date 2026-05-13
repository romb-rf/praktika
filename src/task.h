#pragma once
#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>

class Task {
public:
    Task();
    explicit Task(const QJsonObject &json);

    QJsonObject toJson() const;
    static Task fromJson(const QJsonObject &json);

    QString id;
    QString title;
    QString description;
    QDateTime deadline;
    QDateTime createdAt;
    int quadrant = 0;                // 0: срочно+важно, 1: срочно+неважно, 2: несрочно+важно, 3: несрочно+неважно
    bool completed = false;
    QStringList tags;
    QString project;
    QString recurrenceRule;          // "daily","weekly","monthly","yearly","weekdays" или ""
};