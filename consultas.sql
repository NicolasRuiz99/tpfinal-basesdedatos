select * from users;
select * from purchase;
select * from shipping
select * from purchase

--Dado un usuario, obtener todas sus compras. Filtrado por email
CREATE OR REPLACE FUNCTION ComprasUsuario ( email varchar)
RETURNS table (
		id int,
		price t_price,
		date date,
		state purch_state,
		id_coupon int,
		id_shipping int)
AS $body$
BEGIN
	RETURN QUERY
	SELECT p.id, p.price, p.date, p.state, p.id_coupon, p.id_shipping 
	FROM purchase p, users u
	WHERE (p.id_user = u.id and u.e_mail = email);
END;
$body$
LANGUAGE plpgsql;

select * from ComprasUsuario('nicolasrondan@live.com.ar')

--Dado un producto, listar todas sus reviews. Filtrado por nombre
CREATE OR REPLACE FUNCTION ReviewsProducto ( producto varchar)
RETURNS table (
		date date,
    	stars t_stars,
    	title varchar,
    	commentary text)
AS $body$
BEGIN
	RETURN QUERY
	SELECT r.date, r.stars, r.title, r.commentary 
	FROM review r, products p
	WHERE (p.id = r.id_product and p.name = producto);
END;
$body$
LANGUAGE plpgsql;

select * from ReviewsProducto('jean')
select * from review