# ActiveRecord Recursive Tree Scopes

[![Build Status](https://travis-ci.org/jwulff/activerecord-recursive_tree_scopes.png?branch=master)](https://travis-ci.org/jwulff/activerecord-recursive_tree_scopes)
[![Code Climate](https://codeclimate.com/github/jwulff/activerecord-recursive_tree_scopes.png)](https://codeclimate.com/github/jwulff/activerecord-recursive_tree_scopes)

Using ActiveRecord scopes, recursively traverse trees using a **single SQL 
query**.

Let's say you've got an ActiveRecord model `Employee` with attributes `id`, 
`name`, and `manager_id`. Using stock belongs_to and has_many relations it's 
easy to query for an `Employee`'s manager and directly managed `Employee`'s.

```ruby
class Employee < ActiveRecord::Base
  belongs_to :manager,          class_name: 'Employee'
  has_many   :directly_managed, class_name: 'Employee', foreign_key: :manager_id
...
```

**ActiveRecord Recursive Tree Scopes** provides two scopes. These scopes, 
using a **single SQL query**, match all ancestors or descendants for a record 
in a tree.

```ruby
...
  has_ancestors   :managers, key: :manager_id
  has_descendants :managed,  key: :manager_id
end
```

## A Single Query

Yep, a single query. Thanks to PostgreSQL's [`WITH RECURSIVE`](http://www.postgresql.org/docs/9.2/static/queries-with.html)
it's possible to recursively match records in a single query.

Using the model above as an example, let's say you've got an Employee with an 
`id` of 42. Here's the SQL that would be generated for `employee.managed`
```sql
SELECT "employees".* 
FROM "employees" 
WHERE (
  employees.id IN (
    WITH RECURSIVE descendants_search(id, path) AS (
      SELECT id, ARRAY[id]
      FROM employees
      WHERE id = 42
      UNION ALL
        SELECT employees.id, path || employees.id
        FROM descendants_search
        JOIN employees
        ON employees.manager_id = descendants_search.id
        WHERE NOT employees.id = ANY(path)
    )
    SELECT id
    FROM descendants_search
    WHERE id != 42
    ORDER BY path
  )
)
ORDER BY employees.id
```


## Friendly

Go ahead, chain away:
```ruby
employee.managers.where(name: 'Bob').exists?
```
```sql
SELECT "employees".* 
FROM "employees" 
WHERE 
  "employees"."name" = 'Bob' AND 
  (
    employees.id IN (
      WITH RECURSIVE descendants_search(id, path) AS (
        SELECT id, ARRAY[id]
        FROM employees
        WHERE id = 42
        UNION ALL
          SELECT employees.id, path || employees.id
          FROM descendants_search
          JOIN employees
          ON employees.manager_id = descendants_search.id
          WHERE NOT employees.id = ANY(path)
      )
      SELECT id
      FROM descendants_search
      WHERE id != 42
      ORDER BY path
    )
  )
ORDER BY employees.id
```


## Requirements
* ActiveRecord >= 3.1.0
* PostgreSQL >= 8.4


## Installation

Add `gem 'activerecord-recursive_tree_scopes'` to your Gemfile.


## Alternatives

The [Edge](https://github.com/JackC/edge) gem is similar but makes better use 
of Arel and relations.


## Thanks

Thanks to [Joshua Davey](https://github.com/jgdavey), his 
[blog post](http://hashrocket.com/blog/posts/recursive-sql-in-activerecord) 
inspired this gem.


## Copyright

Copyright (c) 2013 John Wulff. See LICENSE.txt for
further details.
