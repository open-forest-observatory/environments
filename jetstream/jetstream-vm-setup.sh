## Commands for manually setting up a fresh Ubuntu 22 featured image from Jetstream 2 to serve the needs of OFO dev

## Set up mount to the OFO manila share (ceph): https://docs.jetstream-cloud.org/general/manilaVM/
sudo mkdir /ofo-data
sudo touch /etc/ceph/ceph.client.ofo-share-01.keyring
sudo bash -c "echo [client.ofo-share-01] >> /etc/ceph/ceph.client.ofo-share-01.keyring"
sudo bash -c "echo '    key = {KEY GOES HERE IT ENDS IN ==} >> /etc/ceph/ceph.client.ofo-share-01.keyring"
sudo chmod 600 /etc/ceph/ceph.client.ofo-share-01.keyring
sudo bash -c "echo '149.165.158.38:6789,149.165.158.22:6789,149.165.158.54:6789,149.165.158.70:6789,149.165.158.86:6789:/volumes/_nogroup/17faf14d-811c-4a0
a-8c07-28ac9bb92df0/f562cd65-396f-400c-a58f-d8a21cd51024 /ofo-data ceph name=ofo-share-01,x-systemd.device-timeout=30,x-systemd.mount-timeout=30,noatime,_n
etdev,rw 0 2' >> /etc/fstab"
sudo mount -a
# Set the directory so that any new files created in it have the "exouser" group
sudo chmod -R g+s /ofo-data

## Increase SSH timeout: https://www.tecmint.com/increase-ssh-connection-timeout/ : make it 300 and 36 and uncomment it

## Install Flatpak and QGIS
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak # Don't think this is necessary, just for flatpak GUI
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub org.qgis.qgis
# Now need to install any wanted QGIS plugins in the GUI


## Install Anaconda and initialize a Metashape env: https://docs.anaconda.com/anaconda/install/linux/
wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh  # Can check web browser for latest version: # Can check web browser for latest version
bash Anaconda3-2022.10-Linux-x86_64.sh # And have it initialize conda
conda create --name meta184 python=3.8 PyYaml


## Install Metashape GUI and license
cd ~/Downloads
wget https://s3-eu-west-1.amazonaws.com/download.agisoft.com/metashape-pro_1_8_4_amd64.tar.gz
sudo tar -C /opt -xvf metashape-pro_1_8_4_amd64.tar.gz
sudo chown -R exouser:exouser /opt/metashape-pro/
sudo apt install libxcb-xinerama0
# Here, copy the Cyverse Metashape floating license folder to /opt/metashape-pro/ , then...
echo 'export agisoft_LICENSE="/opt/metashape-pro/metashape_lic/"' >> ~/.bashrc
echo 'export agisoft_LICENSE="/opt/metashape-pro/metashape_lic/"' >> ~/.profile

## Add a Metashape launcher
cd /opt/metashape-pro/
wget -O metashape_icon.jpg https://yt3.ggpht.com/ytc/AMLnZu_dMjWqf8JdyAiiVaYhv5DdGECBlHd9MnSv9uQQtw=s176-c-k-c0x00ffffff-no-rj
sudo nano /usr/share/applications/metashape.desktop
# and paste in the following:
[Desktop Entry]
Type=Application
Terminal=true
Name=Metashape
Icon=/opt/metashape-pro/metashape_icon.jpg
Exec=/opt/metashape-pro/metashape.sh


## Install Metashape python module
cd ~/Downloads
wget https://s3-eu-west-1.amazonaws.com/download.agisoft.com/Metashape-1.8.4-cp35.cp36.cp37.cp38-abi3-linux_x86_64.whl
conda activate meta184 # Need to do this for other Conda envs where it's desired too
pip install Metashape-1.8.4-cp35.cp36.cp37.cp38-abi3-linux_x86_64.whl 

## Install R: https://cran.r-project.org/bin/linux/ubuntu/fullREADME.html
sudo bash -c "echo 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/' >> /etc/apt/sources.list"
sudo apt-get update
sudo apt-get install r-base
sudo apt-get install r-base-dev

## Install r2u (precompiled packages via apt and install.packages): https://github.com/eddelbuettel/r2u
sudo bash add_cranapt_jammy.sh

## TODO: Consider installing key R packages

## Point the GUI desktop RStudio to the correct R version
echo 'export RSTUDIO_WHICH_R="/usr/lib/R/bin/R"' >> ~/.profile


## Install RStudio Server
sudo apt-get install gdebi-core
cd ~/Downloads
wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2022.12.0-353-amd64.deb
sudo gdebi rstudio-server-2022.12.0-353-amd64.deb


## Install sublimetext
cd ~/Downloads
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text

## Install rclone
sudo apt install rclone

## Add new user (for personal rclone, git configs)
# need command to create new user
# add user to sudoers group, and exouser group so they can modify ofo-data
usermod -aG sudo <username>
sudo usermod -aG exouser <username>
# I believe these users will not have Anaconda, for that would need to copy.
# TODO: consider copying exouser instead: https://unix.stackexchange.com/questions/204970/clone-linux-user-copy-user-based-on-another-one



## Tips
- For file storage (including code and data), only use /ofo-data/ (a mounted data volume with 5 TB that is shared across instances). Putting data anywhere else will fill up the instance (which only has 80 GB storage). An exception is files that are needed for linux OS configuration.
- Rclone to copy files, and switch to your own user




## THIS ISN'T WORKING:
## Setting up SSH key (assumes local machine is mac or linux): https://www.flownative.com/en/documentation/guides/beach/how-to-generate-a-new-ssh-key-and-add-it-to-the-ssh-agent.html
# Create a SSH key if you don't have one. Locally run:
ssh-keygen -t rsa -b 4096 -C "you@example.com"
# Locally add (or else create) ~/.ssh/config and add the following:
Host *
 UseKeychain yes
 AddKeysToAgent yes
 IdentityFile ~/.ssh/id_rsa
# Locally add private key to ssh-agent
ssh-add -K ~/.ssh/id_rsa
# Set up Jetstream2 instance with ssh key: https://docs.jetstream-cloud.org/ui/exo/access-instance/
# Paste public key text (from ~/.ssh/id_rsa.pub) in this file: /home/exouser/.ssh/authorized_keys
# You can then ssh with: ssh -i ~/.ssh/id_rsa exouser@<PUBLIC.IP.ADDRESS.HERE>