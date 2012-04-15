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
  // step 2, bind is optional
  //------------------------------------------------------------------

  //------------------------------------------------------------------
  // step 3, sendto/recvfrom
  //------------------------------------------------------------------
  struct sockaddr_in peer_ipv4_address;

  memset(&peer_ipv4_address, 0, sizeof(peer_ipv4_address));

  peer_ipv4_address.sin_family = AF_INET;	//IPv4
  peer_ipv4_address.sin_port = htons(port);	// Network byte order

  // int inet_pton(int af, const char *src, void *dst);
  inet_pton(AF_INET, argv[1], &peer_ipv4_address.sin_addr);

  ssize_t n;

  //ssize_t sendto(int s, const void *buf, size_t len, int flags, const struct sockaddr *to, socklen_t tolen);
  if ((n = sendto(fd, argv[3], strlen(argv[3]), 0, (struct sockaddr *) &peer_ipv4_address, sizeof(peer_ipv4_address))) < 0)
  {
    fprintf(stderr, "Send message to %s:%d failed: %s\n", argv[1], port, strerror(errno));
    close(fd);
    exit(1);
  }

  fprintf(stdout, "Sent %d bytes to %s:%d successfully.\n", n, argv[1], port);

  //------------------------------------------------------------------
  // Receive data from server
  //------------------------------------------------------------------
  char buffer[BUFFER_SIZE];
  socklen_t peer_ipv4_address_length;

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
  fprintf(stdout, "Received %d bytes from server: %s\n", n, buffer);

  // step 4, close
  close(fd);

  return 0;
}
