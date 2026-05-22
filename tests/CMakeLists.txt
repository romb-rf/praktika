cmake_minimum_required(VERSION 3.16)
project(EisenNotionTests LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Multimedia)

# Отключаем тесты и примеры внутри Google Test, чтобы не замедлять сборку
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
set(gtest_build_tests OFF CACHE BOOL "" FORCE)
set(gtest_build_samples OFF CACHE BOOL "" FORCE)
set(gmock_build_tests OFF CACHE BOOL "" FORCE)

# Подключаем локальный Google Test (папка лежит рядом с этим CMakeLists)
add_subdirectory(${CMAKE_SOURCE_DIR}/googletest-1.17.0)

# Наши тестовые файлы
set(TEST_SOURCES
    test_task.cpp
    test_taskmanager.cpp
    test_calendar.cpp
)

add_executable(EisenNotion_tests ${TEST_SOURCES})

# Исходники ядра (основной проект)
target_sources(EisenNotion_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/../src/task.cpp
    ${CMAKE_SOURCE_DIR}/../src/taskmanager.cpp
    ${CMAKE_SOURCE_DIR}/../src/jsonstorage.cpp
)

# Инклюды
target_include_directories(EisenNotion_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/../src
    ${CMAKE_SOURCE_DIR}/googletest-1.17.0/googletest/include
    ${CMAKE_SOURCE_DIR}/googletest-1.17.0/googlemock/include
)

# Линкуем
target_link_libraries(EisenNotion_tests PRIVATE
    gtest_main
    gmock
    Qt6::Core
    Qt6::Multimedia
)

include(GoogleTest)
gtest_discover_tests(EisenNotion_tests)