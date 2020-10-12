curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk
sudo chmod 755 jsawk && sudo mv jsawk /bin/
sudo apt-get install libmozjs-24-bin
sudo update-alternatives --install /usr/bin/js js /usr/bin/js24 10
