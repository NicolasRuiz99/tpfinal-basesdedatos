--CONSULTAS

--Dado un usuario, obtener todas sus compras. Filtrado por email

SELECT * FROM ComprasUsuario('nicolasrondan@live.com.ar');

SELECT * FROM ComprasUsuario('ramonvaldez@live.com');

--Dado un producto, listar todas sus reviews. Filtrado por nombre

SELECT * FROM ReviewsProducto('jean');

SELECT * FROM ReviewsProducto('remera');

--Producto mejor valorado

SELECT p.name, p.dsc, p.material, p.genre, p.brand, p.price, pmv.valoracion --Detalles del producto más valorado
FROM products p, ProductoMasValorado pmv
WHERE (p.id = pmv.id_product);

--Dado un tipo de producto, listar los mas vendidos

SELECT * FROM TipoProductoVendidos ('ropa interior');

SELECT * FROM TipoProductoVendidos ('accesorios');

--funcion para crear una reserva

SELECT * FROM color_size WHERE id = 4;

SELECT create_reservation(5945, 4, 4);

--TRIGGERS

--PURCHASE

--trigger que setea el precio total de la compra segun los precios de cada item

SELECT purch.id id_compra, purch.price precio_compra, pitem.id_color_size, pitem.stock stock_solicitado, pd.price precio_producto
FROM purchase purch, purchxitem pitem, color_size cz, products pd 
WHERE purch.id = pitem.id_purchase AND pitem.id_color_size = cz.id AND cz.prod_id = pd.id ORDER BY id_compra;

--trigger para checkear cambios de estado de la compra

SELECT * FROM purchase

UPDATE purchase SET state = 'success' WHERE id = 3;

UPDATE purchase SET state = 'cancelled' WHERE id = 1;

INSERT INTO purchase (state, id_user, id_coupon) VALUES 
('success', 1, 1);

--trigger para restar o sumar stock cuando cambia el estado de la compra

SELECT purch.id id_compra, purch.state estado_compra, pitem.id_color_size, pitem.stock stock_solicitado, cz.stock stock_base
FROM purchase purch, purchxitem pitem, color_size cz
WHERE purch.id = pitem.id_purchase AND pitem.id_color_size = cz.id ORDER BY id_compra;

SELECT * FROM reservations;

--trigger para evitar updates y deletes de una compra (cuando está cancelada, pendiente o completada)

SELECT * FROM purchase;

UPDATE purchase SET price = 0 WHERE id = 3;

UPDATE purchase SET id_coupon = 5 WHERE id = 2;

DELETE FROM purchase WHERE id = 2;

--RESERVATIONS

--trigger para cambiar stock cuando vence la reserva

SELECT res.id, res.state, res.stock srock_reservado, cz.stock stock_base
FROM reservations res, color_size cz
WHERE res.id_color_size = cz.id;

UPDATE reservations SET state = 'cancelled' WHERE id = 1;

--trigger para checkear cambios de estado de la reserva

SELECT * FROM reservations;

UPDATE reservations SET state = 'reserved' WHERE id = 2;

--trigger para evitar updates y deletes de una reserva

SELECT * FROM reservations;

UPDATE reservations SET stock = 9148 WHERE id = 6;

DELETE FROM reservations WHERE id = 5;

--COUPON

--trigger para checkear que la fecha de vencimiento del cupón no sea anterior a la actual

SET DateStyle TO European;
INSERT INTO coupon (pc,cad_date) VALUES (43,'9/12/2019');

--SHIPPING

--trigger para evitar updates de la informacion del envio (shipping) - excepto el track_code

SELECT * FROM shipping;

UPDATE shipping SET track_code = 48983 WHERE id = 2;

UPDATE shipping SET dni = 83745632 WHERE id = 1;



