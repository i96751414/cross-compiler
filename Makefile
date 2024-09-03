# Name of the project.
PROJECT = i96751414
IMAGE_PREFIX = cross-compiler
TAG = $(shell git describe --tags | cut -c2-)
ifeq ($(TAG),)
	TAG := dev
endif

# Set binaries and platform specific variables.
DOCKER = docker

# Platforms on which we want to build the project.
ANDROID_PLATFORMS = android-arm android-arm64 android-x64 android-x86
DARWIN_PLATFORMS = darwin-x64
LINUX_PLATFORMS = linux-arm linux-x64 linux-x86
CTNG_PLATFORMS = linux-armv7 linux-arm64
WINDOWS_PLATFORMS = windows-x64 windows-x86
WINDOWS_MXE_PLATFORMS = windows-x64-shared windows-x64-static windows-x64-static-posix \
	windows-x86-shared windows-x86-static windows-x86-static-posix

PLATFORMS = $(ANDROID_PLATFORMS) $(DARWIN_PLATFORMS) $(LINUX_PLATFORMS) $(CTNG_PLATFORMS) $(WINDOWS_PLATFORMS) $(WINDOWS_MXE_PLATFORMS)

.PHONY: $(PLATFORMS)

all: $(PLATFORMS)

base:
	$(DOCKER) build \
		--tag $(PROJECT)/$(IMAGE_PREFIX)-base:$(TAG)-$(subst :,-,$(BASE_IMAGE)) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) .

$(ANDROID_PLATFORMS) $(WINDOWS_PLATFORMS) $(WINDOWS_MXE_PLATFORMS): BASE_IMAGE ?= debian:bullseye
$(DARWIN_PLATFORMS) $(LINUX_PLATFORMS) $(CTNG_PLATFORMS): BASE_IMAGE ?= debian:buster
$(PLATFORMS): DOCKERFILE = $@.Dockerfile

$(ANDROID_PLATFORMS): DOCKERFILE = android.Dockerfile
android-arm: DOCKER_FLAGS = --build-arg CROSS_TRIPLE=arm-linux-androideabi --build-arg ANDROID_ARCH=arm \
	--build-arg SYSTEM_PROCESSOR=armv7-a --build-arg ANDROID_ARCH_ABI=armeabi-v7a
android-arm64: DOCKER_FLAGS = --build-arg CROSS_TRIPLE=aarch64-linux-android --build-arg ANDROID_ARCH=arm64 \
	--build-arg SYSTEM_PROCESSOR=aarch64 --build-arg ANDROID_ARCH_ABI=arm64-v8a
android-x64: DOCKER_FLAGS = --build-arg CROSS_TRIPLE=x86_64-linux-android --build-arg ANDROID_ARCH=x86_64 \
	--build-arg SYSTEM_PROCESSOR=x86_64 --build-arg ANDROID_ARCH_ABI=x86_64
android-x86: DOCKER_FLAGS = --build-arg CROSS_TRIPLE=i686-linux-android --build-arg ANDROID_ARCH=x86 \
	--build-arg SYSTEM_PROCESSOR=i686 --build-arg ANDROID_ARCH_ABI=x86

$(CTNG_PLATFORMS): DOCKERFILE = crosstool-ng.Dockerfile
linux-armv7: DOCKER_FLAGS = --build-arg CTNG_CONFIG=crosstool-ng/linux-armv7.config --build-arg CROSS_TRIPLE=armv7-unknown-linux-gnueabi
linux-arm64: DOCKER_FLAGS = --build-arg CTNG_CONFIG=crosstool-ng/linux-arm64.config --build-arg CROSS_TRIPLE=aarch64-unknown-linux-gnu

$(WINDOWS_PLATFORMS): DOCKERFILE = windows.Dockerfile
windows-x64: DOCKER_FLAGS = --build-arg CROSS_TRIPLE=x86_64-w64-mingw32
windows-x86: DOCKER_FLAGS = --build-arg CROSS_TRIPLE=i686-w64-mingw32

$(WINDOWS_MXE_PLATFORMS): DOCKERFILE = windows-mxe.Dockerfile
windows-x64-shared: DOCKER_FLAGS = --build-arg MXE_TARGET=x86_64-w64-mingw32.shared
windows-x64-static: DOCKER_FLAGS = --build-arg MXE_TARGET=x86_64-w64-mingw32.static
windows-x64-static-posix: DOCKER_FLAGS = --build-arg MXE_TARGET=x86_64-w64-mingw32.static.posix
windows-x86-shared: DOCKER_FLAGS = --build-arg MXE_TARGET=i686-w64-mingw32.shared
windows-x86-static: DOCKER_FLAGS = --build-arg MXE_TARGET=i686-w64-mingw32.static
windows-x86-static-posix: DOCKER_FLAGS = --build-arg MXE_TARGET=i686-w64-mingw32.static.posix

$(PLATFORMS): base
	$(DOCKER) build \
		--tag $(PROJECT)/$(IMAGE_PREFIX)-$@:$(TAG) \
		--tag $(PROJECT)/$(IMAGE_PREFIX)-$@:latest \
		--build-arg BASE_TAG=$(TAG)-$(subst :,-,$(BASE_IMAGE)) \
		--file docker/$(DOCKERFILE) $(DOCKER_FLAGS) docker

PUSH_TARGET_PREFIX = push-
PUSH_TARGETS = $(addprefix $(PUSH_TARGET_PREFIX), $(PLATFORMS))
$(PUSH_TARGETS): PLATFORM = $(@:$(PUSH_TARGET_PREFIX)%=%)
$(PUSH_TARGETS): $(PLATFORM)
	docker push $(PROJECT)/$(IMAGE_PREFIX)-$(PLATFORM):latest
	docker push $(PROJECT)/$(IMAGE_PREFIX)-$(PLATFORM):$(TAG)
push: $(PUSH_TARGETS)

PULL_TARGET_PREFIX = pull-
PULL_TARGETS = $(addprefix $(PULL_TARGET_PREFIX), $(PLATFORMS))
$(PULL_TARGETS): PLATFORM = $(@:$(PULL_TARGET_PREFIX)%=%)
$(PULL_TARGETS): $(PLATFORM)
	docker pull $(PROJECT)/$(IMAGE_PREFIX)-$(PLATFORM):latest
pull: $(PULL_TARGETS)
