#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <unordered_set>
#include <map>
#include <unordered_map>
#include <string>
#include <QAbstractItemModel>
#include <QObject>
#include "treeitem.hpp"

#ifndef Q_DECLARE_METATYPE_LIST_POINTER
#define Q_DECLARE_METATYPE_LIST_POINTER
Q_DECLARE_METATYPE(List *)
#endif

namespace HUST_C {
class TreeModel : public QAbstractItemModel {
    Q_OBJECT

   public:
    enum ItemType { Root = 0, Class = 1, School = 2 };

    Q_ENUMS(ItemType)

    enum RoleNames {
        SchoolNameRole = Qt::UserRole,
        SchoolPrincipalRole = Qt::UserRole + 1,
        SchoolTeleRole = Qt::UserRole + 2,
        ClassSchoolRole = Qt::UserRole + 3,
        ClassInstructorRole = Qt::UserRole + 4,
        ClassNumberRole = Qt::UserRole + 5,
        ClassGradeRole = Qt::UserRole + 6,
        ClassStudentCntRole = Qt::UserRole + 7,
        ClassListPointerRole = Qt::UserRole + 8,
        TypeRole = Qt::UserRole + 9
    };

    TreeModel(QObject *parent = nullptr);
    ~TreeModel();

    // read
    QVariant data(const QModelIndex &index, int role) const override;

    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    // editing, resizing
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;

   public slots:
    QVariant getDonors(const QModelIndex &index) const;
    QVariant getList() const;

    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    bool setSchoolData(const QModelIndex &index, const QVariant &val,
                       const QString &role);

    bool setClassData(const QModelIndex &index, const QVariant &val,
                      const QString &role);

    bool removeRows(int position, int rows,
                    const QModelIndex &parent = QModelIndex()) override;

    bool insertRows(int position, int rows,
                    const QModelIndex &parent = QModelIndex()) override;
    bool removeRow(int position, const QModelIndex &parent = QModelIndex());
    int type(const QModelIndex &index) const;

    bool writeItem(const QModelIndex &index);
    bool writeTree();
    bool readAll();

  protected:
    bool insertSchoolRows(int position, int rows, const QModelIndex &parent);

    bool insertClassRows(int position, int rows, const QModelIndex &parent);

    virtual QHash<int, QByteArray> roleNames() const override;
    std::unordered_set<TreeItem *> m_validPtrs;

   private:
    QHash<int, QByteArray> m_roleNames;

    TreeItem *getItem(const QModelIndex &index) const;
    TreeItem *m_rootItem;

    unsigned m_classCnt = 0;
    unsigned m_schoolCnt= 0;
};
}
#endif  // TREEMODEL_H
