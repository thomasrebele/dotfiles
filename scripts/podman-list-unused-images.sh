#!/bin/bash

podman images --format "{{.ID}} {{.Repository}}:{{.Tag}} {{.VirtualSize}} {{.Size}}" | grep -vFf <(podman ps -a --format "{{.ImageID}}")


podman images --format "{{.ID}} {{.Repository}}:{{.Tag}} {{.VirtualSize}} {{.Size}}" | grep -vFf <(podman ps -a --format "{{.ImageID}}") | sort -k 3nr
