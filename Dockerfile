FROM ubuntu:16.10
MAINTAINER moremagic <itoumagic@gmail.com>

RUN apt-get update && apt-get install -y openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin .*$/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed -i -e 's/#11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config
RUN echo LANG="ja_JP.UTF-8" > /etc/locale.conf

# japanize
RUN wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
RUN wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
RUN wget https://www.ubuntulinux.jp/sources.list.d/xenial.list -O /etc/apt/sources.list.d/ubuntu-ja.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get dist-upgrade
RUN apt-get install -y ubuntu-defaults-ja

# fcitx setup
RUN apt-get install -y vim dbus-x11 fcitx-mozc
RUN echo "export QT_IM_MODULE=fcitx\n" >> ~/.bashrc && \
    echo "export XMODIFIERS=@im=fcitx\n" >> ~/.bashrc && \
    echo "export QT4_IM_MODULE=fcitx\n" >> ~/.bashrc && \
    echo "export GTK_IM_MODULE=fcitx\n" >> ~/.bashrc

#RUN apt-get install -y fcitx-config-gtk fcitx-config-gtk2 fcitx-frontend-gtk2 fcitx-frontend-gtk3 mozc-utils-gui
#RUN apt-get install -y ibus-mozc dbus-x11


# netbeans setup
# https://github.com/fgrehm/docker-netbeans
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
ADD state.xml /tmp/state.xml
RUN wget http://download.netbeans.org/netbeans/8.0.1/final/bundles/netbeans-8.0.1-javase-linux.sh -O /tmp/netbeans.sh -q && \
    chmod +x /tmp/netbeans.sh && \
    echo 'Installing netbeans' && \
    /tmp/netbeans.sh --silent --state /tmp/state.xml && \
    rm -rf /tmp/*

EXPOSE 22
CMD /usr/sbin/sshd -D

