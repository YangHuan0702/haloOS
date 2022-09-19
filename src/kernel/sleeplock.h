struct sleeplock{
    uint locked;
    struct spinlock splock;
    char *name;
    int pid;
};