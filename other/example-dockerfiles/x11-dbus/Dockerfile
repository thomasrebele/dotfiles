# warning: shares the same X11 connection with host and other containers launched in the same way

# build command: podman build -t x11-dbus-example .
# (obsolete? set permissions on X11 socket: setfacl -m u:100999:rw /tmp/.X11-unix/X0)
# launch: Xephyr -screen 1024x768 :12
# launch: podman run --replace  -it -e DISPLAY=$DISPLAY -e DBUS_SESSION_BUS_ADDRESS="" -e XDG_RUNTIME_DIR=/home/tr/.runtime -e XAUTHORITY=/home/tr/.Xauthority -v "${XAUTHORITY:-$HOME/.Xauthority}:/home/tr/.Xauthority:ro" -v /tmp/.X11-unix/X12:/tmp/.X11-unix/X12:ro --cap-drop=ALL --security-opt=no-new-privileges --name x11-dbus-example x11-dbus-example:latest bash
# NOTE: firefox needs --cap-add=SYS_CHROOT
# NOTE: running x-on-resize --auto helps with Xephyr -resizeable (updates the WM)
# NOTE: fix Neo keyboard layout: Xephyr -xkb-layout de -xkb-variant neo ...
# NOTE: recommended: openbox as WM

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  dbus \
  dbus-x11 \
  libx11-6 \
  x11-apps \
  mesa-utils

RUN apt-get install -y xauth

RUN apt-get install -y x11-utils x11-xkb-utils x-on-resize

# if xdg-open is needed:
#RUN apt-get install -y xdg-utils

# workaround for permission errors with 'apt install ...'
# apt uses a user _apt for sandboxing;
# unfortunately many capabilities would be required:
# --cap-drop=ALL --cap-add=DAC_OVERRIDE --cap-add=SETGID --cap-add=SETUID --cap-add=CHOWN --cap-add=FOWNER
RUN printf 'APT::Sandbox::User "root";\n' > /etc/apt/apt.conf.d/99-no-sandbox && \
  chown -R root:root /var/cache/apt/archives/partial && \
  chown -R root:root /var/lib/apt/lists/auxfiles && \
  chown -R root:root /var/lib/apt/lists/partial


RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

RUN dbus-uuidgen --ensure

RUN useradd -m -s /bin/bash -u 1000 tr

RUN mkdir -p /home/tr/.runtime && \
  chmod 700 /home/tr/.runtime && \
  chown -R tr:tr /home/tr/.runtime

USER tr
WORKDIR /home/tr

ENTRYPOINT ["dbus-run-session", "--", "sh", "-c", "export DBUS_SYSTEM_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS; exec \"$@\"", "--"]
CMD ["xclock"]

# options for more speed, less secure: --device /dev/dri --ipc=host 
# option to keep same user/group ids: --userns=keep-id
# potentially need to create xauth cookie (and export it to the container): export COOKIE=$(mcookie); xauth add "$DISPLAY" . "$COOKIE"
