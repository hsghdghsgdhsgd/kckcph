FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y tmate openssh-server openssh-client
RUN sed -i 's/^#\?\s*PermitRootLogin\s\+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'root:root' | chpasswd
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
RUN apt-get install -y systemd systemd-sysv dbus dbus-user-session
RUN printf "systemctl start systemd-logind" >> /etc/profile
RUN apt install curl -y
RUN apt install ufw -y && ufw allow 80 && ufw allow 443 && apt install net-tools -y
RUN apt-get update && apt-get install -y \
    iproute2 \
    hostname \
    && rm -rf /var/lib/apt/lists/*

# ✅ Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip

# ✅ Copy and install Python requirements
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip3 install --no-cache-dir -r requirements.txt

# ✅ Copy bot files
COPY . /app

# ✅ Change CMD to run your bot
CMD ["python3", "bot.py"]

# ✅ Keep systemd running
ENTRYPOINT ["/sbin/init"]
