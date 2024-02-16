package util

getSingleton::proc($T : typeid) -> ^T{
    @(static) instance : ^T
    if instance == nil {
        instance = new(T)
        return instance
    }
    else {
        return instance
    }
}