Note 1: I have used my Sales Queries from Milestone 2 to perform optimisation 

Note 2: Below are the Index statements I used for performance tuning on my queries

CREATE INDEX idx_sale ON sale (customer_id, product_id);

Note 3: Explanation
1. CREATE INDEX idx_sale ON sale (customer_id, product_id);
   On sale table indexes were created on customer_id and product_id columns because in queries "where" condition statement was used on customer_id column and "group by" statement was used on product_id and customer_id column. So if indexes where created on these columns then performance increased by a huge margin since index lookup and index scan was performed on these columns.

Note 4: Performance Measurements
Q3:
without index: 2.13ms
with index: 0.098ms

Queries Q1, Q2, Q4, Q5 and Q6 performance cannot be improved because 
a. Other than join, queries doesn't have any predicates like "where". 
b. Even on a huge data, postgresql is performing sequence scan on join operation after indexes were created on id's on which join operation was performed. 
c. Since queries has only join opertion Postgresql has to read data of each rows and the efficient way of doing this is to do full table scan since  index scan is slower than a sequential scan