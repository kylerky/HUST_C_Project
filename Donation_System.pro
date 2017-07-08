TEMPLATE = subdirs


SUBDIRS = gui treemodel list

gui.depends = treemodel list
