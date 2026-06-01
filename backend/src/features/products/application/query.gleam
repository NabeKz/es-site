import generated/responses.{type Product, Product}
import gleam/list
import gleam/result
import youid/uuid.{type Uuid}

pub type ProductRow {
  ProductRow(
    id: Uuid,
    name: String,
    price: Int,
    stock: Int,
    description: String,
  )
}

pub type ListAdaptor =
  fn() -> Result(List(ProductRow), String)

pub type ListProducts =
  fn() -> Result(List(Product), String)

fn to_product(row: ProductRow) -> Product {
  Product(
    id: row.id,
    name: row.name,
    price: row.price,
    stock: row.stock,
    description: row.description,
  )
}

pub fn list(adaptor: ListAdaptor) -> ListProducts {
  fn() {
    adaptor()
    |> result.map(list.map(_, to_product))
  }
}
