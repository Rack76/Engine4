package core

import "util/ecs"
import "util"
import "../system"
import "vendor:glfw"

init::proc(){
    glfw.Init()
    setSystemInitProcs()
    setSystemRunProcs()
}

run::proc(){
    util.getSingleton(system.Renderer)^.init()

    for ;!glfw.WindowShouldClose(util.getSingleton(system.Renderer)^.window); {
        util.getSingleton(system.Renderer)^.run()
        glfw.PollEvents()
    }
}

terminate::proc(){
    glfw.Terminate()
    free(util.getSingleton(system.Renderer))
}

addRunningSystem::proc($T : typeid){
    runningSystems[0] = util.getSingleton(T)
}

@(private)
setSystemInitProcs::proc(){
    ecs.systemInitProc(util.getSingleton(system.Renderer), system.initRenderer)
}

@(private)
setSystemRunProcs::proc(){
    ecs.systemRunProc(util.getSingleton(system.Renderer), system.runRenderer)
}

@(private)
runningSystems := [1]^ecs.System{} 