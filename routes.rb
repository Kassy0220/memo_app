# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

require_relative 'memo_class'

get '/memos' do
  # メモ一覧表示
end

get '/:memo_id' do
  memos = File.open('memos.json') do |file|
    JSON.load(file)
  end
  @memo = memos.find { |memo| memo['id'] == params[:memo_id] }
  
  erb :detail
end

get '/:memo_id/edit' do
  # メモ編集ページを表示
end

patch '/:memo_id' do
  # メモ更新処理
end

delete '/:memo_id' do
  # メモ削除処理
end

get '/memos/new' do
  erb :new
end

post '/' do
  memo = Memo.new(params[:title], params[:content])
  File.open('memos.json') do |file|
    # メモ格納ファイルが空の場合は、空配列を用意する
    memo_array = JSON.load(file) || []
    memo_hash = {id: memo.id, title: memo.title, content: memo.content, created_at: memo.created_at, updated_at: memo.updated_at}
    memo_array << memo_hash
    File.open('memos.json', 'w') { |file| JSON.dump(memo_array, file) }
  end

  redirect to("/#{memo.id}")
end
