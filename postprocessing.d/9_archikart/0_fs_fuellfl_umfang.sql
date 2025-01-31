SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

DELETE FROM ak_fs_fuellfl_umfang_klass;
INSERT INTO ak_fs_fuellfl_umfang_klass(fs_gml_id,fuellfl_umfang)
  SELECT f.gml_id AS fs_gml_id, st_perimeter2d(st_difference(max(f.wkb_geometry),ST_MakeValid(st_union(st_intersection(f.wkb_geometry,j.wkb_geometry))))) AS fuellfl_umfang
                  FROM ax_flurstueck f
                  JOIN ax_klassifizierung j
                  ON f.wkb_geometry && j.wkb_geometry
                  AND st_intersects(f.wkb_geometry,j.wkb_geometry)
                  WHERE f.endet IS NULL group by f.gml_id;

DELETE FROM ak_fs_fuellfl_umfang_nutz;
INSERT INTO ak_fs_fuellfl_umfang_nutz(fs_gml_id,fuellfl_umfang)
  SELECT f.gml_id AS fs_gml_id, st_perimeter2d(st_difference(max(f.wkb_geometry),ST_MakeValid(st_union(st_intersection(f.wkb_geometry,j.wkb_geometry))))) AS fuellfl_umfang
                  FROM ax_flurstueck f
                  JOIN ax_tatsaechlichenutzung j
                  ON f.wkb_geometry && j.wkb_geometry
                  AND st_intersects(f.wkb_geometry,j.wkb_geometry)
                  WHERE f.endet IS NULL group by f.gml_id;