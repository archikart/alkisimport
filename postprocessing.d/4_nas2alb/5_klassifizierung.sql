SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

---
--- Klassifizierungen
---

SELECT alkis_dropobject('alkis_klassifizierungen');
CREATE TABLE alkis_klassifizierungen(
	element VARCHAR PRIMARY KEY,
	funktionsfeld VARCHAR,
	prefix VARCHAR,
	ackerzahl VARCHAR,
	bodenzahl VARCHAR,
	enumeration VARCHAR
);

INSERT INTO alkis_klassifizierungen(element, prefix, funktionsfeld, bodenzahl, ackerzahl, enumeration) VALUES
	('ax_bodenschaetzung',			'b', 'kulturart',		'bodenzahlodergruenlandgrundzahl',	'ackerzahlodergruenlandzahl',	'ax_kulturart_bodenschaetzung'),
	('ax_musterlandesmusterundvergleichsstueck',			'M', 'kulturart',		'bodenzahlodergruenlandgrundzahl',	'ackerzahlodergruenlandzahl',	'ax_kulturart_musterlandesmusterundvergleichsstueck'),
	('ax_grablochderbodenschaetzung',			'G', 'bedeutung',		'bodenzahlodergruenlandgrundzahl',	'NULL::varchar',	'ax_bedeutung_grablochderbodenschaetzung'),
	('ax_bewertung',			'B', 'klassifizierung',		'NULL::varchar',			'NULL::varchar',		'ax_klassifizierung_bewertung'),
	('ax_klassifizierungnachwasserrecht',	'W', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_klassifizierungnachwasserrecht'),
	('ax_anderefestlegungnachwasserrecht',	'W1', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_anderefestlegungnachwasserrecht'),
	/*('ax_schutzgebietnachwasserrecht',	'W2', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_schutzgebietnachwasserrecht'),*/
	('ax_klassifizierungnachstrassenrecht',	'S', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_klassifizierungnachstrassenrecht'),
	('ax_anderefestlegungnachstrassenrecht',	'S1', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_anderefestlegungnachstrassenrecht'),
	('ax_naturumweltoderbodenschutzrecht',	'BS', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_naturumweltoderbodenschutzrecht'),
	/*('ax_schutzgebietnachnaturumweltoderbodenschutzrecht',	'BS', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_schutzgebietnachnaturumweltoderbodensc'),*/	
	('ax_bauraumoderbodenordnungsrecht',	'BO', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_bauraumoderbodenordnungsrecht'),
	('ax_denkmalschutzrecht',	'DS', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_denkmalschutzrecht'),
	('ax_forstrecht',	'F', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_forstrecht'),
	('ax_sonstigesrecht',	'SO', 'artderfestlegung',	'NULL::varchar',			'NULL::varchar',		'ax_artderfestlegung_sonstigesrecht');

SELECT alkis_dropobject('alkis_createklassifizierung');
CREATE FUNCTION pg_temp.alkis_createklassifizierung() RETURNS varchar AS $$
DECLARE
	r  RECORD;
	nv VARCHAR;
	kv VARCHAR;
	d  VARCHAR;
	i  INTEGER;
	res VARCHAR;
	invalid INTEGER;
BEGIN
	nv := E'CREATE VIEW ax_klassifizierung AS\n  ';
	kv := E'CREATE VIEW ax_klassifizierungsschluessel AS\n  ';
	d := '';

	i := 0;
	FOR r IN
		SELECT
			name,
			kennung,
			funktionsfeld,
			prefix,
			bodenzahl,
			ackerzahl,
			enumeration
		FROM alkis_elemente e
		JOIN alkis_klassifizierungen ON e.name=alkis_klassifizierungen.element
	LOOP
		res := alkis_string_append(res, alkis_fixareas(r.name));

		nv := nv
		   || d
		   || 'SELECT '
		   || 'ogc_fid*4+' || i || ' AS ogc_fid,'
		   || '''' || r.name    || '''::text AS name,'
		   || 'gml_id,'
		   || alkis_toint(r.kennung) || ' AS kennung,'
		   || r.funktionsfeld || ' AS artderfestlegung,'
		   || r.bodenzahl || ' AS bodenzahl,'
		   || r.ackerzahl || ' AS ackerzahl,'
		   || '''' || r.prefix || ':''||' || r.funktionsfeld || ' AS klassifizierung,'
		   || 'wkb_geometry'
		   || ' FROM ' || r.name
		   || ' WHERE endet IS NULL'
		   ;

		IF r.enumeration IS NOT NULL THEN
			kv := kv
			   || d
			   || 'SELECT '
			   || '''' || r.prefix || ':''|| wert AS klassifizierung, beschreibung AS name'
			   || '  FROM ' || r.enumeration
			   ;
		END IF;

		d := E' UNION\n  ';
		i := i + 1;
	END LOOP;

	PERFORM alkis_dropobject('ax_klassifizierung');
	EXECUTE nv;

	PERFORM alkis_dropobject('ax_klassifizierungsschluessel');
	EXECUTE kv;

	RETURN alkis_string_append(res, 'ax_klassifizierung und ax_klassifizierungsschluessel erzeugt.');
END;
$$ LANGUAGE plpgsql;

SELECT 'Erzeuge Sicht für Klassifizierungen...';
SELECT pg_temp.alkis_createklassifizierung();

DELETE FROM kls_shl;
INSERT INTO kls_shl(klf,klf_text)
  SELECT klassifizierung,name FROM ax_klassifizierungsschluessel;

SELECT 'Bestimme Flurstücksklassifizierungen...';

SELECT alkis_dropobject('klas_3x_pk_seq');
CREATE SEQUENCE klas_3x_pk_seq;

UPDATE ax_bodenschaetzung SET bodenzahlodergruenlandgrundzahl=NULL WHERE bodenzahlodergruenlandgrundzahl IN ('nicht belegt','');

DELETE FROM klas_3x;
INSERT INTO klas_3x(flsnr,pk,klf,wertz1,wertz2,gemfl,fl,ff_entst,ff_stand,nutz_gml_id)
  SELECT
    *
  FROM (
    SELECT
      alkis_flsnr(f) AS flsnr,
      to_hex(nextval('klas_3x_pk_seq'::regclass)) AS pk,
      k.klassifizierung AS klf,
      k.bodenzahl,
      k.ackerzahl,
       sum(st_area(alkis_intersection(f.wkb_geometry,k.wkb_geometry,'ax_flurstueck:'||f.gml_id||'<=>'||k.name||':'||k.gml_id))) AS gemfl,
      (sum(st_area(alkis_intersection(f.wkb_geometry,k.wkb_geometry,'ax_flurstueck:'||f.gml_id||'<=>'||k.name||':'||k.gml_id)))*amtlicheflaeche/NULLIF(st_area(f.wkb_geometry),0))::int AS fl,
      0 AS ff_entst,
      0 AS ff_stand,
      k.gml_id AS nutz_gml_id
    FROM ax_flurstueck f
    JOIN ax_klassifizierung k
      ON f.wkb_geometry && k.wkb_geometry
      AND alkis_relate(f.wkb_geometry,k.wkb_geometry,'2********','ax_flurstueck:'||f.gml_id||'<=>'||k.name||':'||k.gml_id)
    WHERE f.endet IS NULL
    GROUP BY alkis_flsnr(f), f.amtlicheflaeche, f.wkb_geometry, k.klassifizierung, k.bodenzahl, k.ackerzahl, k.gml_id
  ) AS klas_3x
  WHERE fl>0;
