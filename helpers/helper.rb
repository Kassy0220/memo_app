# frozen_string_literal: true

require_relative 'query_utils'

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
end

helpers QueryUtils
