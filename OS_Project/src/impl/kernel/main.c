#include "print.h"

void kernel_main() {
    print_clear();
    print_set_color(PRINT_COLOR_YELLOW, PRINT_COLOR_BLACK);
    print_str("Welcome to my dumbOS");
    print_set_color(PRINT_COLOR_BLACK, PRINT_COLOR_WHITE);
    print_str("\nFunctioning kernel hooks to C code");
    print_set_color(PRINT_COLOR_LIGHT_CYAN, PRINT_COLOR_BLACK);
    print_str("\nVideo memory properly addressed.");

}