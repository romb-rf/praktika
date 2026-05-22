cmake_minimum_required(VERSION 3.16)
project(EisenNotionTests LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Добавляем Multimedia, чтобы taskmanager.h не ругался
find_package(Qt6 REQUIRED COMPONENTS Core Multimedia)

# --- FetchContent для Google Test ---
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        v1.14.0
)
set(FETCHCONTENT_BASE_DIR ${CMAKE_SOURCE_DIR}/_deps)
FetchContent_MakeAvailable(googletest)

set(gtest_build_tests OFF CACHE BOOL "" FORCE)
set(gmock_build_tests OFF CACHE BOOL "" FORCE)

# --- Тестовые файлы ---
set(TEST_SOURCES
    test_task.cpp
    test_taskmanager.cpp
    test_calendar.cpp
)

add_executable(EisenNotion_tests ${TEST_SOURCES})

# --- Исходники ядра ---
target_sources(EisenNotion_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/../src/task.cpp
    ${CMAKE_SOURCE_DIR}/../src/taskmanager.cpp
    ${CMAKE_SOURCE_DIR}/../src/jsonstorage.cpp
)

# --- Инклюды ---
target_include_directories(EisenNotion_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/../src
)

# --- Линковка (Multimedia добавлен) ---
target_link_libraries(EisenNotion_tests PRIVATE
    gtest_main
    Qt6::Core
    Qt6::Multimedia
)

include(GoogleTest)
gtest_discover_tests(EisenNotion_tests)