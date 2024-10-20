import birl
import carpenter/table
import file_streams/file_open_mode
import file_streams/file_stream
import file_streams/file_stream_error
import format
import gleam/bit_array
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/result
import keydir

pub type DiskStoreError {
  KeyDirError(Nil)
  FileStreamError(file_stream_error.FileStreamError)
}

pub type DiskStore {
  DiskStore(
    file: file_stream.FileStream,
    keydir: table.Set(String, format.KeyEntry),
  )
}

pub fn main() {
  use disk_store <- result.try(new_disk_store("test.db"))

  set(disk_store, "hello", "hi")

  set(disk_store, "hello1", "hi1")

  io.debug(get(disk_store, "hello"))
}

fn new_disk_store(file_name: String) -> Result(DiskStore, DiskStoreError) {
  use new_keydir <- result.try(
    keydir.create_new_keydir(file_name) |> result.map_error(KeyDirError),
  )

  use new_file_stream <- result.try(
    file_stream.open(file_name, [file_open_mode.Append, file_open_mode.Read])
    |> result.map_error(FileStreamError),
  )

  Ok(DiskStore(file: new_file_stream, keydir: new_keydir))
}

pub fn set(
  disk_store: DiskStore,
  key: String,
  value: String,
) -> Result(Nil, DiskStoreError) {
  let timenow = birl.now() |> birl.to_unix

  let data_bytes = format.encode_kv(timenow, key, value)
  use pos <- result.try(
    file_stream.position(disk_store.file, file_stream.CurrentLocation(0))
    |> result.map_error(FileStreamError),
  )

  let key_entry =
    format.new_key_entry(timenow, pos, bit_array.byte_size(data_bytes))

  disk_store.keydir |> table.insert([#(key, key_entry)])

  file_stream.write_bytes(disk_store.file, data_bytes)
  |> result.map_error(FileStreamError)
}

pub fn get(disk_store: DiskStore, key: String) -> Result(String, DiskStoreError) {
  let key_entry = table.take(disk_store.keydir, key)

  case key_entry {
    [#(_, ke)] -> {
      use _ <- result.try(
        file_stream.position(
          disk_store.file,
          file_stream.CurrentLocation(ke.position),
        )
        |> result.map_error(FileStreamError),
      )

      use data_bytes <- result.try(
        file_stream.read_remaining_bytes(disk_store.file)
        |> result.map_error(FileStreamError),
      )

      format.decode_kv(data_bytes) |> result.map_error(KeyDirError)
    }
    _ -> Ok("")
  }
}
