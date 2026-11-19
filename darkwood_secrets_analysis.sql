/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Анастасия Ш
 * Дата: 20.10.2025
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
SELECT
	COUNT(id) AS total_users,
	SUM(payer) AS pay_users,
	AVG(payer)::numeric(5, 4) AS perc_pay_users
FROM fantasy.users;
-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
SELECT
	r.race,
	SUM(u.payer) AS pay_users,
	COUNT(u.id) AS total_users,
	AVG(u.payer)::numeric(5, 4) AS perc_users
FROM fantasy.users AS u
JOIN fantasy.race AS r ON u.race_id = r.race_id
GROUP BY r.race
ORDER BY perc_users DESC;
-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
SELECT
	'все покупки' AS group_name,
	COUNT(amount) AS total_purchases,
	SUM(amount) AS sum_cost,
	MIN(amount) AS min_cost,
	MAX(amount) AS max_cost,
	AVG(amount)::numeric(8, 2) AS avg_cost,
	PERCENTILE_DISC(0.5)
	WITHIN GROUP (ORDER BY amount) AS median_cost,
	STDDEV(amount)::numeric(8, 2) AS standard_deviation
FROM fantasy.events
UNION ALL
SELECT
	'исключая нулевые покупки' AS group_name,
	COUNT(amount) AS total_purchases,
	SUM(amount) AS sum_cost,
	MIN(amount) AS min_cost,
	MAX(amount) AS max_cost,
	AVG(amount)::numeric(8, 2) AS avg_cost,
	PERCENTILE_DISC(0.5)
	WITHIN GROUP (ORDER BY amount) AS median_cost,
	STDDEV(amount)::numeric(8, 2) AS standard_deviation
FROM fantasy.events
WHERE amount > 0;
-- 2.2: Аномальные нулевые покупки:
SELECT
	COUNT(amount) FILTER(WHERE amount = 0) AS total_zero_price,
	(COUNT(amount) FILTER(WHERE amount = 0)::float/COUNT(amount))::numeric(8, 5) AS perc_zero_price
FROM fantasy.events;
-- 2.3: Популярные эпические предметы:
SELECT
	i.game_items,
	COUNT(e.transaction_id) AS total_purchase,
	(COUNT(e.transaction_id)/(SELECT COUNT(*) FROM fantasy.events WHERE amount > 0)::float)::numeric (5, 4) AS perc_sale,
	(COUNT(DISTINCT id)/(SELECT COUNT(DISTINCT id) FROM fantasy.events WHERE amount > 0)::float)::numeric (5, 4) AS perc_users
FROM fantasy.events AS e
JOIN fantasy.items AS i ON e.item_code = i.item_code
WHERE amount > 0
GROUP BY i.game_items
ORDER BY total_purchase DESC;
-- 2.4: Общее количество эпических предметов и предметов без покупок:
SELECT
	COUNT(*) AS total_items,
	COUNT(*) - (SELECT COUNT(DISTINCT item_code)
	            FROM fantasy.events
	            WHERE amount > 0) AS items_without_purchases,
	((COUNT(*) - (SELECT COUNT(DISTINCT item_code)
	              FROM fantasy.events
	              WHERE amount > 0))::numeric / COUNT(*))::numeric(5, 4) AS perc_without_purchases
FROM fantasy.items;
-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
WITH users_stat AS (
	SELECT 
		race_id,
		COUNT(id) AS total_reg_users
	FROM fantasy.users
	GROUP BY race_id
),
payer_buyer_stat AS (SELECT
		race_id,
		COUNT(id) AS total_buyer,
		AVG(payer)::numeric(5, 4) AS perc_payer_of_buyer
	FROM fantasy.users
	WHERE id IN (SELECT id FROM fantasy.events WHERE amount > 0)
	GROUP BY race_id
),
buyer_stat AS (
	SELECT
		u.race_id,
		COUNT(e.transaction_id) AS total_purchase,
		SUM(e.amount) AS sum_price
	FROM fantasy.events AS e
	JOIN fantasy.users AS u ON e.id = u.id
	WHERE amount > 0
	GROUP BY u.race_id
)
SELECT
	race,
	total_reg_users,
	total_buyer,
	(total_buyer/total_reg_users::float)::numeric(5, 4) AS perc_buyer,
	perc_payer_of_buyer,
	ROUND(total_purchase::numeric / total_buyer, 2) AS avg_purchase_per_user,
	(sum_price/total_purchase)::numeric(8, 2) AS avg_price_purchase,
	(sum_price/total_buyer)::numeric(8, 2) AS avg_sum_price
FROM buyer_stat AS bs
JOIN users_stat AS us ON bs.race_id = us.race_id
JOIN payer_buyer_stat AS pbs ON us.race_id = pbs.race_id 
JOIN fantasy.race AS r ON pbs.race_id = r.race_id;
