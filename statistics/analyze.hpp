#ifndef ANALYZE_H
#define ANALYZE_H
#include <QObject>
#include <QtCore>
extern "C"{
#include "list.h"
#include "data_def.h"
}

#ifndef Q_DECLARE_METATYPE_LIST_POINTER
#define Q_DECLARE_METATYPE_LIST_POINTER
Q_DECLARE_METATYPE(List *)
#endif

namespace HUST_C {
    class Analyze : public QObject {
        Q_OBJECT
    public slots:
        QVariantMap get(QVariant val);
    };

} // namespace HUST_C
#endif // ANALYZE_H
