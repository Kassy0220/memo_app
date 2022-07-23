# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

require_relative 'memo'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def params_validation(path, title, content)
    redirect to(path) if title.empty? || content.empty?
  end

  def connection
    @conn ||= PG.connect(dbname: 'memo_app')
  end

  def all_memos
    sql = 'SELECT * FROM memos ORDER BY id ASC;'
    connection.prepare('select', sql)

    connection.exec_prepared('select') do |result|
      result.each.with_object([]) do |row, array|
        array << row
      end
    end
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

  def save_memos(memo_hash)
    sql = 'INSERT INTO memos (title, content, created_at, updated_at) VALUES ($1, $2, $3, $4) RETURNING id;'
    connection.prepare('create', sql)
    params = [memo_hash[:title], memo_hash[:content], memo_hash[:created_at], memo_hash[:updated_at]]

    connection.exec_prepared('create', params) do |result|
      result.each.with_object([]) do |row, array|
        array << row
      end
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

get '/memos' do
  @title = 'メモ一覧'
  @memos = all_memos

  erb :index
end

get '/memos/new' do
  @title = 'メモ作成'

  erb :new
end

post '/memos' do
  params_validation('/memos/new', params[:title], params[:content])

  memo = Memo.new(params[:title], params[:content])
  memo_hash = memo.to_hash

  # 作成されたメモのIDを受け取る
  memo_id = save_memos(memo_hash)[0]['id'].to_i

  redirect to("/memos/#{memo_id}")
end

get '/memos/:id' do
  @title = 'メモ内容'
  @memo = find_memo(params[:id])[0]

  erb @memo ? :detail : :notfound
end

get '/memos/:id/edit' do
  @title = 'メモ編集'
  @memo = find_memo(params[:id])[0]

  erb @memo ? :edit : :notfound
end

patch '/memos/:id' do
  params_validation("/memos/#{params[:id]}", params[:title], params[:content])

  update_memo(params[:title], params[:content], params[:id])

  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  delete_memo(params[:id])

  redirect to('/memos')
end

not_found do
  @title = 'Error 404 (Not Found)'
  erb :notfound
end
