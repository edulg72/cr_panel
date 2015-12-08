#!/bin/bash

cd $OPENSHIFT_REPO_DIR/scripts

echo "Inicio: $(date '+%d/%m/%Y %H:%M:%S')"

ruby scan_UR.rb $1 $2 -86.1 11.23 -83.1 10.73 0.5
ruby scan_UR.rb $1 $2 -86.1 10.73 -83.1 10.23 0.5
ruby scan_UR.rb $1 $2 -86.1 10.23 -82.6 9.73 0.5
ruby scan_UR.rb $1 $2 -85.6 9.73 -82.1 9.23 0.5
ruby scan_UR.rb $1 $2 -84.1 9.23 -82.6 8.73 0.5
ruby scan_UR.rb $1 $2 -84.1 8.73 -82.6 8.23 0.5
ruby scan_UR.rb $1 $2 -83.1 8.23 -82.6 7.73 0.5
ruby scan_UR.rb $1 $2 -87.1 5.73 -86.6 5.23 0.5

psql -c 'update ur set city_id = (select id from cities where ST_Contains(geom, ur.position) limit 1) where city_id is null;'
psql -c 'update mp set city_id = (select id from cities where ST_Contains(geom, mp.position) limit 1) where city_id is null;'
psql -c 'select vw_ur_refresh_table();'
psql -c 'select vw_mp_refresh_table();'
psql -c "update updates set updated_at = current_timestamp where object = 'ur';"

echo "Fim de execucao: $(date '+%d/%m/%Y %H:%M:%S')"
