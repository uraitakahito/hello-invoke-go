# Debian 12
FROM debian:bookworm-20240904

ARG user_name=developer
ARG user_id
ARG group_id
ARG dotfiles_repository="https://github.com/uraitakahito/dotfiles.git"
ARG features_repository="https://github.com/uraitakahito/features.git"
ARG go_version=1.23.1

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND=noninteractive

#
# Install packages
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    # Basic
    ca-certificates \
    git \
    iputils-ping \
    # Editor
    vim \
    # Utility
    tmux \
    # fzf needs PAGER(less or something)
    fzf \
    trash-cli && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/

RUN git config --system --add safe.directory /app

#
# clone features
#
RUN cd /usr/src && \
  git clone --depth 1 ${features_repository}

#
# Add user and install basic tools.
#
RUN USERNAME=${user_name} \
    USERUID=${user_id} \
    USERGID=${group_id} \
    CONFIGUREZSHASDEFAULTSHELL=true \
    UPGRADEPACKAGES=false \
      /usr/src/features/src/common-utils/install.sh

#
# Install Go
#
RUN USERNAME=${user_name} \
    VERSION=${go_version} \
      /usr/src/features/src/go/install.sh

USER ${user_name}

#
# dotfiles
#
RUN cd /home/${user_name} && \
  git clone --depth 1 ${dotfiles_repository} && \
  dotfiles/install.sh

#
# delve
#
RUN /usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest

#
# goimports
#
RUN /usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@latest

#
# staticcheck
# https://github.com/golang/vscode-go/blob/master/docs/settings.md#golinttool
#
RUN /usr/local/go/bin/go install honnef.co/go/tools/cmd/staticcheck@latest

WORKDIR /app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-F", "/dev/null"]
