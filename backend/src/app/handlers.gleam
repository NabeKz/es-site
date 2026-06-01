import app/handlers/auth
import app/handlers/cart
import app/handlers/orders
import app/handlers/products

pub type Handlers {
  Handlers(
    auth: auth.AuthHandler,
    products: products.ProductsHandler,
    cart: cart.CartHandler,
    orders: orders.OrdersHandler,
  )
}
