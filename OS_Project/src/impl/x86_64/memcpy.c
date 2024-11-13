#include "memcp.h"
#include "print.h"

void *memcpy(void *dest, const void *src, size_t n, size_t dest_size) {
    unsigned char *d = (unsigned char *) dest;
    const unsigned char *s = (const unsigned char *) src;
    if (n > dest_size) {
        print_set_color(PRINT_COLOR_LIGHT_RED, PRINT_COLOR_BLACK);
        print_str("\nError: buffer overflow. NULL value returned. Original value still in buffer.\n");
        return NULL;
    }
    if (d < s) {
        // Copy from start to end if no overlap or if destination is lower in memory
        for (size_t i = 0; i < n; i++) {
            d[i] = s[i];
        }
    } else if (d > s) {
        // Copy from end to start if destination is higher in memory
        for (size_t i = n; i > 0; i--) {
            d[i - 1] = s[i - 1];
        }
    }
    return dest;
    
} 