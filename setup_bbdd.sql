SET DateStyle TO European;

create domain gen as char 
check (value in ('M','F','U'));

create domain sh_size as varchar 
check (value in ('35','36','37','38','39','40','41','42','43','44','45','46','47','48','49'));

create domain t_size as varchar 
check (value in ('XXS','XS','S','M','L','XL','XXL'));

create domain t_color as varchar 
check (value in ('rojo','verde','azul','cian','magenta','amarillo','naranja','purpura'));

create domain percent as int 
check (value >= 0 and value <= 100);

create domain t_price as float
check (value >= 0 and value <= 9999999);

create domain purch_state as varchar 
check (value in ('success','pending','cancelled'));

create domain res_state as varchar
check (value in ('reserved','cancelled'));

create domain t_stars as int
check (value >= 0 and value <=6);

create domain t_comment as text
check (length (value) < 600);

create table roles (
    id serial,
    name varchar (10) unique,
    primary key (id)
);

create table users (
    id serial,
    e_mail varchar (45) unique,
    psw varchar (40),
    id_role int,
    primary key (id),
    foreign key (id_role) references roles (id)
);

create table customers (
    id serial,
    dni numeric (8),
    name varchar (15),
    surname varchar (15),
    genre gen,
    c_size t_size,
    shoe_size sh_size,
    phone_no numeric (15),
	id_user int not null unique,
    primary key (id),
	foreign key (id_user) references users (id)
);

create table chat (
    id serial,
    id_user int unique not null,
    id_admin int not null,
    primary key (id),
    foreign key (id_user) references customers (id),
    foreign key (id_admin) references users (id)
);

create table message (
    id serial,
    msg t_comment not null,
    date date,
	id_user int,
    id_chat int,
	primary key (id),
	foreign key (id_user) references users (id),
    foreign key (id_chat) references chat (id)
);

create table type (
    id serial,
    name varchar (15),
    primary key (id)
);

create table products (
    id serial,
    name varchar (15) not null,
    dsc t_comment default 'Sin descripcion',
    material varchar (15) not null,
    genre gen not null,
    brand varchar (15) not null,
    type int,
    discount percent default 0,
    price t_price not null,
    primary key (id),
    foreign key (type) references type (id)
);

create table color_size (
    id serial,
    color t_color,
    size varchar (4),
    stock int default 0,
    prod_id int,
    primary key (id),
    foreign key (prod_id) references products (id)
);

create table coupon (
    id serial,
    pc percent,
    cad_date date,
    primary key (id)
);

create table shipping (
    id serial,
    address varchar (30),
    zip numeric (7),
    name varchar (15),
    surname varchar (15),
    dni numeric (8),
    track_code int unique,
    province varchar (15),
    primary key (id)
);

create table purchase (
    id serial,
    price t_price,
    date date,
    state purch_state,
    id_user int,
    id_coupon int,
    id_shipping int,
    primary key (id),
    foreign key (id_user) references users (id),
    foreign key (id_coupon) references coupon (id),
    foreign key (id_shipping) references shipping (id)
);

create table purchxitem (
    id_purchase int,
    id_color_size int,
    primary key (id_purchase,id_color_size)
);

create table reservations (
    id serial,
    date date,
    stock int,
    id_user int,
    id_color_size int,
    state res_state,
    primary key (id),
    foreign key (id_user) references users (id),
    foreign key (id_color_size) references color_size (id)
);

create table wishlist (
    id_user int,
    id_prod int,
    date date,
    primary key (id_user,id_prod),
    foreign key (id_user) references users (id),
    foreign key (id_prod) references products (id)
);

create table review (
    id serial,
    date date,
    stars t_stars not null,
    title varchar(15),
    commentary text default 'Sin comentario' 
);

INSERT INTO "roles" (name) VALUES ('admin'), ('customer');

INSERT INTO "users" (e_mail, psw, id_role) VALUES 
('nicolasrondan@live.com.ar', 'password', 2), 
('ramonvaldez@live.com', 'admin', 2),
('juliocesar@live.com.ar', 'contraseña', 2),    
('leoDavinci@gmail.com', '123456789', 2), 
('arturito12@hotmail.com', 'soytupadre123', 2),
('juanortiga@gmail.com', 'elmasri', 2), ('estebanquito@gmail.com', '456789123', 2), 
('horacioquiroga@live.com.ar', 'almohada45', 2),
('oliviatorres@gmail.com', 'bananasplit5', 2), 
('japonesirz@yahoo.com', '5555s', 2);

INSERT INTO "customers" (dni, name, surname, genre, c_size, shoe_size, phone_no, id_user) VALUES 
(39031040, 'nicolas', 'rondan', 'M', 'L', '42', '3442471711', 1 ),
(41056189, 'ramon', 'valdez', 'M', 'XL', '38', '3442471712', 2 ), 
(28031042, 'julio', 'cesar', 'M', 'XXL', '43', '3452772718', 3 ),
(56023781, 'leonardo', 'davinci', 'M', 'S', '40', '344378986', 4 ), 
(8423589, 'arturo', 'rodriguez', 'M', 'XL', '43', '011567898', 5 ),
(23561589, 'juan', 'ortiga', 'M', 'S', '39', '3445895623', 6 ), 
(56458963, 'esteban', 'fernandez', 'M', 'XS', '41', '3442533731', 7 ),
(28355601, 'horacio', 'quiroga', 'M', 'S', '38', '011455632', 8 ), 
(56892301, 'olivia', 'torres', 'F', 'S', '39', '0114565238', 9 ),
(25563247, 'raizo', 'okiwa', 'M', 'L', '40', '344368947', 10 );

INSERT INTO "chat" (id_user, id_admin) VALUES (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1), (9, 1), (10, 1);

--problema con la fecha, se puede introducir una fecha fantaseosa
INSERT INTO "message" (msg, date, id_user, id_chat) VALUES 
('Hola, tenes stock?', '18/12/2019', 1, 1), ('Hola?', '11/12/2019', 2, 2), 
('quiero reembolsar...', '24/12/2019', 3, 3),
('dssasasd', '03/12/2019', 4, 4), ('Hola, tenes stock?', '18/12/2019', 5, 5), 
('Hola, tenes stock?', '18/12/2019', 6, 6), 
('Hola, quiero un par de medias', '22/11/2019', 7, 7),
('puedo ser admin?', '18/03/2017', 8, 8), (':)', '05/10/1982', 9, 9), 
('Hola, tenes stock?', '17/12/2019', 10, 10);

INSERT INTO "type" (name) VALUES ('calzado'), ('remera'), ('pantalon'), ('medias'), ('ropa interior'), ('accesorios'), ('abrigos');

INSERT INTO "products" (name, dsc, material, genre, brand, type, discount, price) VALUES 
('jean', 'jean azul talle 40', 'denim', 'U', 'levis', 3, 10, 800 ), 
('zapatillas', 'zapatillas para entrenar', 'hule', 'M', 'nike', 1, 5, 1500 ),
('remera', 'remera chomba color roja', 'algodon', 'M', 'lacoste', 2, 0, 950 ), 
('medias', 'par de medias', 'tela', 'U', 'nike', 4, 0, 300 ),
('boxer', 'boxer taverniti blanco', 'algodon', 'M', 'taverniti', 5, 0, 850 ), 
('zapatos','', 'cuero', 'M', 'pizzoni', 1, 20, 3400 ),
('bermuda','', 'gabardina', 'M', 'adidas', 3, 10, 2200 ), 
('lentes de sol', '','vidrio', 'U', 'smartbuy', 6, 5, 1000 ),
('campera','', 'algodon', 'M', 'adidas', 7, 30, 3200 ), 
('bufanda', '', 'lana', 'F', 'vinson', 7, 0, 500);

--Acá hay inconsistencias con el talle, por ejemplo en el jean que se puede poner 40 ¿como resolverlo? , y... ¿que pasa con el talle de los lentes de sol?

INSERT INTO "color_size" (color, size, stock, prod_id) VALUES ('azul', '40', 50, 1),
('verde', '42', 100, 2), 
('purpura', 'L', 150, 3), 
('amarillo', '41', 500, 4),
('naranja', 'XS', 200, 5), 
('magenta', '42', 70, 6), 
('amarillo', 'XL', 600, 7),
('azul', 'L', 500, 8), 
('rojo', 'XL', 500, 9), 
('amarillo', 'XXL', 800, 10);

--En este caso se puede poner una fecha de vencimiento anterior a la actual... habria que verlo con un trigger tal vez

INSERT INTO "coupon" (pc, cad_date) VALUES 
(50, '21/04/2020'), (30, '12/03/1991'), 
(20, '21/12/2070'), (50, '12/12/2020'), 
(31, '10/10/2020');

--Acá puede haber track-codes repetidos y documentos cortos
INSERT INTO "shipping" (address, zip, name, surname, dni, track_code, province) VALUES 
('belgrano 679', 3260, 'Raul', 'Paz', 56512355, 54654231, 'Entre rios'),
('sarmiento 345', 4250, 'Roman', 'Pizeta', 5651, 15923789, 'La pampa'), 
('los tulipanes 789', 3260, 'Manuel', 'Rodriguez', 89562318, 54654232, 'Entre rios');


INSERT INTO "purchase" (price, date, state, id_user, id_coupon, id_shipping) VALUES 
(3400, '17/12/2019', 'success', 1, 1, 1 ), 
(2000, '10/12/2019', 'pending', 2, 2, 2 ),
(1000, '01/12/2019', 'cancelled', 3, 3, 3 );


INSERT INTO "purchxitem" (id_purchase, id_color_size) VALUES (1,1), (2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10);


INSERT INTO "reservations" (date, stock, id_user, id_color_size, state) VALUES 
('04/09/2019', 100, 1, 1, 'reserved'), ('04/10/2019', 50, 2, 3, 'cancelled'),
('20/11/2019', 100, 3, 2, 'reserved'), ('12/11/2019', 25, 4, 4, 'cancelled'), 
('25/10/2019', 16, 5, 7, 'reserved'), ('21/11/2019', 60, 7, 5, 'reserved'),
('22/09/1980', 500, 6, 6, 'cancelled'), ('20/01/2020', 100, 8, 8, 'reserved'), 
('12/12/2019', 78, 9, 9, 'cancelled'), ('04/09/2019', 100, 10, 10, 'reserved');

select * from reservations

