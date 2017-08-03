#ifndef TREEDATA_HPP
#define TREEDATA_HPP
extern "C" {
#include "list.h"
}
#include <QList>

namespace HUST_C {
// class TreeItem
class TreeItem {
    friend class SchoolTreeItem;
    friend class ClassTreeItem;

   public:
    explicit TreeItem(TreeItem *parent);
    explicit TreeItem(Iter_list &iter, TreeItem *parent = nullptr,
                      int type = 0);
    virtual ~TreeItem();

    TreeItem *child(int row);
    int childCount() const;
    int columnCount() const;
    virtual void *data() const = 0;

    virtual TreeItem *insertChild(int position, void *data) = 0;

    int childNumber() const;
    virtual bool setData(void *value) = 0;

    TreeItem *removeChild(int position);

    TreeItem *parent();

    int typeIndex() const;

   protected:
    Iter_list m_iter;

    QList<TreeItem *> m_childItems;
    TreeItem *m_parentItem;
    int m_typeIndex;
};

// class ClassTreeItem

class ClassTreeItem : public TreeItem {
   public:
    explicit ClassTreeItem(Iter_list &iter, TreeItem *parent = nullptr);
    ~ClassTreeItem() override;

    void *data() const override;

    TreeItem *insertChild(int position, void *data) override;

    bool setData(void *value) override;
};

// class SchoolTreeItem

class SchoolTreeItem : public TreeItem {
   public:
    explicit SchoolTreeItem(Iter_list &iter, TreeItem *parent = nullptr);
    ~SchoolTreeItem() override;

    void *data() const override;

    TreeItem *insertChild(int position, void *data) override;

    bool setData(void *value) override;
};

// class RootTreeItem

class RootTreeItem : public TreeItem {
   public:
    explicit RootTreeItem(TreeItem *parent = nullptr);
    ~RootTreeItem() override;

    void *data() const override;

    TreeItem *insertChild(int position, void *data) override;

    virtual bool setData(void *listp) override;
};

}  // namespace HUST_C

#endif  // TREEDATA_HPP
