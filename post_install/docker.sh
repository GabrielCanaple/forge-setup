#!/bin/bash

sudo systemctl enable --now docker.socket
newgrp docker
sudo usermod -aG docker $USER
