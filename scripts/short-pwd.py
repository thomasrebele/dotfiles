#!/usr/bin/env python3


def shorten(path, length):
    # http://stackoverflow.com/a/1616781/1562506
    dirs = path.split("/");
    while sum([len(dir) + 1 for dir in dirs]) > length:

        # Find the longest directory in the path.
        max_index  = -1
        max_length = 3

        for i in range(len(dirs)):
            if len(dirs[i]) > max_length:
                max_index  = i
                max_length = len(dirs[i])

        # Shorten it by one character.
        if max_index >= 0:
            dirs[max_index] = dirs[max_index][:max_length-3]

        # Didn't find anything to shorten. This is as good as it gets.
        else:
            break

    path = "/".join(dirs)
    return path

# adapted from http://askubuntu.com/a/17738/351417
import os, sys
#from socket import gethostname
#hostname = gethostname()
#username = os.environ['USER']
if(len(sys.argv) > 1):
    pwd = sys.argv[1]
else:
    pwd = os.getcwd()
homedir = os.path.expanduser('~')
pwd = pwd.replace(homedir, '~', 1)
pwd = shorten(pwd, 35)

print('{}'.format(pwd))
