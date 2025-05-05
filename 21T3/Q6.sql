-- Regular Entities

create table Users (
    id serial primary key,
    "name" text not null,
    email text not null,
);

-- User is 1, Recipe is n, so user's PK is a FK in Recipe
create table Recipes (
    id serial primary key,
    title text not null,
    user integer references Users(id)
);

create table Ingredients (
    id serial primary key,
    "name" text not null
);

-- Multivalued attributes

create table R_Tags (
    recipe integer references Recipes(id),
    tag text not null,
    primary key (recipe, tag)
);

-- n:m relationships

create table Uses (
    amount integer not null check (amount > 0),
    unit text not null,
    recipe integer references Recipes(id),
    ingredient integer references Ingredients(id),
    primary key (recipe, ingredient),
);

-- Cannot enforce total participation of Ingredeitns in a Recipe