infix operator <-

func <- <T>(item: T, action: (inout T) -> Void) -> T {
    var mutableItem = item
    action(&mutableItem)
    return mutableItem
}
