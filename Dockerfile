FROM debian:jessie

RUN apt-get update && \
    apt-get -y install git curl wget zsh make && \
    rm -fR /var/cache/apt
    
RUN useradd --shell /bin/zsh -u 1000 -m user

COPY bootstrap.sh /
RUN chmod +x bootstrap.sh

USER user
CMD ["/bootstrap.sh"]

