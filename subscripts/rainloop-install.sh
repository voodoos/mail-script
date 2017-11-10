PW=$(pwd)

mkdir -p /srv/nginx/default/rainloop
cd /srv/nginx/default/rainloop
curl -sL https://repository.rainloop.net/installer.php | php


cd ${PW}
