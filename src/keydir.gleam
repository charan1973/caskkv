import carpenter/table

pub fn create_new_keydir(table_name: String) {
  table.build(table_name)
  |> table.privacy(table.Public)
  |> table.write_concurrency(table.AutoWriteConcurrency)
  |> table.read_concurrency(True)
  |> table.decentralized_counters(True)
  |> table.compression(False)
  |> table.set
}
