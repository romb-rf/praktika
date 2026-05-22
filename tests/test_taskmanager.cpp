#include <gtest/gtest.h>
#include <QCoreApplication>
#include <QJsonObject>
#include "taskmanager.h"

class TaskManagerTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Очищаем все задачи перед каждым тестом
        auto allQuadrants = {0, 1, 2, 3, -1};
        for (int q : allQuadrants) {
            auto tasks = TaskManager::instance()->tasksForQuadrant(q);
            for (const auto &val : tasks) {
                QJsonObject obj = val.toObject();
                TaskManager::instance()->removeTask(obj["id"].toString());
            }
        }
    }
};

TEST_F(TaskManagerTest, AddTask) {
    QJsonObject taskJson;
    taskJson["title"] = "Test";
    taskJson["quadrant"] = 0;
    int before = TaskManager::instance()->tasksForQuadrant(0).size();
    TaskManager::instance()->addTask(taskJson);
    int after = TaskManager::instance()->tasksForQuadrant(0).size();
    EXPECT_EQ(after, before + 1);
}

TEST_F(TaskManagerTest, RemoveTask) {
    QJsonObject taskJson;
    taskJson["title"] = "ToDelete";
    taskJson["quadrant"] = 0;
    TaskManager::instance()->addTask(taskJson);
    auto tasks = TaskManager::instance()->tasksForQuadrant(0);
    ASSERT_EQ(tasks.size(), 1);
    QString id = tasks[0].toObject()["id"].toString();
    TaskManager::instance()->removeTask(id);
    EXPECT_EQ(TaskManager::instance()->tasksForQuadrant(0).size(), 0);
}

TEST_F(TaskManagerTest, ToggleComplete) {
    QJsonObject taskJson;
    taskJson["title"] = "Toggle";
    taskJson["quadrant"] = 0;
    TaskManager::instance()->addTask(taskJson);
    auto tasks = TaskManager::instance()->tasksForQuadrant(0);
    QString id = tasks[0].toObject()["id"].toString();
    TaskManager::instance()->toggleComplete(id);
    QJsonObject updated = TaskManager::instance()->taskById(id);
    EXPECT_TRUE(updated["completed"].toBool());
    TaskManager::instance()->toggleComplete(id);
    updated = TaskManager::instance()->taskById(id);
    EXPECT_FALSE(updated["completed"].toBool());
}

TEST_F(TaskManagerTest, SearchByTitle) {
    QJsonObject t1, t2;
    t1["title"] = "Buy milk";
    t1["quadrant"] = 0;
    t2["title"] = "Call doctor";
    t2["quadrant"] = 0;
    TaskManager::instance()->addTask(t1);
    TaskManager::instance()->addTask(t2);
    TaskManager::instance()->setSearchQuery("milk");
    EXPECT_EQ(TaskManager::instance()->tasksForQuadrant(0).size(), 1);
    TaskManager::instance()->setSearchQuery("");
    EXPECT_EQ(TaskManager::instance()->tasksForQuadrant(0).size(), 2);
}

TEST_F(TaskManagerTest, EditTask) {
    QJsonObject taskJson;
    taskJson["title"] = "Old";
    taskJson["quadrant"] = 0;
    TaskManager::instance()->addTask(taskJson);
    auto tasks = TaskManager::instance()->tasksForQuadrant(0);
    QString id = tasks[0].toObject()["id"].toString();
    QJsonObject editJson;
    editJson["title"] = "New";
    editJson["quadrant"] = 1;
    TaskManager::instance()->editTask(id, editJson);
    QJsonObject edited = TaskManager::instance()->taskById(id);
    EXPECT_EQ(edited["title"].toString(), "New");
    EXPECT_EQ(edited["quadrant"].toInt(), 1);
    EXPECT_EQ(TaskManager::instance()->tasksForQuadrant(0).size(), 0);
    EXPECT_EQ(TaskManager::instance()->tasksForQuadrant(1).size(), 1);
}