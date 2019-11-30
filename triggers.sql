select * from purchxitem;
select * from purchase;
select * from color_size;
select * from products;

CREATE VIEW ProductoStockPrecio
AS
select purch.id purch_id,p.id prod_id,sum (pitem.stock) stock,(sum (pitem.stock)*p.price) price from purchxitem pitem, purchase purch, color_size c, products p
where pitem.id_purchase = purch.id and pitem.id_color_size = c.id and c.prod_id = p.id
group by purch.id,p.id order by stock desc;

--seteamos el precio total de la compra segun los precios de cada item

CREATE OR REPLACE FUNCTION precio_compra() RETURNS TRIGGER AS $funcemp$
DECLARE
precio t_price;
BEGIN
precio := (select sum(price) from ProductoStockPrecio where purch_id = NEW.id_purchase);
UPDATE "purchase" SET price = precio WHERE id = NEW.id_purchase;
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER set_precio AFTER INSERT OR UPDATE ON purchxitem
FOR EACH ROW EXECUTE PROCEDURE precio_compra();

--setear fecha mensajes,compras,reservas,wishlist,review

CREATE OR REPLACE FUNCTION set_date() RETURNS TRIGGER AS $funcemp$
BEGIN
NEW.date := CURRENT_TIMESTAMP(2);
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER date_msg BEFORE INSERT ON message
FOR EACH ROW EXECUTE PROCEDURE set_date();

CREATE TRIGGER date_purch BEFORE INSERT OR UPDATE ON purchase
FOR EACH ROW EXECUTE PROCEDURE set_date();

CREATE TRIGGER date_res BEFORE INSERT ON reservations
FOR EACH ROW EXECUTE PROCEDURE set_date();

CREATE TRIGGER date_wsh BEFORE INSERT ON wishlist
FOR EACH ROW EXECUTE PROCEDURE set_date();

CREATE TRIGGER date_rev BEFORE INSERT OR UPDATE ON review
FOR EACH ROW EXECUTE PROCEDURE set_date();

--trigger para cambiar stock cuando vence la reserva

CREATE OR REPLACE FUNCTION update_stock() RETURNS TRIGGER AS $funcemp$
BEGIN
IF (NEW.state = 'cancelled') THEN
	UPDATE "color_size" SET stock = stock + NEW.stock WHERE id = NEW.id_color_size;
END IF;
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER up_stock_res AFTER UPDATE ON reservations
FOR EACH ROW EXECUTE PROCEDURE update_stock();

--trigger para checkear cambios de estado de la reserva

CREATE OR REPLACE FUNCTION check_state_res() RETURNS TRIGGER AS $funcemp$
BEGIN
IF (TG_OP = 'INSERT') THEN
	IF (NEW.state = 'cancelled') THEN
		RAISE EXCEPTION 'estado no valido';
	END IF;
ELSE
	IF (NEW.state = 'reserved' AND OLD.state = 'cancelled') THEN
		RAISE EXCEPTION 'operacion inválida';
	END IF;
END IF;

RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER check_state_res BEFORE INSERT OR UPDATE ON reservations
FOR EACH ROW EXECUTE PROCEDURE check_state_res();

--trigger para checkear cambios de estado de la compra

CREATE OR REPLACE FUNCTION check_state_purch() RETURNS TRIGGER AS $funcemp$
BEGIN
IF (TG_OP = 'INSERT') THEN
	IF (NEW.state = 'cancelled') OR (NEW.state = 'pending') OR (NEW.state = 'success') THEN
		RAISE EXCEPTION 'estado no valido';
	END IF;
ELSE
	IF (NEW.state = 'cancelled' AND OLD.state = 'success') OR (NEW.state = 'pending' AND OLD.state = 'success') OR (NEW.state = 'cart' AND OLD.state = 'pending') OR (NEW.state = 'cancelled' AND OLD.state = 'cart') THEN
		RAISE EXCEPTION 'operacion inválida';
	END IF;
END IF;
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER check_state_purch BEFORE INSERT OR UPDATE ON purchase
FOR EACH ROW EXECUTE PROCEDURE check_state_purch();

--trigger para restar o sumar stock cuando cambia el estado de la compra

CREATE OR REPLACE FUNCTION update_stock_purch() RETURNS TRIGGER AS $funcemp$
BEGIN
IF (NEW.state = 'pending') OR (NEW.state = 'success') THEN
	UPDATE "color_size" SET stock = stock - (select pitem.stock from purchxitem pitem where id_purchase = NEW.id AND pitem.id_color_size = id) WHERE id in (select id_color_size from purchxitem where id_purchase = NEW.id);
ELSE
	UPDATE "color_size" SET stock = stock + (select pitem.stock from purchxitem pitem where id_purchase = NEW.id AND pitem.id_color_size = id) WHERE id in (select id_color_size from purchxitem where id_purchase = NEW.id);
END IF;
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_purch AFTER UPDATE ON purchase
FOR EACH ROW EXECUTE PROCEDURE update_stock_purch();










