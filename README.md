# Breakout-Clone
An example of how you use the [Raylib WASM Template](https://github.com/Aronicu/Raylib-WASM) <br><br>
[Play it Here](https://aronicu.github.io/breakout/)

## Building

### Windows
```batch
.\build.bat
```

### WASM

#### Requirements
1. [emsdk](https://emscripten.org/docs/getting_started/downloads.html)

> [!NOTE]  
> In `build_web.bat`, you need to modify the path to where your `emsdk_env.bat` is located

```batch
.\build_web.bat

:: For running
cd build_web
python -m http.server
```


## References
* [Odin + Raylib: Breakout game from start to finish by Karl Zylinksi](https://www.youtube.com/watch?v=vfgZOEvO0kM)
* [Original Source Code](https://github.com/karl-zylinski/breakout)