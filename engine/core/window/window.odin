package window

import "core:log"

create_window :: proc(title := "Engine", position := Position{ 0, 0 }, size := Size{ 800, 640 }, mode: Window_Mode = .Windowed) -> (^Window, Window_Error) {
    p_window           := new(Window)
    p_window.title     = title
    p_window.position  = position
    p_window.size      = size
    p_window.mode      = mode
    p_window.minimized = false
    p_window.is_open   = true

    error := _initialize_os_specific(p_window)

    log.info("> Creating window...")
    log.infof("  => Title: %s", p_window.title)
    log.infof("  => Mode: %v", p_window.mode)
    log.infof("  => Size:  (%d, %d)", p_window.size.width, p_window.size.height)
    log.infof("  => Position: (%d, %d)", p_window.position.x, p_window.position.y)

    return p_window, error
}

is_open :: proc(p_window: ^Window) -> bool {
    return _is_open_os_specific(p_window)
}


register_event_handler :: proc "contextless" (p_window: ^Window, event_type: Event_Type, handler: proc(event_data: Event_Data, user_data: rawptr), user_data: rawptr) {
    event_handler := Event_Handler{ user_data = user_data, handler = handler }
    p_window.event_handlers[event_type] = event_handler
}

unregister_event_handler :: proc "contextless" (p_window: ^Window, event_type: Event_Type) {
    p_window.event_handlers[event_type] = {}
}

destroy_window :: proc(p_window: ^Window) {
    _destroy_os_specific(p_window)
    free(p_window)
}


@(private)
trigger_event_handler :: proc(p_window: ^Window, event_type: Event_Type, event_data: Event_Data) {
    event_handler := p_window.event_handlers[event_type]
    if event_handler.handler != nil {
        event_handler.handler(event_data, event_handler.user_data)
    }
}