#ifndef INDEXMAP_H
#define INDEXMAP_H

#include <unordered_map>
#include <map>
#include <QObject>
#include <QString>
#include <QtCore>
#include "list.h"
#include "data_def.h"

#ifndef Q_DECLARE_METATYPE_LIST_POINTER
#define Q_DECLARE_METATYPE_LIST_POINTER
Q_DECLARE_METATYPE(List *)
#endif
#ifndef Q_DECLARE_METATYPE_ITER_LIST_POINTER
#define Q_DECLARE_METATYPE_ITER_LIST_POINTER
Q_DECLARE_METATYPE(Iter_list)
#endif

namespace HUST_C {

class IndexMap : public QObject {
    Q_OBJECT
public slots:
    void build_index(QVariant val);
    QVariantList search(const QString &pattern);
    QVariantList searchGender(const char &gender);
    QVariantList find(unsigned long val, unsigned field, int direction);
public:
    Q_ENUMS(ValueType)
    enum ValueType : unsigned {
        DonorType,
        ClassType,
        SchoolType
    };
    Q_ENUMS(Field)
    enum Field : unsigned {
        Age,
        Amount,
        Count,
        Grade
    };

private:
    struct Value {
        unsigned type;
        Iter_list iter;
        unsigned long schoolIndex;
        unsigned long classIndex;
        unsigned long donorIndex;
    };
    typedef std::unordered_multimap<std::string, Value> unordered_text_multimap;
    typedef std::multimap<unsigned long, Value> ulong_multimap;
    typedef std::multimap<char, Value> char_multimap;
    unordered_text_multimap m_indices;
    ulong_multimap m_age_indices;
    ulong_multimap m_amount_indices;
    ulong_multimap m_grade_indices;
    ulong_multimap m_count_indices;
    char_multimap m_gender_indices;

    template <typename Iter>
        QVariantList parseResults(Iter beg, Iter end);
};

} // namespace HUST_C
#endif // INDEXMAP_H
