import gleam/bit_array
import gleam/result
import gleam/string

const header_size: Int = 12

pub type KeyEntry {
  KeyEntry(timestamp: Int, position: Int, total_size: Int)
}

pub fn new_key_entry(timestamp: Int, position: Int, total_size: Int) -> KeyEntry {
  KeyEntry(timestamp, position, total_size)
}

fn encode_header(timestamp: Int, key_size: Int, value_size: Int) -> BitArray {
  <<timestamp:size(32), key_size:size(32), value_size:size(32)>>
}

pub fn encode_kv(timestamp: Int, key: String, value: String) -> BitArray {
  encode_header(timestamp, string.length(key), string.length(value))
  |> bit_array.append(bit_array.from_string(key))
  |> bit_array.append(bit_array.from_string(value))
}

pub fn decode_kv(data_bytes: BitArray) -> Result(String, Nil) {
  case data_bytes {
    <<_:size(32), key_size:size(32), value_size:size(32), _>> -> {
      use value <- result.try(bit_array.slice(
        data_bytes,
        12 + key_size,
        value_size,
      ))

      bit_array.to_string(value)
    }
    _ -> Error(Nil)
  }
}
