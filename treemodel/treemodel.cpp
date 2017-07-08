#include "treemodel.hpp"
#include "treeitem.hpp"
#include "../list/data_def.h"
#include "../list/list.h"

HUST_C::TreeModel::TreeModel(QObject *parent)
    : QAbstractItemModel(parent)
{
    m_rootItem = new RootTreeItem();

}

