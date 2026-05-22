#include <gtest/gtest.h>
#include <QDateTime>
#include "task.h"

// Проверка конструктора по умолчанию
TEST(TaskTest, DefaultConstructor) {
    Task t;
    EXPECT_FALSE(t.id.isEmpty());          // ID генерируется
    EXPECT_TRUE(t.title.isEmpty());
    EXPECT_FALSE(t.deadline.isValid());
    EXPECT_EQ(t.quadrant, 0);
    EXPECT_FALSE(t.completed);
}

// Проверка полного цикла: toJson -> fromJson
TEST(TaskTest, SerializationRoundTrip) {
    Task original;
    original.title = "Test task";
    original.description = "Desc";
    original.deadline = QDateTime(QDate(2026, 5, 15), QTime(14, 30));
    original.quadrant = 2;
    original.tags = {"work", "urgent"};
    original.project = "ProjectX";
    original.recurrenceRule = "weekly";

    QJsonObject json = original.toJson();
    Task restored = Task::fromJson(json);

    EXPECT_EQ(restored.title, original.title);
    EXPECT_EQ(restored.description, original.description);
    EXPECT_EQ(restored.deadline, original.deadline);
    EXPECT_EQ(restored.quadrant, original.quadrant);
    EXPECT_EQ(restored.completed, original.completed);
    EXPECT_EQ(restored.tags, original.tags);
    EXPECT_EQ(restored.project, original.project);
    EXPECT_EQ(restored.recurrenceRule, original.recurrenceRule);
}

// Проверка, что некорректная дата приводит к невалидному QDateTime
TEST(TaskTest, InvalidDeadline) {
    QJsonObject obj;
    obj["title"] = "Bad deadline";
    obj["deadline"] = "не дата";
    Task t = Task::fromJson(obj);
    EXPECT_EQ(t.title, "Bad deadline");
    EXPECT_FALSE(t.deadline.isValid());
}

// Проверка, что пустые теги сериализуются в пустой массив
TEST(TaskTest, EmptyTags) {
    Task t;
    t.tags = QStringList();
    QJsonObject json = t.toJson();
    EXPECT_TRUE(json["tags"].toArray().isEmpty());
}