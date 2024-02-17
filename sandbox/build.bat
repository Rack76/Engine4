@ECHO OFF

SET output_name=sandbox
SET compile_flags=-vet

REM Check if the build directory exists, if not, create it
IF NOT EXIST ..\build\ (
    MKDIR ..\build\
)

ECHO Building %output_name%...
odin build .\src -debug %compile_flags% -collection:engine=../engine/ -out:../build/%output_name%.exe