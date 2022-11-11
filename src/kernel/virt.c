#include "type.h"
#include "riscv.h"
#include "defs.h"
#include "virt.h"
#include "fs.h"


#define R(addr) ((volatile uint32*)(VIRTIO_MMIO_BASE + (addr)))

static struct disk{
    char pages[2 * PGSIZE];

    struct virt_desc *desc;

    struct virt_avail *avail;

    struct virt_used *used;

    char free[NUM]; 

    struct{
        struct buf *b;
        char status;
    } info[NUM];

    uint16 used_idx;

    struct virt_blk_req ops[NUM];

    struct spinlock disklock;
} __attribute__((aligned(PGSIZE))) disk;


// 找到一个空闲描述符，将其标记为非空闲，返回它的索引
static int alloc_desc() {
  for(int i = 0; i < NUM; i++){
    if(disk.free[i]){
      disk.free[i] = 0;
      return i;
    }
  }
  return -1;
}

//将描述符标记为空闲
static void free_desc(int i)
{
  if(i >= NUM){
    printf("free_desc 1");
    return;
  }
  if(disk.free[i]){
    printf("free_desc 2");
    return;
  }
  disk.desc[i].addr = 0;
  disk.desc[i].len = 0;
  disk.desc[i].flags = 0;
  disk.desc[i].next = 0;
  disk.free[i] = 1;
  wakeup(&disk.free[0]);
}

//分配三个描述符（它们不必是连续的）。 磁盘传输总是使用三个描述符
static int alloc3_desc(int *idx)
{
  for(int i = 0; i < 3; i++){
    idx[i] = alloc_desc();
    if(idx[i] < 0){
      for(int j = 0; j < i; j++){
        free_desc(idx[j]);
      }
      return -1;
    }
  }
  return 0;
}

static void free_chain(int i) {
  while (1) {
    int flag = disk.desc[i].flags;
    int nxt = disk.desc[i].next;
    free_desc(i);
    if (flag & VRING_DESC_F_NEXT){
      i = nxt;
    } else{
      break;
    }
  }
}

void virt_disk_rw(struct buf *b, int write) {
    // 指定写入的扇区
    uint64 sector = b->blockno * (BSIZE / 512); 

    acquire(&disk.disklock);
    int idx[3];
    while (1) {
        if (alloc3_desc(idx) == 0) {
            break;
        }
    }

    struct virt_blk_req *buf0 = &disk.ops[idx[0]];

    if (write){
        buf0->type = VIRTIO_BLK_T_OUT;
    } else{
        buf0->type = VIRTIO_BLK_T_IN;
    }
    buf0->reserved = 0;             // 保留部分用于将标头填充到 16 个字节，并将32位扇区字段移动到正确的位置。
    buf0->sector = sector;          // 指定我们要修改的扇区

    disk.desc[idx[0]].addr = (uint64) buf0;
    disk.desc[idx[0]].len = sizeof(struct virt_blk_req);
    disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    disk.desc[idx[0]].next = idx[1];

    disk.desc[idx[1]].addr = (uint64)b->data;
    disk.desc[idx[1]].len = BSIZE;
    if (write){
        disk.desc[idx[1]].flags = 0; // 设备读取 b->data
    }else{
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // 设备写入 b->data
    }
    disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    disk.desc[idx[1]].next = idx[2];

    disk.info[idx[0]].status = 0xff;
    disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    disk.desc[idx[2]].len = 1;
    disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // 设备写入状态
    disk.desc[idx[2]].next = 0;

    // 为 virtio_disk_intr() 记录结构 buf
    b->disk = 1;
    disk.info[idx[0]].b = b;

    // 告诉设备我们的描述符链中的第一个索引
    disk.avail->ring[disk.avail->index % NUM] = idx[0];

    __sync_synchronize();

    //告诉设备另一个可用ring条目可用
    disk.avail->index += 1; // not % NUM ...

    __sync_synchronize();


    *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; //当我们将0写入queue_notify时，设备会立即启动
    while (b->disk == 1) {
      sleep(b, &disk.disklock);
    }

    disk.info[idx[0]].b = 0;
    free_chain(idx[0]);

    release(&disk.disklock);
}


void virtio_disk_init() {
  uint32 status = 0;

  initlock(&disk.disklock, "virtlock");

  //校验磁盘是否存在
  uint64 magic = *R(VIRTIO_MMIO_MAGIC_VALUE);
  uint64 ver = *R(VIRTIO_MMIO_VERSION);
  uint64 deviceId = *R(VIRTIO_MMIO_DEVICE_ID);
  uint64 vendor = *R(VIRTIO_MMIO_VENDOR_ID);
  printf("magic:%p,ver:%d,deviceId:%d,vendor:%p\n",magic,ver,deviceId,vendor);
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||     // virtio-v1.1[4.2.2.2] The driver MUST ignore a device with MagicValue which is not 0x74726976
     *R(VIRTIO_MMIO_VERSION) != 1 ||              
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    printf("could not find virtio disk");
    return;
  }
  
  // os已经找到了该设备，并标识为一个有效的virtio设备
  status |= VIRTIO_CONFIG_S_ACKNOWLEDGE;
  *R(VIRTIO_MMIO_STATUS) = status;

  // os知道如何驱动该设备
  status |= VIRTIO_CONFIG_S_DRIVER;
  *R(VIRTIO_MMIO_STATUS) = status;

  // 读取设备特征位，并将操作系统和驱动程序所理解的特征位子集写到设备上
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
  features &= ~(1 << VIRTIO_BLK_F_RO);
  features &= ~(1 << VIRTIO_BLK_F_SCSI);
  features &= ~(1 << VIRTIO_BLK_F_CONFIG_WCE);
  features &= ~(1 << VIRTIO_BLK_F_MQ);
  features &= ~(1 << VIRTIO_F_ANY_LAYOUT);
  features &= ~(1 << VIRTIO_RING_F_EVENT_IDX);
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;

  // 告诉设备功能协商已完成
  status |= VIRTIO_CONFIG_S_FEATURES_OK;
  *R(VIRTIO_MMIO_STATUS) = status;

  // 驱动程序加载完成，设备可以正常工作了
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
  *R(VIRTIO_MMIO_STATUS) = status;

  // os中的页大小
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;

  // 虚拟队列索引号
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
  if(max == 0){
    printf("virtio disk has no queue 0");
    return;
  }
  if(max < NUM){
    printf("virtio disk max queue too short");
    return;
  }

  // 虚拟队列当前容量值
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
  memset(disk.pages, 0, sizeof(disk.pages));
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;

  disk.desc = (struct virt_desc *) disk.pages;
  disk.avail = (struct virt_avail *)(disk.pages + NUM*sizeof(struct virt_desc));
  disk.used = (struct virt_used *) (disk.pages + PGSIZE);

  // 所有 NUM 描述符开始未使用
  for(int i = 0; i < NUM; i++){
    disk.free[i] = 1;
  }
}

void virtio_disk_isr()
{

  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;

  __sync_synchronize();

  while (disk.used_idx != disk.used->idx) {
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    if (disk.info[id].status != 0){
      printf("virtio_disk_intr status");
    }
    struct buf *b = disk.info[id].b;
    if(b == 0){
      printf("id :%d\n",id);
      panic("virtio_disk_isr: buf is empty");
    }
    b->disk = 0;
    wakeup(b);
    disk.used_idx += 1;
  }

}