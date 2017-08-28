#include <cstring>
extern "C" {
#include "data_def.h"
#include "list.h"
}
#include "tablemodel.hpp"
#include "treemodel.hpp"

namespace HUST_C {

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

    Iter_list iter = seek_list(*m_list, row);
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
            return QVariant(static_cast<qulonglong>(data->amount));
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

    emit beginResetModel();
    m_list = plist;
    emit endResetModel();
}

bool TableModel::insert(int position) {
    if (!m_list || position < 0 || position > m_list->size) return false;

    Iter_list iter = seek_list(*m_list, position);

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

    Iter_list iter = seek_list(*m_list, position);

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
    Iter_list iter = seek_list(*m_list, index);
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
namespace {
inline int name_less(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return std::strcmp(lhs->name, rhs->name) < 0;
}
inline int name_more(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return std::strcmp(lhs->name, rhs->name) > 0;
}

inline int id_less(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return std::strcmp(lhs->id, rhs->id) < 0;
}
inline int id_more(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return std::strcmp(lhs->id, rhs->id) > 0;
}

inline int sex_less(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return lhs->sex < rhs->sex;
}
inline int sex_more(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return lhs->sex > rhs->sex;
}

inline int age_less(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return lhs->age < rhs->age;
}
inline int age_more(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return lhs->age > rhs->age;
}

inline int amount_less(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return lhs->amount < rhs->amount;
}
inline int amount_more(void *left, void *right) {
    Donor *lhs = reinterpret_cast<Donor*>(left);
    Donor *rhs = reinterpret_cast<Donor*>(right);

    return lhs->amount > rhs->amount;
}
}

void TableModel::sort_table(const QString &role, bool ascend) {
    emit beginResetModel();
    switch (m_roleIndex[role]) {
        case NameRole:
            if (ascend)
                sort_list(*m_list, name_less);
            else
                sort_list(*m_list, name_more);
            break;
        case IdRole:
            if (ascend)
                sort_list(*m_list, id_less);
            else
                sort_list(*m_list, id_more);
            break;
        case GenderRole:
            if (ascend)
                sort_list(*m_list, sex_less);
            else
                sort_list(*m_list, sex_more);
            break;
        case AgeRole:
            if (ascend)
                sort_list(*m_list, age_less);
            else
                sort_list(*m_list, age_more);
            break;
        case AmountRole:
            if (ascend)
                sort_list(*m_list, amount_less);
            else
                sort_list(*m_list, amount_more);
            break;
        default:
            break;
    }

    emit endResetModel();
}

QHash<int, QByteArray> TableModel::roleNames() const { return m_roleNames; }

}  // namespace HUST_C
