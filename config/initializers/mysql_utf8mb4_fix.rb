#!ruby
# config/initializers/mysql_utf8mb4_fix.rb

# this is a monkeypatch to ruby migrations since utf8mb4 (for emoji, etc)
# takes 4 bytes instead of 3 and sinced innodb has a max key length of
# 767 bytes the varchar length needs to be reduced for items with keys.

require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      NATIVE_DATABASE_TYPES[:string] = { :name => "varchar", :limit => 191 }
    end
  end
end