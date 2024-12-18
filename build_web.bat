@echo off

if not exist build_web mkdir build_web

set EMSDK_QUIET=1
call C:\SDKs\emsdk\emsdk_env.bat

pushd build_web
odin build ..\src\game -target:freestanding_wasm32 -build-mode:obj -show-system-calls
IF %ERRORLEVEL% NEQ 0 exit /b 1

set files=..\src\wasm\main_wasm.c ..\raylib\wasm\libraylib.a game.wasm.o
set flags=-sUSE_GLFW=3 -sASYNCIFY -sASSERTIONS -DPLATFORM_WEB
set mem=-sTOTAL_STACK=64MB -sINITIAL_MEMORY=128MB
set custom=--shell-file ..\src\wasm\minshell.html --preload-file ..\assets
emcc -o index.html %files% %flags% %mem% %custom%
popd
