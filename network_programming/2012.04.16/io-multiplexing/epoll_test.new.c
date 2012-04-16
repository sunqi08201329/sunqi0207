#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <signal.h>
#include <string.h>
#include <errno.h>

//--------------------------------------------------------------------
// Macro definition
//--------------------------------------------------------------------
#define BUFFER_SIZE		1024
#define EPOLL_MAX_EVENTS	10

//--------------------------------------------------------------------
// Type definition
//--------------------------------------------------------------------
typedef struct
{
  char *data;
  unsigned long size;
  unsigned long payload_length;
} buf_t;

typedef struct
{
  buf_t *rbuf;
  buf_t *sbuf;
} conn_t;

//--------------------------------------------------------------------
// Global variables 
//--------------------------------------------------------------------
conn_t **global_conn_list = NULL;
int global_conn_list_count = 0;
int global_epfd;		// for epoll related functions

volatile sig_atomic_t global_exit_flag = 0;

//--------------------------------------------------------------------
// Function prototype
//--------------------------------------------------------------------
void *utils_safe_malloc(int n);
void utils_safe_free(void *p);

buf_t *create_buf_object(void);
void free_buf_object(buf_t * p);

conn_t *create_conn_object(void);
void free_conn_object(conn_t * p);

int init_conn_list(int n);
void free_conn_list(void);

void do_extra_job(void);

int net_accept(int listening_socket);
int net_read(int fd);
int net_write(int fd);

void sigpipe_handler(int sig);
void sigterm_handler(int sig);

int parse_data(int fd);
int buffered_send(int fd, char *data, unsigned long length);

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  int listening_socket;
  unsigned short port;
  int backlog;

  //------------------------------------------------------------------
  // Parse command line arguments
  //------------------------------------------------------------------
  port = (unsigned short) strtol(argv[2], NULL, 10);
  backlog = (int) strtol(argv[3], NULL, 10);

  //------------------------------------------------------------------
  // Intialize global_conn_list
  //------------------------------------------------------------------
  init_conn_list(1024);

  //------------------------------------------------------------------
  // Create global_epfd
  //------------------------------------------------------------------
  //int epoll_create(int size);
  if ((global_epfd = epoll_create(1024)) < 0)
  {
    fprintf(stderr, "Create global_epfd failed: %s\n", strerror(errno));
    exit(1);
  }

  fprintf(stdout, "Created global_epfd, global_epfd = %d\n", global_epfd);

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

  fprintf(stdout, "Created a new TCP socket, listening_socket = %d\n", listening_socket);

  //------------------------------------------------------------------
  // FIXME: set SO_REUSEADD & SO_REUSEPORT options
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
  struct sockaddr_in local_ipv4_address;	// Local IPv4 address

  memset(&local_ipv4_address, 0, sizeof(local_ipv4_address));

  local_ipv4_address.sin_family = AF_INET;
  local_ipv4_address.sin_port = htons(port);	// Network byte order

  //int inet_pton(int af, const char *src, void *dst);
  inet_pton(AF_INET, argv[1], &local_ipv4_address.sin_addr);

  // int bind(int sockfd, const struct sockaddr *my_addr, socklen_t addrlen);
  if (bind(listening_socket, (struct sockaddr *) &local_ipv4_address, sizeof(local_ipv4_address)) < 0)
  {
    fprintf(stderr, "Bind to %s:%d failed: %s\n", argv[1], port, strerror(errno));
    // FIXME: retry some times.
    close(listening_socket);
    exit(1);
  }

  fprintf(stdout, "Bound to %s:%d successfully.\n", argv[1], port);

  //------------------------------------------------------------------
  // step 3, listen
  //------------------------------------------------------------------
  //int listen(int sockfd, int backlog);
  if (listen(listening_socket, backlog) < 0)
  {
    fprintf(stderr, "Listen on %s:%d failed: %s\n", argv[1], port, strerror(errno));
    // FIXME: retry?
    close(listening_socket);
    exit(1);
  }

  fprintf(stdout, "Listening on %s:%d successfully.\n", argv[1], port);

  //------------------------------------------------------------------
  // Add listening_socket to epoll
  //------------------------------------------------------------------
  struct epoll_event event;

#if 0
  typedef union epoll_data
  {
    void *ptr;
    int fd;
    __uint32_t u32;
    __uint64_t u64;
  } epoll_data_t;

  struct epoll_event
  {
    __uint32_t events;		/* Epoll events */
    epoll_data_t data;		/* User data variable */
  };
#endif

  event.data.fd = listening_socket;
  event.events = 0;
  event.events |= EPOLLIN;

  //int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
  if (epoll_ctl(global_epfd, EPOLL_CTL_ADD, listening_socket, &event) < 0)
  {
    // When an error occurs, epoll_ctl(2) returns -1 and errno is set appropriately.
    fprintf(stderr, "Add listening_socket(%d) into global_epfd failed: %s\n", listening_socket, strerror(errno));
    // FIXME: release all resources
    exit(1);
  }

  fprintf(stdout, "Added listening_socket(%d) into global_epfd successfully.\n", listening_socket);

  //------------------------------------------------------------------
  // Register signal handler
  //------------------------------------------------------------------
  struct sigaction act, oact;

#if 0
  struct sigaction
  {
    void (*sa_handler) (int);
    void (*sa_sigaction) (int, siginfo_t *, void *);
    sigset_t sa_mask;
    int sa_flags;
    void (*sa_restorer) (void);
  }
#endif

  memset(&act, 0, sizeof(act));

  act.sa_handler = sigpipe_handler;
  sigemptyset(&act.sa_mask);
  act.sa_flags = 0;

  //int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);
  sigaction(SIGPIPE, &act, &oact);

  memset(&act, 0, sizeof(act));
  act.sa_handler = sigterm_handler;
  sigemptyset(&act.sa_mask);
  act.sa_flags = 0;

  sigaction(SIGINT, &act, &oact);
  sigaction(SIGQUIT, &act, &oact);
  sigaction(SIGTERM, &act, &oact);

  //------------------------------------------------------------------
  // Main loop
  //------------------------------------------------------------------
  for (;;)
  {
    if (global_exit_flag > 0)
    {
      fprintf(stdout, "It's time to exit, bye!\n");
      break;
    }

    struct epoll_event events[EPOLL_MAX_EVENTS];
    int n;

    //int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout);
    n = epoll_wait(global_epfd, events, EPOLL_MAX_EVENTS, 1000);

    if (n < 0)
    {
      // failed
      if (errno == EINTR)
      {
	continue;
      }
      else
      {
	fprintf(stderr, "select() failed: %s\n", strerror(errno));
	// FIXME: How to do?
	break;
      }
    }
    else if (n == 0)
    {
      // timeout
      fprintf(stdout, "timeout ...\n");
      do_extra_job();
    }
    else
    {
      int i;

      //--------------------------------------------------------------
      // Check every fds, one by one
      //--------------------------------------------------------------
      for (i = 0; i < n; i++)
      {
	// Readable?
	if (events[i].events & EPOLLIN)
	{
	  if (events[i].data.fd == listening_socket)
	  {
	    net_accept(events[i].data.fd);
	  }
	  else
	  {
	    net_read(events[i].data.fd);
	  }
	}

	// Writeable?
	if (events[i].events & EPOLLOUT)
	{
	  net_write(events[i].data.fd);
	}

	// TODO: check other events here if necessary
      }
    }
  }

  //------------------------------------------------------------------
  // Close listening_socket
  //------------------------------------------------------------------
  close(listening_socket);

  // TODO: Don't read any incoming data on each socket
  //int shutdown(int s, int how);

  // TODO: Send out all unsent data on each socket
  // TODO: Close all sockets, set SO_LINGER for all sockets

  //------------------------------------------------------------------
  // Destroy global_conn_list
  //------------------------------------------------------------------
  free_conn_list();

  return 0;
}

void do_extra_job(void)
{
  fprintf(stdout, "Do extra job ...\n");
}

void *utils_safe_malloc(int n)
{
  void *p;

  p = malloc(n);

  if (p == NULL)
  {
    fprintf(stderr, "Allocate memory failed, required size = %d\n", n);
    return NULL;
  }

  return p;
}

void utils_safe_free(void *p)
{
  if (p)
  {
    free(p);
    p = NULL;
  }
#ifdef _DEBUG_
  else
  {
    fprintf(stderr, "Attempt to destroy NULL pointer.\n");
  }
#endif
}

int init_conn_list(int n)
{
  int size = n * sizeof(conn_t *);

  global_conn_list = (conn_t **) utils_safe_malloc(size);

  if (global_conn_list == NULL)
  {
    // failed
    return -1;
  }

  int i;

  for (i = 0; i < n; i++)
  {
    global_conn_list[i] = NULL;
  }

  global_conn_list_count = n;

  return 0;
}

void free_conn_list(void)
{
  int i;

  for (i = 0; i < global_conn_list_count; i++)
  {
    if (global_conn_list[i])
    {
      free_conn_object(global_conn_list[i]);
      global_conn_list[i] = NULL;
    }
  }

  utils_safe_free(global_conn_list);
  global_conn_list = NULL;

  global_conn_list_count = 0;
}

conn_t *create_conn_object(void)
{
  conn_t *p;

  p = (conn_t *) utils_safe_malloc(sizeof(conn_t));

  if (!p)
  {
    return NULL;
  }

  p->rbuf = create_buf_object();
  p->sbuf = create_buf_object();

  if (!p->rbuf || !p->sbuf)
  {
    free_buf_object(p->rbuf);
    free_buf_object(p->sbuf);

    utils_safe_free(p);
  }

  return p;
}

void free_conn_object(conn_t * p)
{
  if (p)
  {
    free_buf_object(p->rbuf);
    free_buf_object(p->sbuf);

    utils_safe_free(p);
    p = NULL;
  }
}

buf_t *create_buf_object(void)
{
  buf_t *p;

  p = (buf_t *) utils_safe_malloc(sizeof(buf_t));

  if (!p)
  {
    return NULL;
  }

  p->data = (char *) utils_safe_malloc(BUFFER_SIZE);

  if (!p->data)
  {
    utils_safe_free(p);
    return NULL;
  }

  p->size = BUFFER_SIZE;
  p->payload_length = 0;

  return p;
}

void free_buf_object(buf_t * p)
{
  if (p)
  {
    utils_safe_free(p->data);
    utils_safe_free(p);

    p = NULL;
  }
}

int net_accept(int listening_socket)
{
  int new_connected_socket;
  struct sockaddr_in peer_ipv4_address;
  socklen_t peer_ipv4_address_length;
  char peer_ipv4_address_string[] = "ddd.ddd.ddd.ddd\0";

  peer_ipv4_address_length = sizeof(peer_ipv4_address);

  // int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
  if ((new_connected_socket = accept(listening_socket, (struct sockaddr *) &peer_ipv4_address, &peer_ipv4_address_length)) < 0)
  {
    // failed
    fprintf(stderr, "accept() failed: %s\n", strerror(errno));
    // FIXME: How to do?
    return -1;
  }
  else
  {
    //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
    inet_ntop(AF_INET, &peer_ipv4_address.sin_addr, peer_ipv4_address_string, sizeof(peer_ipv4_address_string));

    fprintf(stdout, "Accepted a new connection from %s:%d, new_connected_socket = %d.\n", peer_ipv4_address_string, ntohs(peer_ipv4_address.sin_port), new_connected_socket);

    conn_t *new_conn_object = create_conn_object();

    if (!new_conn_object)
    {
      // TODO: Send a error message to new incoming client
      close(new_connected_socket);
    }
    else
    {
      global_conn_list[new_connected_socket] = new_conn_object;

      struct epoll_event event;

      event.data.fd = new_connected_socket;
      event.events = EPOLLIN;

      //int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
      epoll_ctl(global_epfd, EPOLL_CTL_ADD, new_connected_socket, &event);
    }
  }

  return 0;
}

int net_read(int fd)
{
  ssize_t n;
  conn_t *c = global_conn_list[fd];

  if (!c)
  {
#ifdef _DEBUG_
    assert(c != NULL);
#endif

    fprintf(stderr, "Fatal error, no conn_t object exists.\n");
    return -1;
  }

  buf_t *rbuf = c->rbuf;

#ifdef _DEBUG_
  assert(rbuf != NULL);
#endif

  //ssize_t read(int fd, void *buf, size_t count);
  if ((n = read(fd, rbuf->data + rbuf->payload_length, rbuf->size - rbuf->payload_length)) < 0)
  {
    // failed
    fprintf(stderr, "Read data on socket (%d) failed: %s\n", fd, strerror(errno));
    return -1;
  }
  else if (n == 0)
  {
    fprintf(stdout, "Connection (fd = %d) closed by peer.\n", fd);

    // Connection closed by peer.
    close(fd);

    free_conn_object(global_conn_list[fd]);
    global_conn_list[fd] = NULL;

    // closed fd will be removed from epfd set by epoll automatically
  }
  else
  {
    fprintf(stdout, "Received %d bytes on socket %d.\n", n, fd);

    rbuf->payload_length += n;

    // if rbuf is full, increase rbuf size
    if (rbuf->payload_length >= rbuf->size)
    {
      unsigned long newsize = rbuf->size * 2;
      char *newdata = (char *) utils_safe_malloc(newsize);

      if (newdata)
      {
	// void *memcpy(void *dest, const void *src, size_t n);
	memcpy(newdata, rbuf->data, rbuf->payload_length);
	utils_safe_free(rbuf->data);
	rbuf->data = newdata;
	rbuf->size = newsize;
      }
      else
      {
	// FIXME: How to do?
	fprintf(stderr, "Cannot increase receive buffer, how to do?\n");
      }
    }
  }

  return 0;
}

int net_write(int fd)
{
  ssize_t n;
  conn_t *c = global_conn_list[fd];

  if (!c)
  {
#ifdef _DEBUG_
    assert(c != NULL);
#endif

    fprintf(stderr, "Fatal error, no conn_t object exists.\n");
    return -1;
  }

  buf_t *sbuf = c->sbuf;

#ifdef _DEBUG_
  assert(sbuf != NULL);
#endif

write_again:
  //ssize_t write(int fd, const void *buf, size_t count);
  if ((n = write(fd, sbuf->data, sbuf->payload_length)) < 0)
  {
    // failed
    if (errno == EINTR)
    {
      goto write_again;
    }
    else if (errno == EPIPE)
    {
      // Connection closed by peer.
      close(fd);

      free_conn_object(global_conn_list[fd]);
      global_conn_list[fd] = NULL;

      // closed fd will be removed from epfd set by epoll automatically
    }
    else
    {
      fprintf(stderr, "Send data on socket (%d) failed: %s\n", fd, strerror(errno));
    }
  }
  else
  {
    fprintf(stdout, "Sent %d bytes on socket %d successfully.\n", n, fd);

    //void *memmove(void *dest, const void *src, size_t n);
    memmove(sbuf->data, sbuf->data + n, sbuf->payload_length - n);
    sbuf->payload_length -= n;

    if (sbuf->payload_length == 0)
    {
      struct epoll_event event;

      event.data.fd = fd;
      //event.events = EPOLLIN;
      event.events &= ~EPOLLOUT;

      //int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
      epoll_ctl(global_epfd, EPOLL_CTL_MOD, fd, &event);
    }
  }

  return 0;
}

void sigpipe_handler(int sig)
{
  fprintf(stdout, "Caught signal %d.\n", sig);
}

void sigterm_handler(int sig)
{
  fprintf(stdout, "Caught signal %d.\n", sig);
  global_exit_flag++;
}

int parse_data(int fd)
{
  fprintf(stdout, "TODO: Implement %s() function.\n", __func__);
  return 0;
}

int buffered_send(int fd, char *data, unsigned long length)
{
  conn_t *c = global_conn_list[fd];

  if (!c)
  {
#ifdef _DEBUG_
    assert(c != NULL);
#endif

    fprintf(stderr, "Fatal error, no conn_t object exists.\n");
    return -1;
  }

  buf_t *sbuf = c->sbuf;

#ifdef _DEBUG_
  assert(sbuf != NULL);
#endif

  if (sbuf->payload_length + length > sbuf->size)
  {
    unsigned long newsize = sbuf->payload_length + length;
    char *newdata = (char *) utils_safe_malloc(newsize);

    if (newdata)
    {
      // void *memcpy(void *dest, const void *src, size_t n);
      memcpy(newdata, sbuf->data, sbuf->payload_length);
      utils_safe_free(sbuf->data);
      sbuf->data = newdata;
      sbuf->size = newsize;
    }
    else
    {
      // FIXME: How to do?
      fprintf(stderr, "Cannot increase send buffer, how to do?\n");
    }
  }

  // void *memcpy(void *dest, const void *src, size_t n);
  memcpy(sbuf->data + sbuf->payload_length, data, length);
  sbuf->payload_length += length;

  if (sbuf->payload_length > 0)
  {
    struct epoll_event event;

    event.data.fd = fd;
    event.events = EPOLLIN | EPOLLOUT;

    //int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
    epoll_ctl(global_epfd, EPOLL_CTL_MOD, fd, &event);
  }

  return 0;
}
