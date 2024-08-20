# frozen-string-literal: true
#
# The table_exists_caching extension adds a few methods to Sequel::Database
# that make it easy to dump information about database table_exists to a file,
# and load it from that file.  Loading table_exists information from a
# dumped file is faster than parsing it from the database, so this
# can save bootup time for applications with large numbers of table_exists.
#
# Basic usage in application code:
#
#   DB = Sequel.connect('...')
#   DB.extension :table_exists_caching
#   DB.load_table_exists_cache('/path/to/table_exists_cache.dump')
#
#   # load model files
#
# Then, whenever database indicies are modified, write a new cached
# file.  You can do that with <tt>bin/sequel</tt>'s -X option:
#
#   bin/sequel -X /path/to/table_exists_cache.dump postgres://...
#
# Alternatively, if you don't want to dump the table_exists information for
# all tables, and you don't worry about race conditions, you can
# choose to use the following in your application code:
#
#   DB = Sequel.connect('...')
#   DB.extension :table_exists_caching
#   DB.load_table_exists_cache?('/path/to/table_exists_cache.dump')
#
#   # load model files
#
#   DB.dump_table_exists_cache?('/path/to/table_exists_cache.dump')
#
# With this method, you just have to delete the table_exists dump file if
# the schema is modified, and the application will recreate it for you
# using just the tables that your models use.
#
# Note that it is up to the application to ensure that the dumped
# table_exists cache reflects the current state of the database.  Sequel
# does no checking to ensure this, as checking would take time and the
# purpose of this code is to take a shortcut.
#
# The table_exists cache is dumped in Marshal format, since it is the fastest
# and it handles all ruby objects used in the table_exists hash.  Because of this,
# you should not attempt to load from an untrusted file.
#
# Related module: Sequel::TableExistsCaching

#
module Sequel
  module TableExistsCaching
    # Set table_exists cache to the empty hash.
    def self.extended(db)
      db.instance_variable_set(:@table_exists, {})
    end
    
    # Dump the table_exists cache to the filename given in Marshal format.
    def dump_table_exists_cache(file)
      File.open(file, 'wb'){|f| f.write(Marshal.dump(@table_exists))}
      nil
    end

    # Dump the table_exists cache to the filename given unless the file
    # already exists.
    def dump_table_exists_cache?(file)
      dump_table_exists_cache(file) unless File.exist?(file)
    end

    # Replace the table_exists cache with the data from the given file, which
    # should be in Marshal format.
    def load_table_exists_cache(file)
      @table_exists = Marshal.load(File.read(file))
      nil
    end

    # Replace the table_exists cache with the data from the given file if the
    # file exists.
    def load_table_exists_cache?(file)
      load_table_exists_cache(file) if File.exist?(file)
    end

    # If no options are provided and there is cached table_exists information for
    # the table, return the cached information instead of querying the
    # database.
    def table_exists(table, opts=OPTS)
      return super unless opts.empty?

      quoted_name = literal(table)
      if v = Sequel.synchronize{@table_exists[quoted_name]}
        return v
      end

      result = super
      Sequel.synchronize{@table_exists[quoted_name] = result}
      result
    end

    private

    # Remove the table_exists cache for the given schema name
    def remove_cached_schema(table)
      k = quote_schema_table(table)
      Sequel.synchronize{@table_exists.delete(k)}
      super
    end
  end

  Database.register_extension(:table_exists_caching, TableExistsCaching)
end
