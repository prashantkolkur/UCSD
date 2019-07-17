

1. sales_with_precomputed_table.sql has 
	a. Sales schema 
	b. create statement to create precomputed tables 
	c. Create trigger statements and the trigger functions 
	d. Dataset used 

2. sales_precomputed_table_trigger_statment.sql has
	a. Create trigger statements and the trigger function 
		sales_with_precomputed_table.sql already has everything. I have explicitly provided separate sql for create statement of precomputed table for reference. 

3. indices used:
	a. Indices.sql has all the indices created for sales including index on precomputed table
	b. Create index statement on precomputed table:
		create index idx_category_customer_view on category_customer_view(CATEGORY_ID, CUSTOMER_ID);
		create index idx_customer_view on customer_view(dollar_value);
		create index idx_category_view on category_view(dollar_value);

4. Original query without Precomputed table: 
explain analyze SELECT A.CATEGORY_ID, A.CUSTOMER_ID,
CASE WHEN B.QUANTITY IS NOT NULL THEN B.QUANTITY ELSE 0 END AS QUANTITY,
CASE WHEN B.DOLLAR_VALUE IS NOT NULL THEN B.DOLLAR_VALUE ELSE 0 END AS DOLLAR_VALUE
FROM
(SELECT DISTINCT CT.CATEGORY_ID,CU.CUSTOMER_ID FROM CUSTOMER CU
CROSS JOIN CATEGORY CT) A
LEFT JOIN 
(SELECT P.CATEGORY_ID,S.CUSTOMER_ID,SUM(S.QUANTITY) AS QUANTITY, SUM(S.QUANTITY*S.PRICE) AS DOLLAR_VALUE FROM SALE S
JOIN PRODUCT P ON S.PRODUCT_ID=P.PRODUCT_ID
GROUP BY S.CUSTOMER_ID,P.CATEGORY_ID) B
ON B.CATEGORY_ID=A.CATEGORY_ID AND B.CUSTOMER_ID=A.CUSTOMER_ID
WHERE 
A.CATEGORY_ID IN 
(SELECT P.CATEGORY_ID FROM SALE S
JOIN PRODUCT P ON P.PRODUCT_ID=S.PRODUCT_ID
GROUP BY P.CATEGORY_ID
ORDER BY SUM(S.QUANTITY*S.PRICE) DESC
LIMIT 20
)
AND
A.CUSTOMER_ID IN
(SELECT S.CUSTOMER_ID FROM SALE S
GROUP BY S.CUSTOMER_ID
ORDER BY SUM(S.QUANTITY*S.PRICE) DESC
LIMIT 20
);

Performance without use of Precomputed table: 28.843ms

5. NEW QUERY WITH Precomputed Table:
explain analyze SELECT A.CATEGORY_ID, A.CUSTOMER_ID, quantity, dollar_value
from category_customer_view A 
where 
A.CATEGORY_ID IN 
(SELECT B.CATEGORY_ID FROM category_view B
ORDER BY dollar_value DESC
LIMIT 20
)
AND
A.CUSTOMER_ID IN
(SELECT C.CUSTOMER_ID FROM customer_view C
ORDER BY dollar_value DESC
LIMIT 20
)

Performance with use of  Precomputed table: 2.685ms

6. Explanation:
	a. There precomputed tables are created
		1. First Precomputed table: "customer_view"
			--> This table computes total quantity and total sale (dollar_value) for each customer_id
		2. Second Precomputed table: "category_view"
			--> This table computes total quantity and total sale (dollar_value) for each category_id
		3. Third Precomputed table: "category_customer_view"
			--> This table computes total quantity and total sale (dollar_value) for each category_id and customer_id pair
	b. From customer_view table, top 20 customers are taken based on the total sale (dollar_value)
	   From category_view table, top 20 categories are taken based on the total sale (dollar_value)
	   From category_customer_view table, all the category_id and customer_id pair tuples based on top 20 customers and top 20 categories. 

NOTE:
Performance without use of Precomputed table: 28.843ms
Performance with use of  Precomputed table:   2.685ms
