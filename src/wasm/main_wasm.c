#include <stdlib.h>

// IDK How to build raygui without using the raylib headers...
#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

#include <emscripten/emscripten.h>

extern void InitWindow(int width, int height, const char *title);

extern void game_init();
extern void game_frame();

#define WIDTH 1280
#define HEIGHT 720
#define TITLE "Jam"

#define Byte 1
#define Kilobyte 1024 * Byte
#define Megabyte 1024 * Kilobyte
#define Gigabyte 1024 * Megabyte
#define Terabyte 1024 * Gigabyte
#define Petabyte 1024 * Terabyte
#define Exabyte 1024 * Petabyte

#define MEGABYTE

int main(void) {
  InitWindow(WIDTH, HEIGHT, TITLE);
  game_init();

  emscripten_set_main_loop(game_frame, 0, 1);
  return 0;
}