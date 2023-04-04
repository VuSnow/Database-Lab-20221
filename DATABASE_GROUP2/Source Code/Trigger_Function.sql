
-- TRIGGER 

-- func and trigger to insert new row into price_history when updating sale_price of product
CREATE OR REPLACE FUNCTION fn_change_price() 
RETURNS trigger 
AS $$
BEGIN
	INSERT INTO price_history 
	VALUES (new.product_id, current_date, old.sale_price, new.sale_price);
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
	
CREATE TRIGGER change_price
AFTER UPDATE ON products
FOR EACH ROW
WHEN (new.sale_price <> old.sale_price)
EXECUTE PROCEDURE fn_change_price();
-- SELECT * FROM products;
-- UPDATE products
-- SET sale_price = 13.99
-- WHERE product_id like 'RJB-%';
-- select * from products;
-- select * from price_history;

-- CREATE OR REPLACE VIEW prod_inf AS
-- SELECT product_id, category_id, sale_price, discount_id, 
-- 	(SELECT end_date FROM discount WHERE discount.discount_id = discount_id) as end_date
-- FROM products;

--  DROP rule UpdateProdInf on products;
-- CREATE RULE UpdateProdInf AS ON UPDATE TO products
-- DO INSTEAD
-- UPDATE products SET discount_id = new.discount_id
-- WHERE current_date > (SELECT end_date FROM discount WHERE discount.discount_id = discount_id)
-- 		OR discount_id = 0;

-- function to update discount_id for all item of store

CREATE OR REPLACE FUNCTION update_discount_id(in did int)
RETURNS void AS $$
BEGIN 
	UPDATE products
	SET discount_id = did
	WHERE current_date > (SELECT end_date FROM discount WHERE discount_id = products.discount_id) 
		OR (products.discount_id = 0);
END;
$$ LANGUAGE plpgsql;

-- select update_discount_id(3);
-- select product_id, discount_id from products order by discount_id;
-- function to update discount_id for certain category_id

CREATE OR REPLACE FUNCTION update_did_by_cate(in did int, in cate_id int)
RETURNS void AS $$
BEGIN 
	UPDATE products
	SET discount_id = did
	WHERE category_id = cate_id 
		AND ((current_date > (SELECT end_date FROM discount WHERE discount_id = products.discount_id)) OR (products.discount_id is NULL));
END;
$$ LANGUAGE plpgsql
;
--  select update_did_by_cate (7, 3);
 
--  select product_id, category_id, discount_id 
--  from products
--  where category_id = 7;

-- select update_discount_id (2, 20);
-- select * from products, discount
-- where products.discount_id = discount.discount_id;

-- function and trigger to update quantity of product when import product 
CREATE OR REPLACE FUNCTION fn_import() 
RETURNS trigger 
AS $$
BEGIN
	UPDATE products
	SET quan_in_stock = quan_in_stock + new.quantity
	WHERE product_id = new.product_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
	
CREATE TRIGGER tg_import
AFTER INSERT ON product_history
FOR EACH ROW
EXECUTE PROCEDURE fn_import();

-- insert into product_history values ('CBD-black-M', '2023/02/16', 10000, 189.99, 'admin_linhcute');
-- select product_id, quan_in_stock from products where product_id = 'CBD-black-M';

-- function and trigger to update quantity of product when checking-out
CREATE OR REPLACE FUNCTION fn_check_out() 
RETURNS trigger 
AS $$
BEGIN
	UPDATE products
	SET quan_in_stock = quan_in_stock - new.quantity
	WHERE product_id = new.product_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
	
CREATE TRIGGER check_out
AFTER INSERT ON orderlines
FOR EACH ROW
EXECUTE PROCEDURE fn_check_out();

-- insert into orderlines (order_id, product_id, quantity) values (225, 'CT-striped-XXL', 81);
-- select product_id, quan_in_stock from products where product_id = 'CT-striped-XXL';

-- func and trigger to check quantity of orderline
CREATE OR REPLACE FUNCTION fn_check_quan_order()
  RETURNS TRIGGER AS $$
 DECLARE quan_stock int;
BEGIN
  quan_stock = (SELECT quan_in_stock FROM products WHERE product_id = new.product_id);
  IF NEW.quantity > quan_stock
  THEN
    RAISE EXCEPTION 'Product [id:%] is not enough to order!', NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_quan_order
BEFORE INSERT OR UPDATE ON orderlines 
FOR EACH ROW EXECUTE PROCEDURE fn_check_quan_order();

-- func and trigger to check end_date of discounts
CREATE OR REPLACE FUNCTION fn_check_date_discount()
 RETURNS TRIGGER AS $$
BEGIN
  IF NEW.end_date < NEW.begin_date
  THEN
    RAISE EXCEPTION 'Date of discount is invalid!';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_date_discount
BEFORE INSERT OR UPDATE ON discount 
FOR EACH ROW EXECUTE PROCEDURE fn_check_date_discount();

-- insert into discount values (13, 'Invalid Discount', 'Wrong', 12, '2023/02/16', '2023/02/12');
-- orderlines
 -- insert into orderlines (order_id, product_id, quantity) values (227, 'CBD-black-M', 2000000);



-- function and trigger to calculate total_amount for each orderlines

-- view

CREATE VIEW view_prod_dis AS
SELECT product_id, discount_percent, end_date 
FROM discount, products 
WHERE products.discount_id = discount.discount_id;

CREATE OR REPLACE FUNCTION fn_cal_sum_orderlines()
RETURNS trigger 
AS $$
DECLARE total decimal :=0; discount_per decimal := 0; p_price decimal := 0; 
		mtype varchar; discount_by_rank decimal := 0; cid varchar;
		orderdate date; end_date_discount date := current_date;
BEGIN
	orderdate = (SELECT order_date FROM orders WHERE order_id = new.order_id);
	cid = (SELECT customer_id FROM orders WHERE order_id = new.order_id);
	end_date_discount = coalesce(current_date, (SELECT end_date FROM view_prod_dis WHERE product_id = new.product_id));
	discount_per = coalesce(0, (SELECT discount_percent 
					FROM view_prod_dis 
					WHERE product_id = new.product_id AND orderdate <= end_date_discount));  -- check date of discount
-- 	IF orderdate > end_date_discount THEN
-- 		RAISE EXCEPTION 'Order_date: [%]  End_date: [%]  Percent_discount: [%]', orderdate, end_date_discount, discount_per;
-- 	END IF;
	p_price = (SELECT sale_price FROM products WHERE product_id = new.product_id);
	total = p_price * new.quantity;
	-- update total_amount and discount of orderlines
	UPDATE orderlines
	SET total_amount = total * (100 - discount_per) / 100,
		discount = discount_per
	WHERE product_id = new.product_id and order_id = new.order_id;
	-- orders
	mtype = (SELECT member_type FROM customers WHERE phone = cid);
	IF (mtype = 'diamond') THEN discount_by_rank = 10;
	ELSIF (mtype = 'gold') THEN discount_by_rank = 7;
	ELSIF (mtype = 'silver') THEN discount_by_rank = 5;
	END IF;
	-- may occur conflict if rank is updated before finish insert enough orderlines for each order???
	-- update total_amount, discount, and point of order
	UPDATE orders
	SET total_amount = total_amount + (total * (100 - discount_per) / 100)*(100-discount_by_rank)/100,
		discount = discount_by_rank,
		point = point + (total * (100 - discount_per) / 100)*(100-discount_by_rank)/100*0.05
	WHERE order_id = new.order_id;
	-- update point of customer
	UPDATE customers 
	SET point = point + (total * (100 - discount_per) / 100)*(100-discount_by_rank)/100*0.05 -- tich diem = 5% gia tri don hang
	WHERE phone = cid;
	-- update rank of customer
	UPDATE customers SET member_type = 'diamond' WHERE phone = cid AND point >= 5000; -- update rank
	UPDATE customers SET member_type = 'gold' WHERE phone = cid AND point >= 1000 AND point < 5000;
	UPDATE customers SET member_type = 'silver' WHERE phone = cid AND point >= 100 AND point < 1000;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cal_sum_orderlines
AFTER INSERT ON orderlines
FOR EACH ROW
EXECUTE PROCEDURE fn_cal_sum_orderlines();


-- select * from products where discount_id = 4;
-- insert into orderlines (order_id, product_id, quantity) values (11, 'KC-cream-L', 10);
-- select * from orderlines where order_id = 11 and product_id = 'KC-cream-L';

-- select product_id from products where discount_id = 6;
--select * from products where discount_id = 1;
--select * from orderlines natural join products where discount_id = 1;

-- func calculate total amount by month
-- DROP function if exists cal_sum_by_month(in char);
-- CREATE INDEX idx_date ON orders(order_date);
-- DROP INDEX idx_date;
CREATE OR REPLACE FUNCTION cal_sum_during_period(in fromDate date, toDate date)
RETURNS SETOF decimal AS $$
BEGIN 
	RETURN query 
	SELECT sum(total_amount) FROM orders 
	WHERE order_date >= fromDate AND order_date <= toDate;--to_char(order_date, 'YYYY/MM') = month_year;
END;
$$ LANGUAGE plpgsql;
 --select * from orders order by order_date;
-- EXPLAIN ANALYZE select * from cal_sum_during_period ('2020/03/01', '2022/09/30');

--CREATE OR REPLACE FUNCTION fn_find_cate (in cate_name char)
--RETURN
-- CREATE VIEW product_inf AS
-- SELECT p.product_id, p.name, p.quan_in_stock, c.name as category
-- FROM products p, category c
-- WHERE p.category_id = c.category_id;

-- SELECT * from product_inf;


-- Show history of a staff - according to staff's usernames
-- view
CREATE OR REPLACE VIEW view_staff_order AS
	SELECT 
            s.username as v_username, 
            s.first_name||' '||s.last_name AS v_name, 
            o.order_id as v_order_id, 
            o.order_date as v_order_date,
            o.total_amount as v_total_amount
   FROM staffs s, orders o
   WHERE o.staff_id = s.username;
   
CREATE OR REPLACE FUNCTION staff_history(input_username VARCHAR)
RETURNS SETOF view_staff_order
AS $$
BEGIN
   RETURN QUERY SELECT *
   FROM view_staff_order
   WHERE v_username = input_username
   ORDER BY v_order_date;
END; $$
LANGUAGE plpgsql;

-- select * from staff_history ('svallentin0');


-- view 
CREATE OR REPLACE VIEW view_staff_order_cus AS
SELECT 
			c.first_name||' '||c.last_name AS v_cus_name, 
            c.phone v_phone,
            o.order_id v_order_id, 
            o.order_date v_order_date,
            o.total_amount v_total_amount,
			s.username as v_username, 
            s.first_name||' '||s.last_name AS v_staff_name
            
   FROM staffs s, orders o, customers c
   WHERE o.staff_id = s.username
   AND o.customer_id = c.phone;

-- Show history between a period of time
CREATE OR REPLACE FUNCTION date_history(day1 DATE, day2 DATE)
RETURNS SETOF view_staff_order_cus
AS $$
BEGIN
   RETURN QUERY SELECT *
   FROM view_staff_order_cus
   WHERE v_order_date >= day1 AND v_order_date <= day2;
END; $$
LANGUAGE plpgsql;

--SELECT * FROM date_history('2021-12-08', '2021-12-30');
-- SHOW history of a customers - according to customers' phone

CREATE OR REPLACE FUNCTION cus_history(input_cus_phone CHAR(10))
RETURNS SETOF view_staff_order_cus
AS $$
BEGIN
   RETURN QUERY SELECT * 
   FROM view_staff_order_cus
   WHERE v_phone = input_cus_phone;
END; $$
LANGUAGE plpgsql;

-- SELECT * FROM cus_history('6092114493');

-- QUERY Changes in Price of a product (Query by pattern of product_id)
CREATE OR REPLACE VIEW view_prod_his AS
SELECT p.product_id as v_prod_id, p.name, h.date_in, h.old_price, h.new_price
   FROM products p, price_history h
   WHERE p.product_id = h.product_id;
   
CREATE OR REPLACE FUNCTION price_change(name text)
RETURNS SETOF view_prod_his
AS $$
DECLARE
      parttern text := name;
BEGIN 
   RETURN QUERY 
   SELECT *
   FROM view_prod_his
   WHERE v_prod_id LIKE '%'||parttern||'%'; 
END; $$
LANGUAGE plpgsql;
-- select * from price_change ('FJS');

--Staff find product of the same category (Search by category name)
-- view
CREATE VIEW view_prod_cate AS
SELECT p.product_id, p.name as v_prod_name, p.quan_in_stock, c.name as v_cate_name
   FROM products p, category c
   WHERE p.category_id = c.category_id;
   
CREATE OR REPLACE FUNCTION find_category(category text)
RETURNS SETOF view_prod_cate AS $$
DECLARE
   category_name text := category;
BEGIN
   RETURN QUERY SELECT *
   FROM view_prod_cate
   WHERE v_cate_name LIKE '%'||category_name||'%';
END; $$
LANGUAGE plpgsql;
--select * from find_category('skirt');

-- CREATE OR REPLACE FUNCTION find_category(category text)
-- RETURNS TABLE(
--    product_id VARCHAR,
--    product_name VARCHAR,
--    quantity_available INT,
--    category_name VARCHAR
-- ) AS $$
-- DECLARE
--    category_name text := category;
-- BEGIN
--    RETURN QUERY SELECT p.product_id, p.name, p.quan_in_stock, c.name
--    FROM products p, category c
--    WHERE p.category_id = c.category_id
--    AND c.name LIKE '%'||category_name||'%';
-- END; $$
-- LANGUAGE plpgsql;

--Query the money coming in and out through a period of time
CREATE OR REPLACE FUNCTION money_flow(day1 DATE, day2 DATE)
RETURNS TABLE(
      product_id VARCHAR,
      date TIMESTAMP,
      type text,
      amount NUMERIC
)
AS $$
BEGIN
   RETURN QUERY
   SELECT * FROM
   ( 
         SELECT 
            ph.product_id, 
            ph.date_in as date, 
            'OUT' as type, 
            ph.entry_price * ph.quantity as amount
         FROM product_history ph
         WHERE ph.date_in > day1
         AND ph.date_in < day2
      UNION
         SELECT
            ol.product_id,
            o.order_date as date,
            'IN' as type,
            ol.total_amount as amount
         FROM orderlines ol, orders o
         WHERE ol.order_id = o.order_id
         AND o.order_date >day1
         AND o.order_date <day2
   ) AS table1
   ORDER BY date;
END; $$
LANGUAGE plpgsql;

-- SELECT * FROM money_flow('2020-12-6', '2022-12-12');

-- Query the sum of money coming in and out in a period of time
CREATE OR REPLACE FUNCTION sum_money(day1 DATE, day2 DATE)
RETURNS TABLE(
   money_out NUMERIC,
   money_in NUMERIC
) 
AS $$
BEGIN 
   RETURN QUERY 
      WITH T1 AS (
         SELECT COALESCE(SUM(ph.entry_price * ph.quantity), 0) AS money_out 
         FROM product_history ph
         WHERE ph.date_in >= day1
         AND ph.date_in <= day2
), T2 AS (
         SELECT COALESCE(CAST(SUM(ol.total_amount) as NUMERIC), 0) as money_in
         FROM orderlines ol, orders o
         WHERE ol.order_id = o.order_id
         AND o.order_date >= day1
         AND o.order_date <= day2
)
SELECT * FROM T1 CROSS JOIN T2;
END; $$
LANGUAGE plpgsql;
--SELECT * FROM sum_money('2020-12-6', '2022-12-12');

-- query to filter the orders
DROP INDEX IF EXISTS idx_total_amount;

CREATE OR REPLACE FUNCTION filter_total_amount (in base decimal)
RETURNS SETOF orders
AS $$
BEGIN 
   RETURN QUERY 
   SELECT *
   FROM orders
   WHERE total_amount >= base; 
END; $$
LANGUAGE plpgsql;

-- SET auto_explain.log_nested_statements = ON;
-- explain analyse select * from filter_total_amount (1000);

-- ------ analyse index
-- CREATE INDEX idx ON customers (point);

-- explain select * from customers where point > 1000;

-- explain select * from customers where point = 144;

-- DROP INDEX IF EXISTS  idx;

-- select * from customers order by point desc;