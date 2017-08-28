cmake_minimum_required(VERSION 3.1.0)
project(Donation_System)


SET(SUBPRO clist gui treemodel tablemodel index statistics)

foreach(SUB ${SUBPRO})
    add_subdirectory(${SUB})
endforeach(SUB ${SUBPRO})

