#!/bin/make
#
# calc - arbitrary precision calculator
#
# Copyright (C) 1999-2018,2021  Landon Curt Noll
#
# SRC: Makefile - Our calc build environment
#
#	The "# SRC: ... - ..." comment line above indicates
#	the origin of this file.
#
# IMPORTANT: Please see the section on Makefiles near the
#	     bottom of the HOWTO.INSTALL file.
#
# Calc is open software; you can redistribute it and/or modify it under
# the terms of the version 2.1 of the GNU Lesser General Public License
# as published by the Free Software Foundation.
#
# Calc is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
# Public License for more details.
#
# A copy of version 2.1 of the GNU Lesser General Public License is
# distributed with calc under the filename COPYING-LGPL.  You should have
# received a copy with calc; if not, write to Free Software Foundation, Inc.
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Under source code control:	1990/02/15 01:48:41
# File existed as early as:	before 1990
#
# chongo <was here> /\oo/\	http://www.isthe.com/chongo/
# Share and enjoy!  :-)	http://www.isthe.com/chongo/tech/comp/calc/
#
# calculator by David I. Bell with help/mods from others
# Makefile by Landon Curt Noll

# Try uname -s if the target was not already set on the make command line
#
ifeq ($(target),)
target=$(shell uname -s 2>/dev/null)
endif

# The shell used by this Makefile
#
# On some systems, /bin/sh is a rather reduced shell with
# deprecated behavior.
#
# If your system has a up to date, bash shell, then
# you may wish to use:
#
#	SHELL= /bin/bash
#
# On some systems such as macOS, the bash shell is very
# far behind to the point wehre is cannot be depended on.
# On such systems, the zsh may be a much better alternative
# shell for this Makefile to use:
#
#	SHELL= /bin/zsh
#
ifeq ($(target),Darwin)
SHELL= /bin/zsh
else
SHELL= /bin/bash
endif

##############################################################################
#-=-=-=-=-=-=-=-=- You may want to change some values below -=-=-=-=-=-=-=-=-#
##############################################################################

# PREFIX - Top level location for calc
#
# The PREFIX is often prepended to paths within calc and calc Makefiles.
#
# Starting with calc v2.13.0.1, nearly all Makefile places that used
# /usr/local now use ${PREFIX}.  An exception is the olduninstall rule
# and, of course, this section. :-)
#
# When in doubt, try:
#
#	PREFIX= /usr/local
#
PREFIX= /usr/local
#PREFIX= /usr
#PREFIX= /usr/global

# CCBAN is given to ${CC} in order to control if banned.h is in effect.
#
# The banned.h attempts to ban the use of certain dangerous functions
# that, if improperly used, could compromise the computational integrity
# if calculations.
#
# In the case of calc, we are motivated in part by the desire for calc
# to correctly calculate: even durings extremely long calculations.
#
# If UNBAN is NOT defined, then calling certain functions
# will result in a call to a non-existent function (link error).
#
# While we do NOT encourage defining UNBAN, there may be
# a system / compiler environment where re-defining a
# function may lead to a fatal compiler complication.
# If that happens, consider compiling as:
#
#	make clobber all chk CCBAN=-DUNBAN
#
# as see if this is a work-a-round.
#
# If YOU discover a need for the -DUNBAN work-a-round, PLEASE tell us!
# Please send us a bug report.  See the file:
#
#	BUGS
#
# or the URL:
#
#	http://www.isthe.com/chongo/tech/comp/calc/calc-bugrept.html
#
# for how to send us such a bug report.
#
CCBAN= -UUNBAN
#CCBAN= -DUNBAN

# Determine of the GNU-readline facility will be used instead of the
# built-in calc binding method.
#
#USE_READLINE=
USE_READLINE= -DUSE_READLINE
#
#READLINE_LIB=
#READLINE_LIB= -L/usr/gnu/lib -lreadline -lhistory -lncurses
#READLINE_LIB= -L${PREFIX}/lib -lreadline -lhistory -lncurses
ifeq ($(target),Darwin)
# homebrew installs readline & history libs in ${PREFIX}/opt/readline/lib
READLINE_LIB= -L${PREFIX}/opt/readline/lib -lreadline -lhistory -lncurses
else
READLINE_LIB= -lreadline -lhistory -lncurses
endif
#
ifeq ($(target),Darwin)
# homebrew installs readline & history *.h under ${PREFIX}/opt/readline/include
READLINE_INCLUDE= -I${PREFIX}/opt/readline/include
else
READLINE_INCLUDE=
endif
#READLINE_INCLUDE= -I/usr/gnu/include
#READLINE_INCLUDE= -I${PREFIX}/include

# Normally certain files depend on the Makefile.  If the Makefile is
# changed, then certain steps should be redone.	 If MAKE_FILE is
# set to Makefile, then these files will depend on Makefile.  If
# MAKE_FILE is empty, then they wont.
#
MAKE_FILE= Makefile.ship

# Controlling file makefile basename (without the path)
#
# This is the basename same of the makefile that may/does/will drive
# this makefile.
#
TOP_MAKE_FILE= Makefile

# Some out of date operating systems require / want an executable to
# end with a certain file extension.  Some compile systems such as
# Cygwin build calc as calc.exe.  The EXT variable is used to denote
# the extension required by such.
#
EXT=
#EXT=.exe

# This value is configured for chongo for his laptop
#
RPM_TOP= ${HOME}/rpm/calc

################
# compiler set #
################

CCWERR= -Werror -Wextra -pedantic

#################################
# clang -fsanitize test options #
#################################

ifeq ($(target),Darwin)
COMMON_ADD=
else
COMMON_ADD=
endif

##############################################################################
#-=-=-=-=-=-=-=-=- Be careful if you change something below -=-=-=-=-=-=-=-=-#
##############################################################################

# standard utilities used during make
#
MAKE= make
SED= sed
GREP= egrep
RM= rm
CP= cp
MV= mv
CO= co
CMP= cmp
NROFF= nroff
CHECK= check
CI= ci

# Makefile debug
#
# Q=@	do not echo internal Makefile actions (quiet mode)
# Q=	echo internal Makefile actions (debug / verbose mode)
#
# H=@:	do not report hsrc file formation progress
# H=@	do echo hsrc file formation progress
#
# S= >/dev/null 2>&1	slience ${CC} output during hsrc file formation
# S=			full ${CC} output during hsrc file formation
#
# E= 2>/dev/null	slience command stderr during hsrc file formation
# E=			full command stderr during hsrc file formation
#
# V=@:	do not echo debug statements (quiet mode)
# V=@	do echo debug statements (debug / verbose mode)
#
#Q=
Q=@
#
S= >/dev/null 2>&1
#S=
#
E= 2>/dev/null
#E=
#
#H=@:
H=@
#
V=@:
#V=@

##############################################################################
#-=-=-=-=-=- start of make variables not found in Makefile.ship -=-=-=-=-=-=-#
##############################################################################

# We pass these arguments to the make command that invokes the ${MAKE_FILE}.
#
XARG=

# We pass these make variables to the end of each make command line
# that invokes the ${MAKE_FILE}.
#
XVAR= \
	CCBAN='${CCBAN}' \
	CCWERR='${CCWERR}' \
	COMMON_ADD='${COMMON_ADD}' \
	DARWIN_ARCH='${DARWIN_ARCH}' \
	E='${E}' \
	EXT='${EXT}' \
	H='${H}' \
	MAKE_FILE='${MAKE_FILE}' \
	NROFF='${NROFF}' \
	Q='${Q}' \
	PREFIX='${PREFIX}' \
	READLINE_INCLUDE='${READLINE_INCLUDE}' \
	READLINE_LIB='${READLINE_LIB}' \
	RPM_TOP='${RPM_TOP}' \
	S='${S}' \
	USE_READLINE='${USE_READLINE}' \
	V='${V}' \
	target=${target}

# We update the calc version string in these makefiles
#
XMKVER= ${MAKE_FILE} custom/Makefile.head

##############################################################################
#-=-=-=-=-=-=- end of make variables not found in Makefile.ship -=-=-=-=-=-=-#
##############################################################################

###
#
# The reason for this Makefile	:-)
#
###

all: fix_version
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

check_include:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calc-dynamic-only:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR} BLD_TYPE=$@
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calc-static-only:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR} BLD_TYPE=$@
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calc${EXT}: fix_version
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

libcalc.so.%: fix_version
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calc.1:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calc.usage:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

##############################################################################
#-=-=-=-=-=-=- start of make rules not found in Makefile.ship -=-=-=-=-=-=-=-#
##############################################################################

%.o: %.c
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

fix_version:
	@VERSION="`${MAKE} -f Makefile version|${GREP} '^[0-9]'`"; \
	CALC_VERSION="`${MAKE} -f Makefile calc_version|${GREP} '^[0-9]'`"; \
	if [ "$$CALC_VERSION" != "$$VERSION" ]; then \
	    echo "version check: $$CALC_VERSION != $$VERSION"; \
	    echo ${RM} -f Makefile.ship.bak custom/Makefile.head.bak; \
	    ${RM} -f Makefile.ship.bak custom/Makefile.head.bak; \
	    echo ${MAKE} -f Makefile update_version cleanup_version; \
	    ${MAKE} -f Makefile update_version cleanup_version; \
	fi

update_version:
	@CALC_VERSION="`${MAKE} -f Makefile calc_version | ${GREP} '^[0-9]'`"; \
	if [ -z "$$CALC_VERSION" ]; then \
	    echo "empty version string(s), try doing a make clobber" 2>&1; \
	    exit 1; \
	fi; \
	for i in ${XMKVER}; do \
	    echo "updating version in $$i"; \
	    if [ -f "$$i.bak" ]; then \
	        echo "$$i.bak exists, remove or move it out of the way"; \
		exit 1; \
	    fi; \
	    ${RM} -f "$$i.tmp"; \
	    ${SED} -e 's/^VERSION=.*/VERSION= '"$$CALC_VERSION"'/' \
	    	   $$i > $$i.tmp; \
	    if ${CMP} -s "$$i" "$$i.tmp"; then \
		${RM} -f "$$i.tmp"; \
		echo "versions already up to date in $$i"; \
	    else \
		${CP} -f "$$i" "$$i.bak"; \
		if [ ! -w "$$i" ]; then \
		    echo "${CO} -l $$i"; \
		    ${CO} -l "$$i"; \
		fi; \
		${MV} -f "$$i.tmp" "$$i"; \
		echo "updated version in $$i"; \
	    fi; \
	done

cleanup_version:
	@if ${CHECK} Makefile.ship >/dev/null; then \
	    :; \
	else \
	    echo ${CI} -u -m'updated version' Makefile.ship; \
	    ${CI} -u -m'updated version' Makefile.ship; \
	fi
	@if ${CHECK} custom/Makefile.head >/dev/null; then \
	    :; \
	else \
	    echo ${CI} -u -m'updated version' custom/Makefile.head; \
	    ${CI} -u -m'updated version' custom/Makefile.head; \
	fi
	@${RM} -f Makefile.ship.bak custom/Makefile.head.bak

##############################################################################
#-=-=-=-=-=-=-=- end of make rules not found in Makefile.ship -=-=-=-=-=-=-=-#
##############################################################################

##
#
# These rules compile the sample code against the calc library
#
##

sample:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

##
#
# The next set of rules cause the .h files BUILD_H_SRC files to be built
# according tot he system and the Makefile variables above.  The hsrc rule
# is a convenient rule to invoke to built all of the BUILD_H_SRC.
#
# We add in the BUILD_C_SRC files because they are similar to the
# BUILD_H_SRC files in terms of the build process.
#
# NOTE: Due to bogus shells found on one common system we must have
#	an non-empty else clause for every if condition.  *sigh*
#	We also place ; ${TRUE} at the end of some commands to avoid
#	meaningless cosmetic messages by the same system.
#
##

hsrc:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

.hsrc:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

conf.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

endian_calc.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

longbits.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_times.h: ${MAKE_FILE}
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_stdlib.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_unistd.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_string.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

terminal.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_fpos.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_fpos_pos.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

fposval.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_const.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_offscl.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_posscl.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

align32.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_uid_t.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_newstr.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_memmv.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_ustat.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_getsid.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_getpgid.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_gettime.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_getprid.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_urandom.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_rusage.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_strdup.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

args.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calcerr.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calcerr.c:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_unused.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_ban_pragma.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_strlcpy.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

have_strlcat.h:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

##
#
# Build .h files for windoz based systems
#
# This is really a internal utility rule that is used to create the
# win32 sub-directory for distribution.
#
##

win32_hsrc:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

##
#
# These two .all rules are used to determine of the lower level
# directory has had its all rule performed.
#
##

cal/.all:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

help/.all:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

help/builtin:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

cscript/.all:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

custom/.all:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

###
#
# building calc-static and static lib*.a libraries
#
###

calc-static${EXT}:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

libcalc.a:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

custom/libcustcalc.a:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

libcustcalc.a:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

##
#
# Home grown make dependency rules.  Your system make not support
# or have the needed tools.  You can ignore this section.
#
# We will form a skeleton tree of *.c files containing only #include "foo.h"
# lines and .h files containing the same lines surrounded by multiple include
# prevention lines.  This allows us to build a static depend list that will
# satisfy all possible cpp symbol definition combinations.
#
##

depend:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# generate the list of h files for lower level depend use
#
h_list:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

###
#
# calc version
#
###

calc_version:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

version:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

ver_calc${EXT}: version.c
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='


##
#
# File distribution list generation.  You can ignore this section.
#
# We will form the names of source files as if they were in a
# sub-directory called calc.
#
##

distlist:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

distdir:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calcliblist:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

calcliblistfmt:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

custom/Makefile:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

Makefile.simple:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

custom/Makefile.simple:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='


##
#
# Doing a 'make check' will cause the regression test suite to be executed.
# This rule will try to build anything that needs to be built as well.
#
# Doing a 'make chk' will cause only the context around interesting
# (and error) messages to be printed.  Unlike 'make check', this
# rule does not cause things to be built.  I.e., the all rule is
# not invoked.
#
##

check:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

chk:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='


##
#
# debug
#
# make calcinfo:
#       * print information about the host and compile environment
#
# make env:
#	* print major Makefile variables
#
# make mkdebug:
#	* print major Makefile variables
#	* build anything not yet built
#
# make debug:
#	* remove everything that was previously built
#	* print major Makefile variables
#	* make everything
#	* run the regression tests
#
# make prep:
#	* compile without optimizers to make debugging easier
##

calcinfo:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

env:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

mkdebug:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

debug:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

prep:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='


##
#
# make run
#	* only run calc interactively with the ${CALC_ENV} environment
#
# make dbx
#	* run the dbx debugger on calc with the ${CALC_ENV} environment
#
# make gdb
#	* run the gdb debugger on calc with the ${CALC_ENV} environment
#
##

run:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

dbx:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

gdb:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='


##
#
# rpm rules
#
##

rpm:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

rpm-hide-static:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

rpm-unhide-static:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

rpm-chk-static:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

rpm-clean-static:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

rpm-preclean:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='


##
#
# Utility rules
#
##

# Form the installed file list
#
inst_files:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# The olduninstall rule will remove calc files from the older, historic
# locations under the /usr/local directory.  If you are using the
# new default values for ${BINDIR}, ${CALC_SHAREDIR}, ${INCDIR} and ${LIBDIR}
# then you can use this rule to clean out the older calc stuff under
# the /usr/local directory.
#
olduninstall:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

tags:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

clean:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

clobber:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# install everything
#
# NOTE: Keep the uninstall rule in reverse order to the install rule
#
install:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# Try to remove everything that was installed
#
# NOTE: Keep the uninstall rule in reverse order to the install rule
#
uninstall:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# splint - A tool for statically checking C programs
#
splint:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# strip - for reducing the size of the binary files
#
strip:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# calc-symlink - setup symlinks from standard locations into the ${T} tree
#
calc-symlink:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='

# remove any symlinks that may have been created by calc-symlink
#
calc-unsymlink:
	${V} echo '=-=-=-=-= private Makefile $@ rule start =-=-=-=-='
	${Q} ${MAKE} ${XARG} -f ${MAKE_FILE} $@ ${XVAR}
	${V} echo '=-=-=-=-= private Makefile $@ rule end =-=-=-=-='
