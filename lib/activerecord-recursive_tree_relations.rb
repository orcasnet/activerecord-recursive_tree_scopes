module RecursiveTreeRelations
  def has_tree_ancestors(ancestors_name = :ancestors, options = {})
    options[:key] ||= :parent_id
    class_eval <<-EOF
      def #{ancestors_name}
        self.class.ancestors_for(self, :#{options[:key]})
      end
    EOF
  end

  def has_tree_descendants(descendants_name = :descendants, options = {})
    options[:key] ||= :parent_id
    class_eval <<-EOF
      def #{descendants_name}
        self.class.descendants_for(self, :#{options[:key]})
      end
    EOF
  end

  def ancestors_for(instance, key)
    where("#{table_name}.id IN (#{ancestors_sql_for instance, key})").order("#{table_name}.id")
  end

  def ancestors_sql_for(instance, key)
    tree_sql =  <<-SQL
      WITH RECURSIVE ancestor_search(id, #{key}, path) AS (
          SELECT id, #{key}, ARRAY[id]
            FROM #{table_name}
            WHERE id = #{instance.id}
        UNION ALL
          SELECT #{table_name}.id, #{table_name}.#{key}, path || #{table_name}.id
            FROM #{table_name}, ancestor_search
            WHERE ancestor_search.#{key} = #{table_name}.id
        )
      SELECT id
        FROM ancestor_search
        WHERE id != #{instance.id}
        ORDER BY pathX
    SQL
    tree_sql.gsub(/\s{2,}/, ' ')
  end

  def descendants_for(instance, key)
    where("#{table_name}.id IN (#{descendants_sql_for instance, key})").order("#{table_name}.id")
  end

  def descendants_sql_for(instance, key)
    tree_sql =  <<-SQL
      WITH RECURSIVE descendants_search(id, path) AS (
          SELECT id, ARRAY[id]
          FROM #{table_name}
          WHERE id = #{instance.id}
        UNION ALL
          SELECT #{table_name}.id, path || #{table_name}.id
          FROM descendants_search
          JOIN #{table_name} ON #{table_name}.#{key} = descendants_search.id
          WHERE NOT #{table_name}.id = ANY(path)
      )
      SELECT id
        FROM descendants_search
        WHERE id != #{instance.id}
        ORDER BY pathX
    SQL
    tree_sql.gsub(/\s{2,}/, ' ')
  end
end

ActiveRecord::Base.extend RecursiveTreeRelations
