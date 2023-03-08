ARG ANDROID_API_LEVEL="24" \
    ANDROID_ARCHITECTURE="x86" 

#======================
# Set up Android SDK
#======================
FROM ubuntu:22.04 AS android-sdk
ARG ANDROID_API_LEVEL \ 
    ANDROID_ARCHITECTURE
ENV ANDROID_BUILDTOOLS_VERSION="30.0.3" \
    ANDROID_COMMANDLINETOOLS_DOWNLOAD="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    unzip \
    openjdk-11-jdk
# Prepare Android directories and system variables
WORKDIR /home/developer/Android/cmdline-tools
WORKDIR /home/developer/Android/sdk/.android
RUN touch repositories.cfg
ENV ANDROID_HOME /home/developer/Android
# Set up user
RUN useradd -ms /bin/bash developer
# USER developer
# Install SDK
WORKDIR /home/developer
RUN wget -O sdk-tools.zip $ANDROID_COMMANDLINETOOLS_DOWNLOAD
RUN unzip sdk-tools.zip -d /home/developer/Android/cmdline-tools && rm sdk-tools.zip
RUN mv /home/developer/Android/cmdline-tools/cmdline-tools /home/developer/Android/cmdline-tools/latest
RUN yes | /home/developer/Android/cmdline-tools/latest/bin/sdkmanager --install \
    "platform-tools" "platforms;android-$ANDROID_API_LEVEL" \
    "build-tools;$ANDROID_BUILDTOOLS_VERSION" \
    "emulator" \
    "system-images;android-$ANDROID_API_LEVEL;google_apis;$ANDROID_ARCHITECTURE"

#======================
# Set up Flutter SDK
#======================
FROM ubuntu:22.04 AS flutter-sdk
ENV FLUTTER_DOWNLOAD="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.1-stable.tar.xz"
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    xz-utils \
    openjdk-11-jdk \
    git
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer
RUN wget -qO- $FLUTTER_DOWNLOAD | tar -xvJ
ENV PATH "$PATH:/home/developer/flutter/bin"
RUN flutter update-packages

#======================
# Set up noVNC
#======================
FROM ubuntu:22.04 AS novnc
ENV NOVNC_DOWNLOAD="https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0-beta.tar.gz" \
    WEBSOCKIFY_DOWNLOAD="https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz"
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    xz-utils \
    openjdk-11-jdk \
    git
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer
RUN mkdir noVNC
RUN wget -qO- $NOVNC_DOWNLOAD | tar xvz -C noVNC --strip-components 1
WORKDIR /home/developer/noVNC/utils
RUN mkdir websockify
RUN wget -qO- $WEBSOCKIFY_DOWNLOAD | tar xvz -C websockify --strip-components 1

#======================
# Create final build
#======================
FROM ubuntu:22.04 
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    SCREEN=0 \
    VNC_PORT=5901 \
    VNC_GEOMETRY=500x700 \
    ANDROID_DEVICENAME="android_emulator"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    openjdk-11-jdk \
    git \
    libglu1-mesa \
    libgtk-3-dev \
    pkg-config \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    libpulse0 \
    clang \
    cmake \
    ninja-build\
    qemu-kvm \ 
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    menu \
    openbox \
    python3-numpy \
    pip \
    virt-viewer

# Set up user
RUN useradd -ms /bin/bash developer
# USER developer
WORKDIR /home/developer

# Android
COPY --from=android-sdk /home/developer/Android ./Android
ENV ANDROID_HOME /home/developer/Android   
ENV PATH "$PATH:/home/developer/Android/cmdline-tools/latest/bin"
ARG ANDROID_API_LEVEL \
    ANDROID_ARCHITECTURE
RUN echo no | avdmanager create avd \
    -n $ANDROID_DEVICENAME \
    -k "system-images;android-$ANDROID_API_LEVEL;google_apis;$ANDROID_ARCHITECTURE" \
    -d "Nexus 5X"

# Flutter
COPY --from=flutter-sdk /home/developer/flutter ./flutter 
ENV PATH "$PATH:/home/developer/flutter/bin"  
RUN git config --global --add safe.directory /home/developer/flutter
RUN yes | flutter doctor --android-licenses

# noVNC
COPY --from=novnc /home/developer/noVNC ./noVNC 
ENV NOVNC_PORT=6080
EXPOSE $NOVNC_PORT

# Appollo
RUN pip install appollo

# services
COPY ./start_emulator.sh ./start_emulator.sh
RUN chmod +x ./start_emulator.sh

CMD [ "flutter", "doctor" ] 