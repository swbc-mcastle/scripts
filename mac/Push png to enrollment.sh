#!/bin/bash
#created by Marijn van der Maat 2020
#version 0.2
#this script will push a picture From a URL to /private/tmp/ and changes its name to depnotify_logo.png
#this is used adding a personal logo for DEPNotify
  #parameter 4 will be used for the picture URL. Make sure this is a .png
      logourl="${4}"

  #Downloads image from url and puts it in the following folder: /private/tmp/
      curl "${logourl}" > /private/tmp/depnotify_logo.png