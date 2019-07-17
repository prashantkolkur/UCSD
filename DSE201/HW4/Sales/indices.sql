CREATE INDEX idx_sale ON sale (customer_id, product_id);

-- Index on precomputed table
create index idx_category_customer_view on category_customer_view(CATEGORY_ID, CUSTOMER_ID);
create index idx_customer_view on customer_view(dollar_value);
create index idx_category_view on category_view(dollar_value);

