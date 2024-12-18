package main_desktop

import rl "../../raylib"

import "../game"

INIT_WIDTH :: 640
INIT_HEIGHT :: 640
TITLE :: "Breakout"

main :: proc() {
    rl.InitWindow(INIT_WIDTH, INIT_HEIGHT, TITLE)
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    game.init()
    defer game.fini()

    for !rl.WindowShouldClose() {
        game.frame()
    }
}