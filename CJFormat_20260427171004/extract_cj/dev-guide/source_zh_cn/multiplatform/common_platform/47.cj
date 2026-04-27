// specific file
package cmp

specific interface Entity {
    specific prop id: String
}

specific interface Repository<T> where T <: Entity {
    specific func save(entity: T): Unit { }
}