FROM osrf/ros:jazzy-desktop

RUN apt-get update && apt-get install -y \
    x11vnc xvfb fluxbox nano novnc websockify xterm \
    zsh git curl bat \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/.vnc && x11vnc -storepasswd 1234 ~/.vnc/passwd

RUN chsh -s /bin/zsh root
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k

COPY docker_scripts/.zshrc_custom /root/.zshrc
COPY docker_scripts/start.sh /start.sh

RUN chmod +x /start.sh

WORKDIR /workspace
EXPOSE 5900 6080
CMD ["/start.sh"]