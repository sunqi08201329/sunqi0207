STRING(3)                                                    Linux Programmer's Manual                                                    STRING(3)



NAME
       stpcpy,  strcasecmp, strcat, strchr, strcmp, strcoll, strcpy, strcspn, strdup, strfry, strlen, strncat, strncmp, strncpy, strncasecmp, strp‐
       brk, strrchr, strsep, strspn, strstr, strtok, strxfrm, index, rindex - string operations

SYNOPSIS
       #include <strings.h>

       int strcasecmp(const char *s1, const char *s2);

       int strncasecmp(const char *s1, const char *s2, size_t n);

       char *index(const char *s, int c);

       char *rindex(const char *s, int c);

       #include <string.h>

       char *stpcpy(char *dest, const char *src);

       char *strcat(char *dest, const char *src);

       char *strchr(const char *s, int c);

       int strcmp(const char *s1, const char *s2);

       int strcoll(const char *s1, const char *s2);

       char *strcpy(char *dest, const char *src);

       size_t strcspn(const char *s, const char *reject);

       char *strdup(const char *s);

       char *strfry(char *string);

       size_t strlen(const char *s);

       char *strncat(char *dest, const char *src, size_t n);

       int strncmp(const char *s1, const char *s2, size_t n);

       char *strncpy(char *dest, const char *src, size_t n);

       char *strpbrk(const char *s, const char *accept);

       char *strrchr(const char *s, int c);

       char *strsep(char **stringp, const char *delim);

       size_t strspn(const char *s, const char *accept);

       char *strstr(const char *haystack, const char *needle);

       char *strtok(char *s, const char *delim);

       size_t strxfrm(char *dest, const char *src, size_t n);

DESCRIPTION
       The string functions perform string operations on null-terminated strings.  See the individual man pages for descriptions of each function.

SEE ALSO
       index(3), rindex(3), stpcpy(3), strcasecmp(3), strcat(3), strchr(3), strcmp(3), strcoll(3),  strcpy(3),  strcspn(3),  strdup(3),  strfry(3),
       strlen(3),  strncasecmp(3),  strncat(3),  strncmp(3),  strncpy(3),  strpbrk(3),  strrchr(3),  strsep(3),  strspn(3),  strstr(3),  strtok(3),
       strxfrm(3)

COLOPHON
       This page is part of release 3.35 of the Linux man-pages project.  A description of the project, and information about reporting  bugs,  can
       be found at http://man7.org/linux/man-pages/.



                                                                     2010-02-25                                                           STRING(3)
