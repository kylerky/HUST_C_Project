/*
 * list.h
 * this file is the declaration of list related functions and structs
*/

#include <stddef.h>

/*
 * struct Node
 * this struct is the node of the list
 *
 * @members
 *      data    points to the data stored
 *      self_p  points to the pointer that point to the current node
 *      next    points to the next node
*/
typedef struct Node *Iter_list;
typedef struct List List;

struct Node
{
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
 *      size    the size of the list
*/
struct List
{
    Iter_list head;
    Iter_list *last;
    size_t size;
};

// traverse
/*
 *
*/

#define next_list(node) (node) = (node)->next
/*
 *
*/
#define first_list(list) (list).head->next


// create

/*
 * 
*/
List create_list(void);

// ==== Modifiers ====
// insertion

/*
 *
*/
#define append_list(list, data) append_list_generic(&(list), data, sizeof(*(data)))

/*
 *
*/
Iter_list append_list_generic(List *list, void *data, size_t sz);

/*
 *
*/
#define insert_before_list(list, node, data) insert_before_list_generic(&(list), node, data, sizeof(*(data)))

/*
 *
*/
Iter_list insert_before_list_generic(List *list, Iter_list node, void *data, size_t sz);

/*
 *
*/
#define insert_seq_before_list(list, pos, beg, end) insert_seq_before_list_generic(&(list), pos, beg, end, sizeof(*beg))

/*
 *
*/
Iter_list insert_seq_before_list_generic(List *list, Iter_list pos, void *beg, void *end, size_t sz);



// delete
/*
 *
*/
#define delete_list(list) delete_list_p(&(list))
/*
 *
*/
void delete_list_p(List *list);
/*
 *
*/
#define pop_front_list(list) pop_front_list_p(&(list))
/*
 *
*/
void pop_front_list_p(List *list);


/*
 *
*/
#define erase_list(list, node) erase_list_p(&(list), node)

/*
 *
*/
Iter_list erase_list_p(List *list, Iter_list node);

/*
 *
*/
#define erase_seq_list(list, beg, end) erase_seq_list_p(&(list), beg, end)

/*
 *
*/
Iter_list erase_seq_list_p(List *list, Iter_list beg, Iter_list end);
