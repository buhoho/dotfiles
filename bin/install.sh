# bin に直接ダウンロードする系のスクリプト

curl -L https://raw.githubusercontent.com/soimort/translate-shell/develop/trans -o ~/bin/trans
chmod +x ~/bin/trans

curl -sS https://getcomposer.org/installer | php
chmod +x composer.phar
mv composer.phar ~/bin/composer

curl -L https://psysh.org/psysh -o ~/bin/psysh
chmod +x ~/bin/psysh
