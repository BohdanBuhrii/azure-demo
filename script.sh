echo "Installing DotNet sdk"

#sudo apt-get update
#sudo apt-get install dotnet-sdk-6.0


echo "Publishing application"

#git clone https://github.com/BohdanBuhrii/azure-demo.git
#git checkout test1

dotnet publish -c Release -o /var/www/market-app

echo "Setting up Apache"
#sudo apt-get install apache2
#sudo a2enmod proxy proxy_http proxy_html

sudo printf "
<VirtualHost *:80>  
   ProxyPreserveHost On  
   ProxyPass / http://127.0.0.1:5197/  
   ProxyPassReverse / http://127.0.0.1:5197/  
   ErrorLog /var/log/apache2/DotNetApp-error.log  
   CustomLog /var/log/apache2/DotNetApp-access.log common  
</VirtualHost>
" > /etc/apache2/conf-enabled/DotNetApp.conf

sudo systemctl restart apache2

echo "Setting up Kestrel"

printf "
[Unit]
Description=AspNet Web App running on Ubuntu
[Service]
WorkingDirectory=/var/www/market-app
ExecStart=/usr/bin/dotnet /var/www/market-appMarket.dll
Restart=always
RestartSec=10
SyslogIdentifier=dotnet-demo
User=evaadmin
Environment=ASPNETCORE_ENVIRONMENT=Production
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/kestrel-DotNetApp.service

sudo systemctl enable kestrel-DotNetApp.service 
sudo systemctl daemon-reload 
sudo systemctl start kestrel-DotNetApp.service
#sudo systemctl status kestrel-DotNetApp.service

sudo systemctl restart apache2 
sudo service apache2 restart

echo "Finished"