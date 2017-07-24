cmake_minimum_required(VERSION 3.1.0)
project(tablemodel)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

include_directories(../clist ../treemodel)

find_package(Qt5Core)

add_library(tablemodel tablemodel.cpp)

target_link_libraries(tablemodel Qt5::Core)
