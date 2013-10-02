module RecursiveTreeScopes
  module ModelMixin
    def has_ancestors(ancestors_name, options = {})
      if self.respond_to?(ancestors_name)
        raise ArgumentError.new("#{self} already responds to #{ancestors_name}. Please pick another name for has_ancestors scope.")
      end

      options.assert_valid_keys :key
      options[:key] ||= :parent_id

      scope ancestors_name, lambda{ |record|
        RecursiveTreeScopes::Scopes.ancestors_for(record, options[:key])
      }

      class_eval <<-EOF
        def #{ancestors_name}
          self.class.#{ancestors_name}(self)
        end
      EOF
    end

    def has_descendants(descendants_name, options = {})
      if self.respond_to?(descendants_name)
        raise ArgumentError.new("#{self} already responds to #{descendants_name}. Please pick another name for has_descendants scope.")
      end

      options[:key] ||= :parent_id

      scope descendants_name, lambda{ |record|
        RecursiveTreeScopes::Scopes.descendants_for(record, options[:key])
      }

      class_eval <<-EOF
        def #{descendants_name}
          self.class.#{descendants_name}(self)
        end
      EOF
    end
  end

  class Scopes
    class << self
      def ancestors_for(instance, key)
        instance.class.where("#{instance.class.table_name}.id IN (#{ancestors_sql_for instance, key})").order("#{instance.class.table_name}.id")
      end

      def ancestors_sql_for(instance, key)
        keys = [ key ].flatten
        tree_sql =  <<-SQL
          WITH RECURSIVE ancestor_search(id, #{keys.join ', '}, path) AS (
              SELECT id, #{keys.join ', '}, ARRAY[id]
                FROM #{instance.class.table_name}
                WHERE id = #{instance.id}
            UNION ALL
              SELECT #{instance.class.table_name}.id, #{keys.collect{|key| "#{instance.class.table_name}.#{key}" }.join ', '}, path || #{instance.class.table_name}.id
                FROM #{instance.class.table_name}, ancestor_search
                WHERE #{keys.collect{ |key| "ancestor_search.#{key} = #{instance.class.table_name}.id" }.join ' OR '}
            )
          SELECT id
            FROM ancestor_search
            WHERE id != #{instance.id}
            ORDER BY array_length(path, 1), path
        SQL
        tree_sql.gsub(/\s{2,}/, ' ')
      end

      def descendants_for(instance, key)
        instance.class.where("#{instance.class.table_name}.id IN (#{descendants_sql_for instance, key})").order("#{instance.class.table_name}.id")
      end

      def descendants_sql_for(instance, key)
        keys = [ key ].flatten
        tree_sql =  <<-SQL
          WITH RECURSIVE descendants_search(id, path) AS (
              SELECT id, ARRAY[id]
              FROM #{instance.class.table_name}
              WHERE id = #{instance.id}
            UNION ALL
              SELECT #{instance.class.table_name}.id, path || #{instance.class.table_name}.id
              FROM descendants_search
              JOIN #{instance.class.table_name}
              ON #{keys.collect{ |key| "descendants_search.id = #{instance.class.table_name}.#{key}" }.join ' OR '}
              WHERE NOT #{instance.class.table_name}.id = ANY(path)
          )
          SELECT id
            FROM descendants_search
            WHERE id != #{instance.id}
            ORDER BY array_length(path, 1), path
        SQL
        tree_sql.gsub(/\s{2,}/, ' ')
      end
    end
  end
end

ActiveRecord::Base.extend RecursiveTreeScopes::ModelMixin
