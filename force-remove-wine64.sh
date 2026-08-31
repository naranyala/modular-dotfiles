#!/usr/bin/env bash


sudo apt purge --remove wine wine64 wine32 libwine libwine:i386
sudo apt autoremove --purge
sudo apt clean

