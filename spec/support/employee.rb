class Employee < ActiveRecord::Base
  belongs_to :manager,          class_name: 'Employee'
  has_many   :directly_managed, class_name: 'Employee', foreign_key: :manager_id

  has_tree_ancestors   :managers, key: :manager_id
  has_tree_descendants :managed,  key: :manager_id
end
