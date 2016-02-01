#!/usr/bin/env bash

set -e

# Push build/posts.json to homeport.dockyard.com
bundle exec rake build

chmod 600 ./reefpoints_deploy
scp -i ./reefpoints_deploy build/posts.json temp_deploy@homeport.dockyard.com:reefpoints/posts.json
scp -i ./reefpoints_deploy build/new_sitemap.xml temp_deploy@homeport.dockyard.com:reefpoints/sitemap.xml
scp -i ./reefpoints_deploy build/new_atom.xml temp_deploy@homeport.dockyard.com:reefpoints/atom.xml

scp -i ./reefpoints_deploy build/posts.json production@production.dockyard.com:uploads/posts.json
scp -i ./reefpoints_deploy build/new_sitemap.xml production@production.dockyard.com:uploads/sitemap.xml
scp -i ./reefpoints_deploy build/new_atom.xml production@production.dockyard.com:uploads/atom.xml
ssh -i ./reefpoints_deploy production@production.dockyard.com ./load_posts.sh

echo -e "Done\n"
