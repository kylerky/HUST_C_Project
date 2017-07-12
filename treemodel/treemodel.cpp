#include "treemodel.hpp"
#include "treeitem.hpp"
extern "C"
{
    #include "data_def.h"
    #include "list.h"
}
#include <string.h>

namespace HUST_C
{

    TreeModel::TreeModel(QObject *parent)
        : QAbstractItemModel(parent)
    {
        m_roleNames[SchoolNameRole] = "schoolName";
        m_roleNames[SchoolPrincipalRole] = "schoolPrincipal";
        m_roleNames[SchoolTeleRole] = "schoolTele";
        m_roleNames[ClassSchoolRole] = "classSchool";
        m_roleNames[ClassInstructorRole] = "classInstructor";
        m_roleNames[ClassNumberRole] = "classNumber";
        m_roleNames[ClassGradeRole] = "classGrade";
        m_roleNames[ClassStudentCntRole] = "classStudentCnt";

        m_rootItem = new RootTreeItem();
    }

    TreeModel::~TreeModel()
    {
        delete m_rootItem;
    }

    QVariant TreeModel::data(const QModelIndex &index, int role) const
    {
        if (!index.isValid())
            return QVariant();

        TreeItem *item = getItem(index);

        switch(role)
        {
        case SchoolNameRole:
            return QString(reinterpret_cast<char*>(reinterpret_cast<struct School*>(item->data())->name));
        case SchoolPrincipalRole:
            return QString(reinterpret_cast<char*>(reinterpret_cast<struct School*>(item->data())->principal));
        case SchoolTeleRole:
            return QString(reinterpret_cast<char*>(reinterpret_cast<struct School*>(item->data())->tele));
        case ClassSchoolRole:
            return QString(reinterpret_cast<char*>(reinterpret_cast<struct Classes*>(item->data())->school));
        case ClassInstructorRole:
            return QString(reinterpret_cast<char*>(reinterpret_cast<struct Classes*>(item->data())->instructor));
        case ClassNumberRole:
            return QString(reinterpret_cast<char*>(reinterpret_cast<struct Classes*>(item->data())->number));;
        case ClassGradeRole:
            return *reinterpret_cast<int*>(reinterpret_cast<struct Classes*>(item->data())->grade);
        case ClassStudentCntRole:
            return *reinterpret_cast<int*>(reinterpret_cast<struct Classes*>(item->data())->student_cnt);
        }

        return QVariant();
    }

    QVariant TreeModel::headerData(int section, Qt::Orientation oreientation,
                                   int role) const
    {
        return QVariant();
    }


    QModelIndex TreeModel::index(int row, int column, const QModelIndex &parent) const
    {
        if (parent.isValid() && parent.column() != 0)
            return QModelIndex();

        TreeItem *parentItem = getItem(parent);

        TreeItem *childItem = parentItem->child(row);

        if (childItem)
            return createIndex(row, column, childItem);
        else
            return QModelIndex();
    }

    QModelIndex TreeModel::parent(const QModelIndex &index) const
    {
        if (!index.isValid())
            return QModelIndex();

        TreeItem *childItem = getItem(index);
        TreeItem *parentItem = childItem->parent();

        if (parentItem == m_rootItem)
            return QModelIndex();

        return createIndex(parentItem->childNumber(), 0, parentItem);
    }



    int TreeModel::rowCount(const QModelIndex &parent) const
    {
        TreeItem *parentItem = getItem(parent);

        return parentItem->childCount();
    }


    int TreeModel::columnCount(const QModelIndex &parent) const
    {
        return m_rootItem->columnCount();
    }

    Qt::ItemFlags TreeModel::flags(const QModelIndex &index) const
    {
        if (!index.isValid())
            return 0;

        return Qt::ItemIsEditable | QAbstractItemModel::flags(index);
    }

    bool TreeModel::setData(const QModelIndex &index, const QVariant &value,
                 int role)
    {
        return false;
    }

    bool TreeModel::insertRows(int position, int rows,
                    const QModelIndex &parent)
    {
        return false;
    }


    QModelIndex TreeModel::getRootIndex()
    {
        return QModelIndex();
    }

    bool TreeModel::setSchoolData(const QModelIndex &index, const QVariant &val,
                       QString role)
    {
        TreeItem *item = getItem(index);
        struct School *data = reinterpret_cast<struct School *>(item->data());
        bool success = true;

        QByteArray array = val.toString().toLocal8Bit();
        char* value = array.data();

        if (role == QString("name"))
            strcpy(data->name, value);
        else if (role == QString("principal"))
            strcpy(data->principal, value);
        else if (role == QString("tele"))
            strcpy(data->tele, value);
        else
            success = false;

        if (success)
        {
             emit dataChanged(index, index);
        }

        return success;
    }


    bool TreeModel::setClassData(const QModelIndex &index, const QVariant &value,
                       QString role)
    {
        TreeItem *item = getItem(index);
        struct Classes *data = reinterpret_cast<struct Classes *>(item->data());
        bool success = true;

        if (role == QString("school"))
        {
            strcpy(data->school, reinterpret_cast<char*>(value.toString().data()));
        }
        else if (role == QString("instructor"))
        {
            strcpy(data->instructor, reinterpret_cast<char*>(value.toString().data()));
        }
        else if (role == QString("number"))
        {
            strcpy(data->number, reinterpret_cast<char*>(value.toString().data()));
        }
        else if (role == QString("grade"))
        {
            data->grade = value.toInt();
        }
        else if (role == QString("studentCnt"))
        {
            data->student_cnt = value.toInt();
        }
        else
            success = false;

        if (success)
        {
             emit dataChanged(index, index);
        }

        return success;
    }

    bool TreeModel::insertSchoolRows(int position, int rows,
                          const QModelIndex &parent)
    {
        TreeItem *parentItem = getItem(parent);
        bool success = true;

        struct School empty_school;
        empty_school.name[0] = 0;
        empty_school.principal[0] = 0;
        empty_school.tele[0] = 0;

        emit beginInsertRows(parent, position, position+rows-1);

        for (int i = 0; i != rows && success; ++i)
        {
            empty_school.classes = create_list();
            success = parentItem->insertChild(position, &empty_school);
        }

        emit endInsertRows();
        return success;

    }

    bool TreeModel::insertClassRows(int position, int rows,
                         const QModelIndex &parent)
    {
        TreeItem *parentItem = getItem(parent);
        
        bool success = true;

        struct Classes empty_class;
        empty_class.grade = 0;
        empty_class.instructor[0] = 0;
        empty_class.number[0] = 0;
        empty_class.school[0] = 0;
        empty_class.student_cnt = 0;

        emit beginInsertRows(parent, position, position+rows-1);

        for (int i = 0; i != rows && success; ++i)
        {
            empty_class.donors = create_list();
            success = parentItem->insertChild(position, &empty_class);
        }
        emit endInsertRows();
        return success;
    }

    bool TreeModel::removeRows(int position, int rows, const QModelIndex &parent)
    {
        TreeItem *parentItem = getItem(parent);
        bool success = true;

        emit beginRemoveRows(parent, position, position+rows-1);
        success = parentItem->removeChildren(position, rows);
        emit endRemoveRows();

        return success;
    }


    TreeItem *TreeModel::getItem(const QModelIndex &index) const
    {
        if (index.isValid())
        {
            TreeItem *item = static_cast<TreeItem*>(index.internalPointer());
            if (item)
                return item;
        }
        return m_rootItem;
    }

    QHash<int, QByteArray> TreeModel::roleNames() const
    {
        return m_roleNames;
    }

} // namespace HUST_C

