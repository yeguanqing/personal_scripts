#!/usr/bin/env python
#-*- coding: utf-8 -*-
import sys
import os
import re
import time
import datetime
import logging
import fnmatch
import optparse
import paramiko
from multiprocessing import Pool


def server_list(fn,tgt_type='glob',regex=''):
    all = []
    f = open(fn,'r')
    if tgt_type == 'glob':
	for i in f:
	    if i.startswith('#'):
		continue
	    if fnmatch.fnmatch(i.split()[0],sys.argv[1]):
		all.append(i.strip())
    elif tgt_type == 'regex':
    	pattern = re.compile(r'%s' %regex)
    	for i in f:
	    match = pattern.match(i)
            if i.startswith('#'):
                continue
	    if not match:
	        continue
            else:
                all.append(i.strip())
    f.close()
    return all

def printf(msg):
    print msg
    fd = open('result.log','a+')
    print >>fd,msg
    fd.close()

def ssh_cmd(ip, username, passwd, cmd):
    try:
	time.sleep(10)
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip,22,username,passwd,timeout=5)
        stdin, stdout, stderr = ssh.exec_command("bash -l -c '%s'" %cmd)
        out = stdout.readlines()
        err = stderr.readlines()
        printf("\033[36m%s\033[0m" % ip + ':')
        for i in out:
            printf(' ' * 4 + "\033[32m%s\033[0m" % i.strip())
        for j in err:
            printf(' ' * 4 + "\033[31m%s\033[0m" % j.strip())
        else:
            return out
        ssh.close()
	time.sleep(5)
    except Exception as e:
        printf("\033[36m%s\033[0m" % ip + ':')
        printf("\033[31m%s\033[0m" % str(e))

def remote_scp(ip, username, passwd, local_path, remote_path):
    try:
        t = paramiko.Transport((ip ,22))
        t.connect(username = username, password = passwd)  
        sftp = paramiko.SFTPClient.from_transport(t)   
        src = local_path
        des = remote_path
        sftp.put(src, des)
        t.close()
        printf("\033[36m%s\033[0m" % ip + ':')
	printf(' ' * 4 + "\033[32mFile %s is tranfer ok!\033[0m" % local_path)
    except Exception as e:
	printf("\033[36m%s\033[0m" % ip + ':')
        printf("\033[31m%s\033[0m" % str(e))

def remote_scp_dir(ip, username, passwd, local_dir, remote_dir):
    try:
        t=paramiko.Transport((ip,22))
        t.connect(username = username, password = passwd)
        sftp = paramiko.SFTPClient.from_transport(t)
	printf("\033[36m%s\033[0m" % ip + ':')
        for root,dirs,files in os.walk(local_dir):
            for filespath in files:
                local_file = os.path.join(root,filespath)
                a = local_file.replace(local_dir,'')
                remote_file = os.path.join(remote_dir,a)
                try:
                    sftp.put(local_file,remote_file)
                except Exception,e:
                    sftp.mkdir(os.path.split(remote_file)[0])
                    sftp.put(local_file,remote_file)
                printf(' ' * 4 + "\033[32mupload %s to remote %s\033[0m" % (local_file,remote_file))
            for name in dirs:
                local_path = os.path.join(root,name)
                a = local_path.replace(local_dir,'')
                remote_path = os.path.join(remote_dir,a)
                try:
                    sftp.mkdir(remote_path)
                    printf(' ' * 4 + "\033[32mmkdir path %s\033[0m" % remote_path)
                except Exception,e:
                    print e
        t.close()
    except Exception,e:
        print e

def mssh(mfile,type):
    if options.regex:
        a = server_list(mfile,tgt_type='regex',regex=options.regex)
    else:
        a = server_list(mfile)
    printf("\033[33mStart at %s\033[0m"  % time.ctime())
    pool = Pool(processes=10)
    for i in a:
        b = i.split()
	if type == 'ssh_cmd':
            pool.apply_async(ssh_cmd, (b[0],b[1],b[2],options.command))
	elif type == 'remote_scp':
	    pool.apply_async(remote_scp,(b[0], b[1], b[2], options.localfile, options.remotefile))
	elif type == 'remote_scp_dir':
	    pool.apply_async(remote_scp_dir,(b[0], b[1], b[2], options.localfile, options.remotefile))
    pool.close()
    pool.join()
    printf("\033[33mEnd at %s\n\033[0m"  % time.ctime())

def help():
    global p,options,arguments
    usage = "usage: %prog '' [options] arg1 [options] arg2"
    p = optparse.OptionParser(usage=usage)
    p.add_option('-f', '--file', default="/etc/mssh", help = "server list from file default path is /etc/mssh")
    p.add_option('-e', '--regex', help = "use regex to match server")
    p.add_option('-c', '--command', help = "command on the server")
    p.add_option('-l', '--localfile', help = "scp local file name")
    p.add_option('-r', '--remotefile', help = "scp remote file name")
    options,arguments = p.parse_args()

def main():
    help()
    mfile = options.file
    if mfile and options.command:
	mssh(mfile,'ssh_cmd')
    elif mfile and options.localfile and options.remotefile:
	if os.path.isfile(options.localfile):
	    mssh(mfile,'remote_scp')
	elif os.path.isdir(options.localfile):
 	    mssh(mfile,'remote_scp_dir')
    else:
        print p.print_help()
        sys.exit()

if __name__=='__main__':
    main()
