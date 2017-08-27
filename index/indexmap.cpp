#include "indexmap.hpp"
#include <QString>
#include <functional>
#include <iostream>
#include <unordered_set>

namespace HUST_C {

void IndexMap::build_index(QVariant val) {
    m_indices.clear();
    m_age_indices.clear();
    m_amount_indices.clear();
    m_grade_indices.clear();
    m_count_indices.clear();
    m_gender_indices.clear();
    List *list = val.value<List *>();

    unsigned long schoolIndex = 0;
    Iter_list school = first_list(*list);
    while (school) {
        School *school_data = reinterpret_cast<School *>(school->data);

        unsigned long classIndex = 0;
        Iter_list one_class = first_list(school_data->classes);
        while (one_class) {
            Classes *class_data = reinterpret_cast<Classes *>(one_class->data);

            unsigned long donorIndex = 0;
            Iter_list donor = first_list(class_data->donors);
            while (donor) {
                Donor *donor_data = reinterpret_cast<Donor *>(donor->data);
                m_indices.insert(
                    {{std::string(donor_data->name),
                      {DonorType, donor, schoolIndex, classIndex, donorIndex}},
                     {std::string(donor_data->id),
                      {DonorType, donor, schoolIndex, classIndex,
                       donorIndex}}});
                m_age_indices.insert({{donor_data->age,
                                       {DonorType, donor, schoolIndex,
                                        classIndex, donorIndex}}});
                m_amount_indices.insert({{donor_data->amount,
                                          {DonorType, donor, schoolIndex,
                                           classIndex, donorIndex}}});
                m_gender_indices.insert({{donor_data->sex,
                                          {DonorType, donor, schoolIndex,
                                           classIndex, donorIndex}}});
                next_list(donor);
                ++donorIndex;
            }
            m_indices.insert(
                {{std::string(class_data->school),
                  {ClassType, one_class, schoolIndex, classIndex, 0}},
                 {std::string(class_data->instructor),
                  {ClassType, one_class, schoolIndex, classIndex, 0}},
                 {std::string(class_data->number),
                  {ClassType, one_class, schoolIndex, classIndex, 0}}});
            m_grade_indices.insert(
                {{class_data->grade,
                  {ClassType, one_class, schoolIndex, classIndex, 0}}});
            m_count_indices.insert(
                {{class_data->student_cnt,
                  {ClassType, one_class, schoolIndex, classIndex, 0}}});
            next_list(one_class);
            ++classIndex;
        }
        m_indices.insert({{std::string(school_data->name),
                           {SchoolType, school, schoolIndex, 0, 0}},
                          {std::string(school_data->principal),
                           {SchoolType, school, schoolIndex, 0, 0}},
                          {std::string(school_data->tele),
                           {SchoolType, school, schoolIndex, 0, 0}}});
        next_list(school);
        ++schoolIndex;
    }
}

QVariantList IndexMap::search(const QString &pattern) {
    std::pair<unordered_text_multimap::iterator,
              unordered_text_multimap::iterator>
        range;
    if (pattern.isEmpty()) {
        range.first = m_indices.begin();
        range.second = m_indices.end();
    } else
        range = m_indices.equal_range(pattern.toStdString());

    return parseResults(range.first, range.second);
}

QVariantList IndexMap::searchGender(const char &gender) {
    decltype(m_gender_indices.equal_range('f')) range;

    range = m_gender_indices.equal_range(gender);

    return parseResults(range.first, range.second);
}

QVariantList IndexMap::find(unsigned long val, unsigned field, int direction) {
    ulong_multimap *map;
    decltype(m_amount_indices.equal_range(1)) range;

    switch (field) {
        case Age:
            map = &m_age_indices;
            break;
        case Amount:
            map = &m_amount_indices;
            break;
        case Grade:
            map = &m_grade_indices;
            break;
        case Count:
            map = &m_count_indices;
            break;
    }

    switch (direction) {
        case 0:
            range = map->equal_range(val);
            break;
        case -1:
            range.first = map->begin();
            range.second = map->equal_range(val).first;
            break;
        case 1:
            range.first = map->upper_bound(val);
            range.second = map->end();
            break;
        default:
            break;
    }

    return parseResults(range.first, range.second);
}

template <typename Iter>
QVariantList IndexMap::parseResults(Iter beg, Iter end) {
    std::unordered_set<Iter_list> collected;
    QVariantList vlist;
    for (auto iter = beg; iter != end; ++iter) {
        if (collected.count(iter->second.iter) == 1) continue;

        collected.insert(iter->second.iter);

        QVariantMap obj;
        QVariantMap meta;

        meta.insert("type", QVariant::fromValue(
                                static_cast<unsigned>(iter->second.type)));
        meta.insert("iter", QVariant::fromValue(iter->second.iter));
        meta.insert("schoolIndex",
                    QVariant::fromValue(iter->second.schoolIndex));
        meta.insert("classIndex", QVariant::fromValue(iter->second.classIndex));
        meta.insert("donorIndex", QVariant::fromValue(iter->second.donorIndex));

        obj.insert("meta", QVariant::fromValue(std::move(meta)));

        Iter_list elem = iter->second.iter;

        Donor *donor;
        Classes *one_class;
        School *school;
        switch (iter->second.type) {
            case DonorType:
                donor = reinterpret_cast<Donor *>(elem->data);
                obj.insert("name", QVariant::fromValue(QString(donor->name)));
                obj.insert("id", QVariant::fromValue(QString(donor->id)));
                obj.insert("gender", QVariant::fromValue(QString(donor->sex)));
                obj.insert("age", QVariant::fromValue(donor->age));
                obj.insert("amount", QVariant::fromValue(donor->amount));
                break;
            case ClassType:
                one_class = reinterpret_cast<Classes *>(elem->data);
                obj.insert("school",
                           QVariant::fromValue(QString(one_class->school)));
                obj.insert("instructor",
                           QVariant::fromValue(QString(one_class->instructor)));
                obj.insert("number",
                           QVariant::fromValue(QString(one_class->number)));
                obj.insert("grade", QVariant::fromValue(one_class->grade));
                obj.insert("count",
                           QVariant::fromValue(one_class->student_cnt));
                break;
            case SchoolType:
                school = reinterpret_cast<School *>(elem->data);
                obj.insert("name", QVariant::fromValue(QString(school->name)));
                obj.insert("principal",
                           QVariant::fromValue(QString(school->principal)));
                obj.insert("tele", QVariant::fromValue(QString(school->tele)));
                break;
            default:
                break;
        }

        vlist.append(QVariant::fromValue(obj));
    }

    return vlist;
}

}  // namespace HUST_C
