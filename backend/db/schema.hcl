schema "public" {}

schema "app" {}

# ----------------
# Resources
# ----------------

table "members" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "email" {
    type = varchar(255)
    null = false
  }
  column "password_hash" {
    type = text
    null = false
  }
  column "salt" {
    type = text
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "members_email_key" {
    columns = [column.email]
  }
}

table "sessions" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "member_id" {
    type = uuid
    null = false
  }
  column "token" {
    type = text
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "sessions_token_key" {
    columns = [column.token]
  }

  foreign_key "sessions_member_id_fkey" {
    columns     = [column.member_id]
    ref_columns = [table.members.column.id]
  }
}

table "admins" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "email" {
    type = varchar(255)
    null = false
  }
  column "password_hash" {
    type = text
    null = false
  }
  column "salt" {
    type = text
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "admins_email_key" {
    columns = [column.email]
  }
}

table "admin_sessions" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "admin_id" {
    type = uuid
    null = false
  }
  column "token" {
    type = text
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "admin_sessions_token_key" {
    columns = [column.token]
  }

  foreign_key "admin_sessions_admin_id_fkey" {
    columns     = [column.admin_id]
    ref_columns = [table.admins.column.id]
  }
}

table "products" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "name" {
    type = varchar(255)
    null = false
  }
  column "price" {
    type = int
    null = false
  }
  column "description" {
    type = text
    null = false
  }

  primary_key {
    columns = [column.id]
  }
}

table "cart_items" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "member_id" {
    type = uuid
    null = false
  }
  column "product_id" {
    type = uuid
    null = false
  }
  column "quantity" {
    type = int
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  foreign_key "cart_items_member_id_fkey" {
    columns     = [column.member_id]
    ref_columns = [table.members.column.id]
  }

  foreign_key "cart_items_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.id]
  }

  unique "cart_items_member_product_key" {
    columns = [column.member_id, column.product_id]
  }
}

# ----------------
# Events
# ----------------

table "stock_movements" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "product_id" {
    type = uuid
    null = false
  }
  column "delta" {
    type = int
    null = false
  }
  column "type" {
    type = varchar(32)
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  foreign_key "stock_movements_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.id]
  }
}

table "orders" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "member_id" {
    type = uuid
    null = false
  }
  column "total_price" {
    type = int
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  foreign_key "orders_member_id_fkey" {
    columns     = [column.member_id]
    ref_columns = [table.members.column.id]
  }
}

table "order_items" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "order_id" {
    type = uuid
    null = false
  }
  column "product_id" {
    type = uuid
    null = false
  }
  column "name" {
    type = varchar(255)
    null = false
  }
  column "unit_price" {
    type = int
    null = false
  }
  column "quantity" {
    type = int
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  foreign_key "order_items_order_id_fkey" {
    columns     = [column.order_id]
    ref_columns = [table.orders.column.id]
  }

  foreign_key "order_items_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.id]
  }
}

table "payments" {
  schema = schema.app

  column "id" {
    type = uuid
    null = false
  }
  column "order_id" {
    type = uuid
    null = false
  }
  column "amount" {
    type = int
    null = false
  }
  column "created_at" {
    type = timestamp
    null = false
  }

  primary_key {
    columns = [column.id]
  }

  unique "payments_order_id_key" {
    columns = [column.order_id]
  }

  foreign_key "payments_order_id_fkey" {
    columns     = [column.order_id]
    ref_columns = [table.orders.column.id]
  }
}
