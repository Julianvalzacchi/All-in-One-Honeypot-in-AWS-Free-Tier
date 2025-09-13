#!/bin/bash
source /home/ubuntu/secreto

##################FUNCIONES################################
function actualizar() {
for ip in $ips
do
    coordenadas=$(curl -s "http://ip-api.com/json/$ip")
    latitud=$(echo "$coordenadas" | grep -o '"lat":[^,]*' | sed -E 's/"lat"://')
    longitud=$(echo "$coordenadas" | grep -o '"lon":[^,]*' | sed -E 's/"lon"://')

        existe=$(mysql -u "$mysql_user" -p"$mysql_passwd" -sN -e "USE cowrie; SELECT COUNT(*) FROM coord WHERE ip='$ip' AND latitude=$latitud AND longitude=$longitud;")
        if [[ "$existe" -eq 0 ]]; then
            mysql -u "$mysql_user" -p"$mysql_passwd" -e "USE cowrie; INSERT INTO coord (ip, latitude, longitude) VALUES ('$ip', $latitud, $longitud);"
            echo "Insertado: $ip - $latitud, $longitud"
        else
            echo "Ya existe: $ip - $latitud, $longitud"
        fi
    sleep 2
done

}

###################PROGRAMA PRINCIPAL####################
ips=$(mysql -u "$mysql_user" -p"$mysql_passwd" -sN -e "USE cowrie; SELECT DISTINCT ip FROM sessions;" -P 3307)
actualizar
