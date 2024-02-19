package system

import "../core/util/ecs"
import "../core/util"
import "../core/window_manager"
import "../core/asset_manager"
import "vendor:OpenGL"
import "vendor:glfw"
import "core:c"
import "core:fmt"

Renderer::struct{
    using system : ecs.System,
    window : glfw.WindowHandle,
	vao : u32
}

initRenderer::proc(){
    util.getSingleton(Renderer)^.window = window_manager.createWindow()
	if util.getSingleton(Renderer)^.window == nil {
		//Log("error")
		return
	}

	window_manager.bringWindowToFront(util.getSingleton(Renderer)^.window)

    GL_MAJOR_VERSION : c.int : 4
	GL_MINOR_VERSION :: 6
	OpenGL.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

	asset_manager.loadMesh()
	asset_manager.loadProgram("basic.vertex", "basic.fragment")
	vao := &(util.getSingleton(Renderer)^.vao)
	OpenGL.GenVertexArrays(1, vao)
	OpenGL.BindVertexArray(vao^)
	OpenGL.BindBuffer(OpenGL.ARRAY_BUFFER, asset_manager.getVBO())
	OpenGL.VertexAttribPointer(0, 3, OpenGL.FLOAT, OpenGL.FALSE, 0, 0)
    OpenGL.EnableVertexAttribArray(0)
}

runRenderer::proc(){
    OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)
	OpenGL.BindVertexArray(util.getSingleton(Renderer)^.vao)
	OpenGL.UseProgram(asset_manager.getProgram())
	OpenGL.DrawArrays(OpenGL.TRIANGLES, 0, 3)
	glfw.SwapBuffers(util.getSingleton(Renderer)^.window)
}