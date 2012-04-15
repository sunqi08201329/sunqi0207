#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>

int main(int argc, char **argv)
{
  int n;

  //------------------------------------------------------------------
  // IPv4 address structure definition
  // defined in usr/include/netinet/in.h
  //------------------------------------------------------------------
#if 0
  /* Internet address.  */
  typedef uint32_t in_addr_t;
  struct in_addr
  {
    in_addr_t s_addr;
  };
#endif

  char ipv4_address_string[] = "192.168.204.6";
  struct in_addr ipv4_address_structure;

  //------------------------------------------------------------------
  // Conver IPv4 address, string -> binary
  //
  // af = AF_INET
  //
  // src points to a character string containing an IPv4  network
  // address  in  the dotted-quad format, "ddd.ddd.ddd.ddd".  The
  // address is converted to a struct in_addr and copied to  dst,
  // which must be sizeof(struct in_addr) bytes long.
  //
  //------------------------------------------------------------------
  //int inet_pton(int af, const char *src, void *dst);
  if ((n = inet_pton(AF_INET, ipv4_address_string, &ipv4_address_structure)) < 0)
  {
    // inet_pton() returns a negative value and sets errno to EAFNOSUPPORT if af does not contain a valid address family.  
    fprintf(stderr, "Convert IPv4 address from string to binary format failed: %s\n", strerror(errno));
  }
  else if (n == 0)
  {
    // 0 is  returned  if src  does  not contain a character string representing a valid network address in the specified address family.  
    fprintf(stderr, "Convert IPv4 address from string to binary format failed, %s is an invalid address.\n", ipv4_address_string);
  }
  else
  {
    // A positive value  is returned if the network address was successfully converted.
    fprintf(stdout, "Convert IPv4 address from string to binary format success, result: 0x%08x\n", ipv4_address_structure.s_addr);
  }

  //------------------------------------------------------------------
  // Conver IPv4 address, binary -> string
  //
  // af = AF_INET
  //
  // src points to a struct in_addr (network byte  order  format)
  // which is converted to an IPv4 network address in the dotted-
  // quad format, "ddd.ddd.ddd.ddd".  The buffer dst must  be  at
  // least INET_ADDRSTRLEN bytes long.
  //
  //------------------------------------------------------------------
  //char ipv4_address_buffer[INET_ADDRSTRLEN + 1];
  char ipv4_address_buffer[] = "ddd.ddd.ddd.ddd\0";

  //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
  if (inet_ntop(AF_INET, &ipv4_address_structure, ipv4_address_buffer, sizeof(ipv4_address_buffer)) == NULL)
  {
    // failed
    // NULL is returned if there was an error, with errno set to EAFNOSUPPORT if  af  was  not set  to  a  valid  address  family,  or  to ENOSPC if the converted address string would exceed the size of dst given by the cnt  argument.
    fprintf(stderr, "Convert IPv4 address from binary format to string failed: %s\n", strerror(errno));
  }
  else
  {
    // success
    // inet_ntop() returns a non-null pointer to dst.  
    fprintf(stdout, "Convert IPv4 address from binary format to string success, result: %s\n", ipv4_address_buffer);
  }

  //------------------------------------------------------------------
  // IPv6 address structure definition
  // defined in usr/include/netinet/in.h
  //------------------------------------------------------------------
#if 0
  /* IPv6 address */
  struct in6_addr
  {
    union
    {
      uint8_t u6_addr8[16];
      uint16_t u6_addr16[8];
      uint32_t u6_addr32[4];
    } in6_u;
#  define s6_addr			in6_u.u6_addr8
#  define s6_addr16		in6_u.u6_addr16
#  define s6_addr32		in6_u.u6_addr32
  };
#endif

  char ipv6_address_string[] = "fe80::20d:60ff:fecb:86e5";
  struct in6_addr ipv6_address_structure;

  //------------------------------------------------------------------
  // Conver IPv6 address, string -> binary
  // 
  // af = AF_INET6
  // 
  // src  points to a character string containing an IPv6 network
  // address in any allowed IPv6 address format.  The address  is
  // converted to a struct in6_addr and copied to dst, which must
  // be sizeof(struct in6_addr) bytes long.
  //------------------------------------------------------------------
  //int inet_pton(int af, const char *src, void *dst);
  if ((n = inet_pton(AF_INET6, ipv6_address_string, &ipv6_address_structure)) < 0)
  {
    // inet_pton() returns a negative value and sets errno to EAFNOSUPPORT if af does not contain a valid address family.  
    fprintf(stderr, "Convert IPv6 address from string to binary format failed: %s\n", strerror(errno));
  }
  else if (n == 0)
  {
    // 0 is  returned  if src  does  not contain a character string representing a valid network address in the specified address family.  
    fprintf(stderr, "Convert IPv6 address from string to binary format failed, %s is an invalid address.\n", ipv6_address_string);
  }
  else
  {
    // A positive value  is returned if the network address was successfully converted.
    fprintf(stdout, "Convert IPv6 address from string to binary format success, result:");

    int i;

    for (i = 0; i < 16; i++)
    {
      fprintf(stdout, " %02x", ipv6_address_structure.s6_addr[i]);
    }

    fprintf(stdout, "\n");
  }

  //------------------------------------------------------------------
  // Conver IPv6 address, binary -> string
  //
  // af = AF_INET6
  // 
  // src  points to a struct in6_addr (network byte order format)
  // which is converted to a representation of  this  address  in
  // the  most  appropriate  IPv6 network address format for this
  // address.  The buffer dst must be at  least  INET6_ADDRSTRLEN
  // bytes long.
  //
  //------------------------------------------------------------------
  char ipv6_address_buffer[INET6_ADDRSTRLEN + 1];

  //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
  if (inet_ntop(AF_INET6, &ipv6_address_structure, ipv6_address_buffer, sizeof(ipv6_address_buffer)) == NULL)
  {
    // failed
    // NULL is returned if there was an error, with errno set to EAFNOSUPPORT if  af  was  not set  to  a  valid  address  family,  or  to ENOSPC if the converted address string would exceed the size of dst given by the cnt  argument.
    fprintf(stderr, "Convert IPv4 address from binary format to string failed: %s\n", strerror(errno));
  }
  else
  {
    // success
    // inet_ntop() returns a non-null pointer to dst.  
    fprintf(stdout, "Convert IPv6 address from binary format to string success, result: %s\n", ipv6_address_buffer);
  }

  return 0;
}

// vim:tabstop=8
