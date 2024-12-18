@echo off

if not exist build mkdir build

set game_name=Jam.exe

pushd build
odin build ..\src\desktop -out:%game_name% -debug -vet -strict-style
popd