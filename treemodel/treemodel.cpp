#include "treemodel.hpp"
#include "treeitem.hpp"
extern "C" {
#include "data_def.h"
#include "list.h"
}

#include <sstream>
#include <QThread>
#include <cstring>
#include <cstdio>
#include <iostream>

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

QVariant TreeModel::getList() const {
    QVariant val;
    val.setValue(&reinterpret_cast<struct School *>(m_rootItem->data())->classes);

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
                             const QString &role) {
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
    TreeItem *parentItem = getItem(parent);
    TreeItem *ptr = parentItem;

    if (!parent.isValid()) parentItem = m_rootItem;

    emit beginRemoveRows(parent, position, position);
    ptr = parentItem->removeChild(position);
    m_validPtrs.erase(ptr);
    emit endRemoveRows();

    return ptr != nullptr;
}

bool TreeModel::writeItem(const QModelIndex &index) {
    if (!index.isValid()) return false;

    TreeItem *item = static_cast<TreeItem *>(index.internalPointer());
    if (!item) return false;

    if (m_validPtrs.count(item) != 1) return false;
    if (typeid(*item) != typeid(ClassTreeItem)) return false;

    ClassTreeItem *classItem = dynamic_cast<ClassTreeItem*>(item);
    SchoolTreeItem *schoolItem  = dynamic_cast<SchoolTreeItem*>(classItem->parent());

    // set/get indexes
    if (!classItem->getIndex()) {
        ++m_classCnt;
        classItem->setIndex(m_classCnt);
    }
    if (!schoolItem->getIndex()) {
        ++m_schoolCnt;
        schoolItem->setIndex(m_schoolCnt);
    }

    // get the file name
    std::ostringstream fname;
    fname << schoolItem->getIndex() << "-" << classItem->getIndex() << ".bin";

    // get the list
    QVariant listVar = getDonors(index);
    List *donors = listVar.value<List*>();

    if (!donors) return false;

    // open the file
    FILE *fp = std::fopen(fname.str().data(), "wb");
    if (!fp) {
        std::cerr << "failed to open file " << fname.str().data() << ".bin";
        return false;
    }

    // get the first
    Iter_list iter = first_list(*donors);
    while (iter) {
        // write to disk one by one
        Donor *donor = reinterpret_cast<Donor*>(iter->data);

        char data[32];
        std::memcpy(data, &donor->name, 20);
        std::memcpy(data+20, &donor->id, 11);
        data[31] = donor->sex;

        if (std::fwrite(data, sizeof(data), 1, fp) != 1) {
            std::cerr << "cannot write all the data to disk" << std::endl;
            std::fclose(fp);
            return false;
        }

        int16_t age = donor->age;
        if (std::fwrite(&age, sizeof(age), 1, fp) != 1) {
            std::cerr << "cannot write all the data to disk" << std::endl;
            std::fclose(fp);
            return false;
        }

        uint32_t amount = donor->amount;
        if (std::fwrite(&amount, sizeof(amount), 1, fp) != 1) {
            std::cerr << "cannot write all the data to disk" << std::endl;
            std::fclose(fp);
            return false;
        }

        next_list(iter);
    }

    std::fclose(fp);
    return true;
}

bool TreeModel::writeTree() {
    FILE *fp = std::fopen("tree.bin", "wb");

    for (auto child_school = m_rootItem->child_cbeg(); child_school != m_rootItem->child_cend(); ++child_school) {
        // the schools part
        struct School *school = reinterpret_cast<struct School*>((*child_school)->data());

        // fit all the data in an array
        char data_sc[70];
        std::memcpy(data_sc, &school->name, 30);
        std::memcpy(data_sc+30, &school->principal, 20);
        std::memcpy(data_sc+50, &school->tele, 20);

        // write the data
        if (std::fwrite(data_sc, sizeof(data_sc), 1, fp) != 1) {
            std::cerr << "cannot write all the data to disk" << std::endl;
            std::fclose(fp);
            return false;
        }

        // record the length
        uint32_t size = school->classes.size;
        if (std::fwrite(&size, sizeof(size), 1, fp) != 1) {
            std::cerr << "cannot write all the data to disk" << std::endl;
            std::fclose(fp);
            return false;
        }

        uint32_t index_school = (*child_school)->getIndex();
        if (index_school == 0) {
            (*child_school)->setIndex(++m_schoolCnt);
            index_school = m_schoolCnt;
        }
        if (std::fwrite(&index_school, sizeof(index_school), 1, fp) != 1) {
            std::cerr << "cannot write all the data to disk" << std::endl;
            std::fclose(fp);
            return false;
        }

        // the classes part
        auto child_class = (*child_school)->child_cbeg();
        Iter_list iter_cl = first_list(school->classes);
        while (iter_cl) {
            Classes *unit = reinterpret_cast<Classes*>(iter_cl->data);

            // fit all the data in an array
            char data_cl[70];
            std::memcpy(data_cl, &unit->school, 30);
            std::memcpy(data_cl+30, &unit->instructor, 30);
            std::memcpy(data_cl+60, &unit->number, 10);

            if (std::fwrite(data_cl, sizeof(data_cl), 1, fp) != 1) {
                std::cerr << "cannot write all the data to disk" << std::endl;
                std::fclose(fp);
                return false;
            }

            int16_t grade = unit->grade;
            if (std::fwrite(&grade, sizeof(grade), 1, fp) != 1) {
                std::cerr << "cannot write all the data to disk" << std::endl;
                std::fclose(fp);
                return false;
            }

            int16_t cnt = unit->student_cnt;
            if (std::fwrite(&cnt, sizeof(cnt), 1, fp) != 1) {
                std::cerr << "cannot write all the data to disk" << std::endl;
                std::fclose(fp);
                return false;
            }

            uint32_t index_class = (*child_class)->getIndex();
            if (index_class == 0) {
                (*child_class)->setIndex(++m_classCnt);
                index_class = m_classCnt;
            }

            if (std::fwrite(&index_class, sizeof(index_class), 1, fp) != 1) {
                std::cerr << "cannot write all the data to disk" << std::endl;
                std::fclose(fp);
                return false;
            }

            ++child_class;
            next_list(iter_cl);
        }
        std::fflush(fp);
    }
    std::fflush(fp);
    return true;
}

bool TreeModel::readAll() {
    // read the tree
    FILE *tree_fp = fopen("tree.bin", "rb");
    if (!tree_fp) {
        return false;
    }

    char data_sc[78];

    int pos_school = 0;
    while (std::fread(data_sc, sizeof(data_sc), 1, tree_fp) == 1) {
        struct School school;
        std::memcpy(&school.name, data_sc, sizeof(school.name));
        std::memcpy(&school.principal, data_sc+30, sizeof(school.principal));
        std::memcpy(&school.tele, data_sc+50, sizeof(school.tele));

        uint32_t size, index_school;
        std::memcpy(&size, data_sc+70, sizeof(size));
        std::memcpy(&index_school, data_sc+74, sizeof(index_school));

        insertRows(pos_school, 1);
        QModelIndex modelIndexSchool = index(pos_school, 0);
        ++pos_school;

        setSchoolData(modelIndexSchool, QString(school.name), "name");
        setSchoolData(modelIndexSchool, QString(school.principal), "principal");
        setSchoolData(modelIndexSchool, QString(school.tele), "tele");
        getItem(modelIndexSchool)->setIndex(index_school);
        m_schoolCnt = std::max(m_schoolCnt, index_school);

        int pos_class = 0;
        for (unsigned long i = 0; i != size; ++i) {
            char data_cl[78];
            std::fread(data_cl, sizeof(data_cl), 1, tree_fp);
            if (std::ferror(tree_fp)) {
                std::perror("failed to read class");
                std::fclose(tree_fp);
                return false;
            }

            struct Classes cl_item;
            std::memcpy(&cl_item.school, data_cl, sizeof(cl_item.school));
            std::memcpy(&cl_item.instructor, data_cl+30, sizeof(cl_item.instructor));
            std::memcpy(&cl_item.number, data_cl+60, sizeof(cl_item.number));

            int16_t grade, student_cnt;
            std::memcpy(&grade, data_cl+70, sizeof(grade));
            std::memcpy(&student_cnt, data_cl+72, sizeof(student_cnt));

            cl_item.grade = grade;
            cl_item.student_cnt = student_cnt;

            uint32_t index_class;
            std::memcpy(&index_class, data_cl+74, sizeof(index_class));

            insertRows(pos_class, 1, modelIndexSchool);
            QModelIndex modelIndexClass = index(pos_class, 1, modelIndexSchool);
            ++pos_class;

            setClassData(modelIndexClass, QString(cl_item.school), "school");
            setClassData(modelIndexClass, QString(cl_item.instructor), "instructor");
            setClassData(modelIndexClass, QString(cl_item.number), "number");
            setClassData(modelIndexClass, cl_item.grade, "grade");
            setClassData(modelIndexClass, cl_item.student_cnt, "studentCnt");

            TreeItem *classItem = getItem(modelIndexClass);
            classItem->setIndex(index_class);
            m_classCnt = std::max(m_classCnt, index_class);

            List *donors = &reinterpret_cast<struct Classes *>(classItem->data())->donors;

            std::ostringstream fname;
            fname << index_school << "-" << index_class << ".bin";

            FILE *donor_fp = std::fopen(fname.str().data(), "rb");
            if (!donor_fp)
                continue;


            char data_donor[38];
            while (std::fread(data_donor, sizeof(data_donor), 1, donor_fp) == 1) {
                struct Donor donor;
                std::memcpy(&donor.name, data_donor, sizeof(donor.name));
                std::memcpy(&donor.id, data_donor+20, sizeof(donor.id));
                donor.sex = data_donor[31];

                int16_t age;
                uint32_t amount;
                std::memcpy(&age, data_donor+32, sizeof(age));
                std::memcpy(&amount, data_donor+34, sizeof(amount));

                donor.age = age;
                donor.amount = amount;

                insert_before_list(*donors, NULL, &donor);

            }

            if (std::ferror(donor_fp))
                std::perror("failed to read donor");

            std::fclose(donor_fp);
        }
    }

    if (std::ferror(tree_fp)) {
        std::perror("failed to read school");
        std::fclose(tree_fp);
        return false;
    }

    std::fclose(tree_fp);
    return true;
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
    TreeItem *item = reinterpret_cast<TreeItem *>(index.internalPointer());
    if (m_validPtrs.count(item) != 1) return -1;
    return item->typeIndex();
}

}  // namespace HUST_C
