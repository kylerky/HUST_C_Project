#include <cstring>
extern "C" {
#include "data_def.h"
#include "list.h"
}
#include "tablemodel.hpp"
#include "treemodel.hpp"

#include <iostream>

namespace HUST_C {

static inline Iter_list seek(List list, size_t index) {
    Iter_list iter = first_list(list);
    for (size_t i = 0; i != index; ++i) next_list(iter);
    return iter;
}

TableModel::TableModel(QObject *parent)
    : QAbstractItemModel(parent), m_list(nullptr) {
    m_roleNames[NameRole] = "name";
    m_roleNames[IdRole] = "id";
    m_roleNames[GenderRole] = "gender";
    m_roleNames[AgeRole] = "age";
    m_roleNames[AmountRole] = "amount";

    m_roleIndex["name"] = NameRole;
    m_roleIndex["id"] = IdRole;
    m_roleIndex["gender"] = GenderRole;
    m_roleIndex["age"] = AgeRole;
    m_roleIndex["amount"] = AmountRole;
}

TableModel::~TableModel() {}

QVariant TableModel::data(const QModelIndex &index, int role) const {
    int row = index.row();
    if (!m_list || row < 0 || row >= m_list->size) return QVariant();

    Iter_list iter = seek(*m_list, row);
    struct Donor *data = reinterpret_cast<struct Donor *>(iter->data);

    switch (role) {
        case NameRole:
            return QVariant(data->name);
        case IdRole:
            return QVariant(data->id);
        case GenderRole:
            return QVariant(QChar(data->sex));
        case AgeRole:
            return QVariant(data->age);
        case AmountRole:
            return QVariant(data->amount);
    }

    return QVariant();
}

int TableModel::columnCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return 5;
}

int TableModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    if (m_list) return m_list->size;

    return 0;
}

int TableModel::count() const { return rowCount(); }

Qt::ItemFlags TableModel::flags(const QModelIndex &index) const {
    if (!index.isValid()) return 0;

    return Qt::ItemIsEditable | QAbstractItemModel::flags(index);
}

void TableModel::setList(QVariant val) {
    List *plist = val.value<List *>();

    if (!plist) return;
    emit beginResetModel();
    m_list = plist;
    emit endResetModel();
}

bool TableModel::insert(int position) {
    if (!m_list || position < 0 || position > m_list->size) return false;

    Iter_list iter = seek(*m_list, position);

    struct Donor donor;
    std::memset(&donor, 0, sizeof(donor));
    emit beginInsertRows(QModelIndex(), position, position);
    insert_before_list(*m_list, iter, &donor);
    emit endInsertRows();
    return true;
}

bool TableModel::touchData(int position, const QVariant &value,
                           const QString &role) {
    if (!m_list) return false;

    Iter_list iter = seek(*m_list, position);

    struct Donor *data = reinterpret_cast<struct Donor *>(iter->data);

    bool success = true;

    switch (m_roleIndex[role]) {
        case NameRole:
            std::strcpy(data->name, value.toString().toLocal8Bit().data());
            break;
        case IdRole:
            std::strcpy(data->id, value.toString().toLocal8Bit().data());
            break;
        case GenderRole:
            std::cout << "gender: " << static_cast<int>(value.toChar().toLatin1()) << std::endl;
            data->sex = value.toChar().toLatin1();
            break;
        case AgeRole:
            data->age = value.toInt();
            break;
        case AmountRole:
            data->amount = value.toFloat();
            break;
        default:
            success = false;
    }
    if (success) {
        emit dataChanged(createIndex(position, 0), createIndex(position, 4));
    }
    return success;
}

bool TableModel::append() { return insert(m_list->size); }

bool TableModel::remove(int index) {
    if (!m_list || index < 0 || index >= m_list->size) return false;
    Iter_list iter = seek(*m_list, index);
    emit beginRemoveRows(QModelIndex(), index, index);
    erase_list(*m_list, iter);
    emit endRemoveRows();
    return true;
}

void TableModel::clear() {
    if (!m_list) return;

    emit beginResetModel();
    erase_seq_list(*m_list, first_list(*m_list), nullptr);
    emit endResetModel();
}

QModelIndex TableModel::index(int row, int column,
                              const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return createIndex(row, column);
}

QModelIndex TableModel::parent(const QModelIndex &child) const {
    Q_UNUSED(child);
    return QModelIndex();
}

QHash<int, QByteArray> TableModel::roleNames() const { return m_roleNames; }

}  // namespace HUST_C
