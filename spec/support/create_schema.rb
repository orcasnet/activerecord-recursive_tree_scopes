class CreateSchema < ActiveRecord::Migration
  def up
    create_table :employees do |t|
      t.string  :name
      t.integer :manager_id
    end

    execute "ALTER TABLE employees ADD CONSTRAINT employees_fk_manager_id FOREIGN KEY (manager_id) REFERENCES employees (id)"
  end

  def down
    drop_table :employees
  end
end
