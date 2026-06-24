import pog
import youid/uuid

import app/handlers
import app/handlers/admin_auth
import app/handlers/auth
import app/handlers/cart
import app/handlers/orders
import app/handlers/products
import features/admins/adaptor/rdb as admins_rdb
import features/admin_sessions/adaptor/rdb as admin_sessions_rdb
import features/admin_sessions/application as admin_sessions_app
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/products/adaptor/rdb as products_rdb
import features/products/application as products_app
import features/sessions/adaptor/rdb as sessions_rdb
import features/sessions/application as sessions_app

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
    cart: cart.new(conn, find_member_id),
    orders: orders.new(
      conn,
      find_member_id,
    ),
  )
}
