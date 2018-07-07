/* copy from https://metacpan.org/source/MIK/CryptX-0.061/CryptX.xs */
/* assert_not_ROK is broken in 5.8.1 */

#if PERL_VERSION == 8 && PERL_SUBVERSION == 1
# undef assert_not_ROK
# if defined(__GNUC__) && !defined(PERL_GCC_BRACE_GROUPS_FORBIDDEN)
#  define assert_not_ROK(sv)  ({assert(!SvROK(sv) || !SvRV(sv));}),
# else
#  define assert_not_ROK(sv)
# endif
#endif
