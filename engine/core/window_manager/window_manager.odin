package window_manager

import "vendor:glfw"

createWindow::proc() -> glfw.WindowHandle{
    return glfw.CreateWindow(900, 600, "window", nil, nil)
}

bringWindowToFront::proc(hd : glfw.WindowHandle) {
    glfw.MakeContextCurrent(hd)
}