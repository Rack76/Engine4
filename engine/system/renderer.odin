package system

import "../core/util/ecs"
import "../core/util"
import "../core/window_manager"
import "vendor:OpenGL"
import "vendor:glfw"
import "core:c"

Renderer::struct{
    using system : ecs.System,
    window : glfw.WindowHandle
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
}

runRenderer::proc(){
    OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)
	glfw.SwapBuffers(util.getSingleton(Renderer)^.window)
}