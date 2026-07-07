import features/products/application/command
import features/products/application/query

pub type GenerateId =
  command.GenerateId

pub type SaveProduct =
  command.SaveProduct

pub type SaveStockMovement =
  command.SaveStockMovement

pub type Allocate =
  command.Allocate

pub type ReturnStock =
  command.ReturnStock

pub type Create =
  command.Create

pub type ListAdaptor =
  query.ListAdaptor

pub type ListProducts =
  query.ListProducts

pub const create = command.create

pub const validate = command.validate

pub const list = query.list

pub const allocate_stock = command.allocate_stock
