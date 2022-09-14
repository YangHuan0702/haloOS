#include "type.h"

/*
 * References:
 * 1. https://github.com/ianchen0119/xv6-riscv/blob/riscv/kernel/virtio.h
 * 2. https://github.com/sgmarz/osblog/blob/master/risc_v/src/virtio.rs
 */
// virtio mmio control registers, mapped starting at 0x10001000.
#define VIRTIO_MMIO_BASE 0x10001000

/* OFFSET */
#define VIRTIO_MMIO_MAGIC_VALUE		0x000 // 0x74726976 魔数
#define VIRTIO_MMIO_VERSION		0x004 // version; 1 is legacy   设备版本号
#define VIRTIO_MMIO_DEVICE_ID		0x008 // device type; 1 is net, 2 is disk   Virtio子系统设备ID
#define VIRTIO_MMIO_VENDOR_ID		0x00c // 0x554d4551     Virtio子系统供应商ID

#define VIRTIO_MMIO_DEVICE_FEATURES	0x010 // 设备支持的功能
#define VIRTIO_MMIO_DRIVER_FEATURES	0x020 // 驱动程序理解的设备功能
#define VIRTIO_MMIO_GUEST_PAGE_SIZE	0x028 // PFN的页大小，只读; OS中页的大小（应为2的幂）
#define VIRTIO_MMIO_QUEUE_SEL		0x030 // 虚拟队列索引号，只写
#define VIRTIO_MMIO_QUEUE_NUM_MAX	0x034 // 虚拟队列最大容量值，只读
#define VIRTIO_MMIO_QUEUE_NUM		0x038 // 虚拟队列当前容量值，只写
#define VIRTIO_MMIO_QUEUE_ALIGN		0x03c // 虚拟队列的对齐边界（以字节为单位）, 只读
#define VIRTIO_MMIO_QUEUE_PFN		0x040 // 虚拟队列所在的物理页号, 读写
#define VIRTIO_MMIO_QUEUE_READY		0x044 // new interface only，ready bit
#define VIRTIO_MMIO_QUEUE_NOTIFY	0x050 // 队列通知，只写
#define VIRTIO_MMIO_INTERRUPT_STATUS	0x060 // 中断状态，read-only
#define VIRTIO_MMIO_INTERRUPT_ACK	0x064 // 中断确认，write-only
#define VIRTIO_MMIO_STATUS		0x070 // 设备状态，read/write

#define VIRTIO_CONFIG_S_ACKNOWLEDGE	1   // 驱动程序发现了这个设备，并且认为这是一个有效的virtio设备
#define VIRTIO_CONFIG_S_DRIVER		2   // 驱动程序知道该如何驱动这个设备
#define VIRTIO_CONFIG_S_DRIVER_OK	4   // 驱动程序加载完成，设备可以正常工作了
#define VIRTIO_CONFIG_S_FEATURES_OK	8   // 驱动程序认识设备的特征，并且与设备就设备特征协商达成一致
#define VIRTIO_CONFIG_S_DEVICE_NEEDS_RESET 64 // 设备触发了错误，需要重置才能继续工作
#define VIRTIO_CONFIG_S_FAILED 128      // 由于某种错误原因，驱动程序无法正常驱动这个设备

// 设备特征位
#define VIRTIO_BLK_F_RO              5	/* 磁盘是只读的 */
#define VIRTIO_BLK_F_SCSI            7	/* 支持scsi命令 */
#define VIRTIO_BLK_F_CONFIG_WCE     11	/* 配置中可使用回写模式 */
#define VIRTIO_BLK_F_MQ             12	/* 支持一个以上的VQ */
#define VIRTIO_F_ANY_LAYOUT         27
#define VIRTIO_RING_F_INDIRECT_DESC 28
#define VIRTIO_RING_F_EVENT_IDX     29

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
};


#define VRING_DESC_F_NEXT 1     // 与另一个描述符链在一起
#define VRING_DESC_F_WRITE 2    // 设备写入/读取
#define VRING_DESC_F_INDIRECT 4 // buffer包含一个缓冲区描述符的列表

// AvailableRing 用來存放 Descriptor 的索引，当 Device 收到通知時，它會檢查 AvailableRing 确认需要读取哪些 Descriptor
struct virt_avail{
    uint16 flags;       // 始终为0
    uint16 index;       // 驱动将在下一步写入ring[index]
    uint16 ring[NUM];   
    uint16 unused;
};



#define VIRTIO_BLK_T_IN  0
#define VIRTIO_BLK_T_OUT 1

struct virt_used_elem{
    uint32 id;  // 已完成的描述符链的起始索引
    uint32 len;
};

struct virt_used{
    uint16 flags;   // 始终为0
    uint16 idx;     // 添加一个 ring[]元素时，这里会自增
    struct virt_used_elem ring[NUM];
};

struct virt_blk_req{
    uint32 type;
    uint32 reserved;
    uint64 sector;
};