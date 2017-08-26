#include "treeitem.hpp"
extern "C" {
#include "data_def.h"
#include "list.h"
}
#include <cstdlib>

namespace HUST_C {

// TreeItem::*

TreeItem::TreeItem(TreeItem *parent) : m_parentItem(parent), m_typeIndex(0) {
    m_iter = new struct Node();
}

TreeItem::TreeItem(Iter_list &iter, TreeItem *parent, int type)
    : m_iter(iter), m_parentItem(parent), m_typeIndex(type) {}

TreeItem::~TreeItem() {
}

TreeItem *TreeItem::child(int row) { return m_childItems.value(row); }

int TreeItem::childNumber() const {
    if (m_parentItem)
        return m_parentItem->m_childItems.indexOf(const_cast<TreeItem *>(this));

    return 0;
}

TreeItem *TreeItem::removeChild(int position) {
    auto ptr = m_childItems.takeAt(position);
    delete ptr;
    return ptr;
}


// ClassTreeItem::*

ClassTreeItem::ClassTreeItem(Iter_list &iter, TreeItem *parent)
    : TreeItem(iter, parent, 1) {}

ClassTreeItem::~ClassTreeItem() {
    delete_list(reinterpret_cast<struct Classes *>(m_iter->data)->donors);
    if (!m_deleteMode) {
        delete reinterpret_cast<struct Classes *>(m_iter->data);
        delete m_iter;
    }
//    erase_list(
//        reinterpret_cast<struct School *>(m_parentItem->m_iter->data)->classes,
//        m_iter);
}

void *ClassTreeItem::data() const { return m_iter->data; }

TreeItem *ClassTreeItem::insertChild(int position, void *data) {
    Q_UNUSED(position);
    Q_UNUSED(data);
    return nullptr;
}
TreeItem *ClassTreeItem::removeChild(int position) {
    auto ptr = m_childItems.takeAt(position);
    delete ptr;
    return ptr;
}
bool ClassTreeItem::setData(void *value) {
    memcpy(m_iter->data, value, sizeof(struct Classes));
    return true;
}

// SchoolTreeItem::*

SchoolTreeItem::SchoolTreeItem(Iter_list &iter, TreeItem *parent)
    : TreeItem(iter, parent, 2) {}
SchoolTreeItem::~SchoolTreeItem() {
    qDeleteAll(m_childItems);
    delete reinterpret_cast<struct School *>(m_iter->data)->classes.head;
    if (!m_deleteMode) {
        delete reinterpret_cast<struct School *>(m_iter->data);
        delete m_iter;
    }
//    erase_list(
//        reinterpret_cast<struct School *>(m_parentItem->m_iter->data)->classes,
//        m_iter);
}

void *SchoolTreeItem::data() const { return m_iter->data; }

TreeItem *SchoolTreeItem::insertChild(int position, void *data) {
    if (position < 0 || position > m_childItems.size()) return nullptr;

    List *list = &reinterpret_cast<struct School *>(m_iter->data)->classes;

    Iter_list iter_pos = first_list(*list);
    for (int i = 0; i != position; ++i) next_list(iter_pos);

    struct Classes *data_ = reinterpret_cast<struct Classes *>(data);

    iter_pos = insert_before_list(*list, iter_pos, data_);

    ClassTreeItem *item = new ClassTreeItem(iter_pos, this);
    m_childItems.insert(position, item);

    return item;
}
TreeItem *SchoolTreeItem::removeChild(int position) {
    auto ptr = m_childItems.takeAt(position);
    auto class_ptr = dynamic_cast<struct ClassTreeItem*>(ptr);
    class_ptr->deleteMode();
    delete ptr;
    List *list = &reinterpret_cast<struct School*>(m_iter->data)->classes;
    Iter_list pos = seek_list(*list, position);
    erase_list(*list, pos);
    return ptr;
}
bool SchoolTreeItem::setData(void *value) {
    memcpy(m_iter->data, value, sizeof(struct School));
    return true;
}

// RootTreeItem::*

RootTreeItem::RootTreeItem(TreeItem *parent) : TreeItem(parent) {
    m_iter = new struct Node();
    auto p = new struct School();
    p->classes = create_list();
    m_iter->data = p;
}
RootTreeItem::~RootTreeItem() {
    qDeleteAll(m_childItems);
    delete reinterpret_cast<struct School *>(m_iter->data)->classes.head;
    delete reinterpret_cast<struct School *>(m_iter->data);
    delete m_iter;
}

void *RootTreeItem::data() const { return m_iter->data; }

TreeItem *RootTreeItem::insertChild(int position, void *data) {
    if (position < 0 || position > m_childItems.size()) return nullptr;

    List *list = &reinterpret_cast<struct School *>(m_iter->data)->classes;

    Iter_list iter_pos = first_list(*list);
    for (int i = 0; i != position; ++i) next_list(iter_pos);

    struct School *data_ = reinterpret_cast<struct School *>(data);

    iter_pos = insert_before_list(*list, iter_pos, data_);


    SchoolTreeItem *item = new SchoolTreeItem(iter_pos, this);
    m_childItems.insert(position, item);

    return item;
}
TreeItem *RootTreeItem::removeChild(int position) {
    auto ptr = m_childItems.takeAt(position);
    auto school_ptr = dynamic_cast<struct SchoolTreeItem*>(ptr);
    school_ptr->deleteMode();
    delete ptr;
    List *list = &reinterpret_cast<struct School*>(m_iter->data)->classes;
    Iter_list pos = seek_list(*list, position);
    erase_list(*list, pos);
    return ptr;
}
bool RootTreeItem::setData(void *listp) {
    Q_UNUSED(listp);
    return false;
}
}
