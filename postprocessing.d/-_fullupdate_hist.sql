SET search_path TO :"alkis_schema",public;

CREATE OR REPLACE procedure fullupdate_hist()
LANGUAGE plpgsql 
AS $$
DECLARE
  options record;
  metadata record;
  impdate varchar;
  table_schema varchar;
  table_name varchar;
  tabledata record;
  featureid varchar;
  fullupdate boolean;
  sql varchar;
  count integer;
  index integer := 0;
BEGIN
  FOR options IN
    SELECT *
    FROM alkis_options
    WHERE lower(name) IN ('komplettupdate', 'lastimportdate')
  LOOP
    CASE lower(options.name)
      WHEN 'komplettupdate' THEN
        fullupdate := options.value::boolean;
      WHEN 'lastimportdate' THEN
        impdate := options.value;
    END CASE;
  END LOOP;

  IF fullupdate THEN
    raise notice 'Historisierung Komplettupdate gestartet...';
    
    sql := 'SELECT a.table_schema, a.table_name
            FROM information_schema.columns a
            JOIN information_schema.columns b
            ON a.table_schema = b.table_schema
            AND a.table_name = b.table_name
            AND b.column_name = ''beginnt''
            JOIN information_schema.tables c
            ON c.table_schema = a.table_schema 
            AND c.table_name = a.table_name
            AND c.table_type = ''BASE TABLE''
            WHERE a.table_schema = ''archikart''
            AND substr(a.table_name, 1, 3) IN (''ax_'', ''ap_'', ''ln_'', ''lb_'', ''au_'', ''aa_'')
            AND a.column_name = ''gml_id''
            ORDER BY a.table_name';
    
    EXECUTE format('SELECT COUNT(*)
                    FROM (%s) temp',
                   sql)
    INTO count;
    
    FOR metadata IN
      EXECUTE sql
    LOOP
      table_schema := metadata.table_schema;
      table_name := metadata.table_name;
      index := index + 1;

      raise notice 'Historisierung Tabelle <%> (% / %)',table_name,index,count;

      FOR tabledata IN
        EXECUTE format('SELECT gml_id, beginnt
                        FROM %I.%I a
                        LEFT JOIN %I.%I b
                        ON b.featureid = a.gml_id
                        LEFT JOIN %I.%I c
                        ON c.featureid = a.gml_id
                        LEFT JOIN %I.%I d
                        ON d.featureid = a.gml_id
                        WHERE a.beginnt <= %L
                        AND a.endet IS NULL
                        AND b.id IS NULL
                        AND c.id IS NULL
                        AND d.ogc_fid IS NULL',
                       table_schema,table_name,
                       table_schema,'alkis_komplettupdate',
                       table_schema,'alkis_insert',
                       table_schema,'delete',
                       impdate)
      LOOP
        featureid := tabledata.gml_id || translate(tabledata.beginnt,':-','');

        EXECUTE format('INSERT INTO %I.%I
                        (typename, featureid, context, safetoignore, replacedby)
                        VALUES
                        (%L, %L, %L, %L, %L)',
                       table_schema,'delete',
                       table_name,tabledata.gml_id,'delete','false',featureid);
      END LOOP;
    END LOOP;
    
    raise notice 'Historisierung Komplettupdate beendet';
  END IF;
END;
$$ SET search_path TO :"alkis_schema";

CALL fullupdate_hist();
