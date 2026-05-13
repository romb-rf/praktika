cmake_minimum_required(VERSION 3.16)
project(EisenNotion VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

set(CORE_SOURCES
    src/task.h
    src/task.cpp
    src/taskmanager.h
    src/taskmanager.cpp
    src/jsonstorage.h
    src/jsonstorage.cpp
)

set(QML_FILES
    qml/main.qml
    qml/MatrixView.qml
    qml/TaskCard.qml
    qml/TaskDialog.qml
    qml/InboxTaskCard.qml
)

qt_add_executable(EisenNotion
    src/main.cpp
    ${CORE_SOURCES}



)

qt_add_resources(EisenNotion "qml_resources"
    PREFIX "/"
    FILES ${QML_FILES}
)

target_link_libraries(EisenNotion PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
)

target_include_directories(EisenNotion PRIVATE src)

source_group("src" FILES src/main.cpp ${CORE_SOURCES})
source_group("qml" FILES ${QML_FILES})