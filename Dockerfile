FROM debian:jessie

RUN apt-get update && \
    apt-get -y install git curl wget zsh && \
    rm -fR /var/cache/apt
    
RUN useradd --shell /bin/zsh -u 1000 -m user
    
USER user

COPY bootstrap.sh /

CMD ["sh","bootstrap.sh"]

