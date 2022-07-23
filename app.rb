# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

require_relative 'memo'
require_relative 'helpers/helper'

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
  memo_id = save_memo(memo_hash)[0]['id'].to_i

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
