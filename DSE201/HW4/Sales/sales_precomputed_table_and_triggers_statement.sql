
drop table if exists category_customer_view cascade;
CREATE TABLE category_customer_view
(
  category_id serial NOT NULL,
  customer_id serial NOT NULL,
  quantity integer,
  dollar_value numeric 
);

CREATE OR REPLACE FUNCTION category_customer_view() RETURNS TRIGGER AS $category_customer_view$
	DECLARE c record;	
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            FOR c IN select * from customer
            LOOP
            	INSERT INTO category_customer_view values (NEW.category_id , c.customer_id, 0, 0);
           	END LOOP;
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM category_customer_view where category_customer_view.category_id=OLD.category_id;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$category_customer_view$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_category_customer_view
AFTER INSERT OR DELETE OR UPDATE ON category
    FOR EACH ROW EXECUTE PROCEDURE category_customer_view();

    
CREATE OR REPLACE FUNCTION customer_category_view() RETURNS TRIGGER AS $category_customer_view$
	DECLARE c record;	
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            FOR c IN select * from category
            LOOP
            	INSERT INTO category_customer_view values (c.category_id , NEW.customer_id, 0, 0);
           	END LOOP;
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM category_customer_view where category_customer_view.customer_id=OLD.customer_id;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$category_customer_view$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_customer_category_view
AFTER INSERT OR DELETE OR UPDATE ON customer
    FOR EACH ROW EXECUTE PROCEDURE customer_category_view();

drop table if exists customer_view cascade;
CREATE TABLE customer_view
(
  customer_id serial NOT NULL,
  quantity integer NOT NULL,
  dollar_value numeric NOT NULL
);

CREATE OR REPLACE FUNCTION customer_view_update() RETURNS TRIGGER AS $customer_view$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO customer_view values (NEW.customer_id, 0, 0);
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM customer_view where customer_view.customer_id=OLD.customer_id;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$customer_view$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_customer_view
AFTER INSERT OR DELETE ON customer
    FOR EACH ROW EXECUTE PROCEDURE customer_view_update();

CREATE OR REPLACE FUNCTION customer_view_sale_update() RETURNS TRIGGER AS $customer_view$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            UPDATE customer_view SET quantity=quantity+NEW.quantity, dollar_value=dollar_value+NEW.dollar_value
            	   WHERE customer_id=NEW.customer_id;
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE customer_view SET quantity=quantity-OLD.quantity, dollar_value=dollar_value-OLD.dollar_value
            	   WHERE customer_id=OLD.customer_id;
            RETURN NULL;
        ELSIF (TG_OP = 'UPDATE') THEN
            UPDATE customer_view SET quantity=quantity+NEW.quantity-OLD.quantity, dollar_value=dollar_value+NEW.dollar_value-OLD.dollar_value
                   WHERE customer_id=NEW.customer_id;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$customer_view$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_customer_view_sale
AFTER INSERT OR DELETE OR UPDATE ON category_customer_view
    FOR EACH ROW EXECUTE PROCEDURE customer_view_sale_update();

drop table if exists category_view cascade;
CREATE TABLE category_view
(
  category_id serial NOT NULL,
  quantity integer NOT NULL,
  dollar_value numeric NOT NULL
);

CREATE OR REPLACE FUNCTION category_view_update() RETURNS TRIGGER AS $category_view$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO category_view values (NEW.category_id, 0, 0);
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM category_view where category_view.category_id=OLD.category_id;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$category_view$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_category_view
AFTER INSERT OR DELETE ON category
    FOR EACH ROW EXECUTE PROCEDURE category_view_update();

CREATE OR REPLACE FUNCTION category_view_sale_update() RETURNS TRIGGER AS $category_view$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            UPDATE category_view SET quantity=quantity+NEW.quantity, dollar_value=dollar_value+NEW.dollar_value
            	   WHERE category_id=NEW.category_id;
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE category_view SET quantity=quantity-OLD.quantity, dollar_value=dollar_value-OLD.dollar_value
            	   WHERE category_id=OLD.category_id;
            RETURN NULL;
        ELSIF (TG_OP = 'UPDATE') THEN
            UPDATE category_view SET quantity=quantity+NEW.quantity-OLD.quantity, dollar_value=dollar_value+NEW.dollar_value-OLD.dollar_value
                   WHERE category_id=NEW.category_id;
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$category_view$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_category_view_sale
AFTER INSERT OR DELETE OR UPDATE ON category_customer_view
    FOR EACH ROW EXECUTE PROCEDURE category_view_sale_update();

CREATE OR REPLACE FUNCTION category_customer_view_sale_update() RETURNS TRIGGER AS $category_customer_view$
    BEGIN
	IF (TG_OP = 'INSERT') THEN
            UPDATE category_customer_view SET quantity=quantity+NEW.quantity, dollar_value=dollar_value+NEW.quantity*NEW.price
            	   WHERE customer_id=NEW.customer_id and category_id=(select p.category_id from product p where p.product_id=NEW.product_id);
            RETURN NULL;
        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE category_customer_view SET quantity=quantity-OLD.quantity, dollar_value=dollar_value-OLD.quantity*OLD.price
            	   WHERE customer_id=OLD.customer_id and category_id=(select p.category_id from product p where p.product_id=OLD.product_id);
            RETURN NULL;
        
        ELSIF (TG_OP = 'UPDATE') THEN
            UPDATE category_customer_view SET quantity=quantity+NEW.quantity-OLD.quantity, dollar_value=dollar_value+NEW.quantity*NEW.price-OLD.quantity*OLD.price
                   WHERE customer_id=NEW.customer_id and category_id=(select p.category_id from product p where p.product_id=NEW.product_id);
            RETURN NULL;
        END IF;
        RETURN NULL; 
    END;
$category_customer_view$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_category_customer_view_sale
AFTER INSERT OR DELETE OR UPDATE ON sale
    FOR EACH ROW EXECUTE PROCEDURE category_customer_view_sale_update();
