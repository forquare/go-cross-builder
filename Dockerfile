FROM golang:1.15.8

LABEL maintainer="ben.lavery@hashbang0.com"

ENV GORELEASER_VERSION=0.146.0
ENV GORELEASER_SHA=97279a80096bc5d044a5172a205c5b80e8f313aa8137ff9a2d400bb220acd810

ENV GORELEASER_DOWNLOAD_FILE=goreleaser_Linux_x86_64.tar.gz
ENV GORELEASER_DOWNLOAD_URL=https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/${GORELEASER_DOWNLOAD_FILE}


ENV RELEASE_NOTES_VERSION=0.2.0
ENV RELEASE_NOTES_SHA=778c8d12df86710783e3aa0841cdccb610d9115911bc7f9e555f32176f920900

ENV RELEASE_NOTES_DOWNLOAD_FILE=github-release-notes-linux-amd64-${RELEASE_NOTES_VERSION}.tar.gz
ENV RELEASE_NOTES_DOWNLOAD_URL=https://github.com/buchanae/github-release-notes/releases/download/${RELEASE_NOTES_VERSION}/${RELEASE_NOTES_DOWNLOAD_FILE}

# Install tools
RUN dpkg --add-architecture i386 && \
    sed -i.bak 's/^deb/deb [arch=amd64,i386]/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y automake autogen libtool libxml2-dev uuid-dev libssl-dev bash patch cmake make \
    tar xz-utils bzip2 gzip zlib1g-dev sed cpio meson ninja-build gcc-multilib g++-multilib \
    gcc-mingw-w64 g++-mingw-w64 clang llvm-dev libgtk-3-dev libgtk-3-dev:i386 --no-install-recommends || exit 1; \
    rm -rf /var/lib/apt/lists/*;

# Cross compile setup
ENV OSX_SDK_VERSION 		10.10
ENV OSX_SDK     		MacOSX$OSX_SDK_VERSION.sdk
ENV OSX_NDK_X86 		/usr/local/osx-ndk-x86
ENV OSX_SDK_PATH 		/$OSX_SDK.tar.xz

COPY $OSX_SDK.tar.xz /go

RUN git clone https://github.com/tpoechtrager/osxcross.git && \
    git -C osxcross checkout d39ba022313f2d5a1f5d02caaa1efb23d07a559b || exit 1; \
    mv $OSX_SDK.tar.xz osxcross/tarballs/ && \
    UNATTENDED=yes SDK_VERSION=${OSX_SDK_VERSION} OSX_VERSION_MIN=10.10 osxcross/build.sh || exit 1; \
    mv osxcross/target $OSX_NDK_X86; \
    rm -rf osxcross;

ENV PATH $OSX_NDK_X86/bin:$PATH
ENV LD_LIBRARY_PATH=$OSX_NDK_X86/lib:$LD_LIBRARY_PATH

RUN git clone https://github.com/andlabs/libui.git \
  && cd libui/ \
  && mkdir build \
  && meson setup build --buildtype=release --default-library=static \
  && ninja -C build \
  && cp build/meson-out/libui.a /tmp/libui_linux_amd64.a \
  && cd .. \
  && rm -Rf libui

RUN mkdir -p /root/.ssh; \
    chmod 0700 /root/.ssh; \
    ssh-keyscan github.com > /root/.ssh/known_hosts;

RUN wget ${RELEASE_NOTES_DOWNLOAD_URL}; \
    echo "$RELEASE_NOTES_SHA $RELEASE_NOTES_DOWNLOAD_FILE" | sha256sum -c - || exit 1; \
    tar -xzf $RELEASE_NOTES_DOWNLOAD_FILE -C /usr/bin github-release-notes; \
    rm $RELEASE_NOTES_DOWNLOAD_FILE;

RUN  wget ${GORELEASER_DOWNLOAD_URL}; \
    echo "$GORELEASER_SHA $GORELEASER_DOWNLOAD_FILE" | sha256sum -c - || exit 1; \
    tar -xzf $GORELEASER_DOWNLOAD_FILE -C /usr/bin/ goreleaser; \
    rm $GORELEASER_DOWNLOAD_FILE;

CMD ["goreleaser", "-v"]


# Notes for self:
# Windows:
# GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++  go build -ldflags "-extldflags '-static'" -tags extended


# Darwin
# env GO111MODULE=on CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build -tags extended
# env GO111MODULE=on goreleaser --config=goreleaser-extended.yml --skip-publish --skip-validate --rm-dist --release-notes=temp/0.48-relnotes-ready.md
