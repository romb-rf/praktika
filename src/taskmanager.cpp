#include "taskmanager.h"
#include <QCoreApplication>
#include <algorithm>
#include <ranges>
#include <vector>
#include <QDebug>
#include <QSettings>
#include <QSoundEffect>
#include <QCoreApplication>

TaskManager* TaskManager::instance() {
    static TaskManager* inst = new TaskManager(QCoreApplication::instance());
    return inst;
}

TaskManager::TaskManager(QObject *parent) : QObject(parent) {
    loadFromDisk();
    m_notificationSound = new QSoundEffect(this);
    m_notificationSound->setSource(QUrl("qrc:/sounds/bell.wav"));
    m_notificationSound->setVolume(0.8);
    // Если файл не загрузился, статус останется Error, будем использовать beep
    m_saveTimer.setSingleShot(true);
    m_saveTimer.setInterval(200);
    connect(&m_saveTimer, &QTimer::timeout, this, &TaskManager::saveToDisk);
}

void TaskManager::loadFromDisk() {
    QJsonArray arr = m_storage.loadTasks();
    m_tasks.clear();
    for (const auto &val : arr) {
        m_tasks.append(Task::fromJson(val.toObject()));
    }
    emit dataChanged();
}

void TaskManager::scheduleSave() {
    m_saveTimer.start();
}

void TaskManager::saveToDisk() {
    QJsonArray arr;
    for (const auto &task : m_tasks) {
        arr.append(task.toJson());
    }
    m_storage.saveTasks(arr);
}

QJsonArray TaskManager::tasksForQuadrant(int quadrant) const {
    // Фильтрация
    auto filtered = m_tasks | std::views::filter([quadrant, this](const Task &t) {
                        if (t.quadrant != quadrant) return false;
                        if (!m_searchQuery.isEmpty()) {
                            bool matches = t.title.contains(m_searchQuery, Qt::CaseInsensitive)
                            || t.description.contains(m_searchQuery, Qt::CaseInsensitive);
                            if (!matches) {
                                for (const auto &tag : t.tags)
                                    if (tag.contains(m_searchQuery, Qt::CaseInsensitive)) {
                                        matches = true;
                                        break;
                                    }
                            }
                            if (!matches) return false;
                        }
                        return true;
                    });

    // Материализуем в вектор для сортировки
    std::vector<Task> sorted(filtered.begin(), filtered.end());
    std::ranges::sort(sorted, [](const Task &a, const Task &b) {
        if (!a.deadline.isValid()) return false;
        if (!b.deadline.isValid()) return true;
        return a.deadline < b.deadline;
    });

    QJsonArray result;
    for (const auto &t : sorted)
        result.append(t.toJson());
    return result;
}

QJsonObject TaskManager::taskById(const QString &id) const {
    for (const auto &t : m_tasks) {
        if (t.id == id)
            return t.toJson();
    }
    return {};
}

void TaskManager::addTask(const QJsonObject &taskJson) {
    Task task = Task::fromJson(taskJson);
    m_tasks.append(task);
    scheduleSave();
    emit dataChanged();
}

void TaskManager::editTask(const QString &id, const QJsonObject &taskJson) {
    for (auto &t : m_tasks) {
        if (t.id == id) {
            t = Task::fromJson(taskJson);
            t.id = id; // подменяем ID на оригинальный
            scheduleSave();
            emit dataChanged();
            return;
        }
    }
}

void TaskManager::removeTask(const QString &id) {
    auto it = std::remove_if(m_tasks.begin(), m_tasks.end(),
                             [&id](const Task &t) { return t.id == id; });
    if (it != m_tasks.end()) {
        m_tasks.erase(it, m_tasks.end());
        scheduleSave();
        emit dataChanged();
    }
}

void TaskManager::toggleComplete(const QString &id) {
    for (auto &t : m_tasks) {
        if (t.id == id) {
            t.completed = !t.completed;
            if (t.completed) {
                handleRecurrenceIfNeeded(t);
            }
            scheduleSave();
            emit dataChanged();
            return;
        }
    }
}

void TaskManager::moveTaskToQuadrant(const QString &id, int newQuadrant) {
    if (newQuadrant < 0 || newQuadrant > 3) return;
    for (auto &t : m_tasks) {
        if (t.id == id) {
            t.quadrant = newQuadrant;
            scheduleSave();
            emit dataChanged();
            return;
        }
    }
}

void TaskManager::handleRecurrenceIfNeeded(const Task &completedTask) {
    if (completedTask.recurrenceRule.isEmpty())
        return;

    Task newTask;
    newTask.title = completedTask.title;
    newTask.description = completedTask.description;
    newTask.quadrant = completedTask.quadrant;
    newTask.tags = completedTask.tags;
    newTask.project = completedTask.project;
    newTask.recurrenceRule = completedTask.recurrenceRule;

    QDateTime nextDeadline;
    if (!completedTask.deadline.isValid()) {
        nextDeadline = QDateTime::currentDateTimeUtc();
    } else {
        nextDeadline = completedTask.deadline;
    }

    if (completedTask.recurrenceRule == "daily") {
        nextDeadline = nextDeadline.addDays(1);
    } else if (completedTask.recurrenceRule == "weekly") {
        nextDeadline = nextDeadline.addDays(7);
    } else if (completedTask.recurrenceRule == "monthly") {
        nextDeadline = nextDeadline.addMonths(1);
    } else if (completedTask.recurrenceRule == "yearly") {
        nextDeadline = nextDeadline.addYears(1);
    } else if (completedTask.recurrenceRule == "weekdays") {
        nextDeadline = nextDeadline.addDays(1);
        while (nextDeadline.date().dayOfWeek() > 5) // сб, вс -> пн
            nextDeadline = nextDeadline.addDays(1);
    }
    newTask.deadline = nextDeadline;
    newTask.createdAt = QDateTime::currentDateTimeUtc();

    m_tasks.append(newTask);
}

QString TaskManager::searchQuery() const {
    return m_searchQuery;
}

void TaskManager::setSearchQuery(const QString &query) {
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit searchQueryChanged();
        emit dataChanged();
    }
}
QJsonArray TaskManager::inboxTasks() const {
    auto filtered = m_tasks | std::views::filter([](const Task &t) {
                        return t.quadrant == -1;
                    });
    std::vector<Task> sorted(filtered.begin(), filtered.end());
    std::ranges::sort(sorted, [](const Task &a, const Task &b) {
        if (!a.deadline.isValid()) return false;
        if (!b.deadline.isValid()) return true;
        return a.deadline < b.deadline;
    });
    QJsonArray result;
    for (const auto &t : sorted)
        result.append(t.toJson());
    return result;
}

QJsonArray TaskManager::tasksForQuadrantAndPeriod(int quadrant, const QString &period) const {
    // Сначала фильтруем по квадранту и поиску (как в tasksForQuadrant)
    auto filtered = m_tasks | std::views::filter([quadrant, this](const Task &t) {
                        if (t.quadrant != quadrant) return false;
                        if (!m_searchQuery.isEmpty()) {
                            bool matches = t.title.contains(m_searchQuery, Qt::CaseInsensitive)
                            || t.description.contains(m_searchQuery, Qt::CaseInsensitive);
                            if (!matches) {
                                for (const auto &tag : t.tags)
                                    if (tag.contains(m_searchQuery, Qt::CaseInsensitive)) {
                                        matches = true;
                                        break;
                                    }
                            }
                            if (!matches) return false;
                        }
                        return true;
                    });

    QDate today = QDate::currentDate();

    // Фильтрация по периоду
    std::vector<Task> periodFiltered;
    if (period == "all") {
        // Без фильтра даты
        for (const auto &t : filtered)
            periodFiltered.push_back(t);
    } else if (period == "day") {
        for (const auto &t : filtered) {
            if (!t.deadline.isValid()) continue;
            if (t.deadline.date() == today)
                periodFiltered.push_back(t);
        }
    } else if (period == "week") {
        // Пн-Вс текущей недели (Qt: понедельник = 1)
        QDate monday = today.addDays(1 - today.dayOfWeek());
        QDate sunday = monday.addDays(6);
        for (const auto &t : filtered) {
            if (!t.deadline.isValid()) continue;
            if (t.deadline.date() >= monday && t.deadline.date() <= sunday)
                periodFiltered.push_back(t);
        }
    } else if (period == "month") {
        QDate firstDay(today.year(), today.month(), 1);
        QDate lastDay = firstDay.addMonths(1).addDays(-1);
        for (const auto &t : filtered) {
            if (!t.deadline.isValid()) continue;
            if (t.deadline.date() >= firstDay && t.deadline.date() <= lastDay)
                periodFiltered.push_back(t);
        }
    } else if (period == "quarter") {
        int quarter = (today.month() - 1) / 3;
        QDate firstDay(today.year(), quarter * 3 + 1, 1);
        QDate lastDay = firstDay.addMonths(3).addDays(-1);
        for (const auto &t : filtered) {
            if (!t.deadline.isValid()) continue;
            if (t.deadline.date() >= firstDay && t.deadline.date() <= lastDay)
                periodFiltered.push_back(t);
        }
    }

    // Сортировка по дедлайну (как обычно)
    std::ranges::sort(periodFiltered, [](const Task &a, const Task &b) {
        if (!a.deadline.isValid()) return false;
        if (!b.deadline.isValid()) return true;
        return a.deadline < b.deadline;
    });

    QJsonArray result;
    for (const auto &t : periodFiltered)
        result.append(t.toJson());
    return result;
}

QJsonArray TaskManager::tasksForRange(const QString &from, const QString &to) const {
    QDate fromDate = QDate::fromString(from, Qt::ISODate);
    QDate toDate = QDate::fromString(to, Qt::ISODate);
    if (!fromDate.isValid() || !toDate.isValid())
        return {};

    auto filtered = m_tasks | std::views::filter([fromDate, toDate](const Task &t) {
                        if (!t.deadline.isValid()) return false;
                        return t.deadline.date() >= fromDate && t.deadline.date() <= toDate;
                    });

    std::vector<Task> sorted(filtered.begin(), filtered.end());
    std::ranges::sort(sorted, [](const Task &a, const Task &b) {
        return a.deadline < b.deadline;
    });

    QJsonArray result;
    for (const auto &t : sorted)
        result.append(t.toJson());
    return result;
}

QJsonArray TaskManager::calendarModel(const QString &period, const QString &currentISODate) const {
    QDate refDate = QDate::fromString(currentISODate, Qt::ISODate);
    if (!refDate.isValid()) refDate = QDate::currentDate();

    QDate start, end;
    int totalCells = 0;

    if (period == "week") {
        int dayOfWeek = refDate.dayOfWeek(); // 1=пн ... 7=вс
        start = refDate.addDays(1 - dayOfWeek);
        end = start.addDays(6);
        totalCells = 7;
    } else if (period == "month") {
        start = QDate(refDate.year(), refDate.month(), 1);
        end = start.addMonths(1).addDays(-1);
        int startOffset = start.dayOfWeek() - 1; // 0 = пн
        int daysInMonth = start.daysInMonth();
        totalCells = startOffset + daysInMonth;
        while (totalCells % 7 != 0) totalCells++;
    } else {
        return {};
    }

    // Собираем задачи диапазона
    QVector<Task> rangeTasks;
    for (const auto &task : m_tasks) {
        if (task.deadline.isValid() && task.deadline.date() >= start && task.deadline.date() <= end) {
            rangeTasks.append(task);
        }
    }

    QJsonArray cells;
    for (int i = 0; i < totalCells; ++i) {
        QJsonObject cell;
        if (period == "week") {
            QDate cellDate = start.addDays(i);
            cell["day"] = cellDate.day();
            cell["dateStr"] = cellDate.toString(Qt::ISODate);
            cell["isToday"] = (cellDate == QDate::currentDate());
            QJsonArray tasksForDay;
            for (const auto &task : rangeTasks) {
                if (task.deadline.date() == cellDate) tasksForDay.append(task.toJson());
            }
            cell["tasks"] = tasksForDay;
        } else { // month
            int startOffset = start.dayOfWeek() - 1;
            if (i < startOffset) {
                cell["day"] = 0;
                cell["dateStr"] = "";
                cell["isToday"] = false;
                cell["tasks"] = QJsonArray();
            } else {
                int dayNumber = i - startOffset + 1;
                if (dayNumber <= end.day()) {
                    QDate cellDate(start.year(), start.month(), dayNumber);
                    cell["day"] = dayNumber;
                    cell["dateStr"] = cellDate.toString(Qt::ISODate);
                    cell["isToday"] = (cellDate == QDate::currentDate());
                    QJsonArray tasksForDay;
                    for (const auto &task : rangeTasks) {
                        if (task.deadline.date() == cellDate) tasksForDay.append(task.toJson());
                    }
                    cell["tasks"] = tasksForDay;
                } else {
                    cell["day"] = 0;
                    cell["dateStr"] = "";
                    cell["isToday"] = false;
                    cell["tasks"] = QJsonArray();
                }
            }
        }
        cells.append(cell);
    }
    return cells;
}
int TaskManager::dialogX() const {
    QSettings settings("EisenNotion", "EisenNotion");
    return settings.value("dialogX", -1).toInt(); // -1 значит "не задано"
}

void TaskManager::setDialogX(int x) {
    QSettings settings("EisenNotion", "EisenNotion");
    settings.setValue("dialogX", x);
    emit dialogPositionChanged();
}

int TaskManager::dialogY() const {
    QSettings settings("EisenNotion", "EisenNotion");
    return settings.value("dialogY", -1).toInt();
}

void TaskManager::setDialogY(int y) {
    QSettings settings("EisenNotion", "EisenNotion");
    settings.setValue("dialogY", y);
    emit dialogPositionChanged();
}

int TaskManager::pomodoroWorkDuration() const {
    QSettings settings("EisenNotion", "EisenNotion");
    return settings.value("pomodoroWorkDuration", 1).toInt();
}
void TaskManager::setPomodoroWorkDuration(int minutes) {
    QSettings settings("EisenNotion", "EisenNotion");
    settings.setValue("pomodoroWorkDuration", minutes);
    emit pomodoroSettingsChanged();
}
int TaskManager::pomodoroBreakDuration() const {
    QSettings settings("EisenNotion", "EisenNotion");
    return settings.value("pomodoroBreakDuration", 5).toInt();
}
void TaskManager::setPomodoroBreakDuration(int minutes) {
    QSettings settings("EisenNotion", "EisenNotion");
    settings.setValue("pomodoroBreakDuration", minutes);
    emit pomodoroSettingsChanged();
}
// void TaskManager::playNotificationSound() {
//     if (m_notificationSound && m_notificationSound->status() == QSoundEffect::Ready) {
//         m_notificationSound->play();
//     }
// }