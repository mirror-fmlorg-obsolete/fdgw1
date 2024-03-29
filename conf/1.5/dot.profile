# $FML: dot.profile,v 1.2 2002/12/09 03:20:03 fukachan Exp $
# $NetBSD: dot.profile,v 1.1.2.1 2000/10/09 13:43:33 fvdl Exp $
#
# Copyright (c) 1997 Perry E. Metzger
# Copyright (c) 1994 Christopher G. Demetriou
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#          This product includes software developed for the
#          NetBSD Project.  See http://www.netbsd.org/ for
#          information about NetBSD.
# 4. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# <<Id: LICENSE,v 1.2 2000/06/14 15:57:33 cgd Exp>>
#
# $FML: dot.profile,v 1.2 2002/12/09 03:20:03 fukachan Exp $
#
# Copyright (C) 2001,2002,2003 Ken'ichi Fukamachi <fukachan@fml.org>
#
# All rights reserved. This program is free software; you can
# redistribute it and/or modify it under the same terms as NetBSD itself.
#



PATH=/sbin:/bin:/usr/bin:/usr/sbin:/:/usr/pkg/sbin:/usr/pkg/bin
export PATH
TERM=pc3
export TERM
HOME=/
export HOME
BLOCKSIZE=1k
export BLOCKSIZE
EDITOR=ed
export EDITOR
BOOTMODEL=small
export BOOTMODEL

umask 022

ROOTDEV=/dev/md0a

if [ "X${DONEPROFILE}" = "X" ]; then
	DONEPROFILE=YES
	export DONEPROFILE

	# set up some sane defaults
	echo 'erase ^?, werase ^W, kill ^U, intr ^C'
	stty newcrt werase ^W intr ^C kill ^U erase ^? 9600
	echo ''

	# mount the ramdisk read write
	mount -u $ROOTDEV /

	# mount the kern_fs so that we can examine the dmesg state
	mount -t kernfs /kern /kern

	# pull in the functions that people will use from the shell prompt.
	dmesg() cat /kern/msgbuf
	grep() sed -n "/$1/p"

	# read configuration from /dev/fd0a (ffs)
	test -d conf || mkdir conf 
	mount /dev/fd0a /conf

	# symlink(2) for /etc
	mv /etc /etc.orig
	cp -pr /conf/etc /etc

	# warning
	touch /etc/00_NOT_EDIT_HERE
	echo "Please edit /conf/etc not here since /etc is a copy of /conf/etc." \
		> /etc/00_CAUTION

	# XXX not umount since ipnat needs /netbsd for kmem reading ;)
	# umount /conf

	# pwd.db for ps et.al.
	ln /etc.orig/pwd.db /etc/pwd.db

	rm -fr /etc.orig

        if [ -f /etc/rc.router ]
        then
                sh /etc/rc.router
        else
                echo "*** welcome to fdgw (one floppy NetBSD natbox) ***"
                echo "error: no /etc (/dev/fd0a)";
                echo "       no configuration!";
		sh
        fi
fi
