=begin
  ActiveSalesforce
  Copyright 2006 Doug Chasman

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
=end

require 'rubygems'
require 'test/unit'

$:.unshift File.dirname(__FILE__) + '/../../lib'
require 'active_record/connection_adapters/sql_update_statement_parser'

module Asf
  module UnitTests

    class SqlParseTest < Test::Unit::TestCase


      def test_simple_update_parse
        sql = %q{UPDATE contacts SET first_name = 'abc', last_name = 'xyz' WHERE id = '003D000000Q44bZIAR'}
        parser = ActiveSalesforce::SqlUpdateStatementParser.new

        table_name, names, values, id = parser.parse(sql)

        assert_equal 'contacts', table_name
        assert_equal ['first_name', 'last_name'], names
        assert_equal ['abc', 'xyz'], values
        assert_equal '003D000000Q44bZIAR', id
      end

      def test_quoted_assignment_update_parse
        sql = %q{UPDATE contacts SET first_name = 'abc=''xyz''', last_name = 'xyz=''abc''' WHERE id = '003D000000Q44ggIAB'}
        parser = ActiveSalesforce::SqlUpdateStatementParser.new

        table_name, names, values, id = parser.parse(sql)

        assert_equal 'contacts', table_name
        assert_equal ['first_name', 'last_name'], names
        assert_equal [%q{abc='xyz'}, %q{xyz='abc'}], values
        assert_equal '003D000000Q44ggIAB', id
      end

    end

  end
end
