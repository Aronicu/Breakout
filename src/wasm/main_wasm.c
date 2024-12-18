#include <stdlib.h>

// IDK How to build raygui without using the raylib headers...
#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

#include <emscripten/emscripten.h>

extern void InitWindow(int width, int height, const char *title);
extern void InitAudioDevice();

extern void game_init();
extern void game_frame();

#define WIDTH 640
#define HEIGHT 640
#define TITLE "Breakout"

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
  InitAudioDevice();
  game_init();

  emscripten_set_main_loop(game_frame, 0, 1);
  return 0;
}