CREATE VIEW ProductoStockPrecio
AS
SELECT purch.id purch_id,p.id prod_id,sum (pitem.stock) stock,(sum (pitem.stock)*p.price) price FROM purchxitem pitem, purchase purch, color_size c, products p
WHERE pitem.id_purchase = purch.id AND pitem.id_color_size = c.id AND c.prod_id = p.id
GROUP BY purch.id,p.id ORDER BY stock DESC;

--seteamos el precio total de la compra segun los precios de cada item

CREATE OR REPLACE FUNCTION precio_compra() RETURNS TRIGGER AS $funcemp$
DECLARE
precio t_price;
BEGIN
precio := (SELECT SUM(price) FROM ProductoStockPrecio WHERE purch_id = NEW.id_purchase);
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
	UPDATE "color_size" 
	SET stock = stock - (SELECT pitem.stock FROM purchxitem pitem WHERE id_purchase = NEW.id AND pitem.id_color_size = id) 
	WHERE id IN (SELECT id_color_size FROM purchxitem WHERE id_purchase = NEW.id);
ELSE
	UPDATE "color_size" 
	SET stock = stock + (SELECT pitem.stock FROM purchxitem pitem WHERE id_purchase = NEW.id AND pitem.id_color_size = id) 
	WHERE id IN (SELECT id_color_size FROM purchxitem WHERE id_purchase = NEW.id);
END IF;
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_purch AFTER UPDATE ON purchase
FOR EACH ROW EXECUTE PROCEDURE update_stock_purch();

--trigger para checkear que la fecha de vencimiento del cupón no sea anterior a la actual 

CREATE OR REPLACE FUNCTION check_coupon_date() RETURNS TRIGGER AS $funcemp$
BEGIN
IF NEW.cad_date <= CURRENT_TIMESTAMP(2) THEN
	RAISE EXCEPTION 'fecha de vencimiento inválida';
END IF;
RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER check_coupon_date BEFORE INSERT ON coupon
FOR EACH ROW EXECUTE PROCEDURE check_coupon_date();






