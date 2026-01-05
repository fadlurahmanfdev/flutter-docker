FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# =====================
# System dependencies
# =====================
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    git \
    openjdk-17-jdk \
    openssh-client \
    ca-certificates \
    bash \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# =====================
# Create non-root user
# =====================
ARG USERNAME=fadlurahmanfdev
RUN useradd -ms /bin/bash $USERNAME
USER $USERNAME
WORKDIR /home/$USERNAME

# =====================
# Android SDK
# =====================
ENV ANDROID_SDK_ROOT=/home/$USERNAME/Android/sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    mv cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm cmdline-tools.zip && \
    mkdir -p ~/.android && touch ~/.android/repositories.cfg

RUN yes | sdkmanager --licenses

RUN sdkmanager \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0"

# =====================
# Flutter via FVM
# =====================
ENV PUB_CACHE=/home/$USERNAME/.pub-cache
ENV PATH=$PATH:$PUB_CACHE/bin

# Install FVM
RUN curl -fsSL https://raw.githubusercontent.com/leoafarias/fvm/main/scripts/install.sh | bash

# ✅ CORRECT PATH
ENV PATH=$PATH:/home/$USERNAME/fvm/bin

RUN fvm install 3.29.3 && \
    fvm global 3.29.3

ENV PATH=$PATH:/home/$USERNAME/fvm/default/bin

# Pre-cache Flutter artifacts
RUN flutter doctor -v && flutter precache --android

# Optional tools
RUN flutter pub global activate melos

WORKDIR /workspace

CMD ["/bin/bash"]
