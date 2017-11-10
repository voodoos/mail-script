echo "
[nginx-404etc]
bantime  = 60
enabled  = true
port     = http,https
filter   = nginx-404etc
logpath  = /var/log/nginx/access.log
action = ufw
maxretry = 5

[nginx-badbots]
bantime  = 30000
enabled  = true
port     = http,https
filter   = nginx-badbots
logpath  = /var/log/nginx/access.log
action = ufw
maxretry = 2
" >> /etc/fail2ban/jail.local


echo "
[Definition]
#failregex = ^<HOST>.*\"(GET|POST).*\" (404|444|403|400) .*$
failregex = ^<HOST>.*\"(GET|POST).*\" (404|444|403|400) .*$
ignoreregex =
" > /etc/fail2ban/filter.d/nginx-404etc.conf

cp /etc/fail2ban/filter.d/apache-badbots.conf /etc/fail2ban/filter.d/nginx-badbots.conf

service fail2ban restart

