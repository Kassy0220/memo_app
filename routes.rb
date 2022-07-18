# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
include ERB::Util

require_relative 'memo_class'

helpers do 
  def params_validation(path, title, content)
    redirect to(path) if title.empty? || content.empty?
  end

  def all_memos
    File.open('memos.json') do |file| 
      FileTest.empty?('memos.json')? nil : JSON.parse(file.read, symbolize_names: true)
    end
  end

  def find_memo(memos, id)
    memos.find { |memo| memo[:id] == id }
  end

  def save_memos(memos)
    File.open('memos.json', 'w') { |file| JSON.dump(memos, file) }
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
  params_validation("/memos/new", params[:title], params[:content])

  memo = Memo.new(params[:title], params[:content])
  File.open('memos.json') do |file|
    # メモ格納ファイルが空の場合は、空配列を用意する
    memos = FileTest.empty?('memos.json')? [] : JSON.parse(file.read, symbolize_names: true)
    memo_hash = {id: memo.id, title: memo.title, content: memo.content, created_at: memo.created_at, updated_at: memo.updated_at}
    memos << memo_hash
    save_memos(memos)
  end

  redirect to("/memos/#{memo.id}")
end

get '/memos/:id' do
  @title = 'メモ内容'
  memos = all_memos
  @memo = find_memo(memos, params[:id])

  erb @memo? :detail : :notfound
end

get '/memos/:id/edit' do
  @title = 'メモ編集'
  memos = all_memos
  @memo = find_memo(memos, params[:id])

  erb @memo? :edit : :notfound
end

patch '/memos/:id' do
  params_validation("/memos/#{params[:id]}", params[:title], params[:content])

  memos = all_memos
  memos.each do |memo|
    next unless memo[:id] == params[:id]
    memo[:title] = params[:title]
    memo[:content] = params[:content]
    memo[:updated_at] = Time.now.strftime("%F %T")
  end
  save_memos(memos)

  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  memos = all_memos
  removed_memos = memos.delete_if{ |memo| memo[:id] == params[:id]}
  save_memos(removed_memos)

  redirect to("/memos")
end

not_found do
  @title = 'Error 404 (Not Found)'
  erb :notfound
end
