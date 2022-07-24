# frozen_string_literal: true

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def params_validation(path, title, content)
    redirect to(path) if title.empty? || content.empty?
  end

  def connection
    @connection ||= PG.connect(dbname: 'memo_app')
  end

  def find_memo(id)
    sql = 'SELECT * FROM memos WHERE id = $1;'
    connection.prepare('find', sql)
    params = [id]

    connection.exec_prepared('find', params) do |result|
      result.each.with_object([]) do |row, array|
        array << row
      end
    end
  end
end
