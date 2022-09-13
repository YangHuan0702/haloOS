#include "type.h"

#define NUM 8

struct virt_desc{
    // 我們可以在 64-bit 內存地址內的任何位置告訴设备存儲位置
    uint64 addr;
    // 讓 Device 知道有多少內存可用
    uint32 len;
    // 控制 descriptor
    uint16 flags;   
    // 告訴 Device 下一個描述符的 Index。如果指定了 VIRTQ_DESC_F_NEXT，Device仅读取该字段，否则无效
    uint16 next;
}

// AvailableRing 用來存放 Descriptor 的索引，当 Device 收到通知時，它會檢查 AvailableRing 确认需要读取哪些 Descriptor
struct virt_avail{
    uint16 flags;       // 始终为0
    uint16 index;       // 驱动将在下一步写入ring[index]
    uint16 ring[NUM];   
    uint16 unused;
}


struct virt_used_elem{
    uint32 id;  // 已完成的描述符链的起始索引
    uint32 len;
}

struct virt_used{
    uint16 flags;   // 始终为0
    uint16 idx;     // 添加一个 ring[]元素时，这里会自增
    struct virt_used_elem ring[NUM];
}

