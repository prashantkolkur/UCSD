select state.state_name, sum(s.quantity) as quantity_sold, sum(s.price*s.quantity) as dollar_value from sale s
inner join customer c on s.customer_id=c.customer_id
inner join state on c.state_id=state.state_id
group by state.state_name;