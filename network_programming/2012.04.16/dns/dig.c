#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <arpa/inet.h>

extern int h_errno;

int main(int argc, char **argv)
{
  struct hostent *h;

  //struct hostent *gethostbyname(const char *name);
  h = gethostbyname(argv[1]);

  if (!h)
  {
    fprintf(stderr, "Failed: %s\n", hstrerror(h_errno));
    exit(1);
  }

#if 0
  struct hostent
  {
    char *h_name;		/* official name of host */
    char **h_aliases;		/* alias list */
    int h_addrtype;		/* host address type */
    int h_length;		/* length of address */
    char **h_addr_list;		/* list of addresses */
  }
#  define h_addr  h_addr_list[0]	/* for backward compatibility */
#endif

  fprintf(stdout, "Official name: %s\n", h->h_name);

  fprintf(stdout, "Aliases:\n");

  char **p;
  p = h->h_aliases;

  while (p && *p)
  {
    fprintf(stdout, "\t%s\n", *p);
    p++;
  }

  if (h->h_addrtype == AF_INET)
  {
    // IPv4
    fprintf(stdout, "IPv4, %d\n", h->h_length);
  }
  else if (h->h_addrtype == AF_INET6)
  {
    // IPv6
    fprintf(stdout, "IPv6, %d\n", h->h_length);
  }

  fprintf(stdout, "Addresses:\n");

  char ip_string[INET6_ADDRSTRLEN + 1];

  p = h->h_addr_list;

  while (p && *p)
  {
    //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
    inet_ntop(h->h_addrtype, *p, ip_string, sizeof(ip_string));

    fprintf(stdout, "\t%s\n", ip_string);

    p++;
  }

  return 0;
}
