
FROM sunwoo2539/ubuntu:24.04-fat

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

USER root
COPY ./lineage-21.0-*-billie-signed.zip /home/ubuntu
COPY ./build.billie.bash /home/ubuntu
RUN \
	apt update								&&\
	apt upgrade -y								&&\
	apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev libgnutls28-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev android-platform-tools-base lib32ncurses-dev libncurses6 libncurses-dev libwxgtk3.2-dev golang	&&\
	rm -rf /var/lib/apt/lists/*
RUN \
	chown ubuntu:ubuntu /home/ubuntu/lineage-21.0-*-billie-signed.zip	&&\
	chown ubuntu:ubuntu /home/ubuntu/build.billie.bash			&&\
	go install github.com/ssut/payload-dumper-go@latest			&&\
	ln -s $(which python3) /usr/local/bin/python				&&\
	curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo	&&\
	chmod a+x /usr/local/bin/repo						&&\
	git config --system user.name "LineageOS BuildBot"			&&\
	git config --system user.email "LineageOSBuildBot@docker.host"		&&\
	git config --system trailer.changeid.key "Change-Id"

USER ubuntu

CMD ["bash", "/home/ubuntu/build.billie.bash"]
