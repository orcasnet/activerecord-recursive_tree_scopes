class Employee < ActiveRecord::Base
  belongs_to :manager,          class_name: 'Employee'
  has_many   :directly_managed, class_name: 'Employee', foreign_key: :manager_id

  has_ancestors   :managers, key: :manager_id
  has_descendants :managed,  key: :manager_id
end
