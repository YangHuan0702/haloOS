
void* memset(void *dest,int c,int sz){
    char *cdest = (char*) dest;
    for(int i = 0; i < sz; i++){
        cdest[i] = c;
    }
    return dest;
}

int strlen(char *buf){
    int n;
    for(n = 0; buf[n]; n++)
        ;
    return n;
}