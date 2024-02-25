package window

Event_Category :: enum u8 {
    Window_Event   = 0,
    Keyboard_Event = 1
}


Window_Event_Type :: enum u8 {
    Quit        = 0,
    Resize      = 1,
    Maximize    = 2,
    Minimize    = 3,
    Restore     = 4,
    Move        = 5,
}

Keyboard_Event_Type :: enum u8 {
    Key_Press   = 0,
    Key_Release = 1
}

Window_Event_Data :: union {
    Resize_Event,
    Maximize_Event,
    Move_Event
}


Resize_Event :: struct {
    size: Size
}

Maximize_Event :: struct {
    size: Size
}

Move_Event :: struct {
    position: Position
}

Window_Event_Handler :: proc(event_type: Window_Event_Type, event_data: Window_Event_Data, user_data: rawptr)

Handler :: union {
    Window_Event_Handler
}

Event_Handler :: struct {
    user_data: rawptr,
    handler: Handler
    
}