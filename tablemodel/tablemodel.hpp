#ifndef TABLEMODEL_H
#define TABLEMODEL_H

#include <QAbstractItemModel>
#include <QObject>
extern "C" {
#include "list.h"
}
#ifndef Q_DECLARE_METATYPE_LIST_POINTER
#define Q_DECLARE_METATYPE_LIST_POINTER
Q_DECLARE_METATYPE(List *)
#endif

namespace HUST_C {
class TableModel : public QAbstractItemModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

   public:
    enum RoleNames {
        NameRole = Qt::UserRole,
        IdRole = Qt::UserRole + 1,
        GenderRole = Qt::UserRole + 2,
        AgeRole = Qt::UserRole + 3,
        AmountRole = Qt::UserRole + 4
    };

    Q_ENUMS(RoleNames)

    explicit TableModel(QObject *parent = nullptr);
    ~TableModel();

    // read
    QVariant data(const QModelIndex &index, int role) const override;
    List *getDonors(const QModelIndex &index) const;

    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

    // editing, resizing
    Qt::ItemFlags flags(const QModelIndex &index) const override;

   public slots:
    void setList(QVariant plist);
    bool insert(int position);
    bool touchData(int position, const QVariant &value, const QString &role);
    bool append();
    bool remove(int index);
    void clear();

    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;

    void sort_table(const QString &role, bool ascend = true);
   signals:
    void countChanged(int cnt);

   protected:
    virtual QHash<int, QByteArray> roleNames() const override;

   private:
    QHash<int, QByteArray> m_roleNames;
    QHash<QString, int> m_roleIndex;
    int m_count;
    List *m_list;
};
}  // namespace HUST_C

#endif  // TABLEMODEL_H
