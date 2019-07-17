prepare Q3 (int) as
	select s.product_id,sum(s.quantity) as quantity_sold, sum(s.price*s.quantity) as dollar_value from sale s
	where s.customer_id = $1
	group by s.customer_id, s.product_id
	order by sum(s.price) DESC;
Execute Q3 (25);