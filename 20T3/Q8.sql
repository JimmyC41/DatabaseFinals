-- A

create table U (
    id serial,
    a integer not null,
    b text not null,
    primary key (id)
);

create table U_m (
    u integer references U(id),
    m text,
    foreign key (u, m)
);

-- B

create table S (
    id serial references T(id),
    primary key (id)
);

create table T (
    id serial,
    c text not null,
    primary key (id)
);

-- C

create table P (
    id serial,
    e text not null,
    primary key (id)
);

create table Q1 (
    f integer not null,
    p integer references P(id),
    primary key (p)
);

create table Q2 (
    p integer references P(id)
    primary key (p)
);

create table Q3 (
    p integer references P(id),
    g integer not null,
    primary key (p)
);

-- Cannot enfoce total participation of P