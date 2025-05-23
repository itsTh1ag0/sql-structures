USE some_table;
 
-- DML
-- LIKE Y REGEXP
SELECT *
FROM customers
WHERE address LIKE '%v_nu' -- LIKE === HAS
WHERE phone_number NOT LIKE '%9' OR phone_number LIKE '1%'
WHERE phone_number REGEXP 'field' --> === LIKE 'field'
REGEXP --v Operators
'ˆfield' -- MUST BEGIN
'field$' -- TIENE QUE TERMINAR CON
'fie_d' -- JUST EK CHAR
'field|value' -- MULTI-VALORES
'ˆfield|valor$|ca_po' --ˆ
'[gim]e[gim]' -- ge, ie, me OR eg, ei, em 
'[a-h]e' -- === a,b,c,d,e,g,h -> e 

-- COMPOUND JOIN
SELECT *
FROM order_items oi 
JOIN order_items_notes oin 
    ON oi.order_id = oin.order_id
    AND oi.product_id = oin.product_id;

-- JOIN SYNTAXES
-- EXPLICIT 
SELECT *
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id;
-- IMPLICIT
SELECT *
FROM orders o, customers c 
WHERE o.customer_id = c.customer_id;

-- INNER JOIN (ALL ABOVE)
-- OUTER JOIN v
SELECT
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c 
RIGHT JOIN -- OR v
LEFT JOIN orders o -- LEFT/RIGHT OUTER JOIN (Optional) 
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id, c.first_name DESC;

-- EXERCISE
SELECT
    p.product_id,
    p.name,
    oi.quantity AS volume
FROM products p 
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
ORDER BY p.product_id;

-- OUTER JOIN (between multiple tables)
SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    sh.name AS shipper
FROM customers c 
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
LEFT JOIN shippers sh 
    ON o.shipper_id = sh.shipper_id
ORDER BY c.customer_id DESC;

SELECT
    o.order_id,
    o.order_date,
    c.first_name AS customer,
    sh.name AS shipper
    os.name AS status
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
LEFT JOIN shippers sh 
    ON o.shipper_id = sh.shipper_id
JOIN order_statuses os 
    ON o.status = os.order_status_id;

-- SELF OUTER JOINS
USE sql_hr;

SELECT
    e.employee_id,
    e.first_name,
    m.first_name AS manager
FROM employees e 
LEFT JOIN employess m 
    ON e.reports_to = m.employee_id;

-- The USING Clause (function)
SELECT 
    o.order_id,
    c.first_name,
    sh.name AS shipper
FROM orders o 
JOIN customers c 
    -- ON o.customer_id = c.customer_id
    USING (customer_id) -- <
LEFT JOIN shippers sh
    USING (shipper_id);

-- COMPOSE KEY JOINING
SELECT *
FROM order_items oi 
JOIN order_item_notes oin 
    ON oi.order_id = oin.order_id
    AND oi.product_id = oin.product_id
    -- ||
    USING (order_id, product_id);

-- NATURAL JOINS
SELECT
    o.order_id,
    c.first_name
FROM orders o 
NATURAL JOIN customers c; --1st equal column-name

-- CROSS JOINS
SELECT
    c.first_name AS customer,
    p.name AS product 
FROM customers c, products p -- implicit
CROSS JOIN products p -- explicit
ORDER BY c.first_name ASC;

-- UNIONS (row/query-joining)
SELECT 
    order_id, 
    oder_date,
    'Active' AS status 
FROM orders 
WHERE order_date >= '2019-01-01'
UNION -- <
SELECT 
    order_id, 
    oder_date,
    'Archived' AS status 
FROM orders 
WHERE order_date < '2019-01-01';

-- DDL
-- Data-Types (INT, DECIMAL, CHAR, VARCHAR, DATE...)
-- Column-Attributes (NN, AI, PK-FK, Default, UQ)

-- INSERT 
INSERT INTO 
customers (customer_id, first_name, age, birthday, orders)
VALUES 
(DEFAULT, 'John', 69, '2025-01-01', NULL), -- < Multi-row
(DEFAULT, 'Raul', 96, '2024-01-01', NULL);

-- Hierarchically INSERT (Multi-table)
INSERT INTO orders (customer_id, order_date, status)
VALUE (1, '2025-01-02');
-- ^v child-insert
INSERT INTO order_items (order_id, item_id, qtd, price)
VALUES
    (LAST_INSERT_ID(), 1, 1, 2.95),
    (LAST_INSERT_ID(), 3, 2, 3.95);

-- Creando O copiando un imaje de una tabla
CREATE TABLE orders_arquived AS -- Creating 
INSERT INTO orders_arquived -- Copying
--v
SELECT * FROM orders
WHERE order_date < '2024-05-01'; -- appended-query
-- Viene sin clave primaria
-- Truncate DB === purge all data

-- CREATE+JOIN+FILTER
USE sql_invoicing;
CREATE TABLE invoices_archived AS
--
SELECT
    i.invoice_id, i.number, c.name AS client, i.invoice_total,
    payment_total, invoice_date -- prefix-optional if UQ-TB-VL
FROM invoices i 
--
JOIN customers c 
    USING(customer_id)
    WHERE invoice_date IS NOT NULL; --<

-- Actualizar una sola linea/registro
UPDATE invoices 
SET -- chaar modes 
    payment_total = 10, payment_date = '2025-04-29'
    payment_total = DEFAULT, payment_date = NULL
    payment_total = invoice_total * 0.5
    payment_due = payment_date
WHERE invoice_id IS 1;

-- Actualizar multiplas líneas
UPDATE invoices 
SET 
    payment_total = invoice_total * 0.5,
    payment_due = payment_date
WHERE client_id IN (3, 4); -- <

-- Usar las Subqueries en los Updates
UPDATE invoices
SET 
    payment_total = invoice_total * 0.25,
    payment_due = payment_date
    -- v 
WHERE client_id =
    (SELECT client_id
    FROM clients
    WHERE state = 'CA');
    -- OR
WHERE client_id IN
    (SELECT client_id
    FROM clients
    WHERE state IN ('CA', 'NY'));

-- Borrar líneas
DELETE FROM invoices 
WHERE invoice_id = ( 
    SELECT *
    FROM clients
    WHERE name = 'anyName'
    );

-- Restaurar las bases de datos
-- i.e use DDL scripts
  
