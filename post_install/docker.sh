#!/bin/bash

sudo systemctl enable --now docker.socket
sudo usermod -aG docker $USER
