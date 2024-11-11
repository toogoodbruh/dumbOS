#include "print.h"
const static size_t NUM_COLS = 80;
const static size_t NUM_ROWS = 25;
struct Char {
    uint8_t character;
    uint8_t color;
};
struct Char* buffer = (struct Char*) 0xb8000;
size_t col = 0;
size_t row = 0;
uint8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4; // left shift by 4 bits
void clear_row(size_t row) {
    struct Char empty = (struct Char) {
        character: ' ',
        color: color,
    };
    for (size_t col = 0; col < NUM_COLS; col++) {
        buffer[col + NUM_COLS * row] = empty;
    }
}
void print_clear() {
    for (size_t i = 0; i < NUM_ROWS; i++) {
        clear_row(i);
    }
}
void print_newline() {
    col = 0;
    if (row < NUM_ROWS - 1) { //check if not at last row
        row++;
        return;
    }
    //if on last row, text needs to be scrolled up so there is space for new row
    for (size_t row = 1; row < NUM_ROWS; row++) { //loop through from second row onwards
        for (size_t col = 1; col < NUM_COLS; col++) { //loop through all columns
            struct Char character = buffer[col + NUM_COLS * row]; //gets character at row and column
            buffer[col + NUM_COLS * (row - 1)] = character;
        }
    }
    clear_row(NUM_COLS - 1); //clear last row before printing to it
}
void print_char(char character) {
    if (character == '\n') {
        print_newline();
        return;
    }
    if (col > NUM_COLS ) {
        print_newline();
    }
    buffer[col + NUM_COLS * row] = (struct Char) {
        character: (uint8_t) character, //downcast character to 8 bits bc in theory could be greater than 8 bits
        color: color,
    };
    col++;
}

void print_str(char* str) {
    for (size_t i = 0; 1; i++) { // loop through each char in string, string is null terminated instead of showing length, so set to 1, increment
        char character = (uint8_t) str[i]; //downcast to 8 bits
        if (character == '\0') {
            return;
        }
        print_char(character);
    }
}
void print_set_color(uint8_t foreground, uint8_t background) {
    color = foreground + (background << 4); //foregroudn takes up first 4 bits, bitshift background to take up last 4 bits
}