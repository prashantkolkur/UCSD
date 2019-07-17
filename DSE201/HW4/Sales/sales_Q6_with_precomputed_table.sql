SELECT A.CATEGORY_ID, A.CUSTOMER_ID, quantity, dollar_value
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
);

