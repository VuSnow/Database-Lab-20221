--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0
-- Dumped by pg_dump version 15.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cal_sum_during_period(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cal_sum_during_period(fromdate date, todate date) RETURNS SETOF numeric
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN query 
	SELECT sum(total_amount) FROM orders 
	WHERE order_date >= fromDate AND order_date <= toDate;--to_char(order_date, 'YYYY/MM') = month_year;
END;
$$;


ALTER FUNCTION public.cal_sum_during_period(fromdate date, todate date) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    phone character(10) NOT NULL,
    first_name character varying(25),
    last_name character varying(25),
    dob date,
    gender character varying(10),
    email character varying(50),
    address character varying(100),
    member_type character varying DEFAULT 'copper'::character varying,
    point numeric(10,2) DEFAULT 0,
    CONSTRAINT check_member_type CHECK (((member_type)::text = ANY ((ARRAY['diamond'::character varying, 'gold'::character varying, 'silver'::character varying, 'copper'::character varying])::text[])))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    order_date timestamp without time zone DEFAULT CURRENT_DATE,
    customer_id character(10),
    staff_id text,
    discount numeric(12,2) DEFAULT 0,
    total_amount numeric(12,2) DEFAULT 0,
    point numeric(10,2) DEFAULT 0,
    payment_type character varying(10),
    CONSTRAINT ct_payment_type CHECK (((payment_type)::text = ANY ((ARRAY['cash'::character varying, 'card'::character varying, 'banking'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: staffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staffs (
    username character varying NOT NULL,
    password text DEFAULT 'abc123'::text NOT NULL,
    manager_id character varying,
    permissions character varying,
    first_name character varying(25) NOT NULL,
    last_name character varying(25) NOT NULL,
    dob date,
    gender character varying(10),
    phone character(10) NOT NULL,
    email character varying(50),
    address character varying,
    hire_date date NOT NULL,
    off_date date,
    working_status character varying(10) DEFAULT 'doing'::character varying,
    CONSTRAINT check_working_status CHECK (((working_status)::text = ANY ((ARRAY['doing'::character varying, 'quit'::character varying])::text[])))
);


ALTER TABLE public.staffs OWNER TO postgres;

--
-- Name: view_staff_order_cus; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_staff_order_cus AS
 SELECT (((c.first_name)::text || ' '::text) || (c.last_name)::text) AS v_cus_name,
    c.phone AS v_phone,
    o.order_id AS v_order_id,
    o.order_date AS v_order_date,
    o.total_amount AS v_total_amount,
    s.username AS v_username,
    (((s.first_name)::text || ' '::text) || (s.last_name)::text) AS v_staff_name
   FROM public.staffs s,
    public.orders o,
    public.customers c
  WHERE ((o.staff_id = (s.username)::text) AND (o.customer_id = c.phone));


ALTER TABLE public.view_staff_order_cus OWNER TO postgres;

--
-- Name: cus_history(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cus_history(input_cus_phone character) RETURNS SETOF public.view_staff_order_cus
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY SELECT * 
   FROM view_staff_order_cus
   WHERE v_phone = input_cus_phone;
END; $$;


ALTER FUNCTION public.cus_history(input_cus_phone character) OWNER TO postgres;

--
-- Name: date_history(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.date_history(day1 date, day2 date) RETURNS SETOF public.view_staff_order_cus
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY SELECT *
   FROM view_staff_order_cus
   WHERE v_order_date >= day1 AND v_order_date <= day2;
END; $$;


ALTER FUNCTION public.date_history(day1 date, day2 date) OWNER TO postgres;

--
-- Name: filter_total_amount(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.filter_total_amount(base numeric) RETURNS SETOF public.orders
    LANGUAGE plpgsql
    AS $$
BEGIN 
   RETURN QUERY 
   SELECT *
   FROM orders
   WHERE total_amount >= base; 
END; $$;


ALTER FUNCTION public.filter_total_amount(base numeric) OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    category_id integer NOT NULL,
    name character varying(25) NOT NULL,
    description text
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id character varying(25) NOT NULL,
    name character varying(50),
    size character varying(5),
    color character varying(20),
    description text,
    category_id integer,
    sale_price numeric(10,2) NOT NULL,
    quan_in_stock integer DEFAULT 0,
    discount_id integer DEFAULT 0
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: view_prod_cate; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_prod_cate AS
 SELECT p.product_id,
    p.name AS v_prod_name,
    p.quan_in_stock,
    c.name AS v_cate_name
   FROM public.products p,
    public.category c
  WHERE (p.category_id = c.category_id);


ALTER TABLE public.view_prod_cate OWNER TO postgres;

--
-- Name: find_category(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.find_category(category text) RETURNS SETOF public.view_prod_cate
    LANGUAGE plpgsql
    AS $$
DECLARE
   category_name text := category;
BEGIN
   RETURN QUERY SELECT *
   FROM view_prod_cate
   WHERE v_cate_name LIKE '%'||category_name||'%';
END; $$;


ALTER FUNCTION public.find_category(category text) OWNER TO postgres;

--
-- Name: fn_cal_sum_orderlines(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_cal_sum_orderlines() RETURNS trigger
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.fn_cal_sum_orderlines() OWNER TO postgres;

--
-- Name: fn_change_price(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_change_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO price_history 
	VALUES (new.product_id, current_date, old.sale_price, new.sale_price);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_change_price() OWNER TO postgres;

--
-- Name: fn_check_date_discount(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_check_date_discount() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.end_date < NEW.begin_date
  THEN
    RAISE EXCEPTION 'Date of discount is invalid!';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_check_date_discount() OWNER TO postgres;

--
-- Name: fn_check_out(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_check_out() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE products
	SET quan_in_stock = quan_in_stock - new.quantity
	WHERE product_id = new.product_id;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_check_out() OWNER TO postgres;

--
-- Name: fn_check_quan_order(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_check_quan_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 DECLARE quan_stock int;
BEGIN
  quan_stock = (SELECT quan_in_stock FROM products WHERE product_id = new.product_id);
  IF NEW.quantity > quan_stock
  THEN
    RAISE EXCEPTION 'Product [id:%] is not enough to order!', NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_check_quan_order() OWNER TO postgres;

--
-- Name: fn_import(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_import() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE products
	SET quan_in_stock = quan_in_stock + new.quantity
	WHERE product_id = new.product_id;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_import() OWNER TO postgres;

--
-- Name: money_flow(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.money_flow(day1 date, day2 date) RETURNS TABLE(product_id character varying, date timestamp without time zone, type text, amount numeric)
    LANGUAGE plpgsql
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
END; $$;


ALTER FUNCTION public.money_flow(day1 date, day2 date) OWNER TO postgres;

--
-- Name: price_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_history (
    product_id character varying(25) NOT NULL,
    date_in timestamp without time zone,
    old_price numeric(10,2),
    new_price numeric(10,2) NOT NULL
);


ALTER TABLE public.price_history OWNER TO postgres;

--
-- Name: view_prod_his; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_prod_his AS
 SELECT p.product_id AS v_prod_id,
    p.name,
    h.date_in,
    h.old_price,
    h.new_price
   FROM public.products p,
    public.price_history h
  WHERE ((p.product_id)::text = (h.product_id)::text);


ALTER TABLE public.view_prod_his OWNER TO postgres;

--
-- Name: price_change(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.price_change(name text) RETURNS SETOF public.view_prod_his
    LANGUAGE plpgsql
    AS $$
DECLARE
      parttern text := name;
BEGIN 
   RETURN QUERY 
   SELECT *
   FROM view_prod_his
   WHERE v_prod_id LIKE '%'||parttern||'%'; 
END; $$;


ALTER FUNCTION public.price_change(name text) OWNER TO postgres;

--
-- Name: view_staff_order; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_staff_order AS
 SELECT s.username AS v_username,
    (((s.first_name)::text || ' '::text) || (s.last_name)::text) AS v_name,
    o.order_id AS v_order_id,
    o.order_date AS v_order_date,
    o.total_amount AS v_total_amount
   FROM public.staffs s,
    public.orders o
  WHERE (o.staff_id = (s.username)::text);


ALTER TABLE public.view_staff_order OWNER TO postgres;

--
-- Name: staff_history(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.staff_history(input_username character varying) RETURNS SETOF public.view_staff_order
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY SELECT *
   FROM view_staff_order
   WHERE v_username = input_username
   ORDER BY v_order_date;
END; $$;


ALTER FUNCTION public.staff_history(input_username character varying) OWNER TO postgres;

--
-- Name: sum_money(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sum_money(day1 date, day2 date) RETURNS TABLE(money_out numeric, money_in numeric)
    LANGUAGE plpgsql
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
END; $$;


ALTER FUNCTION public.sum_money(day1 date, day2 date) OWNER TO postgres;

--
-- Name: update_did_by_cate(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_did_by_cate(did integer, cate_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
	UPDATE products
	SET discount_id = did
	WHERE category_id = cate_id 
		AND ((current_date > (SELECT end_date FROM discount WHERE discount_id = products.discount_id)) OR (products.discount_id is NULL));
END;
$$;


ALTER FUNCTION public.update_did_by_cate(did integer, cate_id integer) OWNER TO postgres;

--
-- Name: update_discount_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_discount_id(did integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
	UPDATE products
	SET discount_id = did
	WHERE current_date > (SELECT end_date FROM discount WHERE discount_id = products.discount_id) 
		OR (products.discount_id = 0);
END;
$$;


ALTER FUNCTION public.update_discount_id(did integer) OWNER TO postgres;

--
-- Name: discount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discount (
    discount_id integer NOT NULL,
    name character varying,
    description character varying,
    discount_percent numeric NOT NULL,
    begin_date date,
    end_date date
);


ALTER TABLE public.discount OWNER TO postgres;

--
-- Name: orderlines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orderlines (
    order_id integer NOT NULL,
    product_id character varying(25) NOT NULL,
    quantity integer NOT NULL,
    total_amount numeric(12,2) DEFAULT 0,
    discount integer DEFAULT 0
);


ALTER TABLE public.orderlines OWNER TO postgres;

--
-- Name: product_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_history (
    product_id character varying(25) NOT NULL,
    date_in timestamp without time zone NOT NULL,
    quantity integer NOT NULL,
    entry_price numeric(10,2) NOT NULL,
    manager_id character varying NOT NULL
);


ALTER TABLE public.product_history OWNER TO postgres;

--
-- Name: view_prod_dis; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_prod_dis AS
 SELECT products.product_id,
    discount.discount_percent,
    discount.end_date
   FROM public.discount,
    public.products
  WHERE (products.discount_id = discount.discount_id);


ALTER TABLE public.view_prod_dis OWNER TO postgres;

--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (phone);


--
-- Name: discount discount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discount
    ADD CONSTRAINT discount_pkey PRIMARY KEY (discount_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: orderlines pk_orderlines; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderlines
    ADD CONSTRAINT pk_orderlines PRIMARY KEY (order_id, product_id);


--
-- Name: product_history pk_pro_his_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_history
    ADD CONSTRAINT pk_pro_his_id PRIMARY KEY (product_id, date_in);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: staffs staffs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT staffs_pkey PRIMARY KEY (username);


--
-- Name: orderlines cal_sum_orderlines; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER cal_sum_orderlines AFTER INSERT ON public.orderlines FOR EACH ROW EXECUTE FUNCTION public.fn_cal_sum_orderlines();


--
-- Name: products change_price; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER change_price AFTER UPDATE ON public.products FOR EACH ROW WHEN ((new.sale_price <> old.sale_price)) EXECUTE FUNCTION public.fn_change_price();


--
-- Name: discount check_date_discount; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_date_discount BEFORE INSERT OR UPDATE ON public.discount FOR EACH ROW EXECUTE FUNCTION public.fn_check_date_discount();


--
-- Name: orderlines check_out; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_out AFTER INSERT ON public.orderlines FOR EACH ROW EXECUTE FUNCTION public.fn_check_out();


--
-- Name: orderlines check_quan_order; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_quan_order BEFORE INSERT OR UPDATE ON public.orderlines FOR EACH ROW EXECUTE FUNCTION public.fn_check_quan_order();


--
-- Name: product_history tg_import; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_import AFTER INSERT ON public.product_history FOR EACH ROW EXECUTE FUNCTION public.fn_import();


--
-- Name: orderlines orderlines_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderlines
    ADD CONSTRAINT orderlines_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: orderlines orderlines_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderlines
    ADD CONSTRAINT orderlines_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(phone);


--
-- Name: orders orders_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staffs(username);


--
-- Name: price_history price_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_history
    ADD CONSTRAINT price_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: product_history product_history_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_history
    ADD CONSTRAINT product_history_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.staffs(username);


--
-- Name: product_history product_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_history
    ADD CONSTRAINT product_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id);


--
-- Name: products products_discount_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discount(discount_id);


--
-- Name: staffs st_fk_st_man; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT st_fk_st_man FOREIGN KEY (manager_id) REFERENCES public.staffs(username);


--
-- PostgreSQL database dump complete
--

