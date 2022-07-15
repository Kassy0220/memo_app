# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

require_relative 'memo_class'

get '/memos' do
  @memos = File.open('memos.json') { |file| JSON.parse(file.read, symbolize_names: true) }

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/' do
  memo = Memo.new(params[:title], params[:content])
  File.open('memos.json') do |file|
    # メモ格納ファイルが空の場合は、空配列を用意する
    memo_array = JSON.parse(file.read, symbolize_names: true) || []
    memo_hash = {id: memo.id, title: memo.title, content: memo.content, created_at: memo.created_at, updated_at: memo.updated_at}
    memo_array << memo_hash
    File.open('memos.json', 'w') { |file| JSON.dump(memo_array, file) }
  end

  redirect to("/memos/#{memo.id}")
end

get '/memos/:memo_id' do
  memos = File.open('memos.json') { |file| JSON.parse(file.read, symbolize_names: true) }
  @memo = memos.find { |memo| memo[:id] == params[:memo_id] }

  erb :detail
end

get '/memos/:memo_id/edit' do
  memos = File.open('memos.json') { |file| JSON.parse(file.read, symbolize_names: true) }
  @memo = memos.find { |memo| memo[:id] == params[:memo_id] }

  erb :edit
end

patch '/memos/:memo_id' do
  memos = File.open('memos.json') { |file| JSON.parse(file.read, symbolize_names: true) }
  memos.each do |memo|
    next unless memo[:id] == params[:memo_id]
    memo[:title] = params[:title]
    memo[:content] = params[:content]
    memo[:updated_at] = Time.now.strftime("%F %T")
  end
  File.open('memos.json', 'w') { |file| JSON.dump(memos, file) }

  redirect to("/memos/#{params[:memo_id]}")
end

delete '/memos/:memo_id' do
  memos = File.open('memos.json') { |file| JSON.parse(file.read, symbolize_names: true) }
  removed_memos = memos.delete_if{ |memo| memo[:id] == params[:memo_id]}
  File.open('memos.json', 'w') { |file|  JSON.dump(removed_memos, file)}

  redirect to("/memos")
end
