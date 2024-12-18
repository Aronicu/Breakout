package game

import rl "../../raylib"

import "core:fmt"
import "core:math"
import "core:math/rand"
import lm "core:math/linalg"

SCREEN_SIZE :: 320

PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200

BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160

NUM_BLOCKS_X :: 10
NUM_BLOCKS_Y :: 8
BLOCK_WIDTH :: 28
BLOCK_HEIGHT :: 10

Block_Color :: enum {
    Yellow,
    Green,
    Purple,
    Red,
}

row_colors := [NUM_BLOCKS_Y]Block_Color {
    .Red, .Red,
    .Purple, .Purple,
    .Green, .Green,
    .Yellow, .Yellow,
}

block_color_values := [Block_Color]rl.Color {
    .Yellow = rl.Color{253, 249, 150, 255},
    .Green = rl.Color{180, 245, 190, 255},
    .Purple = rl.Color{170, 120, 250, 255},
    .Red = rl.Color{250, 90, 85, 255},
}

block_color_scores := [Block_Color]int {
    .Yellow = 2,
    .Green = 4,
    .Purple = 6,
    .Red = 8,
}

prev_paddle_pos_x: f32
paddle_pos_x: f32
prev_ball_pos: rl.Vector2
ball_pos: rl.Vector2
ball_dir: rl.Vector2
blocks: [NUM_BLOCKS_X][NUM_BLOCKS_Y]bool

score: int
started: bool
game_over: bool

ball_texture: rl.Texture2D
paddle_texture: rl.Texture2D

hit_block_sound: rl.Sound
hit_paddle_sound: rl.Sound
game_over_sound: rl.Sound

accumulated_time: f32

init :: proc() {
    rl.SetTargetFPS(144)
    ball_texture = rl.LoadTexture("assets/ball.png")
    paddle_texture = rl.LoadTexture("assets/paddle.png")
    hit_block_sound = rl.LoadSound("assets/hit_block.wav")
    hit_paddle_sound = rl.LoadSound("assets/hit_paddle.wav")
    game_over_sound = rl.LoadSound("assets/game_over.wav")
    restart()
}

restart :: proc() {
    started = false
    game_over = false
    score = 0
    paddle_pos_x = SCREEN_SIZE/2 - PADDLE_WIDTH/2
    prev_paddle_pos_x = paddle_pos_x
    ball_pos = {SCREEN_SIZE/2, BALL_START_Y}
    prev_ball_pos = ball_pos

    for x in 0..<NUM_BLOCKS_X {
        for y in 0..<NUM_BLOCKS_Y {
            blocks[x][y] = true
        }
    }
}

frame :: proc() {
    DT :: 1.0/60.0

    // dt: f32
    if !started {
        ball_pos = {
            SCREEN_SIZE/2 + f32(math.cos(rl.GetTime()) * SCREEN_SIZE/2.5),
            BALL_START_Y,
        }

        prev_ball_pos = ball_pos
        if rl.IsKeyPressed(.SPACE) {
            paddle_middle := rl.Vector2 {paddle_pos_x + PADDLE_WIDTH/2, PADDLE_POS_Y}
            ball_dir = lm.normalize0(paddle_middle - ball_pos)
            started = true
        }
    } else if game_over {
        if rl.IsKeyPressed(.SPACE) {
            restart()
        }
    } else {
        accumulated_time += rl.GetFrameTime()
    }

    for accumulated_time >= DT {
        prev_ball_pos = ball_pos
        ball_pos += ball_dir * BALL_SPEED * DT
    
        if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
            ball_pos.x = SCREEN_SIZE - BALL_RADIUS
            ball_dir = reflect(ball_dir, {-1, 0})
        }
        if ball_pos.x - BALL_RADIUS < 0 {
            ball_pos.x = BALL_RADIUS
            ball_dir = reflect(ball_dir, {1, 0})
        }
        if ball_pos.y - BALL_RADIUS < 0 {
            ball_pos.y = BALL_RADIUS
            ball_dir = reflect(ball_dir, {0, 1})
        }
    
        if !game_over && ball_pos.y  > SCREEN_SIZE + BALL_RADIUS * 6 {
            rl.PlaySound(game_over_sound)
            game_over = true
        }
    
        paddle_move_velocity: f32
    
        if rl.IsKeyDown(.LEFT) do paddle_move_velocity -= PADDLE_SPEED
        if rl.IsKeyDown(.RIGHT) do paddle_move_velocity += PADDLE_SPEED
        
        prev_paddle_pos_x = paddle_pos_x
        paddle_pos_x += paddle_move_velocity * DT
        paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)
        paddle_rect := rl.Rectangle {paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}
    
        if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
            collision_normal: rl.Vector2
    
            if prev_ball_pos.y < paddle_rect.y + paddle_rect.height {
                collision_normal += {0, -1}
                ball_pos.y = paddle_rect.y - BALL_RADIUS
            }
    
            if prev_ball_pos.y > paddle_rect.y + paddle_rect.height {
                collision_normal += {0, 1}
                ball_pos.y = paddle_rect.y + paddle_rect.height + BALL_RADIUS
            }
    
            if prev_ball_pos.x < paddle_rect.x {
                collision_normal += {-1, 0}
            }
    
            if prev_ball_pos.x > paddle_rect.x + paddle_rect.width {
                collision_normal += {1, 0}
            }
    
            if collision_normal != 0 {
                ball_dir = reflect(ball_dir, collision_normal)
            }
    
            rl.PlaySound(hit_paddle_sound)
        }
    
        block_col: for x in 0..<NUM_BLOCKS_X {
            for y in 0..<NUM_BLOCKS_Y {
                if !blocks[x][y] do continue
    
                block_rect := calc_block_rect(x, y)
    
                if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, block_rect) {
                    collision_normal: rl.Vector2
    
                    if prev_ball_pos.y < block_rect.y {
                        collision_normal += {0, -1}
                    }
    
                    if prev_ball_pos.y > block_rect.y + block_rect.height {
                        collision_normal += {0, 1}
                    }
    
                    if prev_ball_pos.x < block_rect.x {
                        collision_normal += {-1, 0}
                    }
    
                    if prev_ball_pos.x > block_rect.x + block_rect.width {
                        collision_normal += {1, 0}
                    }
    
                    if collision_normal != 0 {
                        ball_dir = reflect(ball_dir, collision_normal)
                    }
    
                    if block_exists(x+int(collision_normal.x), y) {
                        collision_normal.x = 0
                    }
            
                    if block_exists(x, y+int(collision_normal.y)) {
                        collision_normal.y = 0
                    }
    
                    blocks[x][y] = false
                    row_color := row_colors[y]
                    score += block_color_scores[row_color]
                    rl.SetSoundPitch(hit_block_sound, rand.float32_range(0.8, 1.2))
                    rl.PlaySound(hit_block_sound)
                    break block_col
                }
            }
        }

        accumulated_time -= DT
    }

    blend := accumulated_time / DT
    ball_render_pos := math.lerp(prev_ball_pos, ball_pos, blend)
    paddle_render_pos_x := math.lerp(prev_paddle_pos_x, paddle_pos_x, blend)

    rl.BeginDrawing()
    rl.ClearBackground({150, 190, 220, 255})

    camera := rl.Camera2D {
        zoom = f32(rl.GetRenderHeight())/f32(SCREEN_SIZE),
    }

    rl.BeginMode2D(camera)

    rl.DrawTextureV(paddle_texture, {paddle_render_pos_x, PADDLE_POS_Y}, rl.WHITE)
    // rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255})

    rl.DrawTextureV(ball_texture, ball_render_pos-{BALL_RADIUS, BALL_RADIUS}, rl.WHITE)
    // rl.DrawCircleV(ball_pos, BALL_RADIUS, {200, 90, 20, 255})

    for x in 0..<NUM_BLOCKS_X {
        for y in 0..<NUM_BLOCKS_Y {
            if !blocks[x][y] do continue

            block_rect := calc_block_rect(x, y)

            top_left := rl.Vector2 {block_rect.x, block_rect.y}
            top_right := rl.Vector2 {block_rect.x + block_rect.width, block_rect.y}
            bottom_left := rl.Vector2 {block_rect.x, block_rect.y + block_rect.height}
            bottom_right := rl.Vector2 {block_rect.x + block_rect.width, block_rect.y + block_rect.height}
            
            rl.DrawRectangleRec(block_rect, block_color_values[row_colors[y]])
            rl.DrawLineEx(top_left, top_right, 1, {255, 255, 150, 100})
            rl.DrawLineEx(top_left, bottom_left, 1, {255, 255, 150, 100})
            rl.DrawLineEx(top_right, bottom_right, 1, {0, 0, 50, 100})
            rl.DrawLineEx(bottom_left, bottom_right, 1, {0, 0, 50, 100})
        }
    }

    score_text := fmt.ctprint(score)
    rl.DrawText(score_text, 5, 5, 10, rl.WHITE)

    if !started {
        start := fmt.ctprint("Press SPACE to Start")
        start_width := rl.MeasureText(start, 15)
        rl.DrawText(start, SCREEN_SIZE/2 - start_width/2, BALL_START_Y - 30, 15, rl.WHITE)
    } else if game_over {
        game_over_text := fmt.ctprintf("Score: %v. Reset: SPACE", score)
        game_over_text_width := rl.MeasureText(game_over_text, 15)
        rl.DrawText(game_over_text, SCREEN_SIZE/2 - game_over_text_width/2, BALL_START_Y - 30, 15, rl.WHITE)
    }

    rl.EndMode2D()

    rl.EndDrawing()

    free_all(context.temp_allocator)
}

fini :: proc() {
    rl.UnloadTexture(ball_texture)
    rl.UnloadTexture(paddle_texture)
    rl.UnloadSound(hit_block_sound)
    rl.UnloadSound(hit_paddle_sound)
    rl.UnloadSound(game_over_sound)
}

calc_block_rect :: proc(x, y: int) -> rl.Rectangle {
    return {
        f32(20 + x * BLOCK_WIDTH),
        f32(20 + y * BLOCK_HEIGHT),
        BLOCK_WIDTH, BLOCK_HEIGHT,
    }
}

block_exists :: proc(x, y: int) -> bool {
    if x < 0 || y < 0 || x >= NUM_BLOCKS_X || y >= NUM_BLOCKS_Y do return false

    return blocks[x][y]
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
    return lm.normalize(lm.reflect(dir, normal))
}