#ifndef TREEDATA_HPP
#define TREEDATA_HPP

#include "../list/list.h"
#include <QList>
#include <QAbstractItemModel>

namespace HUST_C {
    // class TreeItem
    class TreeItem
    {
    public:
        explicit TreeItem(TreeItem *parent);
        explicit TreeItem(Iter_list &iter, TreeItem *parent = nullptr);
        virtual ~TreeItem();

        TreeItem *child(int row);
        int childCount() const;
        int columnCount() const;
        virtual void *data() const = 0;

        virtual bool insertChild(int position, void *data) = 0;

        int childNumber() const;
        virtual bool setData(void *value) = 0;

        bool removeChildren(int position, int count);

        TreeItem *parent();

    protected:
        Iter_list m_iter;

        QList<TreeItem*> m_childItems;
        TreeItem *m_parentItem;
    };


    // class ClassTreeItem

    class ClassTreeItem : public TreeItem
    {
    public:
        explicit ClassTreeItem(Iter_list &iter, TreeItem *parent = nullptr);
        ~ClassTreeItem() override;

        void *data() const override;

        bool insertChild(int position, void *data) override;

        bool setData(void *value) override;
    };



    // class SchoolTreeItem


    class SchoolTreeItem : public TreeItem
    {
    public:
        explicit SchoolTreeItem(Iter_list &iter, TreeItem *parent = nullptr);
        ~SchoolTreeItem() override;

        void *data() const override;

        bool insertChild(int position, void *data) override;

        bool setData(void *value) override;
    };





    // class RootTreeItem

    class RootTreeItem : public TreeItem
    {
    public:
        explicit RootTreeItem(TreeItem *parent = nullptr);
        ~RootTreeItem() override;

        void *data() const override;

        bool insertChild(int position, void *data) override;

        virtual bool setData(void *listp) override;
    };

} // namespace HUST_C

#endif // TREEDATA_HPP
