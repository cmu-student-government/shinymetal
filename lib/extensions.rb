# Any monkey patches go here

# Make string concatenation database independent
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter

      # Will return the given strings as a SQL concationation. By default
      # uses the SQL-92 syntax:
      #
      #   concat('foo', 'bar') -> "foo || bar"
      # :nocov:
      def concat(*args)
        args * " || "
      end
      # :nocov:

    end

    class AbstractMysqlAdapter < AbstractAdapter

      # Will return the given strings as a SQL concationation.
      # Uses MySQL format:
      #
      #   concat('foo', 'bar')  -> "CONCAT(foo, bar)"
      # :nocov:
      def concat(*args)
        "CONCAT(#{args * ', '})"
      end
      # :nocov:

    end

    class SQLServerAdapter < AbstractAdapter

      # Will return the given strings as a SQL concationation.
      # Uses MS-SQL format:
      #
      #   concat('foo', 'bar')  -> foo + bar
      # :nocov:
      def concat(*args)
        args * ' + '
      end
      # :nocov:

    end
  end
end
