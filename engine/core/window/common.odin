package window

Window_Error :: union #shared_nil {
    General_Error,
    Create_Window_Error,
}


General_Error :: enum u32 {
    None = 0,
}

Position :: struct {
    x: u32,
    y: u32
}

Size :: struct {
    width:  u32,
    height: u32
}

Window_Mode :: enum u8 {
    Windowed   = 0,
    Fullscreen = 1,
    Borderless = 2
}

Window :: struct {
    title:          string,
    position:       Position,
    size:           Size,
    mode:           Window_Mode,
    minimized:      bool,
    is_open:        bool,
    event_handlers: [Event_Category]Event_Handler,
    using specific: Window_Os_Specific
}


is_size_equal :: #force_inline proc "contextless" (s1: Size, s2: Size) -> bool {
    return s1.height == s2.height && s1.width == s2.width
}