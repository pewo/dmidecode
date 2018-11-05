docker stop fusioninventory
docker rmi pewo/fusioninventory
if [ ! -r FusionInventory-Agent-2.4.2.tar.gz ]; then
	wget -O FusionInventory-Agent-2.4.2.tar.gz https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.4.2/FusionInventory-Agent-2.4.2.tar.gz
	wget -O FusionInventory-Agent-2.4.2.tar.gz.sha256sum  https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.4.2/FusionInventory-Agent-2.4.2.tar.gz.sha256sum
	sha256sum --check FusionInventory-Agent-2.4.2.tar.gz.sha256sum
	if [ $? -ne 0 ]; then
		echo "Error in checking tar file"
		exit 1
	else 
		echo "Checksum is OK"
	fi
	tar xfz FusionInventory-Agent-2.4.2.tar.gz -C fusioninventory
fi

exit
docker build -t pewo/fusioninventory /docker/fusioninventory

exit
docker run --rm -it --hostname fusioninventory --name fusioninventory -v /docker/fusioninventory/fusioninventory:/fusioninventory pewo/fusioninventory /bin/bash

#
# I containern
cd /fusioninventory/Fusion*
cpanm --installdeps -L extlib --notest --self-contained  .
