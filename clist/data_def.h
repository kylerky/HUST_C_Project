/*
 * the definition of the data
*/

#ifndef DATA_DEF_H
#define DATA_DEF_H

#include "list.h"

/*
 * struct School
 * info of a school
 *
 * @members
 *      name       the name of the school
 *      principal  the principal of the school
 *      tele       the telephone number of the school
 *      classes    the classes of the school
*/
struct School {
    char name[30];
    char principal[20];
    char tele[20];
    List classes;
};

/*
 * struct Classes
 * info of a class
 *
 * @members
 *      school          the school it belongs
 *      instructor      the instructor of the class
 *      number          the number of the class
 *      grade           the grade of the class
 *      student_cnt     number of students in the class
 *      donors          the donors of the class
*/
struct Classes {
    char school[30];
    char instructor[30];
    char number[10];
    int grade;
    int student_cnt;
    List donors;
};

/*
 * struct Donor
 * info of a donor
 *
 * @members
 *      name        the name of the donor
 *      id          the id of the donor
 *      sex         the sex of the donor (m for male, f for female, x for others)
 *      age         the age of the donor
 *      amount      the amount of money the donor donated
 *
*/
struct Donor {
    char name[20];
    char id[11];
    char sex;
    int age;
    unsigned long amount;
};

#endif  // DATA_DEF_H
