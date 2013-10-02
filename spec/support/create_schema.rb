class CreateSchema < ActiveRecord::Migration
  def up
    create_table :employees do |t|
      t.string  :name
      t.integer :manager_id
    end

    execute "ALTER TABLE employees ADD CONSTRAINT employees_fk_manager_id FOREIGN KEY (manager_id) REFERENCES employees (id)"

    create_table :people do |t|
      t.string  :name
      t.integer :mother_id
      t.integer :father_id
    end
    
    execute "ALTER TABLE people ADD CONSTRAINT people_fk_mother_id FOREIGN KEY (mother_id) REFERENCES people (id)"
    execute "ALTER TABLE people ADD CONSTRAINT people_fk_father_id FOREIGN KEY (father_id) REFERENCES people (id)"
  end

  def down
    drop_table :employees
    drop_table :people
  end
end
