@ObjCMirror
open class MyContainer <: NSObject {
       .  .  .
    public open fund addItemWithUuid(item: MyItem, uuid: NSString): Unit
    public open func itemWithUuid(uuid: NSString): ?MyItem
    public open func uuidForItem:(item: MyItem): ?NSString
    public open prop allItems: NSArray
}