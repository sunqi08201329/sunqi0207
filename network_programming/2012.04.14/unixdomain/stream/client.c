#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
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

  //------------------------------------------------------------------
  // step 1, create socket
  //------------------------------------------------------------------
  //int socket(int domain, int type, int protocol);
  if ((fd = socket(PF_UNIX, SOCK_STREAM, 0)) < 0)
  {
    // failed
    fprintf(stderr, "Create new TCP socket failed: %s\n", strerror(errno));
    exit(1);
  }

  fprintf(stdout, "Created a new TCP socket, fd = %d\n", fd);

  //------------------------------------------------------------------
  // step 2, connect
  //------------------------------------------------------------------
  struct sockaddr_un remote_unixdomain_address;	// unixdomain

  memset(&remote_unixdomain_address, 0, sizeof(remote_unixdomain_address));

  remote_unixdomain_address.sun_family = AF_UNIX;	// unixdomain
  memcpy(remote_unixdomain_address.sun_path, argv[1], strlen(argv[1]));

  //int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen);
  if (connect(fd, (struct sockaddr *) &remote_unixdomain_address, sizeof(remote_unixdomain_address)) < 0)
  {
    // FIXME: retry some times?
    fprintf(stderr, "Connect to remote server %s failed: %s\n", argv[1], strerror(errno));
    close(fd);
    exit(1);
  }

  fprintf(stdout, "Connected to remote server %s", argv[1]);

  //------------------------------------------------------------------
  // Compose http request, 
  // refer to RFC2616: http://www.ietf.org/rfc/rfc2616.txt
  //------------------------------------------------------------------
  char http_request[] = "GET / HTTP/1.0\nConnection: close\n\n";

  //------------------------------------------------------------------
  // Send request to WEB server
  //------------------------------------------------------------------
  ssize_t total = strlen(http_request);
  ssize_t sent = 0;
  ssize_t n;

  while (sent < total)
  {
    //ssize_t write(int fd, const void *buf, size_t count);
    if ((n = write(fd, http_request + sent, total - sent)) < 0)
    {
      // failed
      if (errno == EINTR)
      {
	// Interrupted by a signal
	continue;
      }
      else
      {
	// FIXME: check errno
	fprintf(stderr, "Send data to remote server failed: %s\n", strerror(errno));
	break;
      }
    }
    else
    {
      fprintf(stdout, "Sent %d bytes.\n", n);
      sent += n;
    }
  }

  //------------------------------------------------------------------
  // Receive response from server
  //------------------------------------------------------------------
  char buffer[BUFFER_SIZE];

  for (;;)
  {
    //ssize_t read(int fd, void *buf, size_t count);
    if ((n = read(fd, buffer, sizeof(buffer) - 1)) < 0)
    {
      // failed
      if (errno == EINTR)
      {
	// Interrupted by signal
	continue;
      }

      // FIXME: check errno
      fprintf(stderr, "Receive data failed: %s\n", strerror(errno));
      break;
    }
    else if (n == 0)
    {
      // Connection closed by peer.
      fprintf(stdout, "Connection closed by peer.\n");
      break;
    }
    else
    {
      // success
      buffer[n] = '\0';
      fprintf(stdout, "Received %d bytes from server: \n%s\n", n, buffer);
    }
  }

  //------------------------------------------------------------------
  // step 4, close
  //------------------------------------------------------------------
  close(fd);

  return 0;
}

// vim:tabstop=8
