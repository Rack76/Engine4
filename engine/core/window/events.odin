package window


Event_Type :: enum u8 {
    Quit        = 0,
    Resize      = 1,
    Maximize    = 2,
    Minimize    = 3,
    Restore     = 4,
    Move        = 5,
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


Event_Data :: union {
    Resize_Event,
    Maximize_Event,
    Move_Event
}

Event_Handler :: struct {
    user_data: rawptr,
    handler: proc(event_data: Event_Data, user_data: rawptr)
}