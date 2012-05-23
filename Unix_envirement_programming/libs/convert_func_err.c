#include "package.h"

int inet_pton_r(int af, const char *src, void *dst)
{
	int n;
	if ((n = inet_pton(af, src, dst) < 0))
	{
		// inet_pton() returns a negative value and sets errno to EAFNOSUPPORT if af does not contain a valid address family.  
		err_ret("inet_pton() convert IPv4 address from string to binary format failed");
	}
		// 0 is  returned  if src  does  not contain a character string representing a valid network address in the specified address family.  
		// A positive value  is returned if the network address was successfully converted.
		//fprintf(stdout, "Convert IPv4 address from string to binary format success, result: 0x%08x\n", ipv4_address_structure.s_addr);
	return n;
}
//const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
const char *inet_ntop_r(int af, const void *src, char *dst, socklen_t cnt)
{
	char *str_addr ;
	if ((str_addr = (char *)inet_ntop(af, src, dst, cnt)) == NULL)
	{
		err_ret("inet_ntop() convert IPv4 address from binary format to string failed");
	}
	return str_addr;
}
