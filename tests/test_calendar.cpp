#include <gtest/gtest.h>
#include <QJsonArray>
#include <QDate>
#include "taskmanager.h"

class CalendarModelTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Очищаем все задачи
        auto allQuadrants = {0, 1, 2, 3, -1};
        for (int q : allQuadrants) {
            auto tasks = TaskManager::instance()->tasksForQuadrant(q);
            for (const auto &val : tasks) {
                QJsonObject obj = val.toObject();
                TaskManager::instance()->removeTask(obj["id"].toString());
            }
        }
        // Добавляем задачи на конкретные даты
        QJsonObject t1;
        t1["title"] = "Task May 15";
        t1["deadline"] = "2026-05-15T10:00:00.000";
        t1["quadrant"] = 0;
        TaskManager::instance()->addTask(t1);

        QJsonObject t2;
        t2["title"] = "Task May 20";
        t2["deadline"] = "2026-05-20T12:00:00.000";
        t2["quadrant"] = 0;
        TaskManager::instance()->addTask(t2);
    }
};

TEST_F(CalendarModelTest, WeekModelHasCorrectDays) {
    QJsonArray week = TaskManager::instance()->calendarModel("week", "2026-05-15");
    ASSERT_EQ(week.size(), 7);
    // Понедельник 11 мая
    QJsonObject monday = week[0].toObject();
    EXPECT_EQ(monday["day"].toInt(), 11);
    EXPECT_EQ(monday["dateStr"].toString().left(10), "2026-05-11");
    // Пятница 15 мая
    QJsonObject friday = week[4].toObject();
    EXPECT_EQ(friday["day"].toInt(), 15);
    EXPECT_EQ(friday["dateStr"].toString().left(10), "2026-05-15");
}

TEST_F(CalendarModelTest, MonthModelFirstDayOffset) {
    QJsonArray month = TaskManager::instance()->calendarModel("month", "2026-05-01");
    // Май 2026: 1-е пятница → 4 пустых ячейки перед ним
    EXPECT_EQ(month[0].toObject()["day"].toInt(), 0);
    EXPECT_EQ(month[4].toObject()["day"].toInt(), 1);
    EXPECT_EQ(month[4].toObject()["dateStr"].toString().left(10), "2026-05-01");
}

TEST_F(CalendarModelTest, TasksAssignedToCorrectDate) {
    QJsonArray week = TaskManager::instance()->calendarModel("week", "2026-05-15");
    QJsonObject friday = week[4].toObject();
    QJsonArray tasks = friday["tasks"].toArray();
    ASSERT_EQ(tasks.size(), 1);
    EXPECT_EQ(tasks[0].toObject()["title"].toString(), "Task May 15");
}