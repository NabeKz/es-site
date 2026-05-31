```mermaid
erDiagram
    app_members["app.members"] {
      uuid id PK
      character_varying(255) email
      text password_hash
      text salt
    }
    app_sessions["app.sessions"] {
      uuid id PK
      uuid member_id FK
      text token
      timestamp created_at
    }
    app_products["app.products"] {
      uuid id PK
      character_varying(255) name
      integer price
      integer stock
      text description
    }
    app_cart_items["app.cart_items"] {
      uuid id PK
      uuid member_id FK
      uuid product_id FK
      integer quantity
    }
    app_orders["app.orders"] {
      uuid id PK
      uuid member_id FK
      integer total_price
      timestamp created_at
    }
    app_order_items["app.order_items"] {
      uuid id PK
      uuid order_id FK
      uuid product_id FK
      character_varying(255) name
      integer unit_price
      integer quantity
    }

    app_sessions }o--o| app_members : sessions_member_id_fkey
    app_cart_items }o--o| app_members : cart_items_member_id_fkey
    app_cart_items }o--o| app_products : cart_items_product_id_fkey
    app_orders }o--o| app_members : orders_member_id_fkey
    app_order_items }o--o| app_orders : order_items_order_id_fkey
    app_order_items }o--o| app_products : order_items_product_id_fkey
```
