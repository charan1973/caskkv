import carpenter/table
import gleam/bit_array
import gleam/result
import simplifile

pub type Store {
  Store(keydir: table.Set(String, String), file: String)
}

pub type DBError {
  InsertError(msg: String)
}

pub fn insert(store: Store, key: String, value: String) -> Result(Nil, DBError) {
  case
    simplifile.append_bits(to: store.file, bits: bit_array.from_string(key))
  {
    Error(_) -> {
      Result(Nil, InsertError(msg: "Write to file failed"))
    }
    Ok(_) -> todo
  }
  // store.keydir
  // |> table.insert([#(key, value)])
  // |> Ok
}

pub fn get(store: Store, key: String) -> List(#(String, String)) {
  store.keydir
  |> table.lookup(key)
}
