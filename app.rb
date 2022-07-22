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
    memos = []
    connection.exec('SELECT * FROM memos;') do |result|
      result.each.with_object(memos) do |row, memos|
        memos << row
      end
    end
  end

  def find_memo(memos, id)
    # TODO: SQLに書き換え
    memos.find { |memo| memo[:id] == id }
  end

  def save_memos(memo_hash)
    prepared = "INSERT INTO memos (title, content, created_at, updated_at) VALUES ($1, $2, $3, $4);"
    connection.prepare("create_memo", prepared)
    params = [memo_hash[:title], memo_hash[:content], memo_hash[:created_at], memo_hash[:updated_at]]

    connection.exec_prepared("create_memo", params)
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

  save_memos(memo_hash)

  redirect to("/memos/#{memo.id}")
end

get '/memos/:id' do
  @title = 'メモ内容'
  @memo = find_memo(all_memos, params[:id])

  erb @memo ? :detail : :notfound
end

get '/memos/:id/edit' do
  @title = 'メモ編集'
  @memo = find_memo(all_memos, params[:id])

  erb @memo ? :edit : :notfound
end

patch '/memos/:id' do
  params_validation("/memos/#{params[:id]}", params[:title], params[:content])

  memos = all_memos
  memos.each do |memo|
    next unless memo[:id] == params[:id]

    memo[:title] = params[:title]
    memo[:content] = params[:content]
    memo[:updated_at] = Time.now.strftime('%F %T')
  end
  save_memos(memos)

  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  memos = all_memos
  removed_memos = memos.delete_if { |memo| memo[:id] == params[:id] }
  save_memos(removed_memos)

  redirect to('/memos')
end

not_found do
  @title = 'Error 404 (Not Found)'
  erb :notfound
end
