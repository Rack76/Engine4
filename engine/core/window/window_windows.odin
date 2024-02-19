//+build windows
//+private
package window

import win "core:sys/windows"
import "core:runtime"

Window_Os_Specific :: struct {
    h_instance: win.HINSTANCE,
    handle:     win.HWND
}

WINDOW_RESIZED   :: 0
WINDOW_MINIMIZED :: 1
WINDOW_MAXIMIZED :: 2


_initialize_os_specific :: proc(p_window: ^Window) -> Window_Error {
    h_instance := cast(win.HINSTANCE)win.GetModuleHandleW(nil)
    if h_instance == nil {
        return Create_Window_Error(win.GetLastError())
    }

    window_class := win.WNDCLASSW {
        style         = win.CS_HREDRAW | win.CS_VREDRAW,
        lpfnWndProc   = window_callback,
        cbClsExtra    = 0,
        cbWndExtra    = 0, // TODO[Jeppe]: Look into if this should be DLGWINDOWEXTRA in case we want to display error dialog box.
        hInstance     = h_instance,
        hIcon         = nil, // TODO[Jeppe]: Add the possibility to set this.
        hCursor       = nil,
        hbrBackground = nil,
        lpszMenuName  = nil,
        lpszClassName = win.utf8_to_wstring("WindowClass") }

    if win.RegisterClassW(&window_class) == 0 {
        return Create_Window_Error(win.GetLastError())
    }

    window_handle := win.CreateWindowExW(0, 
        window_class.lpszClassName,
        win.utf8_to_wstring(p_window.title),
        win.WS_OVERLAPPEDWINDOW | win.WS_VISIBLE,
        i32(p_window.position.x), i32(p_window.position.y),
        i32(p_window.size.width), i32(p_window.size.height),
        nil,
        nil,
        h_instance,
        nil )
    
    if window_handle == nil {
        return Create_Window_Error(win.GetLastError())
    }

    win.SetWindowLongPtrW(window_handle, win.GWLP_USERDATA, cast(win.LONG_PTR)cast(uintptr)p_window)

    win.ShowWindow(window_handle, win.SW_NORMAL)

    p_window.h_instance = h_instance

    return nil
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
                trigger_event_handler(p_window, .Move, Move_Event{ new_position })


        }
    }
    return win.DefWindowProcW(window, message, wParam, lParam)
}

handle_size_event :: proc (p_window: ^Window, wParam: win.WPARAM, lParam: win.LPARAM) {
    switch wParam {
        case WINDOW_RESIZED:
            if p_window.minimized {
                p_window.minimized = false
                trigger_event_handler(p_window, .Restore, nil)
            } else {
                new_size := get_new_size(lParam)
                p_window.size = new_size
                trigger_event_handler(p_window, .Resize, Resize_Event{ new_size })
            }

        case WINDOW_MINIMIZED:
            p_window.minimized = true
            trigger_event_handler(p_window, .Minimize, nil)

        case WINDOW_MAXIMIZED:
            new_size := get_new_size(lParam)
            p_window.size = new_size
            trigger_event_handler(p_window, .Maximize, Maximize_Event{ new_size })
    }

    win.InvalidateRect(p_window.handle, nil, false)

}

get_new_size :: #force_inline proc "contextless" (lParam: win.LPARAM) -> Size {
    client_width  := u32(lParam & 0xffff)
    client_height := u32(lParam >> 16)
    return Size{ client_width, client_height }
}