#!/bin/bash

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')"
psql -c 'delete from pu; delete from places;' >> ${OPENSHIFT_LOG_DIR}/scan_PU.log
ruby scan_PU.rb $1 $2 -117.38 32.73 -111.38 31.73 1.0
ruby scan_PU.rb $1 $2 -108.38 32.73 -106.38 31.73 1.0
ruby scan_PU.rb $1 $2 -117.38 31.73 -104.38 30.73 1.0
ruby scan_PU.rb $1 $2 -116.38 30.73 -104.38 29.73 1.0
ruby scan_PU.rb $1 $2 -103.38 30.73 -101.38 29.73 1.0
ruby scan_PU.rb $1 $2 -118.38 29.73 -117.38 28.73 1.0
ruby scan_PU.rb $1 $2 -116.38 29.73 -100.38 28.73 1.0
ruby scan_PU.rb $1 $2 -116.38 28.73 -99.38 27.73 1.0
ruby scan_PU.rb $1 $2 -115.38 27.73 -98.38 26.73 1.0
ruby scan_PU.rb $1 $2 -114.38 26.73 -96.38 25.73 1.0
ruby scan_PU.rb $1 $2 -116.38 25.73 -115.38 24.73 1.0
ruby scan_PU.rb $1 $2 -112.38 25.73 -96.38 24.73 1.0
ruby scan_PU.rb $1 $2 -112.38 24.73 -109.38 23.73 1.0
ruby scan_PU.rb $1 $2 -108.38 24.73 -97.38 23.73 1.0
ruby scan_PU.rb $1 $2 -111.38 23.73 -109.38 22.73 1.0
ruby scan_PU.rb $1 $2 -107.38 23.73 -97.38 22.73 1.0
ruby scan_PU.rb $1 $2 -107.38 22.73 -97.38 21.73 1.0
ruby scan_PU.rb $1 $2 -92.38 22.73 -89.38 21.73 1.0
ruby scan_PU.rb $1 $2 -107.38 21.73 -96.38 20.73 1.0
ruby scan_PU.rb $1 $2 -92.38 21.73 -86.38 20.73 1.0
ruby scan_PU.rb $1 $2 -106.38 20.73 -96.38 19.73 1.0
ruby scan_PU.rb $1 $2 -92.38 20.73 -86.38 19.73 1.0
ruby scan_PU.rb $1 $2 -111.38 19.73 -110.38 18.73 1.0
ruby scan_PU.rb $1 $2 -105.38 19.73 -95.38 18.73 1.0
ruby scan_PU.rb $1 $2 -92.38 19.73 -86.38 18.73 1.0
ruby scan_PU.rb $1 $2 -115.38 18.73 -114.38 17.73 1.0
ruby scan_PU.rb $1 $2 -111.38 18.73 -110.38 17.73 1.0
ruby scan_PU.rb $1 $2 -104.38 18.73 -86.38 17.73 1.0
ruby scan_PU.rb $1 $2 -103.38 17.73 -90.38 16.73 1.0
ruby scan_PU.rb $1 $2 -100.38 16.73 -89.38 15.73 1.0
ruby scan_PU.rb $1 $2 -97.38 15.73 -95.38 14.73 1.0
ruby scan_PU.rb $1 $2 -94.38 15.73 -91.38 14.73 1.0
ruby scan_PU.rb $1 $2 -93.38 14.73 -91.38 13.73 1.0

psql -c 'update pu set city_id = (select id from cities where ST_Contains(geom, pu.position) limit 1) where city_id is null;' >> ${OPENSHIFT_LOG_DIR}/scan_PU.log
psql -c 'select vw_pu_refresh_table();' >> ${OPENSHIFT_LOG_DIR}/scan_PU.log
psql -c "update updates set updated_at = current_timestamp where object = 'pu';" >> ${OPENSHIFT_LOG_DIR}/scan_PU.log

echo "End: $(date '+%d/%m/%Y %H:%M:%S')"
