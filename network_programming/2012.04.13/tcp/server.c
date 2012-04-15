#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>

int main(int argc, char **argv)
{
  int listening_socket;
  unsigned short port;
  int backlog;

  //------------------------------------------------------------------
  // Command line arguments
  //------------------------------------------------------------------
  port = (unsigned short) strtol(argv[2], NULL, 10);
  backlog = (int) strtol(argv[3], NULL, 10);

  //------------------------------------------------------------------
  // step 1, create socket
  //------------------------------------------------------------------
  //int socket(int domain, int type, int protocol);
  if ((listening_socket = socket(PF_INET, SOCK_STREAM, 0)) < 0)
  {
    // failed
    fprintf(stderr, "Create new TCP socket failed: %s\n", strerror(errno));
    exit(1);
  }

#ifdef _DEBUG_
  fprintf(stdout, "Created a new TCP socket, listening_socket = %d\n", listening_socket);
#endif

  //------------------------------------------------------------------
  // Set SO_REUSEADDR & SO_REUSEPORT options
  //------------------------------------------------------------------
  int optval;

  optval = 1;
  //int setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen);
  setsockopt(listening_socket, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));

#ifdef SO_REUSEPORT
  optval = 1;
  //int setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen);
  setsockopt(listening_socket, SOL_SOCKET, SO_REUSEPORT, &optval, sizeof(optval));
#endif

  //------------------------------------------------------------------
  // step 2, bind 
  //------------------------------------------------------------------
  struct sockaddr_in local_ipv4_address;

#if 0
  struct sockaddr_in
  {
    sa_family_t sin_family;
    in_port_t sin_port;
    struct in_addr sin_addr;
    unsigned char sin_zero[8];
  };
#endif

  memset(&local_ipv4_address, 0, sizeof(local_ipv4_address));

  local_ipv4_address.sin_family = AF_INET;	// IPv4
  local_ipv4_address.sin_port = htons(port);	// Network byte order

  //int inet_pton(int af, const char *src, void *dst);
  inet_pton(AF_INET, argv[1], &local_ipv4_address.sin_addr);
  //local_ipv4_address.sin_addr.s_addr = INADDR_ANY;

  //int bind(int sockfd, const struct sockaddr *my_addr, socklen_t addrlen);
  if (bind(listening_socket, (struct sockaddr *) &local_ipv4_address, sizeof(local_ipv4_address)) < 0)
  {
    fprintf(stderr, "Bind to %s:%d failed: %s\n", argv[1], port, strerror(errno));
    close(listening_socket);
    exit(1);
  }

#ifdef _DEBUG_
  fprintf(stdout, "Bound to %s:%d successfully.\n", argv[1], port);
#endif

  //------------------------------------------------------------------
  // step 3, listen
  //------------------------------------------------------------------
  // int listen(int sockfd, int backlog);
  if (listen(listening_socket, backlog) < 0)
  {
    fprintf(stderr, "Listen on %s:%d failed: %s\n", argv[1], port, strerror(errno));
    close(listening_socket);
    exit(1);
  }

#ifdef _DEBUG_
  fprintf(stdout, "Listen on %s:%d successfully.\n", argv[1], port);
#endif

  int new_connected_socket;
  struct sockaddr_in peer_ipv4_address;	// IPv4
  socklen_t peer_ipv4_address_length;

  //------------------------------------------------------------------
  // Main loop
  //------------------------------------------------------------------
  for (;;)
  {
    // peer_ipv4_address is value-result parameter
    peer_ipv4_address_length = sizeof(peer_ipv4_address);

    //----------------------------------------------------------------
    // step 4, accept, create a new_connected_socket, original socket still listen
    //----------------------------------------------------------------
    //int accept(int sockfd, struct sockaddr *addr, socklen_t * addrlen);
    if ((new_connected_socket = accept(listening_socket, (struct sockaddr *) &peer_ipv4_address, &peer_ipv4_address_length)) < 0)
    {
      // failed
      if (errno == EINTR)
      {
	continue;
      }

      // FIXME: How to do?
      fprintf(stderr, "accept() failed: %s\n", strerror(errno));
      break;
    }
    else
    {
      // success
      char peer_ipv4_address_buffer[] = "ddd.ddd.ddd.ddd\0";

      //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
      inet_ntop(AF_INET, &peer_ipv4_address.sin_addr, peer_ipv4_address_buffer, sizeof(peer_ipv4_address_buffer));

#ifdef _DEBUG_
      fprintf(stdout, "Accepted a new connection %d from %s:%d.\n", new_connected_socket, peer_ipv4_address_buffer, ntohs(peer_ipv4_address.sin_port));
#endif

      //--------------------------------------------------------------
      // Implement blacklist/whitelist to filter incomming connections
      //--------------------------------------------------------------

      // step 5, r/w on new_connected_socket
      char banner[] = "Welcome to AKAE T49 test server, version 0.1\n";

      // ssize_t write(int listening_socket, const void *buf, size_t count);
      write(new_connected_socket, banner, strlen(banner));

      // step 6, close new_connected_socket
      close(new_connected_socket);
    }
  }

  //------------------------------------------------------------------
  // final, close listening_socket
  //------------------------------------------------------------------
  close(listening_socket);

  return 0;
}

// vim:tabstop=8
