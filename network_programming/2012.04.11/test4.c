#include <stdio.h>
#include <netinet/in.h>		// IPv4, IPv6
#include <sys/un.h>		// unixdomain
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

int main(int argc, char **argv)
{
  int fd;
  unsigned short port;
  char ipv4_address_string[] = "192.168.204.6";

  // used to define function prototype
  struct sockaddr generic_address_structure;

#if 0
  struct sockaddr
  {
    sa_family_t sa_family;
    char sa_data[14];
  };
#endif

#if 0
  int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen);
  int bind(int sockfd, const struct sockaddr *my_addr, socklen_t addrlen);
  int accept(int sockfd, struct sockaddr *addr, socklen_t * addrlen);
  ssize_t recvfrom(int s, void *buf, size_t len, int flags, struct sockaddr *from, socklen_t * fromlen);
  ssize_t sendto(int s, const void *buf, size_t len, int flags, const struct sockaddr *to, socklen_t tolen);
#endif

  struct sockaddr_in ipv4_address_structure;

#if 0
  struct sockaddr_in
  {
    sa_family_t sin_family;
    in_port_t sin_port;
    struct in_addr sin_addr;
    unsigned char sin_zero[8];
  };
#endif

  // step 1, memset
  memset(&ipv4_address_structure, 0, sizeof(ipv4_address_structure));

  // step 2, set fields
  ipv4_address_structure.sin_family = AF_INET;	// IPv4
  ipv4_address_structure.sin_port = htons(port);	// Network byte order
  inet_pton(AF_INET, ipv4_address_string, &ipv4_address_structure.sin_addr);

  // step 3, call function
  //int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen);
  connect(fd, (struct sockaddr *) &ipv4_address_structure, sizeof(ipv4_address_structure));

  struct sockaddr_in6 ipv6_address_structure;

#if 0
  struct sockaddr_in6
  {
    sa_family_t sin6_family;
    in_port_t sin6_port;
    uint32_t sin6_flowinfo;
    struct in6_addr sin6_addr;
    uint32_t sin6_scope_id;
  };
#endif

  struct sockaddr_un unixdomain_address_structure;

#if 0
  struct sockaddr_un
  {
    sa_family_t sun_family;
    char sun_path[108];
  };
#endif

  return 0;
}

// vim:tabstop=8
