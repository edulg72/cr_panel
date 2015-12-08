require 'pg'

if ARGV.size > 0
  passo = ARGV[0].to_f
else
  passo = 0.08
end

if ARGV.size > 1
  sigla = "and iso2 = '#{ARGV[1]}' "
else
  sigla = nil
end

puts "#!/bin/bash\n\necho \"Inicio: $(date '+%d/%m/%Y %H:%M:%S')\"\n\ncase \"$3\" in"

db = PG::Connection.new(:hostaddr => '192.168.1.7', :dbname => 'wazecr', :user => 'waze', :password => 'waze')
db.prepare('box_pais','select iso2 from countries where (ST_Overlaps(geom,ST_SetSRID(ST_MakeBox2D(ST_Point($1,$2),ST_Point($3,$4)),4326)) or ST_Contains(geom,ST_SetSRID(ST_MakeBox2D(ST_Point($1,$2),ST_Point($3,$4)),4326)) or ST_Contains(ST_SetSRID(ST_MakeBox2D(ST_Point($1,$2),ST_Point($3,$4)),4326),geom)) and iso2 = $5')

db.exec("select iso2, ST_Xmin(ST_Envelope(geom)) as longoeste, ST_Xmax(ST_Envelope(geom)), ST_Ymax(ST_Envelope(geom)) as latnorte, ST_Ymin(ST_Envelope(geom)) as latsul from countries where iso2 is not null #{sigla if not sigla.nil?} order by iso2").each do |pais|
  puts "  #{pais['iso2']})"
  latIni = (pais['latnorte'].to_f.round(2) + 0.01).round(8)
  while latIni > pais['latsul'].to_f
#    puts "Latitude: [#{latIni} #{(latIni - passo).round(8)}]"
    area = false
    out = ''
    lonIni = (pais['longoeste'].to_f.round(2) - 0.01).round(8)
    while lonIni < pais['longleste'].to_f
#      puts "  Longitude: [#{lonIni} #{(lonIni + passo).round(8)}] #{area}"
      if area
        if db.exec_prepared('box_pais',[lonIni, (latIni - passo).round(8), (lonIni + passo).round(8), latIni, pais['iso2']]).ntuples == 0
          area = false
          puts "#{out} #{lonIni} #{(latIni - passo).round(8)} #{passo}"
          out = ''
        end
      else
        if db.exec_prepared('box_pais',[lonIni, (latIni - passo).round(8), (lonIni + passo).round(8), latIni, pais['iso2']]).ntuples > 0
          area = true
          out = "    ruby scan_UR.rb $1 $2 #{lonIni} #{latIni}"
        end
      end
      lonIni = (lonIni + passo).round(8)
    end
    latIni = (latIni - passo).round(8)
  end
  puts "  ;;"
end
puts "  *)\n    echo \"Sintaxe: scan_UR.sh <usuario> <senha>\"\n    exit 1\nesac\n"

puts "psql -h 192.168.1.7 -d wazecr -U waze -c 'delete from segment where id in (select id from segment except select s.id from segment s, node n1, node n2 where s.tonodeid = n1.id and s.fromnodeid = n2.id)'\npsql -h 192.168.1.7 -d wazecr -U waze -c 'update segment set municipioid = (select cd_geocmu from municipios where ST_Contains(geom, ST_StartPoint(segment.geometry))) where municipioid is null;'\npsql -h 192.168.1.7 -d wazecr -U waze -c 'refresh materialized view vw_segments;'\npsql -h 192.168.1.7 -d wazecr -U waze -c 'refresh materialized view vw_ruas;'\npsql -h 192.168.1.7 -d wazecr -U waze -c 'refresh materialized view vw_cidades;'\npsql -h 192.168.1.7 -d wazecr -U waze -c \"update atualizacao set data = current_timestamp where objeto = 'segments';\"\n\necho \"Fim de execucao: $(date '+%d/%m/%Y %H:%M:%S')\""

