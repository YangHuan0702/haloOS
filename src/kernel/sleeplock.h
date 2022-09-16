struct sleeplock{
    uint locked;
    struct spinlock spin_lock;

    char *name;
    int pid;
}