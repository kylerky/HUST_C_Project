#include "analyze.hpp"
#include <unordered_map>
#include <functional>
#include <tuple>
#include <QString>

namespace {
    struct SchoolSum {
        School *school;
        unsigned long count;
        unsigned long amount;
        unsigned long index;
    };

    struct GradeStat {
        int grade;
        float percentage;
        unsigned long count;
        unsigned long total;
        unsigned long amount;
    };

    inline int schoolComp(void *left, void *right) {
        SchoolSum *lhs = static_cast<SchoolSum*>(left);
        SchoolSum *rhs = static_cast<SchoolSum*>(right);

        return lhs->amount > rhs->amount;
    }

    inline int gradeComp(void *left, void *right) {
        GradeStat *lhs = static_cast<GradeStat*>(left);
        GradeStat *rhs = static_cast<GradeStat*>(right);

        return lhs->percentage > rhs->percentage;
    }}

namespace HUST_C {

QVariantMap Analyze::get(QVariant val) {
    List *list = val.value<List *>();
    std::unordered_map<int, std::tuple<unsigned long, unsigned long, unsigned long>> grade_sum;

    List schoolsResults = create_list();
    List gradeResults = create_list();
    unsigned long schoolIndex = 0;
    Iter_list school = first_list(*list);
    while (school) {
        School *school_data = reinterpret_cast<School *>(school->data);

        struct SchoolSum school_stat = {NULL, 0, 0, schoolIndex};
        school_stat.school = school_data;

        Iter_list one_class = first_list(school_data->classes);
        while (one_class) {
            Classes *class_data = reinterpret_cast<Classes *>(one_class->data);
            school_stat.count += class_data->donors.size;

            auto &grade = grade_sum[class_data->grade];

            std::get<0>(grade) += class_data->donors.size;
            std::get<1>(grade) += class_data->student_cnt;

            Iter_list donor = first_list(class_data->donors);
            while (donor) {
                Donor *donor_data = reinterpret_cast<Donor *>(donor->data);
                school_stat.amount += donor_data->amount;
                std::get<2>(grade) += donor_data->amount;

                next_list(donor);
            }
            next_list(one_class);
        }

        append_list(schoolsResults, &school_stat);
        next_list(school);
        ++schoolIndex;
    }

    for (auto iter : grade_sum) {
        GradeStat data = {iter.first,
                          static_cast<float>(std::get<0>(iter.second))/static_cast<float>(std::get<1>(iter.second)),
                          std::get<0>(iter.second),
                          std::get<1>(iter.second),
                          std::get<2>(iter.second)
                         };
        append_list(gradeResults, &data);
    }

    sort_list(gradeResults, gradeComp);
    sort_list(schoolsResults, schoolComp);

    QVariantList schoolVList;
    QVariantList gradeVList;

    Iter_list iter = first_list(schoolsResults);
    while (iter) {
        QVariantMap map;
        map["count"] = QVariant::fromValue(reinterpret_cast<SchoolSum*>(iter->data)->count);
        map["amount"] = QVariant::fromValue(reinterpret_cast<SchoolSum*>(iter->data)->amount);
        map["name"] = QVariant::fromValue(QString(reinterpret_cast<SchoolSum*>(iter->data)->school->name));
        map["index"] = QVariant::fromValue(reinterpret_cast<SchoolSum*>(iter->data)->index);

        schoolVList.append(map);
        next_list(iter);
    }

    iter = first_list(gradeResults);
    while (iter) {
        QVariantMap map;
        map["grade"] = QVariant::fromValue(reinterpret_cast<GradeStat*>(iter->data)->grade);
        map["percentage"] = QVariant::fromValue(reinterpret_cast<GradeStat*>(iter->data)->percentage);
        map["count"] =  QVariant::fromValue(reinterpret_cast<GradeStat*>(iter->data)->count);
        map["total"] =  QVariant::fromValue(reinterpret_cast<GradeStat*>(iter->data)->total);
        map["amount"] = QVariant::fromValue(reinterpret_cast<GradeStat*>(iter->data)->amount);

        gradeVList.append(map);
        next_list(iter);
    }

    QVariantMap result;
    result["schools"] = schoolVList;
    result["grades"] = gradeVList;
    return result;
}

} // namespace HUST_C
