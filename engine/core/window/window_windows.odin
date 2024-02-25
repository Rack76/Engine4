//+build windows
//+private
package window

import win "core:sys/windows"
import "core:runtime"

WINDOW_RESIZED   :: 0
WINDOW_MINIMIZED :: 1
WINDOW_MAXIMIZED :: 2

DEFAULT_APPLICATION_ICON :: 32512
NORMAL_SELECT_CURSOR     :: 32512

Window_Os_Specific :: struct {
    h_instance: win.HINSTANCE,
    handle:     win.HWND
}



_initialize_os_specific :: proc(p_window: ^Window) -> Window_Error {
    p_window.h_instance = cast(win.HINSTANCE)win.GetModuleHandleW(nil)
    if p_window.h_instance == nil {
        return Create_Window_Error(win.GetLastError())
    }

    // Load window Icon - TODO[Jeppe]: Allow user to choose icon
    default_application_icon := win.MAKEINTRESOURCEW(DEFAULT_APPLICATION_ICON)
    icon := win.LoadIconW(nil, default_application_icon)
    if icon == nil {
        return Create_Window_Error(win.GetLastError())
    }

    // Load window cursor
    normal_select_cursor := win.MAKEINTRESOURCEW(NORMAL_SELECT_CURSOR)
    cusor := win.LoadCursorW(nil, normal_select_cursor)
    if cusor == nil {
        return Create_Window_Error(win.GetLastError())
    }

    window_class := win.WNDCLASSW {
        style         = win.CS_DBLCLKS,
        lpfnWndProc   = window_callback,
        cbClsExtra    = 0,
        cbWndExtra    = 0,
        hInstance     = p_window.h_instance,
        hIcon         = icon,
        hCursor       = cusor,
        hbrBackground = nil,
        lpszMenuName  = nil,
        lpszClassName = win.utf8_to_wstring("hagall_window_class") }

    if win.RegisterClassW(&window_class) == 0 {
        return Create_Window_Error(win.GetLastError())
    }

    window_style    := set_window_styles()
    window_ex_style := win.WS_EX_APPWINDOW
    border_rect := win.RECT{ 0, 0, 0, 0 }

    // Fetch window border rect
    if !win.AdjustWindowRectEx(&border_rect, window_style, false, window_ex_style) {
        return Create_Window_Error(win.GetLastError())
    }

    client_position, client_size := calculate_client_dimensions(p_window, border_rect)

    p_window.handle = create_win32_window(p_window, window_style, client_position, client_size)
    if p_window.handle == nil {
        return Create_Window_Error(win.GetLastError())
    }

    win.SetWindowLongPtrW(p_window.handle, win.GWLP_USERDATA, cast(win.LONG_PTR)cast(uintptr)p_window)
    win.ShowWindow(p_window.handle, win.SW_SHOW)

    return nil
}

create_win32_window :: proc (p_window: ^Window, window_style: win.DWORD, client_position: Position, client_size: Size) -> win.HWND {
    return win.CreateWindowExW(
        win.WS_EX_APPWINDOW, 
        win.utf8_to_wstring("hagall_window_class"),
        win.utf8_to_wstring(p_window.title),
        window_style,
        i32(client_position.x), i32(client_position.y),
        i32(client_size.width), i32(client_size.height),
        nil, nil,
        p_window.h_instance,
        nil )
}

calculate_client_dimensions :: proc "contextless" (p_window: ^Window, border_rect: win.RECT) -> (Position, Size) {
    client_position := p_window.position
    client_size     := p_window.size

    client_position.x += u32(border_rect.left)
    client_position.y += u32(border_rect.top)

    client_size.width  += u32(border_rect.right)  - u32(border_rect.left)
    client_size.height += u32(border_rect.bottom) - u32(border_rect.top)
    return client_position, client_size
}


set_window_styles :: proc "contextless" () -> win.DWORD{
    window_style    := win.WS_OVERLAPPED | win.WS_SYSMENU | win.WS_CAPTION
    window_style    |= win.WS_MAXIMIZEBOX
    window_style    |= win.WS_MINIMIZEBOX
    window_style    |= win.WS_THICKFRAME
    return window_style
}

_is_open_os_specific :: proc(p_window: ^Window) -> bool {
    MESSAGES_TO_HANDLE :: 10
    message := win.MSG{}
    for i := 0; i < MESSAGES_TO_HANDLE; i += 1 {
        if win.PeekMessageW(&message, nil, 0, 0, win.PM_REMOVE) {
            if message.message == win.WM_QUIT {
                p_window.is_open = false
                return p_window.is_open
            }
            win.TranslateMessage(&message)
            win.DispatchMessageW(&message)
        } else {
            break
        }

    }

    return p_window.is_open
}


_destroy_os_specific :: proc(p_window: ^Window) {
    win.DestroyWindow(p_window.handle)
}


window_callback :: proc "stdcall" (window: win.HWND, message: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) -> win.LRESULT {
    context = runtime.default_context()
    p_window := cast(^Window)cast(uintptr)win.GetWindowLongPtrW(window, win.GWLP_USERDATA)
    if p_window != nil { 
        switch message {
            case win.WM_CLOSE:
                p_window.is_open = false
            case win.WM_DESTROY:
                win.PostQuitMessage(0)
            case win.WM_PAINT:
                win.InvalidateRect(p_window.handle, nil, false)
            case win.WM_SIZE:
                handle_size_event(p_window, wParam, lParam)
            case win.WM_MOVE:
                // TODO[Jeppe]: Is it an issue that the x or y position jumps to a large number if moved outside the screen?
                new_x := u32(lParam & 0xffff)
                new_y := u32(lParam >> 16)
                new_position := Position{ new_x, new_y }
                p_window.position = new_position
                trigger_window_event_handler(p_window, .Move, Move_Event{ new_position })


        }
    }
    return win.DefWindowProcW(window, message, wParam, lParam)
}

handle_size_event :: proc (p_window: ^Window, wParam: win.WPARAM, lParam: win.LPARAM) {
    switch wParam {
        case WINDOW_RESIZED:
            if p_window.minimized {
                p_window.minimized = false
                trigger_window_event_handler(p_window, .Restore, nil)
            } else {
                new_size := get_new_size(lParam)
                p_window.size = new_size
                trigger_window_event_handler(p_window, .Resize, Resize_Event{ new_size })
            }

        case WINDOW_MINIMIZED:
            p_window.minimized = true
            trigger_window_event_handler(p_window, .Minimize, nil)

        case WINDOW_MAXIMIZED:
            new_size := get_new_size(lParam)
            p_window.size = new_size
            trigger_window_event_handler(p_window, .Maximize, Maximize_Event{ new_size })
    }

    win.InvalidateRect(p_window.handle, nil, false)

}

get_new_size :: #force_inline proc "contextless" (lParam: win.LPARAM) -> Size {
    client_width  := u32(lParam & 0xffff)
    client_height := u32(lParam >> 16)
    return Size{ client_width, client_height }
}