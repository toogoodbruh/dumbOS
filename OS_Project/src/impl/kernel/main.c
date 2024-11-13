#include "print.h"
#include "memcp.h"

void kernel_main() {
    print_clear();
    print_set_color(PRINT_COLOR_YELLOW, PRINT_COLOR_BLACK);
    print_str("Welcome to my dumbOS");
    print_set_color(PRINT_COLOR_BLACK, PRINT_COLOR_WHITE);
    print_str("\nFunctioning kernel hooks to C code");
    print_set_color(PRINT_COLOR_LIGHT_CYAN, PRINT_COLOR_BLACK);
    print_str("\nVideo memory properly addressed.");
    char buffer[20];
    char str[] = "\nmemcpy works!";
    memcpy(buffer, "\nhello", 6, 20);
    print_set_color(PRINT_COLOR_MAGENTA, PRINT_COLOR_BLACK);
    print_str(buffer);
    memcpy(buffer, str, sizeof(str), 20);
    print_str(buffer);
    char checkoverflowstr [] = "this is a test to  see the handling of more than 20 chars";
    memcpy(buffer, checkoverflowstr, sizeof(checkoverflowstr), 20);
    print_str(buffer);
}