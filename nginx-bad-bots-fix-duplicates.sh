#!/bin/bash

# comment out IPs that lead to duplicates in globalblacklist -> after update comment them out each time again

# 1) copy over file
# cp /home/moon/pubdotfiles/nginx-bad-bots-fix-duplicates.sh /home/moon/nginx-bad-bots-fix-duplicates.sh
# 2) cron job: (run always after update of globalblacklist)
# 8 22 * * * /home/moon/nginx-bad-bots-fix-duplicates.sh >> /home/moon/logs/sudologs.txt 2>&1 

sudo sed -i 's/^\t*138.199.57.151\t*1;$/#\t138.199.57.151\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sudo sed -i 's/^\t*143.244.38.129\t*1;$/#\t143.244.38.129\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sudo sed -i 's/^\t*195.181.163.194\t*1;$/#\t195.181.163.194\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sudo sed -i 's/^\t*5.188.120.15\t*1;$/#\t5.188.120.15\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sudo sed -i 's/^\t*89.187.173.66\t*1;$/#\t89.187.173.66\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf

# fix wrongly blacklisted google bot IPs
sudo sed -i 's/^\t*66.249.66.27\t*1;$/#\t66.249.66.27\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf

# allow WeChat messenger user agent -> from 3 to 1
sudo sed -i 's/MicroMessenger(?:\\b)"\t\t3/MicroMessenger(?:\\b)"\t\t1/g' /etc/nginx/conf.d/globalblacklist.conf
# allow Sogou web spider -> from 3 to 1
sudo sed -i 's/Sogou\\ web\\ spider(?:\\b)"\t\t3/Sogou\\ web\\ spider(?:\\b)"\t\t1/g' /etc/nginx/conf.d/globalblacklist.conf
# do not request limit Baidu based browsers -> from 2 to 1
sudo sed -i 's/Baidu(?:\\b)"\t\t2/Baidu(?:\\b)"\t\t1/g' /etc/nginx/conf.d/globalblacklist.conf


# comment out rule that blocks {} (false block sof fb in app browser) => in custom file (once is enough)
sudo sed -i '/\"\~\*(?:\\b){/ s/^#*/#/g' /etc/nginx/bots.d/blacklist-user-agents.conf

sudo nginx -t
sudo service nginx reload
