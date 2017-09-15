/*
* list.h
* this file is the declaration of list related functions and structs
*/

#ifndef LIST_H
#define LIST_H

#include <stddef.h>

/*
 * some shorthands
*/
typedef struct Node *Iter_list;
typedef struct List List;

/*
 * struct Node
 * this struct is the node of the list
 *
 * @members
 *      data    points to the data stored
 *      self_p  points to the pointer that point to the current node
 *      next    points to the next node
*/
struct Node {
    void *data;
    Iter_list *self_p;
    Iter_list next;
};

/*
 * struct List
 * this struct represents the list
 *
 *
 * @members
 *      head    points to the head node of the list
 *      last    points to the last node's next pointer
 *      size    the size of the list
*/
struct List {
    Iter_list head;
    Iter_list *last;
    size_t size;
};

// traverse
/*
 * next_list
 * for incrementing the list iterator
 *
 * @param
 *          node    the iterator to be increased
*/
<<<<<<< HEAD
#define next_list(node) (node) = (node)->next
=======
#define next_list(node) ((node) = (node)->next)
>>>>>>> small fix

/*
 * first_list
 * for getting the first element of a list
 *
 * @param
 *          list    the list to get the first element
 *
 * @return
 *          the iterator positioned at the first elment
*/
<<<<<<< HEAD
#define first_list(list) (list).head->next
=======
#define first_list(list) ((list).head->next)
>>>>>>> small fix

// create

/*
 * create_list
 * creating a list
 *
 * @return
 *          a list (type List)
*/
List create_list(void);

// ==== Modifiers ====
// insertion

/*
 * append_list
 * (shorthand for append_list_generic)
 * to append a node with data set to the given data
 *
 * @param
 *          list    the list to be operated
 *          data    the pointer to the data to be appended
 *
 * @return
 *          the iterator positioned at the inserted elment
*/
#define append_list(list, data) \
    append_list_generic(&(list), data, sizeof(*(data)))

/*
 * append_list_generic
 * to append a node with data set to the given data
 *
 * @param
 *          list    the list to be operated
 *          data    the pointer to the data to be appended
 *          sz      the number of bytes the data occupy
 *
 * @return
 *          the iterator positioned at the inserted elment
*/
Iter_list append_list_generic(List *list, void *data, size_t sz);

/*
 * insert_before_list
 * (shorthand for insert_before_list_generic)
 * to insert a node with data set to the given data before a node
 *
 * @param
 *          list    the list to be operated
 *          node    the node to be inserted before
 *          data    the pointer to the data to be appended
 *
 * @return
 *          the iterator positioned at the inserted elment
*/
#define insert_before_list(list, node, data) \
    insert_before_list_generic(&(list), node, data, sizeof(*(data)))

/*
 * insert_before_list_generic
 * to insert a node with data set to the given data before a node
 *
 * @param
 *          list    the list to be operated
 *          node    the node to be inserted before
 *          data    the pointer to the data to be appended
 *          sz      the number of bytes the data occupy
 *
 * @return
 *          the iterator positioned at the inserted elment
*/
Iter_list insert_before_list_generic(List *list, Iter_list node, void *data,
                                     size_t sz);

/*
 * insert_seq_before_list
 * (shorthand for insert_seq_before_list_generic)
 * to insert a sequence of node with data set to the given data before a node
 *
 * @param
 *          list    the list to be operated
 *          pos     the node to be inserted before
 *          beg     the pointer pointed to the first element of the sequence
 *          end     the pointer pointed to the "past the end" of the sequence
 *
 * @return
 *          the iterator positioned at the first inserted elment
*/
#define insert_seq_before_list(list, pos, beg, end) \
    insert_seq_before_list_generic(&(list), pos, beg, end, sizeof(*beg))

/*
 * insert_seq_before_list_generic
 * to insert a sequence of node with data set to the given data before a node
 *
 * @param
 *          list    the list to be operated
 *          pos     the node to be inserted before
 *          beg     the pointer pointed to the first element of the sequence
 *          end     the pointer pointed to the "past the end" of the sequence
 *          sz      the number of bytes each element of the sequence occupies
 *
 * @return
 *          the iterator positioned at the first inserted elment
*/
Iter_list insert_seq_before_list_generic(List *list, Iter_list pos, void *beg,
                                         void *end, size_t sz);

// delete
/*
 * delete_list
 * (shorthand for delete_list_p)
 * to delete a list, totally
 *
 * @param
 *          list    the list to be deleted
 *
*/
#define delete_list(list) delete_list_p(&(list))
/*
 * delete_list_p
 * to delete a list, totally
 *
 * @param
 *          list    pointer to the list to be deleted
 *
*/
void delete_list_p(List *list);
/*
 * pop_front_list
 * (shorthand for pop_front_list_p)
 * to pop the first node of the list
 *
 * @param
 *          list    the list to be operated
*/
#define pop_front_list(list) pop_front_list_p(&(list))

/*
 * pop_front_list_p
 * to pop the first node of the list
 *
 * @param
 *          list    the list to be operated
*/
void pop_front_list_p(List *list);

/*
 * erase_list
 * (shorthand for erase_list_p)
 * to erase a node in a list
 *
 * @param
 *          list    the list to be operated
 *          node    the node to be erased
 *
 * @return
 *          the iterator following the last removed element
*/
#define erase_list(list, node) erase_list_p(&(list), node)

/*
 * erase_list_p
 * to erase a node in a list
 *
 * @param
 *          list    the pointer to the list to be operated
 *          node    the node to be erased
 *
 * @return
 *          the iterator following the last removed element
*/
Iter_list erase_list_p(List *list, Iter_list node);

/*
 * erase_seq_list
 * (shorthand for erase_seq_list_p)
 * to erase a sequence of nodes in a list
 *
 * @param
 *          list    the list to be operated
 *          beg     the iterator of the first element of the sequence
 *          end     the iterator of the "past the end" of the sequence
 *
 * @return
 *          the iterator following the last removed element
*/
#define erase_seq_list(list, beg, end) erase_seq_list_p(&(list), beg, end)

/*
 * erase_seq_list_p
 * to erase a sequence of nodes in a list
 *
 * @param
 *          list    the pointer to the list to be operated
 *          beg     the iterator of the first element of the sequence
 *          end     the iterator of the "past the end" of the sequence
 *
 * @return
 *          the iterator following the last removed element
*/
Iter_list erase_seq_list_p(List *list, Iter_list beg, Iter_list end);

// operations
/*
 * splice_list
 * (shorthand for splice_list_p)
 * transfer elements from one list to another
 *
 * @param
 *          pos      the position before which to insert the elements
 *          other    the list to be inserted
 *
*/
#define splice_list(this, pos, other) splice_list_p(&this, pos, &other)

/*
 * splice_list_p
 * transfer elements from one list to another
 *
 * @param
 *          pos      the position before which to insert the elements
 *          other    the list to be inserted
 *
*/
void splice_list_p(List *th, Iter_list pos, List *other);

/*
 * sort_list
 * (shorthand for sort_list_p)
 * sort a list
 *
 * @param
 *          list    the list to be sorted
 *          comp    the compare function
 *
*/
#define sort_list(list, comp) sort_list_p(&list, comp)

/*
 * sort_list_p
 * sort a list
 *
 * @param
 *          list    the list to be sorted
 *          comp    the compare function
 *
*/
void sort_list_p(List *list, int (*comp)(void *, void *));

#define seek_list(list, pos) seek_list_p(&list, pos)

Iter_list seek_list_p(List *list, size_t pos);

#endif  // LIST_H
