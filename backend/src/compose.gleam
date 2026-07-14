import pog
import youid/uuid

import app/handlers
import app/handlers/admin_auth
import app/handlers/auth
import app/handlers/cart
import app/handlers/orders
import app/handlers/products
import features/admin_sessions/adaptor/rdb as admin_sessions_rdb
import features/admin_sessions/application as admin_sessions_app
import features/admins/adaptor/rdb as admins_rdb
import features/cart/adaptor/rdb as cart_rdb
import features/cart/application as cart_app
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/orders/adaptor/rdb as orders_rdb
import features/orders/application as orders_app
import features/payments/adaptor/rdb as payments_rdb
import features/payments/application as payments_app
import features/products/adaptor/rdb as products_rdb
import features/products/application as products_app
import features/sessions/adaptor/rdb as sessions_rdb
import features/sessions/application as sessions_app
import workflows/orders as orders_workflow

pub fn build(conn: pog.Connection, pepper: String) -> handlers.Handlers {
  let find_member_id = sessions_rdb.find_member_id_by_token(conn)
  let find_admin_id = admin_sessions_rdb.find_admin_id_by_token(conn)

  handlers.Handlers(
    auth: auth.new(
      members_app.signup(
        members_rdb.save(conn),
        members_rdb.find_by_email(conn),
        pepper,
      ),
      sessions_app.login(
        members_rdb.find_by_email(conn),
        sessions_rdb.save_session(conn),
        pepper,
      ),
      sessions_app.logout(sessions_rdb.delete_session(conn)),
      sessions_app.me(find_member_id, members_rdb.find_by_id(conn)),
    ),
    admin_auth: admin_auth.new(
      admin_sessions_app.login(
        admins_rdb.find_by_email(conn),
        admin_sessions_rdb.save_session(conn),
        pepper,
      ),
      admin_sessions_app.logout(admin_sessions_rdb.delete_session(conn)),
      admin_sessions_app.me(find_admin_id, admins_rdb.find_by_id(conn)),
    ),
    products: products.new(
      find_admin_id,
      products_app.create(
        uuid.v4,
        products_rdb.save(conn),
        products_rdb.save_stock_movement(conn),
      ),
      products_app.list(products_rdb.list(conn)),
    ),
    cart: cart.new(
      find_member_id,
      cart_app.create(
        cart_rdb.save_item(conn),
        products_rdb.find_stock(conn),
        cart_rdb.find_item_by_member_product(conn),
      ),
      cart_app.update(cart_rdb.update_item(conn)),
      cart_app.delete(cart_rdb.delete_item(conn)),
      cart_rdb.find_items_by_member(conn),
    ),
    orders: orders.new(
      find_member_id,
      orders_app.accept(
        cart_rdb.find_items_by_member(conn),
        orders_rdb.save(conn),
      ),
      // 受付は同期で返す。在庫引き当て・決済・確定/補償はワークフローが行う（workflow.md）。
      // YAGNI: 決済モックの間は event_queue によるポーリングを作らず直接呼び出しにとどめる。
      orders_workflow.process(
        allocate_stock: products_rdb.allocate(conn),
        return_stock: products_rdb.return_stock(conn),
        pay: payments_app.pay(payments_rdb.save(conn)),
        confirm_order: orders_rdb.confirm(conn),
        cancel_order: orders_rdb.cancel(conn),
        clear_cart: cart_rdb.clear(conn),
      ),
    ),
  )
}
