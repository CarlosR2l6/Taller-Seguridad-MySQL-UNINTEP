-- =====================================================
-- TRABAJO: SEGURIDAD EN MYSQL
-- CAPITULO 9: LABORATORIO PRACTICO
-- BASE DE DATOS: SAKILA
-- UNINTEP
-- =====================================================


-- =====================================================
-- 1. CREACION DE ROLES

-- Se crean dos roles para organizar los permisos
-- de los usuarios del sistema.
-- =====================================================

CREATE ROLE IF NOT EXISTS 'rol_lectura';
CREATE ROLE IF NOT EXISTS 'rol_cajero';


-- =====================================================
-- 2. CREACION DE USUARIOS

-- Se crean tres cuentas independientes para el
-- analista, el cajero y el personal de soporte.
-- =====================================================

CREATE USER IF NOT EXISTS 'analista_bi'@'localhost'
IDENTIFIED BY 'Analista_Practica_2026!';

CREATE USER IF NOT EXISTS 'cajero'@'localhost'
IDENTIFIED BY 'Cajero_Practica_2026!';

CREATE USER IF NOT EXISTS 'soporte'@'localhost'
IDENTIFIED BY 'Soporte_Practica_2026!';


-- =====================================================
-- 3. ASIGNACION DE PRIVILEGIOS A LOS ROLES

-- rol_lectura recibe SELECT para consultar peliculas.
-- rol_cajero recibe SELECT, INSERT y UPDATE para
-- consultar, registrar y modificar alquileres.
-- =====================================================

GRANT SELECT ON sakila.film
TO 'rol_lectura';

GRANT SELECT, INSERT, UPDATE ON sakila.rental
TO 'rol_cajero';


-- =====================================================
-- 4. ASIGNACION DE ROLES A LOS USUARIOS

-- El analista recibe rol_lectura.
-- El cajero recibe rol_cajero.
-- El usuario soporte queda pendiente de configuracion.
-- =====================================================

GRANT 'rol_lectura' TO 'analista_bi'@'localhost';

GRANT 'rol_cajero' TO 'cajero'@'localhost';


-- =====================================================
-- 5. ACTIVACION AUTOMATICA DE LOS ROLES

-- Se establece que los roles asignados se activen
-- automaticamente cuando los usuarios inicien sesion.
-- =====================================================

SET DEFAULT ROLE ALL TO
'analista_bi'@'localhost',
'cajero'@'localhost';


-- =====================================================
-- 6. VERIFICACION DE PRIVILEGIOS Y ROLES

-- Se consultan los permisos de cada rol y usuario
-- para comprobar que fueron asignados correctamente.
-- =====================================================

SHOW GRANTS FOR 'rol_lectura';

SHOW GRANTS FOR 'rol_cajero';

SHOW GRANTS FOR 'analista_bi'@'localhost';

SHOW GRANTS FOR 'cajero'@'localhost';

SHOW GRANTS FOR 'soporte'@'localhost';

-- =====================================================
-- CORRECCION DE PRIVILEGIOS DEL USUARIO ANALISTA_BI
-- Durante las prácticas realizadas en clase se asignaron
-- diferentes privilegios al usuario analista_bi para
-- comprobar el funcionamiento de los permisos en MySQL.

-- Al verificar los privilegios actuales, se identificó
-- que el usuario tenía un permiso SELECT directo sobre
-- toda la base de datos Sakila.

-- Como en este laboratorio el usuario debe acceder
-- únicamente a la tabla film mediante el rol rol_lectura,
-- se procede a retirar el privilegio adicional.
-- =====================================================


REVOKE SELECT ON sakila.*
FROM 'analista_bi'@'localhost';

-- Verificar los permisos actuales del usuario.

SHOW GRANTS FOR 'analista_bi'@'localhost';

-- =====================================================
-- 7. VERIFICACION DE PRIVILEGIOS DEL USUARIO SOPORTE

-- Se verifica que el usuario soporte no tenga
-- privilegios adicionales asignados directamente.
-- Posteriormente se le otorgara acceso limitado
-- mediante una vista y un procedimiento almacenado.
-- =====================================================

SHOW GRANTS FOR 'soporte'@'localhost';

-- =====================================================
 -- Se comprueba que el permiso SELECT directo sobre
-- toda la base Sakila ya no aparece y que se conserva
-- la asignación del rol rol_lectura.
-- =====================================================

SHOW GRANTS FOR 'analista_bi'@'localhost';

-- =====================================================
-- 8. CREACION DE UNA VISTA PARA EL USUARIO SOPORTE

-- Se crea una vista que permite consultar informacion
-- basica de los clientes sin exponer todos sus datos.
-- La vista mostrara el identificador, nombres,
-- apellidos y estado del cliente.
-- =====================================================


CREATE OR REPLACE VIEW sakila.v_clientes_publico AS
SELECT
    customer_id,
    first_name,
    last_name,
    active
FROM sakila.customer;

-- =====================================================
-- 9. VERIFICACION DEL FUNCIONAMIENTO DE LA VISTA

-- Se comprueba que la vista v_clientes_publico
-- fue creada correctamente y permite consultar
-- la informacion basica de los clientes.
-- =====================================================

SELECT *
FROM sakila.v_clientes_publico
LIMIT 5;

-- =====================================================
-- 10. ASIGNACION DE PERMISO DE CONSULTA A LA VISTA

-- Se concede al usuario soporte permiso SELECT
-- exclusivamente sobre la vista v_clientes_publico.
-- No se le otorga acceso directo a la tabla customer.
-- =====================================================

GRANT SELECT ON sakila.v_clientes_publico
TO 'soporte'@'localhost';

-- =====================================================
-- 11. VERIFICACION DE PRIVILEGIOS DEL USUARIO SOPORTE

-- Se comprueba que el usuario soporte tenga permiso
-- SELECT sobre la vista v_clientes_publico.
-- =====================================================

SHOW GRANTS FOR 'soporte'@'localhost';

-- =====================================================
-- 12. PRUEBA DE ACCESO A LA VISTA
-- Se consulta la vista para comprobar que permite
-- recuperar la informacion autorizada.
-- =====================================================

SELECT *
FROM sakila.v_clientes_publico
LIMIT 5;

-- =====================================================
-- 13. PARTE D: PRUEBAS DE ACCESO

-- Se realizan pruebas para comprobar los privilegios
-- asignados a cada usuario.
-- Las pruebas se ejecutan mediante conexiones
-- independientes con las cuentas correspondientes.
-- =====================================================

SELECT CURRENT_USER(), 
CURRENT_ROLE();

SELECT CURRENT_USER(),
CURRENT_ROLE();


-- =====================================================
-- 14. VERIFICACION DE RESTRICCION DEL PERMISO DELETE
-- AL USUARIO

-- Se ejevcuta una consulta DELETE sobre la tabla sakila.payment.
-- MySQL rechazo la operacion porque el usuario analista_bi
-- no cuenta con privilegios para eliminar registros.
-- Esto compruba que los permisos asignados mediante el 
-- rol rol_lectura funciona correctamente
-- =====================================================

DELETE FROM sakila.payment
WHERE payment_id = 1;

-- =====================================================
-- 15. PRUEBAS DE ACCESO - USUARIO CAJERO
-- PRUEBA 3: PERMISO DE ACTUALIZACION

-- Se inicia una transaccion para realizar la prueba
-- sin dejar cambios permanentes en la base de datos.

-- Se intenta actualizar la fecha de devolucion
-- del alquiler con identificador 1.

-- =====================================================

START TRANSACTION;

UPDATE sakila.rental
SET return_date = NOW()
WHERE rental_id = 1;

-- =====================================================
-- 16.	VERIFICACION DE RESTRICCION DEL PERMISO DELETE 
-- AL USUARIO cajero

-- Se ejecuto una consulta DELETE sobre la tabla sakila.rental. 
-- MySQL rechazo la operación porque el usuario cajero no 
-- cuenta con privilegios para eliminar registros. Esto comprueba
-- que los permisos asignados mediante el rol rol_cajero funcionan
-- correctamente.
-- =====================================================

DELETE FROM sakila.rental
WHERE rental_id = 2;

-- =====================================================
-- 17.	RESTRICCION DEL PERMISO SELECT

-- Se ejecuto una consulta SELECT sobre la tabla sakila.payment.
-- MySQL rechazo la operación porque el usuario cajero 
-- no cuenta con privilegios para consultar dicha tabla. Esto 
-- comprueba que los permisos asignados mediante el rol rol_cajero
-- funcionan correctamente.
-- =====================================================

SELECT * FROM sakila.payment;

-- =====================================================
-- 18.	PRUEBA DE ACCESO USUARIO SOPORTE

-- Se verifica los permisos asignados al usuario soporte.
-- Se comprueba que puede consultar la vista v_clientes_publico,
-- pero no puede acceder directamente a las tablas customer
-- y rental ni a la base de datos mysql.
-- =====================================================

SELECT CURRENT_USER(),
CURRENT_ROLE();

SELECT * FROM sakila.v_clientes_publico
LIMIT 5;

SELECT * FROM sakila.customer
LIMIT 5;

SELECT * FROM sakila.rental
LIMIT 5;

USE mysql;


-- =====================================================
-- 19. REVOCACION DE PRIVILEGIOS Y VERIFICACION

-- En esta sección se revoca el permiso UPDATE al rol
-- rol_cajero y se comprueba que el usuario cajero ya
-- no puede modificar registros en la tabla sakila.rental.
-- =====================================================

SHOW GRANTS FOR 'rol_cajero';

REVOKE UPDATE ON sakila.rental
FROM 'rol_cajero';

SHOW GRANTS FOR 'rol_cajero';

SELECT CURRENT_USER(),
CURRENT_ROLE();
START TRANSACTION;

UPDATE sakila.rental
SET return_date = NOW()
WHERE rental_id = 1;

ROLLBACK;

-- =====================================================
-- 20. PARTE F: LIMPIEZA DEL LABORATORIO

-- Ahora se procede a eliminar los usuarios, roles y
-- la vista creados durante el desarrollo de las pruebas.
-- =====================================================

DROP USER IF EXISTS
'analista_bi'@'localhost',
'cajero'@'localhost',
'soporte'@'localhost';

DROP ROLE IF EXISTS
'rol_lectura',
'rol_cajero';

DROP VIEW IF EXISTS sakila.v_clientes_publico;