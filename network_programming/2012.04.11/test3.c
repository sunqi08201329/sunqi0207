#include <stdio.h>
#include <netdb.h>

int main(int argc, char **argv)
{
  struct servent *s;

#if 0
  struct servent
  {
    char *s_name;		/* official service name */
    char **s_aliases;		/* alias list */
    int s_port;			/* port number */
    char *s_proto;		/* protocol to use */
  };
#endif

  //struct servent *getservbyname(const char *name, const char *proto);
  s = getservbyname(argv[1], argv[2]);

  if (s == NULL)
  {
    fprintf(stderr, "Failed.\n");
  }

  fprintf(stdout, "Official service name: %s\n", s->s_name);
  fprintf(stdout, "Aliases: \n");

  char **p;

  p = s->s_aliases;

  while (p && *p)
  {
    fprintf(stdout, "\t%s\n", *p);
    p++;
  }

  fprintf(stdout, "Port number: %d\n", ntohs(s->s_port));

  fprintf(stdout, "Prtocol: %s\n", s->s_proto);

  return 0;
}

// vim:tabstop=8
