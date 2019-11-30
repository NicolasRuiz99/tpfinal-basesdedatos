--creacion de dominios

CREATE domain gen AS char 
CHECK (value IN ('M','F','U'));

CREATE domain sh_size AS varchar 
CHECK (value IN ('35','36','37','38','39','40','41','42','43','44','45','46','47','48','49'));

CREATE domain t_size AS varchar 
CHECK (value IN ('XXS','XS','S','M','L','XL','XXL'));

CREATE domain all_size AS varchar 
CHECK (value IN ('35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','XXS','XS','S','M','L','XL','XXL'));

CREATE domain t_color AS varchar 
CHECK (value IN ('rojo','verde','azul','cian','magenta','amarillo','naranja','purpura'));

CREATE domain percent AS int 
CHECK (value >= 0 AND value <= 100);

CREATE domain t_price AS float
CHECK (value >= 0 AND value <= 9999999);

CREATE domain purch_state AS varchar 
CHECK (value IN ('success','pending','cancelled','cart'));

CREATE domain res_state AS varchar
CHECK (value IN ('reserved','cancelled'));

CREATE domain t_stars AS int
CHECK (value >= 0 AND value <=6);

CREATE domain t_comment AS text
CHECK (length (value) < 600);

CREATE domain t_stock AS int
CHECK (value >= 0 AND value <= 9999999);

CREATE domain t_dni AS varchar
CHECK (length (value) = 8);

--creacion de tablas

CREATE TABLE roles (
    id serial,
    name varchar (10) unique,
    PRIMARY KEY (id)
);

CREATE TABLE users (
    id serial,
    e_mail varchar (45) unique,
    psw varchar (40),
    id_role int,
    PRIMARY KEY (id),
    FOREIGN KEY (id_role) REFERENCES roles (id)
);

CREATE TABLE customers (
    id serial,
    dni t_dni,
    name varchar (15),
    surname varchar (15),
    genre gen,
    c_size t_size,
    shoe_size sh_size,
    phone_no numeric (15),
	id_user int not null unique,
    PRIMARY KEY (id),
	FOREIGN KEY (id_user) REFERENCES users (id)
);

CREATE TABLE chat (
    id serial,
    id_customer int unique not null,
    id_admin int not null,
    PRIMARY KEY (id),
    FOREIGN KEY (id_customer) REFERENCES customers (id),
    FOREIGN KEY (id_admin) REFERENCES users (id)
);

CREATE TABLE message (
    id serial,
    msg t_comment not null,
    date date,
	id_user int,
    id_chat int,
	PRIMARY KEY (id),
	FOREIGN KEY (id_user) REFERENCES users (id),
    FOREIGN KEY (id_chat) REFERENCES chat (id)
);

CREATE TABLE type (
    id serial,
    name varchar (15),
    PRIMARY KEY (id)
);

CREATE TABLE products (
    id serial,
    name varchar (15) not null,
    dsc t_comment default 'Sin descripcion',
    material varchar (15) not null,
    genre gen not null,
    brand varchar (15) not null,
    type int,
    discount percent default 0,
    price t_price not null,
    PRIMARY KEY (id),
    FOREIGN KEY (type) REFERENCES type (id)
);

CREATE TABLE color_size (
    id serial,
    color t_color,
    size all_size,
    stock t_stock default 0,
    prod_id int,
    PRIMARY KEY (id),
    FOREIGN KEY (prod_id) REFERENCES products (id)
);

CREATE TABLE coupon (
    id serial,
    pc percent,
    cad_date date,
    PRIMARY KEY (id)
);

CREATE TABLE shipping (
    id serial,
    address varchar (30),
    zip numeric (7),
    name varchar (15),
    surname varchar (15),
    dni t_dni,
    track_code numeric (30) unique,
    province varchar (15),
    PRIMARY KEY (id)
);

CREATE TABLE purchase (
    id serial,
    price t_price,
    date date,
    state purch_state,
    id_user int,
    id_coupon int,
    id_shipping int,
    PRIMARY KEY (id),
    FOREIGN KEY (id_user) REFERENCES users (id),
    FOREIGN KEY (id_coupon) REFERENCES coupon (id),
    FOREIGN KEY (id_shipping) REFERENCES shipping (id)
);

CREATE TABLE purchxitem (
    id_purchase int not null,
    id_color_size int,
    stock t_stock,
    PRIMARY KEY (id_purchase,id_color_size),
	FOREIGN KEY (id_purchase) REFERENCES purchase (id)
);

CREATE TABLE reservations (
    id serial,
    date date,
    stock t_stock,
    id_user int,
    id_color_size int,
    state res_state,
    PRIMARY KEY (id),
    FOREIGN KEY (id_user) REFERENCES users (id),
    FOREIGN KEY (id_color_size) REFERENCES color_size (id)
);

CREATE TABLE wishlist (
    id_user int,
    id_prod int,
    date date,
    PRIMARY KEY (id_user,id_prod),
    FOREIGN KEY (id_user) REFERENCES users (id),
    FOREIGN KEY (id_prod) REFERENCES products (id)
);

CREATE TABLE review (
    id serial,
    date date,
    stars t_stars not null,
    title varchar(15),  
    commentary t_comment default 'Sin comentario',
	id_product int,
	FOREIGN KEY (id_product) REFERENCES products (id)
);

--creación de roles

CREATE ROLE "admin";

GRANT ALL ON users,customers,chat,message,type,products,color_size,coupon,shipping,purchase,purchxitem,reservations,wishlist,review TO "admin";

CREATE ROLE "customer";

GRANT ALL ON users,customers,purchase,purchxitem,reservations,wishlist,review TO "customer";

GRANT INSERT ON message,shipping TO "customer";

