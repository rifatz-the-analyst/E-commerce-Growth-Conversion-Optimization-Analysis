CREATE TABLE products_clean AS
SELECT
	product_id id,
	CAST(created_at AS DATETIME) created_at,
	product_name
FROM products;

SELECT 
	order_item_id, 
	COUNT(*) FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

CREATE TABLE order_items_clean AS
SELECT
	order_item_id id,
	CAST(created_at AS DATETIME) created_at,
	order_id,
	product_id,
	is_primary_item,
	CAST(price_usd AS FLOAT) price_usd,
	CAST(cogs_usd AS FLOAT) cogs_usd
FROM order_items;

SELECT 
	order_id, 
	COUNT(*) FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

CREATE TABLE orders_clean AS
SELECT
	order_id id,
	CAST(created_at AS DATETIME) created_at,
	website_session_id,
	user_id,
	primary_product_id,
	items_purchased,
	CAST(price_usd AS FLOAT) price_usd,
	CAST(cogs_usd AS FLOAT) cogs_usd
FROM orders;

SELECT order_item_refund_id, COUNT(*) FROM order_item_refunds
GROUP BY order_item_refund_id
HAVING COUNT(*) > 1;

CREATE TABLE order_item_refunds_clean AS
SELECT
	order_item_refund_id id,
	CAST(created_at AS DATETIME) created_at,
	order_item_id,
	order_id,
	CAST(refund_amount_usd AS FLOAT) refund_amount_usd
FROM order_item_refunds;

SELECT 
	website_pageview_id, 
	COUNT(*) 
FROM website_pageviews
GROUP BY website_pageview_id
HAVING COUNT(*) > 1;

CREATE TABLE website_pageviews_clean AS
SELECT
	website_pageviews_id,
	CAST(created_at AS DATETIME) created_at,
	website_session_id,
	pageview_url,
	CASE WHEN pageview_url LIKE '%home%' THEN 'Landing'
			WHEN pageview_url LIKE '%lander-1%' THEN 'Landing'
			WHEN pageview_url LIKE '%lander-2%' THEN 'Landing'
			WHEN pageview_url LIKE '%lander-3%' THEN 'Landing'
			WHEN pageview_url LIKE '%lander-4%' THEN 'Landing'
			WHEN pageview_url LIKE '%lander-5%' THEN 'Landing'
		WHEN pageview_url LIKE '%products%' THEN 'Products'
		WHEN pageview_url LIKE '%mr-fuzzy%' THEN 'Item'
		WHEN pageview_url LIKE '%love-bear%' THEN 'Item'
		WHEN pageview_url LIKE '%sugar-panda%' THEN 'Item'
		WHEN pageview_url LIKE '%mini-bear%' THEN 'Item'
		WHEN pageview_url LIKE '%cart%' THEN 'Cart'
		WHEN pageview_url LIKE '%shipping%' THEN 'Shipping'
		WHEN pageview_url LIKE '%billing%' THEN 'Billing'
			WHEN pageview_url LIKE '%billing-2%' THEN 'Billing'
		WHEN pageview_url LIKE '%thank-you%' THEN 'Thank You'
	END funnel_step
FROM website_pageviews;

SELECT 
	website_sessions_id, 
	COUNT(*) FROM website_sessions
GROUP BY website_sessions_id
HAVING COUNT(*) > 1;

SELECT 
	COUNT(*) 
FROM website_sessions
WHERE utm_source IS NULL;

WITH null_check AS
	(SELECT 
		website_sessions_id,
		created_at,
		user_id,
		is_repeat_sessions,
		utm_source,
		utm_campaign,
		utm_content,
		device_type,
		CASE WHEN http_referer NOT LIKE 'http%'
				THEN replace(http_referer, http_referer,'')
			ELSE http_referer
		END http_referer_clean_1
	FROM website_sessions),
null_clean AS
	(SELECT
		website_sessions_id,
		created_at,
		user_id,
		is_repeat_sessions,
		utm_source,
		utm_campaign,
		utm_content,
		device_type,
		nullif(http_referer_clean_1,'') http_referer
	FROM null_check)
SELECT *,
CASE WHEN utm_source IS NOT NULL
		THEN 'paid'
	WHEN utm_source IS NULL AND http_referer IS NULL
		THEN 'direct/unknown'
	WHEN utm_source IS NULL AND http_referer IS NOT NULL
		THEN 'organic/referal'
END traffic
FROM null_clean;

CREATE TABLE website_sessions_clean AS
WITH null_check AS
	(SELECT 
		website_sessions_id,
		created_at,
		user_id,
		is_repeat_sessions,
		utm_source,
		utm_campaign,
		utm_content,
		device_type,
	CASE WHEN http_referer NOT LIKE 'http%'
			THEN replace(http_referer, http_referer,'')
		ELSE http_referer
	END http_referer_clean_1
	FROM website_sessions),
null_clean AS
	(SELECT
		website_sessions_id id,
		created_at,
		user_id,
		is_repeat_sessions,
		utm_source,
		utm_campaign,
		utm_content,
		device_type,
		nullif(http_referer_clean_1,'') http_referer
	FROM null_check)
SELECT 
	*,
	CASE WHEN utm_source IS NOT NULL
			THEN 'paid'
		WHEN utm_source IS NULL AND http_referer IS NULL
			THEN 'direct/unknown'
		WHEN utm_source IS NULL AND http_referer IS NOT NULL
			THEN 'organic/referal'
	END traffic
FROM null_clean;

CREATE TABLE product_detail AS
SELECT
	i.id,
	i.created_at order_date,
	i.order_id,
	i.is_primary_item,
	p.product_name,
	i.price_usd,
	i.cogs_usd,
	r.id refund_id,
	r.created_at refund_date,
	r.refund_amount_usd refund_amount,
	o.user_id,
	o.website_session_id
FROM order_items_clean i
LEFT JOIN products_clean p
ON i.product_id = p.id
LEFT JOIN orders_clean o
ON i.order_id = o.id
LEFT JOIN order_item_refunds_clean r
ON i.id = r.order_item_id;

CREATE TABLE funnel_detail AS
WITH product_agg AS
	(SELECT
        order_id,
        COUNT(*) AS total_items,
        GROUP_CONCAT(product_name SEPARATOR ', ') AS products_purchased,
        round(SUM(price_usd),2) AS product_price,
        round(SUM(cogs_usd),2) AS product_cogs
    FROM product_detail
    GROUP BY order_id)
SELECT
	wp.website_pageviews_id,
	wp.created_at session_date,
	wp.pageview_url,
	wp.funnel_step,
	s.id session_id,
	s.user_id,
	s.is_repeat_sessions,
	s.utm_source,
	s.utm_campaign,
	s.utm_content,
	s.device_type,
	s.http_referer,
	s.traffic,
	s.order_id,
	s.order_date,
	p.products_purchased,
	p.product_price,
	p.product_cogs,
	s.items_purchased,
	s.revenue,
	s.cogs,
	s.refund_amount,
	s.refund_cogs,
	s.net_revenue,
	s.profit
FROM website_pageviews_clean wp
LEFT JOIN session_detail s
ON wp.website_session_id = s.id
LEFT JOIN product_agg p
ON s.order_id = p.order_id;

CREATE TABLE session_detail AS
WITH refund_amount AS
	(SELECT
		order_id,
		round(SUM(refund_amount_usd),2) refund_amount
	FROM order_item_refunds_clean
	GROUP BY order_id),
cogs_refund AS
	(SELECT
		ir.order_id,
		round(SUM(i.cogs_usd),2) refund_cogs
	FROM order_item_refunds_clean ir
	LEFT JOIN order_items_clean i
	ON ir.order_item_id = i.id
	GROUP BY ir.order_id),
order_data AS
	(SELECT
		id order_id,
		created_at order_date,
		items_purchased,
		price_usd revenue,
		cogs_usd cogs,
		website_session_id
	FROM orders_clean)
SELECT
	ws.id,
	ws.created_at session_date,
	ws.user_id,
	ws.is_repeat_sessions,
	ws.utm_source,
	ws.utm_campaign,
	ws.utm_content,
	ws.device_type,
	ws.http_referer,
	ws.traffic,
	o.order_id,
	o.order_date,
	o.items_purchased,
	o.revenue,
	o.cogs,
	r.refund_amount,
	c.refund_cogs,
	round(CASE
		WHEN r.refund_amount IS NOT NULL
		THEN o.revenue - r.refund_amount
		ELSE o.revenue
	END,2) net_revenue,
	round(CASE
		WHEN r.refund_amount IS NOT NULL
		THEN
		round(CASE
			WHEN r.refund_amount IS NOT NULL
			THEN o.revenue - r.refund_amount
			ELSE o.revenue
		END,2) - o.cogs + c.refund_cogs
		ELSE o.revenue - o.cogs
	END, 2) as profit
FROM website_sessions_clean ws
LEFT JOIN order_data o
ON ws.id = o.website_session_id
LEFT JOIN refund_amount r
ON o.order_id = r.order_id
LEFT JOIN cogs_refund c
ON o.order_id = c.order_id;

CREATE TABLE product_funnel AS
WITH item_sessions AS
	(SELECT DISTINCT
		wp.website_session_id,
		p.id product_id,
		p.product_name
	FROM website_pageviews_clean wp
	JOIN products_clean p
	ON wp.pageview_url = concat('/', replace(replace(p.product_name,' ','-'),'.',''))
	WHERE wp.funnel_step = 'Item'
	),
session_stages AS
	(SELECT
		website_session_id,
		max(CASE
			WHEN funnel_step = 'Item'
			THEN 1 ELSE 0
			END) as item_viewed,
		max(CASE
			WHEN funnel_step = 'Cart'
			THEN 1 ELSE 0
			END) as cart_reached,
		max(CASE
			WHEN funnel_step = 'Shipping'
			THEN 1 ELSE 0
			END) as shipping_reached,
		max(CASE 
			WHEN funnel_step = 'Billing'
			THEN 1 ELSE 0
			END) as billing_reached,
		max(CASE
			WHEN funnel_step = 'Thank You'
			THEN 1 ELSE 0
			END) as purchase_completed
	FROM website_pageviews_clean
	GROUP BY website_session_id),
refund_amount AS
	(SELECT
		order_id,
		round(SUM(refund_amount_usd),2) refund_amount
	FROM order_item_refunds_clean
	GROUP BY order_id),
cogs_refund AS
	(SELECT
		ir.order_id,
		round(SUM(i.cogs_usd),2) refund_cogs
	FROM order_item_refunds_clean ir
	LEFT JOIN order_items_clean i
	ON ir.order_item_id = i.id
	GROUP BY ir.order_id),
order_data AS
	(SELECT
		id order_id,
		created_at order_date,
		primary_product_id,
		items_purchased,
		price_usd revenue,
		cogs_usd cogs,
		website_session_id
	FROM orders_clean)
SELECT
	i.website_session_id,
	ws.created_at session_date,
	ws.is_repeat_sessions,
    ws.utm_source,
    ws.utm_campaign,
    ws.utm_content,
    ws.device_type,
    ws.http_referer,
    i.product_id,
    i.product_name,
    st.item_viewed,
    st.cart_reached,
    st.shipping_reached,
    st.billing_reached,
    st.purchase_completed,
    o.order_id,
    o.order_date,
    o.primary_product_id,
    o.revenue,
    o.revenue - o.cogs + c.refund_cogs profit,
    r.refund_amount,
    c.refund_cogs,
    CASE
        WHEN o.primary_product_id = i.product_id
        THEN 1
        ELSE 0
    END AS product_purchased
FROM item_sessions i
JOIN website_sessions_clean ws
    ON i.website_session_id = ws.id
LEFT JOIN session_stages st
    ON i.website_session_id = st.website_session_id
LEFT JOIN order_data o
    ON i.website_session_id = o.website_session_id
LEFT JOIN refund_amount r
	ON o.order_id = r.order_id
LEFT JOIN cogs_refund c
	ON o.order_id = c.order_id;

CREATE TABLE landing_product AS
WITH product_agg AS (
    SELECT
        order_id,
        COUNT(*) AS total_items,
        GROUP_CONCAT(product_name SEPARATOR ', ') AS products_purchased,
        round(SUM(price_usd),2) AS product_price,
        round(SUM(cogs_usd),2) AS product_cogs
    FROM product_detail
    GROUP BY order_id
)
SELECT
    f.website_pageviews_id,
    f.session_date,
    f.pageview_url,
    f.funnel_step,
    f.session_id,
    f.utm_source,
    f.utm_campaign,
    f.device_type,
    f.traffic,
    f.items_purchased,
    f.order_id,
    f.revenue,
    f.cogs,
    f.refund_amount,
    f.refund_cogs,
    f.profit,
    pa.total_items,
    pa.products_purchased,
    pa.product_price,
    pa.product_cogs
FROM funnel_detail f
LEFT JOIN product_agg pa
    ON f.order_id = pa.order_id
WHERE funnel_step = 'Landing' and f.session_date >= '2014-08-02';