#include <stdlib.h>
#include <string.h>

#include "list.h"

List create_list(void) {
    // create the head node
    List list;

    // initialize the head node and the list
    list.head = (Iter_list)calloc(1, sizeof(struct Node));
    list.last = &(list.head->next);
    list.size = 0;

    return list;
}

Iter_list append_list_generic(List *list, void *data, size_t sz) {
    // create the new node
    Iter_list new_node = (Iter_list)calloc(1, sizeof(struct Node));
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

Iter_list insert_before_list_generic(List *list, Iter_list pos, void *data,
                                     size_t sz) {
    // create new node
    Iter_list new_node = (Iter_list)malloc(sizeof(struct Node));
    // get pointer pointed to the node itself
    Iter_list *last_next = list->last;
    if (pos) {
        last_next = pos->self_p;
        pos->self_p = &(new_node->next);
    } else
        list->last = &(new_node->next);

    // change pointers
    new_node->next = pos;

    *last_next = new_node;

    new_node->self_p = last_next;

    // allocate space and copy data
    new_node->data = malloc(sz);

    memcpy(new_node->data, data, sz);

    // increment size
    ++list->size;

    return new_node;
}

Iter_list insert_seq_before_list_generic(List *list, Iter_list pos, void *beg,
                                         void *end, size_t sz) {
    // get the node before pos
    Iter_list first_inserted = (Iter_list)pos;

    // get pointer pointed to the node itself
    Iter_list *last_next = list->last;
    if (pos) last_next = pos->self_p;

    int first_flag = 1;  // flag the first
    // initialize the pointer
    Iter_list new_node;
    for (char *first = (char *)beg, *last = (char *)end; first != last;
         first += sz) {
        // create new node
        new_node = (Iter_list)malloc(sizeof(struct Node));

        // change the previous node's pointer

        *last_next = new_node;

        // allocate space and copy data
        new_node->data = malloc(sz);
        memcpy(new_node->data, first, sz);

        // renew the pointers
        new_node->self_p = last_next;

        if (first_flag) {
            first_inserted = new_node;
            first_flag = 0;
        }

        last_next = &(new_node->next);
    }

    *last_next = pos;
    if (pos)
        pos->self_p = &(new_node->next);
    else
        list->last = &(new_node->next);

    list->size += (end - beg) / sz;

    return first_inserted;
}

void delete_list_p(List *list) {
    // get pointers
    Iter_list next = list->head->next;
    Iter_list curr = list->head;

    // free the head node
    free(curr);
    curr = next;

    while (curr) {
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

void pop_front_list_p(List *list) {
    // get the first element
    Iter_list first = first_list(*list);

    // change the pointers
    list->head->next = first->next;
    first->next->self_p = &list->head->next;

    // free the memory
    free(first->data);
    free(first);

    // decrease the size
    --list->size;
}

Iter_list erase_list_p(List *list, Iter_list node) {
    // get the next node
    Iter_list next = node->next;

    // change pointers
    *node->self_p = next;
    if (next)
        next->self_p = node->self_p;
    else
        list->last = node->self_p;

    // free the memory
    free(node->data);
    free(node);

    // decrease size
    --list->size;

    return next;
}

Iter_list erase_seq_list_p(List *list, Iter_list beg, Iter_list end) {
    // change pointers
    *beg->self_p = end;

    // change the pointers of the end element
    if (end)
        end->self_p = beg->self_p;
    else
        list->last = beg->self_p;


    // iterate through the sequence to erase
    while (beg != end) {
        // store the next
        Iter_list next = beg->next;

        // free the memory
        free(beg->data);
        free(beg);

        // decrease size
        --list->size;

        // next
        beg = next;
    }

    return beg;
}

void splice_list_p(List *first, Iter_list pos, List *other) {
    // get the self pointer
    Iter_list *self_p = first->last;
    if (pos) self_p = pos->self_p;

    // change the pointers
    *self_p = other->head->next;
    other->head->next->self_p = self_p;

    *other->last = pos;
    if (pos)
        pos->self_p = other->last;
    else
        first->last = other->last;

    first->size += other->size;

    // free the head node
    free(other->head);
    other->head = NULL;
    other->size = 0;
    other->last = NULL;
}

void sort_list_p(List *list, int (*comp)(void *, void *)) {
    if (list->size < 2) return;

    for (size_t sz = 1; sz < list->size; sz *= 2) {
        Iter_list left = list->head->next, right = left;

        // bottom-up merge sort
        while (1) {
            // find the beginning of the right
            for (unsigned i = 0; right && i != sz; ++i) next_list(right);

            // the right does not exist
            if (!right) break;

            // merge
            size_t lcnt = 0, rcnt = 0;  // boundary
            Iter_list *last = left->self_p;

            while (lcnt < sz || (right && rcnt < sz)) {
                if (lcnt >= sz ||
                    (right && rcnt < sz && comp(right->data, left->data))) {
                    *last = right;
                    right->self_p = last;

                    last = &(right->next);
                    next_list(right);
                    ++rcnt;
                } else {
                    *last = left;
                    left->self_p = last;

                    last = &(left->next);
                    next_list(left);
                    ++lcnt;
                }
            }
            // next
            if (right) right->self_p = last;
            *last = right;
            left = right;
        }
    }
}
Iter_list seek_list_p(List *list, size_t index) {
    Iter_list iter = first_list(*list);
    for (size_t i = 0; i != index; ++i) next_list(iter);
    return iter;
}
