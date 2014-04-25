require_relative 'test_helper'

class SerializationTest < MiniTest::Unit::TestCase
  class Post
    include Chassis::Serializable

    attr_accessor :title

    def initialize(hash = {})
      hash.each do |key, value|
        send "#{key}=", value
      end
    end

    def marshal_dump
      { title: title }
    end

    def marshal_load(hash)
      @title = hash.fetch :title
    end
  end

  class BrokenPost
    include Chassis::Serializable
  end

  def test_round_trips_with_marshal
    post = Post.new title: 'foo'
    round_tripped = Marshal.load(Marshal.dump(post))
    assert_equal post.title, round_tripped.title
  end

  def test_round_trips_with_yaml
    post = Post.new title: 'foo'
    round_tripped = Post.from_yaml(post.to_yaml)
    assert_equal post.title, round_tripped.title
  end

  def test_round_trips_with_json
    post = Post.new title: 'foo'
    round_tripped = Post.from_json(post.to_json)
    assert_equal post.title, round_tripped.title
  end

  def test_round_trips_with_a_hash
    post = Post.new title: 'foo'
    round_tripped = Post.from_hash(post.to_hash)
    assert_equal post.title, round_tripped.title
  end

  def test_to_hash_is_implemented
    post = Post.new title: 'foo'
    assert_equal({ title: 'foo' },  post.to_hash)
  end

  def test_to_h_uses_to_hash
    post = Post.new title: 'foo'
    assert_equal post.to_hash, post.to_h
  end

  def test_fails_without_marshal_load
    error = assert_raises NotImplementedError do
      BrokenPost.from_hash({})
    end

    assert_includes error.message, 'marshal_load'
  end

  def test_fails_without_marshal_load
    error = assert_raises NotImplementedError do
      BrokenPost.new.to_hash
    end

    assert_includes error.message, 'marshal_dump'
  end
end
