# frozen_string_literal: true

require 'securerandom'

# メモのクラス
class Memo
  attr_accessor :title, :content, :updated_at
  attr_reader :id, :created_at

  def initialize(title, content)
    @id = SecureRandom.uuid
    @title = title
    @content = content
    @created_at = Time.now.strftime('%F %T')
    @updated_at = Time.now.strftime('%F %T')
  end

  def to_hash
    { id: @id, title: @title, content: @content, created_at: @created_at, updated_at: @updated_at }
  end
end
