package main_desktop

import rl "../../raylib"

import "../game"

INIT_WIDTH :: 1280
INIT_HEIGHT :: 720
TITLE :: "JAMMERS"

main :: proc() {
    rl.InitWindow(INIT_WIDTH, INIT_HEIGHT, TITLE)
    defer rl.CloseWindow()

    game.init()
    defer game.fini()

    for !rl.WindowShouldClose() {
        game.frame()
    }
}