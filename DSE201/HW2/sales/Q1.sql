select s.customer_id, sum(s.quantity) as quantity_sold, sum(s.price*s.quantity) as dollar_value from sale s
group by s.customer_id;