#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>

int main(int argc, char **argv)
{
  //------------------------------------------------------------------
  // IPv4 address definition
  // defined in /usr/include/netinet/in.h
  //------------------------------------------------------------------
#if 0
  /* Internet address.  */
  typedef uint32_t in_addr_t;
  struct in_addr
  {
    in_addr_t s_addr;
  };
#endif

  struct in_addr ipv4_address_structure;
  char ipv4_address_string[] = "192.168.203.6";
  //char ipv4_address_string[] = "255.255.255.255";

  //------------------------------------------------------------------
  // string -> binary, by inet_aton()
  //
  // inet_aton() converts the Internet host address cp from the standard
  // numbers-and-dots  notation  into  binary  data and stores it in the
  // structure that inp points to. inet_aton() returns non-zero  if  the
  // address is valid, zero if not.
  //------------------------------------------------------------------
  //int inet_aton(const char *cp, struct in_addr *inp);
  if (inet_aton(ipv4_address_string, &ipv4_address_structure) == 0)
  {
    fprintf(stderr, "Invalid address: %s\n", ipv4_address_string);
  }
  else
  {
    fprintf(stdout, "%s -> 0x%08x\n", ipv4_address_string, ipv4_address_structure.s_addr);
  }

  //------------------------------------------------------------------
  // string -> binary, by inet_addr()
  //
  // The inet_addr() function converts the Internet host address cp from
  // numbers-and-dots notation into binary data in network  byte  order.
  // If  the  input  is  invalid,  INADDR_NONE (usually -1) is returned.
  // This is an obsolete interface to inet_aton(), described immediately
  // above;   it   is   obsolete   because   -1   is   a  valid  address
  // (255.255.255.255), and inet_aton() provides a cleaner way to  indi-
  // cate error return.
  //------------------------------------------------------------------
  //in_addr_t inet_addr(const char *cp);
  if ((ipv4_address_structure.s_addr = inet_addr(ipv4_address_string)) == INADDR_NONE)
  {
    fprintf(stderr, "Invalid address: %s\n", ipv4_address_string);
  }
  else
  {
    fprintf(stdout, "%s -> 0x%08x\n", ipv4_address_string, ipv4_address_structure.s_addr);
  }

  //------------------------------------------------------------------
  // string -> binary, by inet_pton()
  //
  // src points to a character string containing an IPv4  network
  // address  in  the dotted-quad format, "ddd.ddd.ddd.ddd".  The
  // address is converted to a struct in_addr and copied to  dst,
  // which must be sizeof(struct in_addr) bytes long.
  //------------------------------------------------------------------
  int n;

  //int inet_pton(int af, const char *src, void *dst);
  if ((n = inet_pton(AF_INET, ipv4_address_string, &ipv4_address_structure)) < 0)
  {
    // failed
    // inet_pton()  returns  a  negative  value  and  sets  errno to EAFNOSUPPORT 
    // if af does not contain a valid address family.  
    fprintf(stderr, "inet_pton() failed: %s\n", strerror(errno));
  }
  else if (n == 0)
  {
    // invalid address
    // 0 is returned if src does not contain a character string representing a valid  
    // network address  in  the  specified address family.  
    fprintf(stderr, "Invalid address: %s\n", ipv4_address_string);
  }
  else
  {
    // success
    // A positive value is returned if the network address was successfully converted.
    fprintf(stdout, "%s -> 0x%08x\n", ipv4_address_string, ipv4_address_structure.s_addr);
  }

  //------------------------------------------------------------------
  // binary -> string, use inet_ntoa()
  //
  // The  inet_ntoa()  function  converts  the  Internet host address in
  // given in network byte order to a string  in  standard  numbers-and-
  // dots  notation.   The  string is returned in a statically allocated
  // buffer, which subsequent calls will overwrite.
  //------------------------------------------------------------------
  //char *inet_ntoa(struct in_addr in);
  fprintf(stdout, "0x%08x -> %s\n", ipv4_address_structure.s_addr, inet_ntoa(ipv4_address_structure));

  //------------------------------------------------------------------
  // binary -> string, use inet_ntop()
  //
  // src points to a struct in_addr (network byte  order  format)
  // which is converted to an IPv4 network address in the dotted-
  // quad format, "ddd.ddd.ddd.ddd".  The buffer dst must  be  at
  // least INET_ADDRSTRLEN bytes long.
  //------------------------------------------------------------------
  char buffer[INET_ADDRSTRLEN + 1];

  //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
  inet_ntop(AF_INET, &ipv4_address_structure, buffer, sizeof(buffer));

  fprintf(stdout, "by inet_ntop(), result = %s\n", buffer);

  //------------------------------------------------------------------
  // IPv6 address definition
  // defined in /usr/include/netinet/in.h
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
#  define s6_addr		in6_u.u6_addr8
#  define s6_addr16		in6_u.u6_addr16
#  define s6_addr32		in6_u.u6_addr32
  };
#endif

  struct in6_addr ipv6_address_structure;
  char ipv6_address_string[] = "fe80::205:4eff:fe48:fa93";

  //------------------------------------------------------------------
  // string -> binary, by inet_pton()
  //
  // src  points to a character string containing an IPv6 network
  // address in any allowed IPv6 address format.  The address  is
  // converted to a struct in6_addr and copied to dst, which must
  // be sizeof(struct in6_addr) bytes long.
  //------------------------------------------------------------------

  //int inet_pton(int af, const char *src, void *dst);
  inet_pton(AF_INET6, ipv6_address_string, &ipv6_address_structure);

  fprintf(stdout, "%s -> ", ipv6_address_string);

  int i;

  for (i = 0; i < 16; i++)
  {
    //fprintf(stdout, "%02x", ipv6_address_structure.in6_u.u6_addr8[i]);
    fprintf(stdout, "%02x", ipv6_address_structure.s6_addr[i]);
  }

  //fprintf(stdout, "\n");

  //------------------------------------------------------------------
  // binary -> string, by inet_ntop()
  //
  // src  points to a struct in6_addr (network byte order format)
  // which is converted to a representation of  this  address  in
  // the  most  appropriate  IPv6 network address format for this
  // address.  The buffer dst must be at  least  INET6_ADDRSTRLEN
  //------------------------------------------------------------------
  char buffer6[INET6_ADDRSTRLEN + 1];

  //const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
  inet_ntop(AF_INET6, &ipv6_address_structure, buffer6, sizeof(buffer6));

  fprintf(stdout, " -> %s\n", buffer6);

  return 0;
}

// vim:tabstop=8
