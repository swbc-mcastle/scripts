#!/usr/bin/env python3
import sys
import subprocess
import json

JELLYFIN_SERVER='http://1.2.3.4:8096'
JELLYFIN_API_KEY='xxx'

def jf_media_updated(mediapaths):
    reqdata = { 'Updates': [{'Path': p} for p in mediapaths] }
    reqstr = json.dumps(reqdata)
    print(reqstr)
    command = ['curl', '-v',
        '-H','Content-Type: application/json',
        '-H','X-MediaBrowser-Token: '+JELLYFIN_API_KEY,
        '-d',reqstr,
        JELLYFIN_SERVER+'/Library/Media/Updated']
    subprocess.run(command)

def jf_refresh():
    command = ['curl', '-v',
        '-H','X-MediaBrowser-Token: '+JELLYFIN_API_KEY,
        '-d','',
        JELLYFIN_SERVER+'/Library/Refresh']
    subprocess.run(command)

if __name__ == '__main__':
    mp = sys.argv[1:]
    if mp:
        jf_media_updated(mp)
    else:
        jf_refresh()