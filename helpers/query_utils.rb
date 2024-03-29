# frozen_string_literal: true

module QueryUtils
  def all_memos
    sql = 'SELECT * FROM memos ORDER BY id ASC;'
    connection.prepare('select', sql)

    connection.exec_prepared('select') do |result|
      result.to_a
    end
  end

  def find_memo(id)
    sql = 'SELECT * FROM memos WHERE id = $1;'
    connection.prepare('find', sql)
    params = [id]

    connection.exec_prepared('find', params) do |result|
      result.to_a.first
    end
  end

  def create_memo(memo)
    sql = 'INSERT INTO memos (title, content, created_at, updated_at) VALUES ($1, $2, $3, $4) RETURNING id;'
    connection.prepare('create', sql)
    params = [memo.title, memo.content, memo.created_at, memo.updated_at]

    connection.exec_prepared('create', params) do |result|
      # 作成したメモのIDを返す
      result.to_a.first['id'].to_i
    end
  end

  def update_memo(title, content, id)
    sql = 'UPDATE memos SET title = $1, content = $2, updated_at = $3 WHERE id = $4;'
    connection.prepare('update', sql)
    params = [title, content, Time.now.strftime('%F %T'), id]

    connection.exec_prepared('update', params)
  end

  def delete_memo(id)
    sql = 'DELETE FROM memos WHERE id = $1;'
    connection.prepare('delete', sql)
    params = [id]

    connection.exec_prepared('delete', params)
  end
end
