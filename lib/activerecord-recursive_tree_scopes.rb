module RecursiveTreeScopes
  module ModelMixin
    def has_ancestors(ancestors_name = :ancestors, options = {})
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
    
    def has_descendants(descendants_name = :descendants, options = {})
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
        tree_sql =  <<-SQL
          WITH RECURSIVE ancestor_search(id, #{key}, path) AS (
              SELECT id, #{key}, ARRAY[id]
                FROM #{instance.class.table_name}
                WHERE id = #{instance.id}
            UNION ALL
              SELECT #{instance.class.table_name}.id, #{instance.class.table_name}.#{key}, path || #{instance.class.table_name}.id
                FROM #{instance.class.table_name}, ancestor_search
                WHERE ancestor_search.#{key} = #{instance.class.table_name}.id
            )
          SELECT id
            FROM ancestor_search
            WHERE id != #{instance.id}
            ORDER BY path
        SQL
        tree_sql.gsub(/\s{2,}/, ' ')
      end
      
      def descendants_for(instance, key)
        instance.class.where("#{instance.class.table_name}.id IN (#{descendants_sql_for instance, key})").order("#{instance.class.table_name}.id")
      end
      
      def descendants_sql_for(instance, key)
        tree_sql =  <<-SQL
          WITH RECURSIVE descendants_search(id, path) AS (
              SELECT id, ARRAY[id]
              FROM #{instance.class.table_name}
              WHERE id = #{instance.id}
            UNION ALL
              SELECT #{instance.class.table_name}.id, path || #{instance.class.table_name}.id
              FROM descendants_search
              JOIN #{instance.class.table_name} ON #{instance.class.table_name}.#{key} = descendants_search.id
              WHERE NOT #{instance.class.table_name}.id = ANY(path)
          )
          SELECT id
            FROM descendants_search
            WHERE id != #{instance.id}
            ORDER BY path
        SQL
        tree_sql.gsub(/\s{2,}/, ' ')
      end
    end
  end
end

ActiveRecord::Base.extend RecursiveTreeScopes::ModelMixin
