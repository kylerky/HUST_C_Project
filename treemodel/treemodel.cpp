#include "treemodel.hpp"
#include "treeitem.hpp"
extern "C" {
#include "data_def.h"
#include "list.h"
}
#include <QThread>
#include <cstring>
#include <iostream>

Q_DECLARE_METATYPE(List *)

namespace HUST_C {

TreeModel::TreeModel(QObject *parent) : QAbstractItemModel(parent) {
    m_roleNames[SchoolNameRole] = "schoolName";
    m_roleNames[SchoolPrincipalRole] = "schoolPrincipal";
    m_roleNames[SchoolTeleRole] = "schoolTele";
    m_roleNames[ClassSchoolRole] = "classSchool";
    m_roleNames[ClassInstructorRole] = "classInstructor";
    m_roleNames[ClassNumberRole] = "classNumber";
    m_roleNames[ClassGradeRole] = "classGrade";
    m_roleNames[ClassStudentCntRole] = "classStudentCnt";
    m_roleNames[TypeRole] = "type";

    m_rootItem = new RootTreeItem();
    m_validPtrs.insert(m_rootItem);
}

TreeModel::~TreeModel() { delete m_rootItem; }

QVariant TreeModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) return QVariant();

    TreeItem *item = getItem(index);

    switch (role) {
        case SchoolNameRole:
            return QString(reinterpret_cast<char *>(
                reinterpret_cast<struct School *>(item->data())->name));
        case SchoolPrincipalRole:
            return QString(
                reinterpret_cast<struct School *>(item->data())->principal);
        case SchoolTeleRole:
            return QString(
                reinterpret_cast<struct School *>(item->data())->tele);
        case ClassSchoolRole:
            return QString(
                reinterpret_cast<struct Classes *>(item->data())->school);
        case ClassInstructorRole:
            return QString(
                reinterpret_cast<struct Classes *>(item->data())->instructor);
        case ClassNumberRole:
            return QString(
                reinterpret_cast<struct Classes *>(item->data())->number);
        case ClassGradeRole:
            return reinterpret_cast<struct Classes *>(item->data())->grade;
        case ClassStudentCntRole:
            return reinterpret_cast<struct Classes *>(item->data())
                ->student_cnt;
        case TypeRole:
            return type(index);
    }

    return QVariant();
}

QVariant TreeModel::getDonors(const QModelIndex &index) const {
    if (!index.isValid()) return QVariant();

    TreeItem *item = getItem(index);

    if (item->typeIndex() != 1) return QVariant();

    QVariant val;
    val.setValue(&reinterpret_cast<struct Classes *>(item->data())->donors);

    return val;
}

QVariant TreeModel::headerData(int section, Qt::Orientation oreientation,
                               int role) const {
    return QVariant();
}

QModelIndex TreeModel::index(int row, int column,
                             const QModelIndex &parent) const {
    if (parent.isValid() && parent.column() != 0) return QModelIndex();

    TreeItem *parentItem = getItem(parent);

    if (m_validPtrs.count(parentItem) != 1) return QModelIndex();

    TreeItem *childItem = parentItem->child(row);

    if (childItem)
        return createIndex(row, column, childItem);
    else
        return QModelIndex();
}

QModelIndex TreeModel::parent(const QModelIndex &index) const {
    if (!index.isValid()) return QModelIndex();

    TreeItem *childItem = getItem(index);
    TreeItem *parentItem = childItem->parent();
    if (parentItem == m_rootItem || m_validPtrs.count(parentItem) != 1)
        return QModelIndex();
    return createIndex(parentItem->childNumber(), 0, parentItem);
}

int TreeModel::rowCount(const QModelIndex &parent) const {
    TreeItem *parentItem = getItem(parent);

    return parentItem->childCount();
}

int TreeModel::columnCount(const QModelIndex &parent) const {
    return m_rootItem->columnCount();
}

Qt::ItemFlags TreeModel::flags(const QModelIndex &index) const {
    if (!index.isValid()) return 0;

    return Qt::ItemIsEditable | QAbstractItemModel::flags(index);
}

bool TreeModel::setData(const QModelIndex &index, const QVariant &value,
                        int role) {
    if (index.internalPointer() == m_rootItem ||
        index.internalPointer() == nullptr)
        return setSchoolData(index, value, m_roleNames[role]);

    return setClassData(index, value, m_roleNames[role]);
}

bool TreeModel::insertRows(int position, int rows, const QModelIndex &parent) {
    if (parent.internalPointer() == m_rootItem ||
        parent.internalPointer() == nullptr)
        return insertSchoolRows(position, rows, parent);

    return insertClassRows(position, rows, parent);
}

bool TreeModel::setSchoolData(const QModelIndex &index, const QVariant &val,
                              const QString &role) {
    TreeItem *item = getItem(index);
    struct School *data = reinterpret_cast<struct School *>(item->data());
    bool success = true;

    QByteArray array = val.toString().toLocal8Bit();
    char *cstring = array.data();

    if (role == QString("name"))
        std::strcpy(data->name, cstring);
    else if (role == QString("principal"))
        std::strcpy(data->principal, cstring);
    else if (role == QString("tele"))
        std::strcpy(data->tele, cstring);
    else
        success = false;

    if (success) {
        emit dataChanged(index, index);
    }

    return success;
}

bool TreeModel::setClassData(const QModelIndex &index, const QVariant &value,
                             QString role) {
    TreeItem *item = getItem(index);
    struct Classes *data = reinterpret_cast<struct Classes *>(item->data());
    bool success = true;

    QByteArray array;
    char *cstring;

    if (role == QString("school")) {
        array = value.toString().toLocal8Bit();
        cstring = array.data();
        std::strcpy(data->school, cstring);
    } else if (role == QString("instructor")) {
        array = value.toString().toLocal8Bit();
        cstring = array.data();
        std::strcpy(data->instructor, cstring);
    } else if (role == QString("number")) {
        array = value.toString().toLocal8Bit();
        cstring = array.data();
        std::strcpy(data->number, cstring);
    } else if (role == QString("grade")) {
        data->grade = value.toInt();
    } else if (role == QString("studentCnt")) {
        data->student_cnt = value.toInt();
    } else
        success = false;

    if (success) {
        emit dataChanged(index, index);
    }

    return success;
}

bool TreeModel::insertSchoolRows(int position, int rows,
                                 const QModelIndex &parent) {
    TreeItem *parentItem = getItem(parent);
    TreeItem *ptr = parentItem;

    struct School empty_school;
    std::memset(&empty_school, 0, sizeof(empty_school));

    emit beginInsertRows(parent, position, position + rows - 1);

    for (int i = 0; i != rows && ptr; ++i) {
        empty_school.classes = create_list();
        ptr = parentItem->insertChild(position, &empty_school);
        if (ptr) m_validPtrs.insert(ptr);
    }

    emit endInsertRows();
    return ptr != nullptr;
}

bool TreeModel::insertClassRows(int position, int rows,
                                const QModelIndex &parent) {
    if (reinterpret_cast<TreeItem *>(parent.internalPointer())->typeIndex() !=
        2)
        return false;

    TreeItem *parentItem = getItem(parent);

    TreeItem *ptr = parentItem;

    struct Classes empty_class;
    std::memset(&empty_class, 0, sizeof(empty_class));

    emit beginInsertRows(parent, position, position + rows - 1);

    for (int i = 0; i != rows && ptr; ++i) {
        empty_class.donors = create_list();
        ptr = parentItem->insertChild(position, &empty_class);
        if (ptr) m_validPtrs.insert(ptr);
    }
    emit endInsertRows();
    return ptr != nullptr;
}

bool TreeModel::removeRows(int position, int rows, const QModelIndex &parent) {
    bool success = true;

    for (int i = 0; i != rows && success; ++i)
        success = removeRow(position, parent);

    return success;
}
bool TreeModel::removeRow(int position, const QModelIndex &parent) {
    if (!parent.isValid()) return false;
    TreeItem *parentItem = getItem(parent);
    TreeItem *ptr = parentItem;

    emit beginRemoveRows(parent, position, position);
    ptr = parentItem->removeChild(position);
    m_validPtrs.erase(ptr);
    emit endRemoveRows();

    return ptr != nullptr;
}

TreeItem *TreeModel::getItem(const QModelIndex &index) const {
    if (index.isValid()) {
        TreeItem *item = static_cast<TreeItem *>(index.internalPointer());
        if (item) return item;
    }
    return m_rootItem;
}

QHash<int, QByteArray> TreeModel::roleNames() const { return m_roleNames; }

int TreeModel::type(const QModelIndex &index) const {
    return reinterpret_cast<TreeItem *>(index.internalPointer())->typeIndex();
}

}  // namespace HUST_C
