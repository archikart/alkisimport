SET client_encoding = 'UTF8';
SET search_path TO :"alkis_schema", public;

DROP TABLE IF EXISTS alkis_options;
CREATE TABLE alkis_options (
	id serial NOT NULL,
	name varchar NOT NULL,
	value varchar NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX idx_alkis_options_name 
ON alkis_options (name);

DROP TABLE IF EXISTS alkis_komplettupdate;
CREATE TABLE alkis_komplettupdate (
	id serial NOT NULL,
	typename varchar NOT NULL,
	featureid character(16) NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX idx_alkis_komplettupdate_typename 
ON alkis_komplettupdate (typename);
CREATE INDEX idx_alkis_komplettupdate_featureid 
ON alkis_komplettupdate (featureid);

DROP TABLE IF EXISTS alkis_insert;
CREATE TABLE alkis_insert (
	id serial NOT NULL,
	typename varchar NOT NULL,
	featureid character(16) NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX idx_alkis_insert_typename 
ON alkis_insert (typename);
CREATE INDEX idx_alkis_insert_featureid 
ON alkis_komplettupdate (featureid);
