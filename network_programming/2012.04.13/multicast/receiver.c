#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>

//--------------------------------------------------------------------
// Macro definition
//--------------------------------------------------------------------
#define BUFFER_SIZE	1024

//--------------------------------------------------------------------
// Main function
// Usage: ./receiver <bind ip> <bind port> <multicast group> <interface>
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  int fd;
  unsigned short port;

  //------------------------------------------------------------------
  // Parse command line arguments
  //------------------------------------------------------------------
  port = (unsigned short) strtol(argv[2], NULL, 10);

  //------------------------------------------------------------------
  // step 1, create socket, type = SOCK_DGRAM
  //------------------------------------------------------------------
  //int socket(int domain, int type, int protocol);
  if ((fd = socket(PF_INET, SOCK_DGRAM, 0)) < 0)
  {
    fprintf(stderr, "Create new UDP socket failed: %s\n", strerror(errno));
    exit(1);
  }

  fprintf(stdout, "Created a new UDP socket, fd = %d\n", fd);

  //------------------------------------------------------------------
  // step 2, bind is necessary
  //------------------------------------------------------------------
  struct sockaddr_in local_ipv4_address;

  memset(&local_ipv4_address, 0, sizeof(local_ipv4_address));

  local_ipv4_address.sin_family = AF_INET;	// IPv4
  local_ipv4_address.sin_port = htons(port);	// Network byte order
  inet_pton(AF_INET, argv[1], &local_ipv4_address.sin_addr);

  //int bind(int sockfd, const struct sockaddr *my_addr, socklen_t addrlen);
  if (bind(fd, (struct sockaddr *) &local_ipv4_address, sizeof(local_ipv4_address)) < 0)
  {
    // failed
    fprintf(stderr, "Bind to %s:%d failed: %s\n", argv[1], port, strerror(errno));
    close(fd);
    exit(1);
  }

  fprintf(stdout, "Bound to %s:%d successfully.\n", argv[1], port);

  //------------------------------------------------------------------
  // Join multicast group
  // http://tldp.org/HOWTO/Multicast-HOWTO-6.html
  // You can use "netstat -g" command to check membership
  //------------------------------------------------------------------
  struct ip_mreq mreq;

#if 0
  struct ip_mreq
  {
    struct in_addr imr_multiaddr;	/* IP multicast address of group */
    struct in_addr imr_interface;	/* local IP address of interface */
  };
#endif

  //int inet_pton(int af, const char *src, void *dst);
  inet_pton(AF_INET, argv[3], &mreq.imr_multiaddr);
  inet_pton(AF_INET, argv[4], &mreq.imr_interface);

  //int setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen);
  if (setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0)
  {
    fprintf(stderr, "Join multicast group failed: %s\n", strerror(errno));
    close(fd);
    exit(1);
  }
  
  fprintf(stdout, "Join multicast group successfully.\n");
    
  //------------------------------------------------------------------
  // Main loop
  //------------------------------------------------------------------

  for (;;)
  {
    //----------------------------------------------------------------
    // Receive data
    //----------------------------------------------------------------
    struct sockaddr_in peer_ipv4_address;
    socklen_t peer_ipv4_address_length;
    char peer_ipv4_address_buffer[] = "ddd.ddd.ddd.ddd";
    char buffer[BUFFER_SIZE];
    ssize_t n;

    // peer_ipv4_address_length is a value-result parameter
    peer_ipv4_address_length = sizeof(peer_ipv4_address);

    //ssize_t recvfrom(int s, void *buf, size_t len, int flags, struct sockaddr *from, socklen_t * fromlen);
    if ((n = recvfrom(fd, buffer, sizeof(buffer) - 1, 0, (struct sockaddr *) &peer_ipv4_address, &peer_ipv4_address_length)) < 0)
    {
      fprintf(stderr, "Receive data from server failed: %s\n", strerror(errno));
      close(fd);
      exit(1);
    }

    buffer[n] = '\0';
    inet_ntop(AF_INET, &peer_ipv4_address.sin_addr, peer_ipv4_address_buffer, sizeof(peer_ipv4_address_buffer));

    fprintf(stdout, "Received %d bytes from %s:%d: %s\n", n, peer_ipv4_address_buffer, ntohs(peer_ipv4_address.sin_port), buffer);

    //----------------------------------------------------------------
    // echo back
    //----------------------------------------------------------------

    //ssize_t sendto(int s, const void *buf, size_t len, int flags, const struct sockaddr *to, socklen_t tolen);
    if ((n = sendto(fd, buffer, n, 0, (struct sockaddr *) &peer_ipv4_address, sizeof(peer_ipv4_address))) < 0)
    {
      fprintf(stderr, "Send message to %s:%d failed: %s\n", peer_ipv4_address_buffer, ntohs(peer_ipv4_address.sin_port), strerror(errno));
      close(fd);
      exit(1);
    }

    fprintf(stdout, "Send %d bytes to %s:%d successfully.\n", n, peer_ipv4_address_buffer, ntohs(peer_ipv4_address.sin_port));
  }

  //------------------------------------------------------------------
  // Leave from multicast group
  //------------------------------------------------------------------
  //int inet_pton(int af, const char *src, void *dst);
  inet_pton(AF_INET, argv[3], &mreq.imr_multiaddr);
  inet_pton(AF_INET, argv[4], &mreq.imr_interface);

  //int setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen);
  if (setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0)
  {
    fprintf(stderr, "Leave from multicast group failed: %s\n", strerror(errno));
    close(fd);
    exit(1);
  }
    
  fprintf(stdout, "Leave from multicast group successfully.\n");

  //------------------------------------------------------------------
  // step 4, close
  //------------------------------------------------------------------
  close(fd);

  return 0;
}
