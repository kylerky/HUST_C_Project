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
    int childCount() const { return m_childItems.count(); }
    int columnCount() const { return 1; }
    virtual void *data() const = 0;

    virtual TreeItem *insertChild(int position, void *data) = 0;

    int childNumber() const;
    virtual bool setData(void *value) = 0;

    TreeItem *removeChild(int position);

    TreeItem *parent() { return m_parentItem; }
    int typeIndex() const { return m_typeIndex; }

    unsigned long getIndex() const {return m_index;}
    void setIndex(unsigned long index) {m_index = index;}

    QList<TreeItem*>::const_iterator child_cbeg() const {return m_childItems.cbegin();}
    QList<TreeItem*>::const_iterator child_cend() const {return m_childItems.cend();}
   protected:
    Iter_list m_iter;

    QList<TreeItem *> m_childItems;
    TreeItem *m_parentItem;
    int m_typeIndex;
private:
    unsigned long m_index = 0;
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
