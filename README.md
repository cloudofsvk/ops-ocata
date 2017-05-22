 Command line instructions
 
Git global setup

git config --global user.name "SVK"

git config --global user.email "svk@localhost"

Create a new repository

git clone http://gitlab-ub16/svk/ops-ocata.git

cd ops-ocata

touch README.md

git add README.md

git commit -m "add README"

git push -u origin master

Existing folder or Git repository

cd existing_folder

git init

git remote add origin http://gitlab-ub16/svk/ops-ocata.git

git add .

git commit

git push -u origin maste
