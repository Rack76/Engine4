package ecs

systemInitProc::proc(system : ^System, procedure : proc()){
    system^.init = procedure;
}

systemRunProc::proc(system : ^System, procedure : proc()){
    system^.run = procedure;
}