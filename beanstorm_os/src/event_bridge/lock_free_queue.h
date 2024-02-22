#pragma once

#include <atomic>
#include <memory>

/**
 * A single-producer, single-consumer lock-free queue
 *
 * Taken from Anthony Williams, C++ Concurrency in Action
 * PRACTICAL MULTITHREADING
 *
 */
template <typename T>
class LockFreeQueue
{
public:
    LockFreeQueue ()
        : head (new Node)
        , tail (head.load ())
    {
    }

    LockFreeQueue (const LockFreeQueue & other) = delete;
    LockFreeQueue & operator= (const LockFreeQueue & other) = delete;
    ~LockFreeQueue ()
    {
        while (Node * const old_head = head.load ())
        {
            head.store (old_head->next);
            delete old_head;
        }
    }

    std::shared_ptr<T> Pop ()
    {
        Node * old_head = PopHead ();
        if (! old_head)
        {
            return std::shared_ptr<T> ();
        }
        std::shared_ptr<T> const res (old_head->data);
        delete old_head;
        return res;
    }

    void Push (T new_value)
    {
        std::shared_ptr<T> new_data (std::make_shared<T> (new_value));
        Node * p = new Node;
        Node * const old_tail = tail.load ();
        old_tail->data.swap (new_data);
        old_tail->next = p;

        tail.store (p);
    }

private:
    struct Node
    {
        std::shared_ptr<T> data;
        Node * next;
        Node ()
            : next (nullptr)
        {
        }
    };

    std::atomic<Node *> head;
    std::atomic<Node *> tail;

    Node * PopHead ()
    {
        Node * const old_head = head.load ();
        if (old_head == tail.load ())
        {
            return nullptr;
        }
        head.store (old_head->next);
        return old_head;
    }
};