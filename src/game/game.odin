package game

import rl "../../raylib"

GameContext :: struct {
    pos: rl.Vector2,
}

ctx: GameContext 

init :: proc() {
    rl.SetTargetFPS(144)
    ctx.pos = {100, 100}
}

frame :: proc() {
    dt := rl.GetFrameTime()
    SPEED :: 300.0
    if rl.IsKeyDown(.W) do ctx.pos.y -= SPEED * dt
    if rl.IsKeyDown(.S) do ctx.pos.y += SPEED * dt
    if rl.IsKeyDown(.A) do ctx.pos.x -= SPEED * dt
    if rl.IsKeyDown(.D) do ctx.pos.x += SPEED * dt

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)

    rl.DrawText("Hello From Raylib", 100, 100, 60, rl.WHITE)

    rl.DrawRectangleV(ctx.pos, {100, 100}, rl.PURPLE)
    rl.EndDrawing()
}

fini :: proc() {

}