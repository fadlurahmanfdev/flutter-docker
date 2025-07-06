# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set noninteractive mode to suppress prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        git \
        openjdk-17-jdk \
        openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=fadlurahmanfdev
RUN useradd -m $USERNAME
USER $USERNAME
WORKDIR /home/$USERNAME

# Install Android SDK
RUN mkdir -p Android/sdk && mkdir -p .android && touch .android/repositories.cfg && \
    wget -O sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip sdk-tools.zip -d Android/sdk && rm sdk-tools.zip && \
    mv Android/sdk/cmdline-tools Android/sdk/cmdline-tools-temp && \
    mkdir Android/sdk/cmdline-tools && \
    mv Android/sdk/cmdline-tools-temp Android/sdk/cmdline-tools/latest && \
    yes | Android/sdk/cmdline-tools/latest/bin/sdkmanager --licenses && \
    Android/sdk/cmdline-tools/latest/bin/sdkmanager \
        "cmdline-tools;latest" \
        "build-tools;34.0.0" \
        "platform-tools" \
        "platforms;android-34" \
        "sources;android-34"

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT="/home/$USERNAME/Android/sdk"
ENV PATH="$PATH:/home/$USERNAME/Android/sdk/cmdline-tools/latest/bin"
ENV PATH="$PATH:/home/$USERNAME/Android/sdk/platform-tools"

# Install Flutter
RUN git clone --branch 3.19.6 https://github.com/flutter/flutter.git && \
    echo "export PATH=\$PATH:/home/$USERNAME/flutter/bin" >> ~/.bashrc && \
    echo "export PATH=\$PATH:/home/$USERNAME/flutter/bin/cache/dart-sdk/bin" >> ~/.bashrc
ENV PATH="$PATH:/home/$USERNAME/flutter/bin"
ENV PATH="$PATH:/home/$USERNAME/flutter/bin/cache/dart-sdk/bin"

# Run Flutter doctor to pre-cache dependencies
RUN flutter doctor -v

# Install FVM
RUN dart pub global activate fvm && \
    echo "export PATH=\$PATH:/home/$USERNAME/.pub-cache/bin" >> ~/.bashrc
ENV PATH="$PATH:/home/$USERNAME/.pub-cache/bin"

# Install Melos
RUN flutter pub global activate melos

# Verify Melos and FVM installations
RUN melos --version && fvm --version

# Install Fvm Flutter
RUN fvm install 3.19.6

# Verify installed flutter in FVM
RUN fvm list

# Make flutter
RUN fvm global 3.19.6

# Set working directory to root
WORKDIR /

# Default command
CMD ["/bin/bash"]
