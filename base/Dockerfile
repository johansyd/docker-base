FROM ubuntu
MAINTAINER Johan Sydseter "johan@aptoma.com"
RUN apt-get update
RUN apt-get install -y sudo
RUN cp /etc/sudoers /tmp/sudoers
RUN cp /tmp/sudoers /tmp/sudoers.old
RUN sed -i '/^\%admin/ s|%admin ALL=(ALL) ALL|%admin ALL=NOPASSWD: ALL|' /tmp/sudoers
RUN cp -f /tmp/sudoers /etc/sudoers
RUN groupadd admin
RUN /etc/init.d/sudo restart
EXPOSE 5300 80
