#include "src/kernel/type.h"
#include "src/kernel/fcntl.h"
#include "src/kernel/stat.h"
#include "src/user/users.h"

void* memset(void *dest, int c, uint sz) {
  char *cdest = (char *)dest;
  for (int i = 0; i < sz; i++) {
    cdest[i] = c;
  }
  return dest;
}

uint strlen(const char *buf) {
  int n;
  for (n = 0; buf[n]; n++)
    ;
  return n;
}

void *memmove(void *vdst,const void *vsrc, int n) {
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    while (n-- > 0) {
      *dst++ = *src++;
    };
  } else {
    dst += n;
    src += n;
    while (n-- > 0) {
      *--dst = *--src;
    };
  }
  return vdst;
}

int atoi(const char *s) {
  int n = 0;

  while ('0' <= *s && *s <= '9'){
      n = n * 10 + *s++ - '0';
  } 
  return n;
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    p++, q++;
  return (uchar)*p - (uchar)*q;
}


int memcmp(const void *s1, const void *s2, uint n) {
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    if (*p1 != *p2) {
      return *p1 - *p2;
    }
    p1++;
    p2++;
  }
  return 0;
}

void *memcpy(void *dst, const void *src, uint n) { 
    return memmove(dst, src, n); 
}

char*
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
  return buf;
}

int stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0){
    return -1;
  }
  r = fstat(fd, st);
  close(fd);
  return r;
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
}


char*
strcpy(char *s, const char *t)
{
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    ;
  return os;
}
