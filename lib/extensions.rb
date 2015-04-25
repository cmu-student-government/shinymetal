# This monkey patch courtesy of
# http://stackoverflow.com/questions/2986405/database-independant-sql-string-concatenation-in-rails
# Makes string concatenation database independent.
# Extend ActiveRecord.
module ActiveRecord
  # Extend ConnectionAdapters.
  module ConnectionAdapters
    # Extends default abstract adapter.
    class AbstractAdapter

      # Will return the given strings as a SQL concationation. By default
      # uses the SQL-92 syntax:
      #
      # @example
      #   concat('foo', 'bar') # => "foo || bar"
      # :nocov:
      # @return [String] String to be used in sqlite database query (useful for development database).
      def concat(*args)
        args * " || "
      end
      # :nocov:

    end
    
    # Extends mysql abstract adapter.
    class AbstractMysqlAdapter < AbstractAdapter

      # Will return the given strings as a SQL concationation.
      # Uses MySQL format:
      #
      # @example
      #   concat('foo', 'bar') # => "CONCAT(foo, bar)"
      # @return [String] String to be used in mysql database query (useful for staging/production database).
      # :nocov:
      def concat(*args)
        "CONCAT(#{args * ', '})"
      end
      # :nocov:

    end
  end
end
