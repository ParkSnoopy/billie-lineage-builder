
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

USER root
COPY ./build.billie.bash /home/ubuntu
RUN \
	apt update								&&\
	apt upgrade -y								&&\
	apt install -y build-essential pkg-config python3 clang curl wget sudo nano bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev libgnutls28-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev android-platform-tools-base lib32ncurses-dev libncurses6 libncurses-dev libwxgtk3.2-dev golang	&&\
	rm -rf /var/lib/apt/lists/*
RUN \
	echo 'ubuntu  ALL=(ALL:ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo	&&\
	chown ubuntu:ubuntu /home/ubuntu/build.billie.bash			&&\
	ln -s $(which python3) /usr/local/bin/python				&&\
	curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo	&&\
	chmod a+x /usr/local/bin/repo

USER ubuntu
RUN\
	go install github.com/ssut/payload-dumper-go@latest			&&\
	git config --global user.name "LineageOS BuildBot"			&&\
	git config --global user.email "LineageOSBuildBot@docker.host"		&&\
	git config --global trailer.changeid.key "Change-Id"			&&\
	git config --global color.ui true					&&\
	sudo -u ubuntu git lfs install

CMD ["bash", "/home/ubuntu/build.billie.bash"]
