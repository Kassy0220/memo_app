# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'json'
require 'pg'

require_relative 'memo'
require_relative 'helpers/helper'

enable :sessions

get '/memos' do
  @title = 'メモ一覧'

  sql = 'SELECT * FROM memos ORDER BY id ASC;'
  connection.prepare('select', sql)

  @memos = connection.exec_prepared('select') do |result|
    result.each.with_object([]) do |row, array|
      array << row
    end
  end

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

  sql = 'INSERT INTO memos (title, content, created_at, updated_at) VALUES ($1, $2, $3, $4) RETURNING id;'
  connection.prepare('create', sql)
  parameters = [memo_hash[:title], memo_hash[:content], memo_hash[:created_at], memo_hash[:updated_at]]

  sql_result = connection.exec_prepared('create', parameters) do |result|
    result.each.with_object([]) do |row, array|
      array << row
    end
  end
  # 作成されたメモのIDを受け取る
  memo_id = sql_result[0]['id'].to_i
  flash[:success] = 'メモを作成しました'

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

  sql = 'UPDATE memos SET title = $1, content = $2, updated_at = $3 WHERE id = $4;'
  connection.prepare('update', sql)
  parameters = [params[:title], params[:content], Time.now.strftime('%F %T'), params[:id]]

  connection.exec_prepared('update', parameters)
  flash[:success] = 'メモを更新しました'

  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  sql = 'DELETE FROM memos WHERE id = $1;'
  connection.prepare('delete', sql)
  parameter = [params[:id]]

  connection.exec_prepared('delete', parameter)
  flash[:success] = 'メモを削除しました'

  redirect to('/memos')
end

not_found do
  @title = 'Error 404 (Not Found)'
  erb :notfound
end
