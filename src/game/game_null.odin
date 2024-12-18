#+private
#+build freestanding
package game

import "base:runtime"

import rl "../../raylib"

@(export)
game_init :: proc "c" () {
    context = wasm_context()
    init()
}

@(export)
game_frame :: proc "c" () {
    context = wasm_context()
    frame()
}

wasm_context :: proc "contextless" () -> runtime.Context {
    c: runtime.Context = runtime.default_context()
    c.allocator = rl.MemAllocator()

    return c
}