SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

DELETE FROM ak_fs_fuellfl_umfang_klass;
INSERT INTO ak_fs_fuellfl_umfang_klass(fs_gml_id,fuellfl_umfang)
   SELECT f.gml_id AS fs_gml_id, 
       st_perimeter2d(st_difference(max(f.wkb_geometry),st_union(st_intersection(f.wkb_geometry,d.wkb_geometry)))) AS fuellfl_umfang,
       st_union(st_intersection(f.wkb_geometry,d.wkb_geometry)) AS wkb_fuellflaeche
                  FROM archikart.ax_flurstueck f
                  JOIN archikart.klas_3x c ON c.fs_gml_id = f.gml_id
                  JOIN archikart.ax_klassifizierung d ON d.gml_id = c.klas_gml_id 
		  WHERE f.endet IS NULL AND ASCII(SUBSTRING(c.klf,1,1)) < 96 AND c.klf NOT LIKE 'B:%' group by f.gml_id;

DELETE FROM ak_fs_fuellfl_umfang_nutz_klass
INSERT INTO ak_fs_fuellfl_umfang_nutz_klass(fs_gml_id,fuellfl_umfang,wkb_fuellflaeche)
   SELECT f.gml_id AS fs_gml_id, 
       st_perimeter2d(st_difference(max(f.wkb_geometry),st_union(st_intersection(f.wkb_geometry,d.wkb_geometry)))) AS fuellfl_umfang,
       st_union(st_intersection(f.wkb_geometry,d.wkb_geometry)) AS wkb_fuellflaeche
                  FROM archikart.ax_flurstueck f
                  JOIN archikart.klas_3x c ON c.fs_gml_id = f.gml_id
                  JOIN archikart.ax_klassifizierung d ON d.gml_id = c.klas_gml_id 
                  WHERE f.endet IS NULL AND ASCII(SUBSTRING(c.klf,1,1)) > 96  group by f.gml_id;


DELETE FROM ak_fs_fuellfl_umfang_nutz;
INSERT INTO ak_fs_fuellfl_umfang_nutz(fs_gml_id,fuellfl_umfang,wkb_fuellflaeche)
   SELECT f.gml_id AS fs_gml_id, 
       st_perimeter2d(st_difference(max(f.wkb_geometry),st_union(st_intersection(f.wkb_geometry,d.wkb_geometry)))) AS fuellfl_umfang,
       st_union(st_intersection(f.wkb_geometry,d.wkb_geometry)) AS wkb_fuellflaeche
                  FROM archikart.ax_flurstueck f
                  JOIN archikart.nutz_21 c ON c.fs_gml_id = f.gml_id
                  JOIN archikart.ax_tatsaechlichenutzung d ON d.gml_id = c.nutz_gml_id 
                  WHERE f.endet IS NULL group by f.gml_id;