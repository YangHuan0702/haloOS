char* memset(void *target,int val,int end){
    char *upd = (char*) target;
    for(int i = 0;i < end; i++){
        upd[i] = val;
    }
    return upd;
}