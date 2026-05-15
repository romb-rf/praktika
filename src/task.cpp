#include "task.h"
#include <QUuid>

Task::Task()
    : id(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , createdAt(QDateTime::currentDateTime())   // локальное время
{
}

Task::Task(const QJsonObject &json) {
    *this = fromJson(json);
}

QJsonObject Task::toJson() const {
    QJsonObject obj;
    obj["id"] = id;
    obj["title"] = title;
    obj["description"] = description;
    // Сохраняем дедлайн как локальное время в формате без миллисекунд и без часового пояса
    obj["deadline"] = deadline.isValid() ? deadline.toString("yyyy-MM-ddTHH:mm:ss") : QString();
    obj["createdAt"] = createdAt.isValid() ? createdAt.toString("yyyy-MM-ddTHH:mm:ss") : QString();
    obj["quadrant"] = quadrant;
    obj["completed"] = completed;
    obj["tags"] = QJsonArray::fromStringList(tags);
    obj["project"] = project;
    obj["recurrenceRule"] = recurrenceRule;
    return obj;
}

Task Task::fromJson(const QJsonObject &json) {
    Task task;
    task.id = json.value("id").toString();
    if (task.id.isEmpty())
        task.id = QUuid::createUuid().toString(QUuid::WithoutBraces);

    task.title = json.value("title").toString();
    task.description = json.value("description").toString();

    QString ds = json.value("deadline").toString();
    // Парсим локальное время без миллисекунд (формат совпадает с toJson)
    task.deadline = ds.isEmpty() ? QDateTime() : QDateTime::fromString(ds, "yyyy-MM-ddTHH:mm:ss");

    QString cs = json.value("createdAt").toString();
    task.createdAt = cs.isEmpty() ? QDateTime::currentDateTime() : QDateTime::fromString(cs, "yyyy-MM-ddTHH:mm:ss");

    task.quadrant = json.value("quadrant").toInt(0);
    task.completed = json.value("completed").toBool(false);

    QJsonArray tagsArray = json.value("tags").toArray();
    task.tags.clear();
    for (const auto &t : tagsArray)
        task.tags << t.toString();

    task.project = json.value("project").toString();
    task.recurrenceRule = json.value("recurrenceRule").toString();
    return task;
}