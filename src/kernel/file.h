#define OPENFILE 16
#define ROOTDEV 1
#define ROOTINO 1
#define NDEV 10

#define MAXPATH 128

#define CONSOLE 1

struct file {
  enum { FD_NONE, FD_PIPE, FD_INODE, FD_DEVICE } type;
  int ref;            // reference count
  char readable;
  char writable;
 // struct pipe *pipe; // FD_PIPE
  struct inode *ip;  // FD_INODE and FD_DEVICE
  uint off;          // FD_INODE
  short major;       // FD_DEVICE
};

struct devsw {
  int (*read)(int,uint64,int);
  int (*write)(int,uint64,int);
};

extern struct devsw devsw[];
