#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>		// unix domain protocol
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
  int listening_socket;
  int backlog;

  //------------------------------------------------------------------
  // Parse command line arguments
  //------------------------------------------------------------------
  backlog = (int) strtol(argv[2], NULL, 10);

  //------------------------------------------------------------------
  // step 1, create socket
  //------------------------------------------------------------------
  //int socket(int domain, int type, int protocol);
  if ((listening_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0)
  {
    fprintf(stderr, "Create new UNIX domain socket failed: %s\n", strerror(errno));
    exit(1);
  }

  fprintf(stdout, "Created a new UNIX domain socket, listening_socket = %d\n", listening_socket);

  //------------------------------------------------------------------
  // step 2, bind
  //------------------------------------------------------------------
  struct sockaddr_un local_unixdomain_address;	// unix domain

#if 0
  struct sockaddr_un
  {
    sa_family_t sun_family;
    char sun_path[108];
  };
#endif

  memset(&local_unixdomain_address, 0, sizeof(local_unixdomain_address));

  local_unixdomain_address.sun_family = AF_UNIX;	// unix domain
  //void *memcpy(void *dest, const void *src, size_t n);
  memcpy(local_unixdomain_address.sun_path, argv[1], strlen(argv[1]));

  //int bind(int sockfd, const struct sockaddr *my_addr, socklen_t addrlen);
  if (bind(listening_socket, (struct sockaddr *) &local_unixdomain_address, sizeof(local_unixdomain_address)) < 0)
  {
    fprintf(stderr, "Bind to %s failed: %s\n", argv[1], strerror(errno));
    close(listening_socket);
    exit(1);
  }

  fprintf(stdout, "Bound to %s successfully.\n", argv[1]);

  //------------------------------------------------------------------
  // step 3, listen
  //------------------------------------------------------------------
  // int listen(int sockfd, int backlog);
  if (listen(listening_socket, backlog) < 0)
  {
    fprintf(stderr, "Listen on %s failed: %s\n", argv[1], strerror(errno));
    close(listening_socket);
    exit(1);
  }

  fprintf(stdout, "Listen on %s successfully.\n", argv[1]);

  for (;;)
  {
    // step 4, accept
    int new_connected_socket;
    struct sockaddr_un peer_unixdomain_address;
    socklen_t peer_unixdomain_address_length;

    peer_unixdomain_address_length = sizeof(peer_unixdomain_address);

    // int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
    if ((new_connected_socket = accept(listening_socket, (struct sockaddr *) &peer_unixdomain_address, &peer_unixdomain_address_length)) < 0)
    {
      // failed
      if (errno == EINTR)
      {
	continue;
      }

      fprintf(stderr, "Accept new connection on %s failed: %s\n", argv[1], strerror(errno));
      break;
    }
    else
    {
      fprintf(stdout, "Accepted a new connection %d from %s.\n", new_connected_socket, peer_unixdomain_address.sun_path);

      // step 5, r/w on new_connected_socket
      char buffer[BUFFER_SIZE];
      ssize_t n;

      // ssize_t recv(int s, void *buf, size_t len, int flags);
      if ((n = recv(new_connected_socket, buffer, sizeof(buffer) - 1, 0)) < 0)
      {
	// failed
	if (errno == EINTR)
	{
	  continue;
	}

	fprintf(stderr, "Receive data on socket %d failed: %s\n", new_connected_socket, strerror(errno));
	break;
      }
      else if (n == 0)
      {
	// Connetion closed by peer.
	fprintf(stdout, "Connection closed by peer.\n");
      }
      else
      {
	// success
	fprintf(stdout, "Received %d bytes from client, echo back.\n", n);

	// ssize_t send(int s, const void *buf, size_t len, int flags);
	if ((n = send(new_connected_socket, buffer, n, 0)) < 0)
	{
	  // failed
	  fprintf(stderr, "Send data to client failed: %s\n", strerror(errno));
	}
	else
	{
	  // success
	  fprintf(stdout, "Sent %d bytes to client.\n", n);
	}
      }

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
