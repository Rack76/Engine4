package asset_manager

import "vendor:OpenGL"
import "core:os"
import "core:fmt"
import "core:strings"

triangle := 
[9]f32{
    -1, -1, 0,
    0, 1, 0,
    1, 0, 0,
}

@(private)
vbo : u32

@(private)
program : u32

loadMesh::proc(){
    OpenGL.GenBuffers(1, &vbo)
    OpenGL.BindBuffer(OpenGL.ARRAY_BUFFER, vbo)
    OpenGL.BufferData(OpenGL.ARRAY_BUFFER, len(triangle) * 4, rawptr(&triangle), OpenGL.STATIC_DRAW)
}

loadProgram::proc(vertexShaderFilename : string, fragmentShaderFilename : string){
    program = OpenGL.CreateProgram()

    vertexShader := loadShaderStage(OpenGL.VERTEX_SHADER, vertexShaderFilename)
    fragmentShader := loadShaderStage(OpenGL.FRAGMENT_SHADER, fragmentShaderFilename)

    OpenGL.AttachShader(program, vertexShader)
    OpenGL.AttachShader(program, fragmentShader)
    OpenGL.LinkProgram(program)
    OpenGL.UseProgram(program)

    linkStatus : i32
    OpenGL.GetProgramiv(program, OpenGL.LINK_STATUS, &linkStatus)

    infoLog : [500]u8
    infoLogp : [^]u8 = raw_data(infoLog[:])

    if linkStatus == 0 {
        OpenGL.GetProgramInfoLog(program, 500, nil, infoLogp)
        fmt.println(cstring(infoLogp))
    }
}

@(private)
loadShaderStage::proc(shaderStageType : u32, filename : string) -> u32{
    shaderStage := OpenGL.CreateShader(shaderStageType)
    bytes , success := os.read_entire_file_from_filename(filename)
    if success == false {
        fmt.println("could not load file")
    }
    shaderString := strings.clone_to_cstring(string(bytes))
    OpenGL.ShaderSource(shaderStage, 1, &shaderString, nil)
    OpenGL.CompileShader(shaderStage)
    compileStatus : i32
    OpenGL.GetShaderiv(shaderStage, OpenGL.COMPILE_STATUS, &compileStatus)

    infoLog : [500]u8
    infoLogp : [^]u8 = raw_data(infoLog[:])

    if compileStatus == 0 {
        OpenGL.GetShaderInfoLog(shaderStage, 500, nil, infoLogp)
        fmt.println(cstring(infoLogp))
    }
    return shaderStage
}

getVBO::proc() -> u32{
    return vbo
}

getProgram::proc() -> u32{
    return program
}