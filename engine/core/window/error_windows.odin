//+build windows
//+private
package window

import "core:c"

// TODO[Jeppe]: When added to Odin, use them there.
ERROR_INVALID_HANDLE       :: 6    // The handle is invalid.
ERROR_NOT_ENOUGH_MEMORY    :: 8    // Not enough memory resources are available to process this command.
ERROR_CANNOT_MAKE          :: 82   // The directory or file cannot be created.
ERROR_INVALID_PARAMETER    :: 87   // The parameter is incorrect.
ERROR_MOD_NOT_FOUND        :: 126  // The specified module could not be found.
ERROR_CLASS_ALREADY_EXISTS :: 1410 // Class already exists.


// TODO[Jeppe]: Consider better enum names - more related to the functions called in create.
Create_Window_Error :: enum c.int {
    None                 = 0,
    Invalid_Handle       = ERROR_INVALID_HANDLE,
    Not_Enough_Memory    = ERROR_NOT_ENOUGH_MEMORY,
    Cannot_Make          = ERROR_CANNOT_MAKE,
    Invalid_Parameter    = ERROR_INVALID_PARAMETER,
    Module_Not_Found     = ERROR_MOD_NOT_FOUND,
    Class_Already_Exists = ERROR_CLASS_ALREADY_EXISTS
}

Poll_Event_Error :: enum c.int {
    
}