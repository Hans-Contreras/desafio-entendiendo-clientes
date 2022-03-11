--Desafío Clientes - Hans Contreras

-- 1. Cargar el respaldo de la base de datos unidad2.sql

CREATE DATABASE unidad2;

psql -U postgres unidad2 < unidad2.sql --(ejecutado en CMD, desde donde se encuentre la ruta del archivo)

\c unidad2

-- 2. El cliente usuario01 ha realizado la siguiente compra:
-- ● producto: producto9 
-- ● cantidad: 5
-- ● fecha: fecha del sistema 
-- Mediante el uso de transacciones, realiza las consultas correspondientes para este requerimiento y luego consulta la tabla producto para validar si fue efectivamente descontado en el stock.

BEGIN TRANSACTION;
    UPDATE producto SET stock = stock - 5 WHERE descripcion='producto9';
    INSERT INTO compra (cliente_id, fecha) VALUES ((SELECT id FROM cliente WHERE nombre='usuario01'), CURRENT_DATE);
    INSERT INTO detalle_compra (producto_id, compra_id, cantidad) 
    VALUES ((SELECT id FROM producto WHERE descripcion='producto9'), (SELECT MAX(id) FROM compra), 5);
COMMIT;

-- 3. El cliente usuario02 ha realizado la siguiente compra: 
-- ● producto: producto 1, producto 2, producto 8 
-- ● cantidad: 3 de cada producto 
-- ● fecha: fecha del sistema 
-- Mediante el uso de transacciones, realiza las consultas correspondientes para este requerimiento y luego consulta la tabla producto para validar que si alguno de ellos se queda sin stock, no se realice la compra.

--producto 1
BEGIN TRANSACTION;
INSERT INTO compra (cliente_id, fecha)VALUES ((SELECT id FROM cliente WHERE nombre='usuario02'), CURRENT_DATE);
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) 
VALUES ((SELECT id FROM producto WHERE descripcion='producto1'), (SELECT MAX(id) FROM compra), 3);
UPDATE producto SET stock = stock - 3 WHERE descripcion='producto1';
SAVEPOINT check_01;
SELECT * FROM producto WHERE id=1;
COMMIT;

--producto 2
BEGIN TRANSACTION;
INSERT INTO compra (cliente_id, fecha)VALUES ((SELECT id FROM cliente WHERE nombre='usuario02'), CURRENT_DATE);
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) 
VALUES ((SELECT id FROM producto WHERE descripcion='producto2'), (SELECT MAX(id) FROM compra), 3);
UPDATE producto SET stock = stock - 3 WHERE descripcion='producto2';
SAVEPOINT check_02;
SELECT * FROM producto WHERE id=2;
COMMIT;

--producto 8
BEGIN TRANSACTION;
INSERT INTO compra (cliente_id, fecha)VALUES ((SELECT id FROM cliente WHERE nombre='usuario02'), CURRENT_DATE);
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) 
VALUES ((SELECT id FROM producto WHERE descripcion='producto8'), (SELECT MAX(id) FROM compra), 3);
UPDATE producto SET stock = stock - 3 WHERE descripcion='producto8';
SELECT * FROM producto WHERE id=8;
ROLLBACK TO check_02;
COMMIT;

SELECT * FROM producto WHERE id=8;

-- 4. Realizar las siguientes consultas:
-- a. Deshabilitar el AUTOCOMMIT  
\set AUTOCOMMIT off

-- b. Insertar un nuevo cliente
SELECT * FROM cliente;
SAVEPOINT check_03;
INSERT INTO cliente (nombre, email) VALUES ('usuario11','usuario11@gmail.com');

-- c. Confirmar que fue agregado en la tabla cliente 
SELECT * from cliente WHERE nombre='usuario11';

-- d. Realizar un ROLLBACK 
ROLLBACK TO check_03;

-- e. Confirmar que se restauró la información, sin considerar la inserción del punto b 
SELECT * from cliente;

-- f. Habilitar de nuevo el AUTOCOMMIT
\set AUTOCOMMIT true

--FIN--