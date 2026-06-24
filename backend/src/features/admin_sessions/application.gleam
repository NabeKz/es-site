import features/admin_sessions/application/command

pub type Login =
  command.Login

pub type Logout =
  command.Logout

pub type FindAdminByEmail =
  command.FindAdminByEmail

pub type SaveSession =
  command.SaveSession

pub type DeleteSession =
  command.DeleteSession

pub type FindAdminIdByToken =
  command.FindAdminIdByToken

pub type FindAdminById =
  command.FindAdminById

pub type Me =
  command.Me

pub const login = command.login

pub const logout = command.logout

pub const me = command.me
