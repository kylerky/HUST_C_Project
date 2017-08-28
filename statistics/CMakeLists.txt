cmake_minimum_required(VERSION 3.1.0)
project(statistics)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

include_directories(../clist)

find_package(Qt5Core)

add_library(statistics analyze.cpp)

target_link_libraries(statistics Qt5::Core)
