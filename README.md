# ActiveRecord Recursive Tree Relations

ActiveRecord::Relations for querying tree structure ancestors and
descendants.

## Installation
Add `gem 'activerecord-recursive_tree_relations'` to your Gemfile

## Example Usage
Let's say you've got an ActiveRecord model `Employee` with attributes `id`, 
`name`, and `manager_id`. Using stock belongs_to and has_many relations it's 
easy to build a relation to an `Employee`'s manager and directly managed 
`Employee`'s.

```ruby
class Employee < ActiveRecord::Base
  belongs_to :manager,          class_name: 'Employee'
  has_many   :directly_managed, class_name: 'Employee'

  has_tree_ancestors   :managers, key: :manager_id
  has_tree_descendants :managed,  key: :manager_id
end
```

## Requirements
* ActiveRecord >= 3.0.0
* PostgreSQL >= 8.4

## Copyright

Copyright (c) 2013 John Wulff. See LICENSE.txt for
further details.
