-- A: ER Mapping of subclasses

create table A (
    id integer not null primary key,
    x text
);

create table B (
    a integer primary key references A(id),
    y text
);

create table C (
    a integer primary key references A(id)
);

create table D (
    id integer not null primary key,
    w text,
);

-- Cannot enforce total participation of A

-- Multivalued attribute
create table C_Z (
    c integer references C(a),
    z text,
    primary key (c, z)
);

-- n:m
create table R (
    c integer references C(a),
    d integer references D(id),
    primary key (c, d)
);

-- B: Single table mapping for subclasses

create table A (
    id integer not null primary key,
    x text,
    b boolean,
    c boolean,
    y text,
    constraint subclasses check (x or y)
);

create table C_Z (
    a integer references A(id),
    z text,
    primary key (a, z)
)

create table D (
    id integer not null primary key,
    w text
);

create table R (
    a integer references A(id),
    d integer references D(id),
    primary key (a, d)
);

-- Cannot prevent Z or R tuple from being related to A