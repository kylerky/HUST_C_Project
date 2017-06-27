#include <stdlib.h>
#include <string.h>

#include "list.h"

/*
 * 
*/
List create_list(void)
{
    // create the head node
    List list = {NULL, NULL, 0};

    // initialize the head node and the list
    list.head = (Iter_list) calloc(1, sizeof(struct Node));
    list.last = &list.head->next;

    return list;
};

/*
 *
*/
Iter_list append_list_generic(List *list, void *data, size_t sz)
{
    // create the new node
    Iter_list new_node = (Iter_list) calloc(1, sizeof(struct Node));
    *list->last = new_node;
    new_node->self_p = list->last;
    list->last = &new_node->next;

    // allocate space and copy the data
    new_node->data = malloc(sz);

    memcpy(new_node->data, data, sz);

    // increment size
    ++list->size;

    return new_node;
}

Iter_list insert_before_list_generic(List *list, Iter_list node, void *data, size_t sz)
{
    // create new node
    Iter_list new_node = (Iter_list) malloc(sizeof(struct Node));
    *(node->self_p) = new_node;

    // change pointers
    new_node->self_p = node->self_p;
    new_node->next = node;
    node->self_p = &(new_node->next);

    // allocate space and copy data
    new_node->data = malloc(sz);
    
    memcpy(new_node->data, data, sz);

    // increment size
    ++list->size;

    return new_node;
}

Iter_list insert_seq_before_list_generic(List *list, Iter_list pos, void *beg, void *end, size_t sz)
{
    // get the node before pos
    Iter_list first_inserted = (Iter_list)pos;

    // get pointer pointed to the node itself
    Iter_list *last_next = pos->self_p;
    // get the first pos

    int first_flag=1; // flag the first
    // initialize the pointer
    for (char *first = (char*)beg, *last = (char*)end; first != last; first+=sz)
    {
        // create new node
        Iter_list new_node = (Iter_list)malloc(sizeof(struct Node));

        // change the previous node's pointer

        *last_next = new_node;
        

        // allocate space and copy data
        new_node->data = malloc(sz);
        memcpy(new_node->data, first, sz);

        // renew the pointers
        new_node->self_p = last_next;

        if (first_flag)
        {
            first_inserted = new_node;
            first_flag = 0;
        }
        

        last_next = &(new_node->next);
    }

    *last_next = pos;

    list->size += (end-beg)/sz;

    return first_inserted;
}

void delete_list_p(List *list)
{
    // get pointers
    Iter_list next = list->head->next;
    Iter_list curr = list->head;

    // free the head node
    free(curr);
    curr = next;

    while(curr)
    {
        next = curr->next;

        // free data
        free(curr->data);
        // free node
        free(curr);
        curr = next;
    }

    // reset list
    list->head = NULL;
    list->last = NULL;
    list->size = 0;
}

void pop_front_list_p(List *list)
{
    Iter_list first = first_list(*list);

    list->head->next = first->next;
    first->next->self_p = &list->head->next;

    free(first->data);
    free(first);

    --list->size;
}

Iter_list erase_list_p(List *list, Iter_list node)
{
    Iter_list next = node->next;

    *node->self_p = next;
    next->self_p = node->self_p;

    free(node->data);
    free(node);

    --list->size;

    return next;
}

Iter_list erase_seq_list_p(List *list, Iter_list beg, Iter_list end)
{
    *beg->self_p = end;

    if (end)
        end->self_p = beg->self_p;
    
    while (beg != end)
    {
        Iter_list next = beg->next;

        free(beg->data);
        free(beg);

        --list->size;
        beg = next;
    }
    return beg;
}
