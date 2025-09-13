#!/bin/bash
source /home/ubuntu/secreto

LOG_FILE="/var/log/nginx/access.log"
DB_NAME="nginx"
DB_TABLE="nginx_logs"

# Leer línea por línea
while IFS= read -r line; do
    # Extraer datos con regex (usando grep y sed)
    ip=$(echo "$line" | awk '{print $1}')
    raw_date=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p' | cut -d' ' -f1)
    method=$(echo "$line" | awk -F\" '{print $2}' | awk '{print $1}')
    route=$(echo "$line" | awk -F\" '{print $2}' | awk '{print $2}')
    protocol=$(echo "$line" | awk -F\" '{print $2}' | awk '{print $3}')
    status=$(echo "$line" | awk '{print $9}')
    bytes=$(echo "$line" | awk '{print $10}')
    ua=$(echo "$line" | awk -F\" '{print $6}')

    # Convertir fecha al formato YYYY-MM-DD HH:MM:SS
    fecha=$(date -d "$raw_date" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    if [ -z "$fecha" ]; then
        continue  # si falla la fecha, salta la línea
    fi

    # Insertar en MySQL
    mysql -u "$mysql_user" -p"$mysql_passwd" "$DB_NAME" -e \
    "INSERT INTO $DB_TABLE (ip, fecha, metodo, ruta, protocolo, status, bytes, user_agent) \
     VALUES ('$ip', '$fecha', '$method', '$route', '$protocol', $status, $bytes, '$(echo "$ua" | sed "s/'/\\'/g")');"

done < "$LOG_FILE"
