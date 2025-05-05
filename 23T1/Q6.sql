-- A: ER-style mapping

create table Peoples (
    id integer primary key,
    "name" text not null,
    lives_in text not null
);

create table Customers (
    p integer references Peoples(id) primary key
);

create table Employees (
    p integer references Peoples(id) primary key,
    salary integer not null check (salary > 0),
    works_in integer references Branches(id)
);

create table Accounts (
    id integer primary key
);

create table Branches (
    id integer primary key
);

-- n : m
create table Held_by (
    a integer references Accounts(id),
    c integer references Customers(id),
    primary key (a, c)
);

-- Cannot enforce total participation of People
-- Cannot enforce total participation of Customers and Accounts in Held_by
-- Cannot enforce total participation of Branches (i.e. can't guarantee that a branch has at least an Employee)

-- B: Single-table mapping

create table Peoples (
    id integer primary key,
    "name" text not null,
    lives_in text not null,
    customer boolean not null,
    employee boolean not null,
    salary integer,
    works_in integer references Branches(id),
    constraint subclasses check (customer or employee),
    constraint employee_rules check (
        (employee = true and salary > 0 and works_in is not null)
        or
        (employee = false and salary is null and works_in is null))
);

create table Accounts (
    id integer primary key
);

create table Branches (
    id integer primary key
);

create table Held_by (
    a integer references Accounts(id),
    c integer references Peoples(id),
    primary key (a, c)
);

-- Cannot enforce total participation of Customers and Accounts in Held_by
-- Non-customers can have an account (we can't prevent this)