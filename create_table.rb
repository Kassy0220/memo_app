# frozen_string_literal: true

require 'pg'

conn = PG.connect(dbname: 'memo_app')

sql = <<SQL
  CREATE TABLE Memos
  (id serial PRIMARY KEY,
  title varchar(20) NOT NULL,
  content varchar(256) NOT NULL,
  created_at timestamp,
  updated_at timestamp);
SQL

conn.exec(sql)
