########################################################
#                                                      #
#			HoneyPot                                         #
#		     Farmacia Paafin                               #
#                                                      #
########################################################

This set of honeypots was tested on an AWS free tier T2.micro instance with 1 CPU, 1 GB of RAM, and 30 GiB of storage and with a Domain name bought in https://www.namecheap.com although it would be advisable to use one with more resources. In this GitHub repository, I 
provide a guide in Spanish describing the process and the scripts and backups of the configuration of the honeypots and, below, the steps required to start all the honeypots when the instance boots. You are going to use Cowrie, OpenCanary, Laravel, Grafana, GoAccess, Nginx and Mysql.

The honeypot is currently inactive; it was deployed for research only. I observed path traversal, LFI, and brute-force attacks, and captured the commands attackers ran after gaining apparent access.

All the API Keys and passwords where in a file called secret.txt but it's not here.

Many of the services are disabled by default to avoid overloading the CPU. MySQL consumes a large amount of memory but is responsible for storing all the data, so it comes enabled by default and must remain active.

1. Start Nginx with HoneypotWeb

1.1 sudo systemctl start nginx
1.2 sudo systemctl status nginx (check that it is running)
1.3 It works correctly if a web application appears when searching the domain name "farmaciapaafin.shop" in the browser.

2. Start Cowrie (SSH and TELNET Honeypot)

2.1 Redirect connections:

sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
sudo iptables -t nat -A PREROUTING -p tcp --dport 23 -j REDIRECT --to-port 2223

2.2 sudo su - cowrie
2.3 cd /home/cowrie/cowrie/cowrie
2.4 source cowrie-env/bin/activate
2.5 bin/cowrie start
2.6 bin/cowrie stop (Stop Cowrie)
2.7 deactivate (Exit the virtual environment)

3. Start OpenCanary (FTP and MySQL Honeypot)

3.1 ~/.local/bin/opencanaryd --start
3.2 ~/.local/bin/opencanaryd --stop (Stop OpenCanary)
3.3 To enable the MySQL honeypot module, change "mysql.enabled": false, to "mysql.enabled": true, in the file /etc/opencanaryd/opencanary.conf. Then restart the honeypot with step 3.1, and both modules will be activated.

VIEWING RESULTS

It is highly recommended not to have all honeypots active while using visualization tools, as this may cause memory and CPU overload, significantly slowing down the machine.

4. Start Grafana

4.1 sudo systemctl start grafana
4.2 Access in the browser at "farmaciapaafin.shop:3000"
4.3 Credentials: Username → admin, Password → Pizzasteve953051!
4.4 Dashboards → Cowrie

5. Update Grafana Maps (necessary to update them with the following scripts)

5.1 sudo ./open_ftp.sh
5.2 sudo ./actualizar_mapa.sh

6. Start and generate a report with GoAccess

6.1 Enter the following command; otherwise, you might be able to see the graphs with step 6.2, but they will not update when refreshing the page:

sudo goaccess /var/log/nginx/access.log \
  -o /home/ubuntu/laravel/public/nginx_dashboard.html \
  --log-format=COMBINED \
  --real-time-html \
  --port=7890 \
  --addr=127.0.0.1 \
  --ws-url=wss://farmaciapaafin.shop/goaccess_ws \
  --daemonize


6.2 Access via browser: "https://farmaciapaafin.shop/nginx_dashboard.html
"
6.3 Press F5 to refresh the graphs

7. Obtain information about a specific IP

7.1 sudo ./open_ftp.sh
7.2 Enter the IP address to investigate

8. Verify suspicious files with the VirusTotal API

8.1 python3 virus_total.sh
