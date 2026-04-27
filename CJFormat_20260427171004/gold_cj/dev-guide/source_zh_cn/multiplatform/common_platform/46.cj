// common file
package cmp

common interface Entity {
    common prop id: String
}

common interface Repository<T> where T <: Entity {
    common func save(entity: T): Unit
}
