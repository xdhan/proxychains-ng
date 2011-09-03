/***************************************************************************
                          main.c  -  description

    begin                : Tue May 14 2002
    copyright            :  netcreature (C) 2002
    email                : netcreature@users.sourceforge.net
 ***************************************************************************/
 /*     GPL */
/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>

extern char *optarg;
extern int optind, opterr, optopt;

#define PROXYCHAINS_CONF_FILE "proxychains.conf"

static void usage(char** argv) {
	printf("\nUsage:	 %s [h] [f] config_file program_name [arguments]\n"
		"\t for example : proxychains telnet somehost.com\n"
		"More help in README file\n", argv[0]);
}

int main(int argc, char *argv[]) {
	char *path = NULL;
	char buf[256];
	char pbuf[256];
	int opt;

	while ((opt = getopt(argc, argv, "fh:")) != -1) {
		switch (opt) {
			case 'h':
				usage(argv);
				break;
			case 'f':
				path = (char *)optarg;
				break;
			default: /* '?' */
				usage(argv);
				exit(EXIT_FAILURE);
			}
	}

	if(!path) {
		if(!(path = getenv("PROXYCHAINS_CONF_FILE")))
			path = getcwd(buf, sizeof(buf));
		else if(access(path, R_OK) != -1) goto have; 
		if(!path ||
			!snprintf(pbuf, sizeof(pbuf), "%s/%s", path, PROXYCHAINS_CONF_FILE) ||
			access(pbuf, R_OK) == -1
		) 
			path = "/etc/proxychains.conf";
		else 
			path = pbuf;
	}
	if(access(path, R_OK) == -1) {
		perror("couldnt find configuration file");
		return 1;
	}
	have:

	printf("Proxychains is going to use %s as config file.\n", path);
	printf("argv = %s\n", argv[1]);

	/* Set PROXYCHAINS_CONF_FILE to get proxychains lib to use new config file. */
	setenv("PROXYCHAINS_CONF_FILE", path, 1);
	
	snprintf(buf, sizeof(buf), "LD_PRELOAD=%s/libproxychains.so", LIB_DIR);
	putenv(buf);
	execvp(argv[1], &argv[1]);
	perror("proxychains can't load process....");

	return EXIT_SUCCESS;
}
