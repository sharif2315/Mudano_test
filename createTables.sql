-- creating table for world bank country data
create table world_bank_country_data
(
    index         bigint,
    id            text,
    "iso2Code"    text,
    name          text,
    region        text,
    adminregion   text,
    "incomeLevel" text,
    "lendingType" text,
    "capitalCity" text,
    longitude     double precision,
    latitude      double precision
);

alter table world_bank_country_data
    owner to doadmin;

-- creating table for gdp growth data
create table gdp_data
(
    index           bigint,
    "countryName"   text,
    "countryCode"   text,
    "indicatorName" text,
    "indicatorCode" text,
    "2019"          double precision,
    "2020"          double precision,
    "2021"          double precision,
    "2022"          double precision,
    "2023"          double precision
);

alter table gdp_data
    owner to doadmin;