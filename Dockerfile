FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

USER root

COPY ./src /app

CMD ["bash", "/app/build.billie.bash"]
