\unset ON_ERROR_STOP
SET client_min_messages TO notice;
\set ON_ERROR_STOP

SET search_path = :"alkis_schema", :"postgis_schema", public;

SELECT alkis_dropobject('ak_fs_fuellfl_umfang_klass');
CREATE TABLE ak_fs_fuellfl_umfang_klass (
	fs_gml_id character(16),
	fuellfl_umfang double precision,	
	primary key (fs_gml_id)
);
COMMENT ON TABLE ak_fs_fuellfl_umfang_klass IS 'ARCHIKART: Füllflächenumfang Flurstücke';
CREATE INDEX ak_fs_fuellfl_umfang_klass_idx1 ON ak_fs_fuellfl_umfang_klass(fs_gml_id);

SELECT alkis_dropobject('ak_fs_fuellfl_umfang_nutz');
CREATE TABLE ak_fs_fuellfl_umfang_nutz(
	fs_gml_id character(16),
	fuellfl_umfang double precision,	
	primary key (fs_gml_id)
);
COMMENT ON TABLE ak_fs_fuellfl_umfang_nutz IS 'ARCHIKART: Füllflächenumfang Flurstücke Nutzung';
CREATE INDEX ak_fs_fuellfl_umfang_nutz_idx1 ON ak_fs_fuellfl_umfang_nutz(fs_gml_id);