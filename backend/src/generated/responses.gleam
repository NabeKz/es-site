// This file is auto-generated from openapi.yaml. Do not edit manually.
import gleam/json
import youid/uuid.{type Uuid}

pub type Member {
  Member(
    id: Uuid,
    email: String,
  )
}

pub fn encode_member(value: Member) -> json.Json {
  json.object([
    #("id", json.string(uuid.to_string(value.id))),
    #("email", json.string(value.email)),
  ])
}

pub type Admin {
  Admin(
    id: Uuid,
    email: String,
  )
}

pub fn encode_admin(value: Admin) -> json.Json {
  json.object([
    #("id", json.string(uuid.to_string(value.id))),
    #("email", json.string(value.email)),
  ])
}

pub type Product {
  Product(
    id: Uuid,
    name: String,
    price: Int,
    stock: Int,
    description: String,
  )
}

pub fn encode_product(value: Product) -> json.Json {
  json.object([
    #("id", json.string(uuid.to_string(value.id))),
    #("name", json.string(value.name)),
    #("price", json.int(value.price)),
    #("stock", json.int(value.stock)),
    #("description", json.string(value.description)),
  ])
}

pub type CartItem {
  CartItem(
    id: Uuid,
    product_id: Uuid,
    name: String,
    price: Int,
    quantity: Int,
  )
}

pub fn encode_cart_item(value: CartItem) -> json.Json {
  json.object([
    #("id", json.string(uuid.to_string(value.id))),
    #("productId", json.string(uuid.to_string(value.product_id))),
    #("name", json.string(value.name)),
    #("price", json.int(value.price)),
    #("quantity", json.int(value.quantity)),
  ])
}

pub type Order {
  Order(
    id: Uuid,
    items: List(OrderItem),
    total_price: Int,
  )
}

pub fn encode_order(value: Order) -> json.Json {
  json.object([
    #("id", json.string(uuid.to_string(value.id))),
    #("items", json.array(value.items, fn(item) { encode_order_item(item) })),
    #("totalPrice", json.int(value.total_price)),
  ])
}

pub type OrderItem {
  OrderItem(
    id: Uuid,
    product_id: Uuid,
    name: String,
    unit_price: Int,
    quantity: Int,
  )
}

pub fn encode_order_item(value: OrderItem) -> json.Json {
  json.object([
    #("id", json.string(uuid.to_string(value.id))),
    #("productId", json.string(uuid.to_string(value.product_id))),
    #("name", json.string(value.name)),
    #("unitPrice", json.int(value.unit_price)),
    #("quantity", json.int(value.quantity)),
  ])
}
