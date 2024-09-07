# Debian 12
# https://github.com/docker-library/golang/blob/724988cd7e877c42252631f262420cc7d97abc9e/1.23/bookworm/Dockerfile
FROM golang:1.23.1-bookworm

ARG user_name=developer
ARG user_id
ARG group_id
ARG dotfiles_repository="https://github.com/uraitakahito/dotfiles.git"
ARG features_repository="https://github.com/uraitakahito/features.git"

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND=noninteractive

#
# Install packages
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    # Basic
    ca-certificates \
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

# git is already installed in buildpack-deps:bookworm-scm
# https://github.com/docker-library/buildpack-deps/blob/91dd87eecfa0cf2ae7e793aedbaca682dfcf693d/debian/bookworm/scm/Dockerfile#L12
RUN git config --system --add safe.directory /app

#
# Add user and install basic tools.
#
RUN cd /usr/src && \
  git clone --depth 1 ${features_repository} && \
  USERNAME=${user_name} \
  USERUID=${user_id} \
  USERGID=${group_id} \
  CONFIGUREZSHASDEFAULTSHELL=true \
    /usr/src/features/src/common-utils/install.sh
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
RUN go install github.com/go-delve/delve/cmd/dlv@latest

#
# goimports
#
RUN go install golang.org/x/tools/cmd/goimports@latest

#
# staticcheck
# https://github.com/golang/vscode-go/blob/master/docs/settings.md#golinttool
#
RUN go install honnef.co/go/tools/cmd/staticcheck@latest

WORKDIR /app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-F", "/dev/null"]
