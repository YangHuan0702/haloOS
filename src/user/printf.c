#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "users.h"

#include <stdarg.h>

static char nums[] = "0123456789abcdef";

void putc(int fd, char c) { write(fd, &c, 1); }

// static void printInt(int val,int u){
//     char buf[16];
//     int i = 0;
//     do
//     {
//         buf[i++] = nums[val % 10];
//     } while ((val /= 10) > 0);
//     for(i-=1;i >= 0; i--){
//         putc(1,buf[i]);
//     }
// }

// static void print(char *s){
//     while (*s) {
//         putc(1,*(s++));
//     }
// }

static void printptr(int fd,uint64 ptr){
    putc(1,'0');
    putc(1,'x');

    for(int i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    }
}

// void printfD(char *s,...){
//      if(s == 0){
//         return;
//     }
//     va_list ap;
//     va_start(ap,s);
//     char *str;
//     for(int i = 0; s[i] != 0; i++){
//         char c = s[i];
//         if(c != '%'){
//             putc(1,c);
//             continue;
//         }
//         char next = s[++i];
//         if(next == 0){
//             putc(1,c);
//             continue;
//         }
//         switch (next) {
//         case 'd':
//             printInt(va_arg(ap,int),1);
//             break;
//         case 's':
//             str = va_arg(ap,char*);
//             if(str){
//                 print(str);
//             }
//         break;
//         case 'p':
//             printPtr(va_arg(ap,uint64));
//         break;
//         default:
//             putc(1,next);
//             break;
//         }
//     }
// }

static void printint(int fd, int xx, int base, int sgn) {
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if (sgn && xx < 0) {
    neg = 1;
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
  do {
    buf[i++] = nums[x % base];
  } while ((x /= base) != 0);
  if (neg) buf[i++] = '-';

  while (--i >= 0) putc(fd, buf[i]);
}

void vprintf(int fd, const char *fmt, va_list ap) {
  char *s;
  int c, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
    c = fmt[i] & 0xff;
    if (state == 0) {
      if (c == '%') {
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if (state == '%') {
      if (c == 'd') {
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c == 'l') {
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if (c == 'x') {
        printint(fd, va_arg(ap, int), 16, 0);
      } else if (c == 'p') {
        printptr(fd, va_arg(ap, uint64));
      } else if (c == 's') {
        s = va_arg(ap, char *);
        if (s == 0) s = "(null)";
        while (*s != 0) {
          putc(fd, *s);
          s++;
        }
      } else if (c == 'c') {
        putc(fd, va_arg(ap, uint));
      } else if (c == '%') {
        putc(fd, c);
      } else {
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    }
  }
}

void fprintf(int fd, const char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  vprintf(fd, fmt, ap);
}

void printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  vprintf(1, fmt, ap);
}