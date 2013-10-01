class Person < ActiveRecord::Base
  belongs_to :mother, class_name: 'Person'
  belongs_to :father, class_name: 'Person'

  has_ancestors   :ancestors,   key: [ :mother_id, :father_id ]
  has_descendants :descendants, key: [ :mother_id, :father_id ]
end
