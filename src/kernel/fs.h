// +------------------+
// |  File descriptor |
// +------------------+
// |  Pathname        |
// +------------------+
// |  Directory       |
// +------------------+
// |  Inode           |
// +------------------+
// |  Logging         |
// +------------------+
// |  Buffer cache    |
// +------------------+
// |  Disk            |
// +------------------+

// [boot block] [super block] [log block] [inode block] [bit map] [data block] ...
//      0             1       2   ~   31  32    ~   45     46     47

#include "type.h"
#include "spinlock.h"
#include "sleeplock.h"

#define BSIZE 1024

#define PGSIZE 4096
#define PGSHIFT 12  // 页内的偏移量



struct buf {
    int vaild;
    int disk;
    uint dev;
    uint blockno;
    struct sleeplock sk;    
    uint refcnt;
    struct buf *prev;
    struct buf *next;
    uchar data[BSIZE];    
};

struct superblock {
  uint magic;        // Must be FSMAGIC
  uint size;         // Size of file system image (blocks)
  uint nblocks;      // Number of data blocks
  uint ninodes;      // Number of inodes.
  uint nlog;         // Number of log blocks
  uint logstart;     // Block number of first log block
  uint inodestart;   // Block number of first inode block
  uint bmapstart;    // Block number of first free map block
};
