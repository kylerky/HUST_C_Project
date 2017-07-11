#include "treeitem.hpp"
extern "C" {
    #include "list.h"
    #include "data_def.h"
}
#include <stdlib.h>

namespace HUST_C {

    // TreeItem::*


    TreeItem::TreeItem(TreeItem *parent)
    {
        m_iter = new struct Node();
        m_parentItem = parent;
    }

    TreeItem::TreeItem(Iter_list &iter, TreeItem *parent) : m_iter(iter), m_parentItem(parent){}

    TreeItem::~TreeItem()
    {
        free(m_iter->data);
        free(m_iter);
        qDeleteAll(m_childItems);
    }

    TreeItem *TreeItem::child(int row)
    {
        return m_childItems.value(row);
    }

    int TreeItem::childCount() const
    {
        return m_childItems.count();
    }

    int TreeItem::columnCount() const
    {
        return 1;
    }

    int TreeItem::childNumber() const
    {
        if (m_parentItem)
            return m_parentItem->m_childItems.indexOf(const_cast<TreeItem*>(this));

        return 0;
    }


    bool TreeItem::removeChildren(int position, int count)
    {
        if (position < 0 || position + count > m_childItems.size())
            return false;

        for (int row = 0; row != count; ++row)
            delete m_childItems.takeAt(position);

        return true;
    }

    TreeItem *TreeItem::parent()
    {
        return m_parentItem;
    }






    // ClassTreeItem::*


    ClassTreeItem::ClassTreeItem(Iter_list &iter, TreeItem *parent):TreeItem(iter, parent){}
    ClassTreeItem::~ClassTreeItem()
    {
        delete_list(reinterpret_cast<struct Classes*>(m_iter->data)->donors);
    }

    void *ClassTreeItem::data() const
    {
        return m_iter->data;
    }


    bool ClassTreeItem::insertChild(int position, void *data)
    {
        Q_UNUSED(position);
        Q_UNUSED(data);
        return false;
    }

    bool ClassTreeItem::setData(void *value)
    {
        memcpy(m_iter->data, value, sizeof(struct Classes));
        return true;
    }





    // SchoolTreeItem::*

    SchoolTreeItem::SchoolTreeItem(Iter_list &iter, TreeItem *parent):TreeItem(iter, parent){}
    SchoolTreeItem::~SchoolTreeItem(){}

    void *SchoolTreeItem::data() const
    {
        return m_iter->data;
    }

    bool SchoolTreeItem::insertChild(int position, void *data)
    {
        if (position < 0 || position > m_childItems.size())
            return false;

        List list = reinterpret_cast<struct School *>(m_iter->data)->classes;

        Iter_list iter_pos = first_list(list);
        for (int i = 0; i != position; ++i)
            next_list(iter_pos);

        struct School *data_ = reinterpret_cast<struct School *>(data);

        iter_pos = insert_before_list(list, iter_pos, data_);

        ClassTreeItem *item = new ClassTreeItem(iter_pos, this);
        m_childItems.insert(position, item);

        return true;
    }

    bool SchoolTreeItem::setData(void *value)
    {
        memcpy(m_iter->data, value, sizeof(struct School));
        return true;
    }



    // RootTreeItem::*

    RootTreeItem::RootTreeItem(TreeItem *parent) : TreeItem(parent){}
    RootTreeItem::~RootTreeItem(){}

    void *RootTreeItem::data() const
    {
        return nullptr;
    }

    bool RootTreeItem::insertChild(int position, void *data)
    {
        if (position < 0 || position > m_childItems.size())
            return false;

        List list = reinterpret_cast<struct School *>(m_iter->data)->classes;

        Iter_list iter_pos = first_list(list);
        for (int i = 0; i != position; ++i)
            next_list(iter_pos);

        struct School *data_ = reinterpret_cast<struct School*>(data);

        iter_pos = insert_before_list(list, iter_pos, data_);

        SchoolTreeItem *item = new SchoolTreeItem(iter_pos, this);
        m_childItems.insert(position, item);

        return true;
    }

    bool RootTreeItem::setData(void *listp)
    {
        Q_UNUSED(listp);
        return false;
    }

}

