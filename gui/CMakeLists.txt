cmake_minimum_required(VERSION 3.1.0)
project(gui)

find_package(Qt5 COMPONENTS Quick Core QuickControls2)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

qt5_add_resources(RESOURCES qml.qrc)
add_executable(main main.cpp ${RESOURCES})
add_library(errmsg launcherrmsg.cpp)

include_directories(../clist ../treemodel ../tablemodel ../index ../statistics .)

target_link_libraries(errmsg Qt5::Core)

link_directories(../clist ../treemodel ../tablemodel ../index ../statistics .)
target_link_libraries(main errmsg treemodel tablemodel indexmap statistics clist Qt5::Quick Qt5::Core Qt5::QuickControls2)
