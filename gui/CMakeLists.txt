cmake_minimum_required(VERSION 3.1.0)
project(gui)

find_package(Qt5 COMPONENTS Quick Core Qml Gui)

qt5_add_resources(RESOURCES qml.qrc)
add_executable(main main.cpp ${RESOURCES})

include_directories(../clist ../treemodel ../tablemodel)

link_directories(../list ../treemodel ../tablemodel)
target_link_libraries(main treemodel tablemodel clist Qt5::Quick Qt5::Core)
