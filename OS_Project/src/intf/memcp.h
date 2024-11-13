#pragma once

#include <stdint.h> //for fixed-width integer types
#include <stddef.h> //for size_t, NULL, etc.
#include <limits.h> //for integer limits (e.g., INT_MAX)

void *memcpy (void *dest, const void *src, size_t n, size_t dest_size);