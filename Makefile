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
LINUX_PLATFORMS = linux-arm linux-armv7 linux-arm64 linux-x64 linux-x86
WINDOWS_PLATFORMS = windows-x64 windows-x86 \
	windows-x64-shared windows-x64-static windows-x64-static-posix \
	windows-x86-shared windows-x86-static windows-x86-static-posix

PLATFORMS = $(ANDROID_PLATFORMS) $(DARWIN_PLATFORMS) $(LINUX_PLATFORMS) $(WINDOWS_PLATFORMS)

.PHONY: $(PLATFORMS)

all:
	for i in $(PLATFORMS); do \
		$(MAKE) $$i; \
	done

base:
	$(DOCKER) build \
		--tag $(PROJECT)/$(IMAGE_PREFIX)-base:$(TAG)-$(subst :,-,$(BASE_IMAGE)) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) .

$(ANDROID_PLATFORMS) $(WINDOWS_PLATFORMS): BASE_IMAGE ?= debian:bullseye
$(DARWIN_PLATFORMS) $(LINUX_PLATFORMS): BASE_IMAGE ?= debian:buster
$(PLATFORMS): base
	$(DOCKER) build \
		--tag $(PROJECT)/$(IMAGE_PREFIX)-$@:$(TAG) \
		--tag $(PROJECT)/$(IMAGE_PREFIX)-$@:latest \
		--build-arg BASE_TAG=$(TAG)-$(subst :,-,$(BASE_IMAGE)) \
		--file docker/$@.Dockerfile docker

push:
	docker push $(PROJECT)/$(IMAGE_PREFIX)-$(PLATFORM):latest
	docker push $(PROJECT)/$(IMAGE_PREFIX)-$(PLATFORM):$(TAG)

push-all:
	for i in $(PLATFORMS); do \
		PLATFORM=$$i $(MAKE) push; \
	done

pull:
	docker pull $(PROJECT)/$(IMAGE_PREFIX)-$(PLATFORM):latest

pull-all:
	for i in $(PLATFORMS); do \
		PLATFORM=$$i $(MAKE) pull; \
	done
