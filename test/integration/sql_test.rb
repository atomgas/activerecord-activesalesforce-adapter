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

$:.unshift File.dirname(__FILE__) + '/../../lib'
require 'active_record/connection_adapters/activesalesforce_adapter'

require File.dirname(__FILE__) + '/recorded_test_case'
require 'pp'

module Salesforce
  class Contact < ActiveRecord::Base
  end
end


module Asf
  module IntegrationTests

    class SqlTest < Test::Unit::TestCase
      include RecordedTestCase

      attr_reader :contact

      def setup
        puts "\nStarting test '#{self.class.name.gsub('::', '')}.#{method_name}'"

        super

        @contact = Salesforce::Contact.new

        reset_header_options

        contact.first_name = 'DutchTestFirstName'
        contact.last_name = 'DutchTestLastName'
        contact.home_phone = '555-555-1212'
        contact.save!

        contact.reload
      end

      def teardown
        reset_header_options

        contact.destroy if contact

        super
      end

      def reset_header_options
        binding = Salesforce::Contact.connection.binding
        binding.assignment_rule_id = nil
        binding.use_default_rule = false
        binding.update_mru = false
        binding.trigger_user_email = false
      end


      def test_simple_sql_insert
        test_contact = Salesforce::Contact.create!(:first_name => "foo", :last_name => "bar")
        test_contact.reload
        assert test_contact.first_name == "foo"
        assert test_contact.last_name == "bar"
      end

      def test_simple_sql_update
        test_contact = Salesforce::Contact.create!(:first_name => "foo", :last_name => "bar")
        test_contact.reload
        test_contact.attributes = {:first_name => "abc", :last_name => "xyz"}
        test_contact.save!
        test_contact.reload
        assert test_contact.first_name == "abc"
        assert test_contact.last_name == "xyz"
      end

      def test_assignment_sql_insert
        test_contact = Salesforce::Contact.create!(:first_name => "foo=bar", :last_name => "bar=foo")
        test_contact.reload
        assert test_contact.first_name == "foo=bar"
        assert test_contact.last_name == "bar=foo"
      end

      def test_assignment_sql_update
        test_contact = Salesforce::Contact.create!(:first_name => "foo", :last_name => "bar")
        test_contact.reload
        test_contact.attributes = {:first_name => "abc=xyz", :last_name => "xyz=abc"}
        test_contact.save!
        test_contact.reload
        assert test_contact.first_name == "abc=xyz"
        assert test_contact.last_name == "xyz=abc"
      end

      def test_quoted_assignment_sql_insert
        test_contact = Salesforce::Contact.create!(:first_name => "foo='bar'", :last_name => "bar='foo'")
        test_contact.reload
        assert test_contact.first_name == "foo='bar'"
        assert test_contact.last_name == "bar='foo'"
      end

      def test_quoted_assignment_sql_update
        test_contact = Salesforce::Contact.create!(:first_name => "foo", :last_name => "bar")
        test_contact.reload
        test_contact.attributes = {:first_name => "abc='xyz'", :last_name => "xyz='abc'"}
        test_contact.save!
        test_contact.reload
        assert test_contact.first_name == "abc='xyz'"
        assert test_contact.last_name == "xyz='abc'"
      end

    end

  end
end
