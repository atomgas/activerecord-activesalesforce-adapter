require 'rubygems'
require 'treetop'
require 'test/unit'

Treetop.load(File.dirname(__FILE__) + "/../../lib/active_record/connection_adapters/sql_update")
#require "../../lib/active_record/connection_adapters/sql_update"

class SqlUpdateGrammarTest < Test::Unit::TestCase

  def setup
    @parser = SqlUpdateParser.new
  end

  def test_identifier
    parse = @parser.parse('abc')
    assert parse
    assert_equal 'abc', parse.text_value
  end

  def test_text
    parse = @parser.parse("kelly''s house")
    assert parse
    assert_equal "kelly''s house", parse.text_value
  end

  def test_quoted_string
    assert_equal "123", @parser.parse("'123'").text_value
  end

  def test_quoted_string_w_embeded_quotes
    assert_equal "kelly''s", @parser.parse("'kelly''s'").text_value
  end

  def test_assignment
    parse = @parser.parse("foo='123'", :consume_all_input => false)
    assert_equal "foo", parse.key
    assert_equal "123", parse.value
  end

  def test_assignment_w_embeded_quotes
    parse = @parser.parse("foo='abc=''xyz'''")
    assert_equal "foo", parse.key
    assert_equal "abc=''xyz''", parse.value
  end

  def test_assignment_w_spaces
    parse = @parser.parse("foo = '123'")
    assert_equal "foo", parse.key
    assert_equal "123", parse.value
  end

  def test_assignment_list
    parse = @parser.parse("foo='123',bar='abc'")
    list = parse.items
    expected = {"foo" => "123", "bar" => "abc"}
    assert_equal expected, list
  end

  def test_assignment_list_w_spaces
    parse = @parser.parse("foo = '123' , bar = 'abc'")
    list = parse.items
    expected = {"foo" => "123", "bar" => "abc"}
    assert_equal expected, list
  end

  def test_assignment_list_including_values_w_quotes
    parse = @parser.parse("first_name = 'abc=''xyz''', last_name = 'xyz=''abc'''")
    list = parse.items
    expected = {"first_name" => "abc=''xyz''", "last_name" => "xyz=''abc''"}
    assert_equal expected, list
  end

  def test_longer_assignment_list
    parse = @parser.parse("foo='123',bar='abc',baz='xyz'")
    list = parse.items
    expected = {"foo" => "123", "bar" => "abc", "baz" => "xyz"}
    assert_equal expected, list
  end

  def test_simple_where_clause
    sql = "WHERE id = '003D000000Q44bZIAR'"
    parse = @parser.parse(sql)
    assert_equal '003D000000Q44bZIAR', parse.id
  end

  def test_update_statement
    sql = "UPDATE contacts SET first_name = 'abc', last_name = 'xyz' WHERE id = '003D000000Q44bZIAR'"
    parse = @parser.parse(sql)
    expected = {"first_name" => "abc", "last_name" => "xyz"}
    assert_equal expected, parse.items  
    assert_equal '003D000000Q44bZIAR', parse.id
    assert_equal 'contacts', parse.table_name
  end

  def test_complex_update_statement
    sql = "UPDATE contacts SET first_name = 'abc=''xyz''', last_name = 'xyz=''abc''' WHERE id = '003D000000Q44upIAB'"
    parse = @parser.parse(sql)
    expected = {"first_name" => "abc=''xyz''", "last_name" => "xyz=''abc''"}
    assert_equal expected, parse.items
    assert_equal '003D000000Q44upIAB', parse.id
    assert_equal 'contacts', parse.table_name
  end

end