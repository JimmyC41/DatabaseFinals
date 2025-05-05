-- A: ER-style

create table R (
    id integer primary key,
    x text not null
);

create table A (
    r integer references R(id) primary key,
    y text not null
);

create table B (
    r integer references R(id) primary key
);

create table C (
    r integer references R(id) primary key
);

create table C_Z (
    c integer references C(r),
    z text not null,
    primary key (c, z)
);

-- Cannot enforce total participation
-- Cannot restrict R to one subclass

-- B: Single-table

create table R (
    id integer primary key,
    x text,
    y text,
    is_a char(1) not null check (is_a in ('A', 'B', 'C'))
);

create table R_Z (
    a integer references A(id)
    z text not null,
    primary key (c, a)
);

-- Cannot enforce Rz only references R typles where R.is_a = 'C