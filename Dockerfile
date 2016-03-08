FROM debian
MAINTAINER INAJIMA Daisuke <inajima@sopht.jp>

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    ccache \
    cvs \
    git \
    sudo \
    zlib1g-dev \
    && \
  rm -rf /var/lib/apt/lists/*

COPY mk.conf /etc/

RUN useradd -ms /bin/bash builder
USER builder
RUN \
  echo '. <(buildenv init)' >> ~/.bashrc && \
  mkdir -m 700 ~/.ssh && \
  printf "Host anoncvs.NetBSD.org\n\tStrictHostKeyChecking no\n" \
    >> ~/.ssh/config

USER root
WORKDIR /home/builder

ENV \
  BUILD_MACH="amd64" \
  BUILD_OPTS="" \
  CVSROOT="anoncvs@anoncvs.NetBSD.org:/cvsroot" \
  CVS_CO_OPTS="-P" \
  CVS_OPTS="-z6" \
  NETBSD_TAG=""

COPY buildenv/entrypoint.sh /usr/local/sbin/entrypoint
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
CMD ["/bin/bash"]
