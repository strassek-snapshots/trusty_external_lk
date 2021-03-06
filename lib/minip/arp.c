/*
 * Copyright (c) 2014 Chris Anderson
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "minip-internal.h"

#include <list.h>
#include <string.h>
#include <malloc.h>
#include <stdio.h>
#include <kernel/thread.h>
#include <kernel/mutex.h>
#include <trace.h>

typedef union {
    uint32_t u;
    uint8_t b[4];
} ipv4_t;

#define LOCAL_TRACE 0
static struct list_node arp_list;
typedef struct {
    struct list_node node;
    uint32_t addr;
    uint8_t mac[6];
} arp_entry_t;

static mutex_t arp_mutex = MUTEX_INITIAL_VALUE(arp_mutex);

void arp_cache_init(void)
{
    list_initialize(&arp_list);
}

static inline void mru_update(struct list_node *entry)
{
    if (arp_list.next == entry)
        return;

    list_delete(entry);
    list_add_head(&arp_list, entry);
}

void arp_cache_update(uint32_t addr, const uint8_t mac[6])
{
    arp_entry_t *arp;
    ipv4_t ip;
    bool found = false;

    ip.u = addr;

    // Ignore 0.0.0.0 or x.x.x.255
    if (ip.u == 0 || ip.b[3] == 0xFF) {
        return;
    }

    /* If the entry is in the cache update the address and move
     * it to head */
    mutex_acquire(&arp_mutex);
    list_for_every_entry(&arp_list, arp, arp_entry_t, node) {
        if (arp->addr == addr) {
            arp->addr = addr;
            mru_update(&arp->node);
            found = true;
            break;
        }
    }

    if (!found) {
        LTRACEF("Adding %u.%u.%u.%u -> %02x:%02x:%02x%02x:%02x:%02x to cache\n",
            ip.b[0], ip.b[1], ip.b[2], ip.b[3],
            mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
        arp = malloc(sizeof(arp_entry_t));
        if (arp == NULL) {
            goto err;
        }

        arp->addr = addr;
        memcpy(arp->mac, mac, sizeof(arp->mac));
        list_add_head(&arp_list, &arp->node);
    }

err:
    mutex_release(&arp_mutex);
    return;
}

/* Looks up and returns a MAC address based on the provided ip addr */
uint8_t *arp_cache_lookup(uint32_t addr)
{
    arp_entry_t *arp = NULL;
    uint8_t *ret = NULL;

    /* If the entry is in the cache update the address and move
     * it to head */
    mutex_acquire(&arp_mutex);
    list_for_every_entry(&arp_list, arp, arp_entry_t, node) {
        if (arp->addr == addr) {
            mru_update(&arp->node);
            ret = arp->mac;
            break;
        }
    }
    mutex_release(&arp_mutex);

    return ret;
}

void arp_cache_dump(void)
{
    int i = 0;
    arp_entry_t *arp;

    if (!list_is_empty(&arp_list)) {
            list_for_every_entry(&arp_list, arp, arp_entry_t, node) {
            ipv4_t ip;
            ip.u = arp->addr;
            printf("%2d: %u.%u.%u.%u -> %02x:%02x:%02x:%02x:%02x:%02x\n",
                i++, ip.b[0], ip.b[1], ip.b[2], ip.b[3],
                arp->mac[0], arp->mac[1], arp->mac[2], arp->mac[3], arp->mac[4], arp->mac[5]);
            }
    } else {
        printf("The arp table is empty\n");
    }
}

// vim: set ts=4 sw=4 expandtab:

