import carpenter/table
import gleam/io
import keydir
import simplifile
import store

pub fn main() {
  let new_table: table.Set(String, String) = case
    keydir.create_new_keydir("cask")
  {
    Error(_) -> panic
    Ok(new_keydir) -> new_keydir
  }

  let new_directory = simplifile.create_directory("cask")

  let new_file = simplifile.create_file("cask/file1")

  let new_store = store.Store(new_table, file: "cask/file1")

  store.insert(new_store, "Hello", "Hi")
}
