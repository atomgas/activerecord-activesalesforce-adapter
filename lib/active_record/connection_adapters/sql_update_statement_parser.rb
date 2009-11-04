require 'rubygems'
require 'treetop'
require File.dirname(__FILE__) + '/sql_update'

module ActiveSalesforce

  class SqlUpdateStatementParser

    def parse(sql)
      results = SqlUpdateParser.new.parse(sql)
      return unless results

      names = []
      values = []
      results.items.each do |name, value|
        names << name
        values << value.gsub(/''/, "'")
      end
      [results.table_name, names, values, results.id]
    end

  end
end

