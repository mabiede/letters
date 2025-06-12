FROM ocaml/opam:debian-12-ocaml-5.2
COPY --from=hadolint/hadolint:latest-alpine /bin/hadolint /bin/hadolint

USER root

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# install packages
# hadolint ignore=DL3008
RUN apt-get update -q && apt-get install -yqq --no-install-recommends \
  # development dependencies
  inotify-tools \
  libgmp-dev \
  pkg-config \
  wget \
  zsh \
  #
  # cleanup installations
  && apt-get autoremove -y \
  && apt-get clean all \
  && rm -rf /var/lib/apt/lists/*

# add timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime

# link opam version
# hadolint ignore=DL3059
RUN ln -fs /usr/bin/opam-2.2 /usr/bin/opam

USER opam

# install oh-my-zsh
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -q -O - | zsh \
  && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
  && sed -i "/^plugins=/c\plugins=(git dotenv)" ~/.zshrc \
  #
  # link make to devcontainer makefile
  && echo 'alias make="make -f /workspace/.devcontainer/Makefile"' >> ~/.zshrc

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
