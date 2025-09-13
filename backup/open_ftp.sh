#!/bin/bash
source /home/ubuntu/secreto

##################FUNCIONES##################################
function mapear() {

while IFS= read -r line; do
    echo "$line" | grep -q '"logtype": 2000' || continue

    src_ip=$(echo "$line" | grep -oP '"src_host":\s*"\K[^"]+')
    src_port=$(echo "$line" | grep -oP '"src_port":\s*\K[0-9]+')
    user=$(echo "$line" | grep -oP '"USERNAME":\s*"\K[^"]+')
    pass=$(echo "$line" | grep -oP '"PASSWORD":\s*"\K[^"]+')
    time=$(echo "$line" | grep -oP '"utc_time":\s*"\K[^"]+')

    coordenadas=$(curl -s http://ip-api.com/json/"$src_ip")
    latitud=$(echo "$coordenadas" | grep -o '"lat":[^,]*' | cut -d: -f2)
    longitud=$(echo "$coordenadas" | grep -o '"lon":[^,]*' | cut -d: -f2)

    count=$(mysql -u "$mysql_user" -p"$mysql_passwd" -se \
    "SELECT COUNT(*) FROM opencanary.open_ftp WHERE src_port=$src_port AND src_ip='$src_ip' AND user_name='$user' AND password='$pass' AND time='$time';" -P 3307)

    if [[ -n "$user" && -n "$pass" && -n "$src_ip" && -n "$time" && "$count" -eq 0 ]]; then
        mysql -u "$mysql_user" -P 3307 -p"$mysql_passwd" opencanary <<EOF
	INSERT INTO open_ftp (src_port, src_ip, user_name, password, time)
	VALUES ($src_port, '$src_ip', '$user', '$pass', '$time');
EOF

        mysql -u "$mysql_user" -P 3307 -p"$mysql_passwd" opencanary <<EOF
	INSERT INTO map_ftp (ip, latitud, longitud)
	VALUES ('$src_ip', $latitud, $longitud);
EOF
    fi
done < "$logfile"

}

##################PROGRAMA PRINCIPAL##################################
logfile="/var/tmp/opencanary.log"
mapear
