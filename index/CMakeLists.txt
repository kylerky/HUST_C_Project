cmake_minimum_required(VERSION 3.1.0)
project(treemodel)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

include_directories(../clist)

find_package(Qt5Core)

add_library(indexmap indexmap.cpp)

target_link_libraries(indexmap Qt5::Core)
