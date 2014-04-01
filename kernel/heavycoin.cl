/*
 * HEAVYCOIN kernel implementation.
 *
 * @author   Min Kim <mkimid@me.com>
 *
 */


#ifndef HEAVYCOIN_CL
#define HEAVYCOIN_CL

#define SPH_LITTLE_ENDIAN                 1

#define SPH_UPTRs                         sph_u64

typedef uint                              sph_u32;
typedef int                               sph_s32;
typedef ulong                             sph_u64;
typedef long                              sph_s64;

#define SPH_64                            1
#define SPH_64_TRUE                       1

#define SPH_C32(x)                        ((uint)(x ## U))
#define SPH_T32(x)                        ((x) & SPH_C32(0xFFFFFFFF))

#define SPH_ROTL32(x, n)                  rotate(x, (uint)n)
#define SPH_ROTR32(x, n)                  SPH_ROTL32(x, (uint)(32U - (n)))

#define SPH_C64(x)                        ((ulong)(x ## UL))
#define SPH_T64(x)                        ((x) & SPH_C64(0xFFFFFFFFFFFFFFFF))
#define SPH_ROTL64(x, n)                  rotate(x, (ulong)(n))
#define SPH_ROTR64(x, n)                  SPH_ROTL64(x, (64 - (n)))

#define SWAP4(x)                          as_uint (as_uchar4(x).wzyx     )
#define SWAP8(x)                          as_ulong(as_uchar8(x).s76543210)

#define DEC32E(x)                         SWAP4(x)
#define DEC32BE(x)                        SWAP4(*(const __global uint  *) (x))

#define DEC64E(x)                         SWAP8(x)
#define DEC64BE(x)                        SWAP8(*(const __global ulong *) (x))


#include "hefty1.cl"
#include "sha256.cl"

#define SPH_KECCAK_64                     1
#define SPH_KECCAK_NOCOPY                 0
#define SPH_KECCAK_UNROLL                 1

#include "keccak.cl"


#define SPH_GROESTL_64                    1
#define SPH_GROESTL_BIG_ENDIAN            1
#define SPH_SMALL_FOOTPRINT_GROESTL       0

#include "groestl.cl"


#define SPH_COMPACT_BLAKE_64              0

#include "blake.cl"


void KECCAK(uint INPUT[21], uint HASH[8], ulong RESULT[8]) {	
     ulong a00 = as_ulong((uint2)(INPUT[ 0], INPUT[ 1]));
     ulong a10 = as_ulong((uint2)(INPUT[ 2], INPUT[ 3])) ^ 0xFFFFFFFFFFFFFFFFUL;
     ulong a20 = as_ulong((uint2)(INPUT[ 4], INPUT[ 5])) ^ 0xFFFFFFFFFFFFFFFFUL;
     ulong a30 = as_ulong((uint2)(INPUT[ 6], INPUT[ 7]));
     ulong a40 = as_ulong((uint2)(INPUT[ 8], INPUT[ 9]));
     ulong a01 = as_ulong((uint2)(INPUT[10], INPUT[11]));
     ulong a11 = as_ulong((uint2)(INPUT[12], INPUT[13]));
     ulong a21 = as_ulong((uint2)(INPUT[14], INPUT[15]));
     ulong a31 = as_ulong((uint2)(INPUT[16], INPUT[17])) ^ 0xFFFFFFFFFFFFFFFFUL;
     ulong a41 = 0;
     ulong a02 = 0;
     ulong a12 = 0;
     ulong a22 = 0xFFFFFFFFFFFFFFFFUL;
     ulong a32 = 0;
     ulong a42 = 0;
     ulong a03 = 0;
     ulong a13 = 0;
     ulong a23 = 0xFFFFFFFFFFFFFFFFUL;
     ulong a33 = 0;
     ulong a43 = 0;
     ulong a04 = 0xFFFFFFFFFFFFFFFFUL;
     ulong a14 = 0;
     ulong a24 = 0;
     ulong a34 = 0;
     ulong a44 = 0;	 
     KECCAK_F_1600;
		 a00 ^= as_ulong((uint2)(INPUT[18], INPUT[19]));
     a10 ^= as_ulong((uint2)(INPUT[20], HASH[0]));
     a20 ^= as_ulong((uint2)(HASH[1],   HASH[2]));
     a30 ^= as_ulong((uint2)(HASH[3],   HASH[4]));
     a40 ^= as_ulong((uint2)(HASH[5],   HASH[6]));
     a01 ^= as_ulong((uint2)(HASH[7], 1));
     a31 ^= 0x8000000000000000UL;
     KECCAK_F_1600;
     a10          = ~a10;
     a20          = ~a20;
     RESULT[0x00] =  a00;
     RESULT[0x01] =  a10;
     RESULT[0x02] =  a20;
     RESULT[0x03] =  a30;
     RESULT[0x04] =  a40;
     RESULT[0x05] =  a01;
     RESULT[0x06] =  a11;
     RESULT[0x07] =  a21;
}


void GROESTL64(uint INPUT[21], uint HASH[8], ulong RESULT[8]) {
     ulong g[16], m[16], x[16];
     ulong H[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x000200UL };
     union {
			  uchar   U1[128];
        uint    U4[32];
        ulong   U8[16];
     } BUFFER;
				 #pragma unroll
     for (uint u =  0; u < 21; u++) BUFFER.U4[u] = INPUT[u];
				 #pragma unroll
     for (uint u = 21; u < 29; u++) BUFFER.U4[u] = HASH[u - 21];
     BUFFER.U1[116] = 0x80;
     BUFFER.U1[127] = 0x01;		 
     for (uint u = 0; u < 16; u++) {
         m[u] = SWAP8(BUFFER.U8[u]);
         g[u] = m[u] ^ H[u];
     }
     for (uint r = 0; r < 14; r++) {
         ROUND_BIG_P(g, r);
     }
     for (uint r = 0; r < 14; r++) {
         ROUND_BIG_Q(m, r);
     }
				 #pragma unroll
     for (uint u = 0; u < 16; u++) H[u] ^= (g[u] ^ m[u]);
				 #pragma unroll
		 for (uint u = 0; u < 16; u++) x[u]  = H[u];
     for (uint r = 0; r < 14; r++) {
         ROUND_BIG_P(x, r);
     }
				 #pragma unroll
     for (uint u = 0; u < 16; u++) H[u] ^= x[u];
				 #pragma unroll
     for (uint u = 0; u <  8; u++) RESULT[u] = SWAP8(H[u + 8]);
}


void BLAKE(uint INPUT[21], uint HASH[8], ulong RESULT[8])	{
     union {
       uchar U1[128];
       uint  U4[64];
       ulong U8[16];
     } BUFFER;
				 #pragma unroll
     for (uint u =  0; u < 21; u++) BUFFER.U4[u] = INPUT[u];
				 #pragma unroll
     for (uint u = 21; u < 29; u++) BUFFER.U4[u] = HASH[u - 21];
				 #pragma unroll
     for (uint u = 29; u < 32; u++) BUFFER.U4[u] = 0;
     BUFFER.U1[116] = 0x80;
     ulong V0 = BLAKE_IV512[0];
     ulong V1 = BLAKE_IV512[1];
     ulong V2 = BLAKE_IV512[2];
     ulong V3 = BLAKE_IV512[3];
     ulong V4 = BLAKE_IV512[4];
     ulong V5 = BLAKE_IV512[5];
     ulong V6 = BLAKE_IV512[6];
     ulong V7 = BLAKE_IV512[7];
     ulong V8 = CB0;
     ulong V9 = CB1;
     ulong VA = CB2;
     ulong VB = CB3;
     ulong VC = CB4 ^ 0x03A0;
     ulong VD = CB5 ^ 0x03A0;
     ulong VE = CB6;
     ulong VF = CB7;
     ulong M0 = as_ulong((uint2)(SWAP4(INPUT[ 1]), SWAP4(INPUT[ 0]))); // DEC64E(BUFFER.U8[0x00]);
     ulong M1 = as_ulong((uint2)(SWAP4(INPUT[ 3]), SWAP4(INPUT[ 2]))); // DEC64E(BUFFER.U8[0x01]);
     ulong M2 = as_ulong((uint2)(SWAP4(INPUT[ 5]), SWAP4(INPUT[ 4]))); // DEC64E(BUFFER.U8[0x02]);
     ulong M3 = as_ulong((uint2)(SWAP4(INPUT[ 7]), SWAP4(INPUT[ 6]))); // DEC64E(BUFFER.U8[0x03]);
     ulong M4 = as_ulong((uint2)(SWAP4(INPUT[ 9]), SWAP4(INPUT[ 8]))); // DEC64E(BUFFER.U8[0x04]);
     ulong M5 = as_ulong((uint2)(SWAP4(INPUT[11]), SWAP4(INPUT[10]))); // DEC64E(BUFFER.U8[0x05]);
     ulong M6 = as_ulong((uint2)(SWAP4(INPUT[13]), SWAP4(INPUT[12]))); // DEC64E(BUFFER.U8[0x06]);
     ulong M7 = as_ulong((uint2)(SWAP4(INPUT[15]), SWAP4(INPUT[14]))); // DEC64E(BUFFER.U8[0x07]);
     ulong M8 = as_ulong((uint2)(SWAP4(INPUT[17]), SWAP4(INPUT[16]))); // DEC64E(BUFFER.U8[0x08]);
     ulong M9 = as_ulong((uint2)(SWAP4(INPUT[19]), SWAP4(INPUT[18]))); // DEC64E(BUFFER.U8[0x09]);
     ulong MA = as_ulong((uint2)(SWAP4(HASH[ 0]),  SWAP4(INPUT[20]))); // DEC64E(BUFFER.U8[0x0A]);
     ulong MB = as_ulong((uint2)(SWAP4(HASH[ 2]),  SWAP4(HASH[ 1])));  // DEC64E(BUFFER.U8[0x0B]);
     ulong MC = as_ulong((uint2)(SWAP4(HASH[ 4]),  SWAP4(HASH[ 3])));  // DEC64E(BUFFER.U8[0x0C]);
     ulong MD = as_ulong((uint2)(SWAP4(HASH[ 6]),  SWAP4(HASH[ 5])));  // DEC64E(BUFFER.U8[0x0D]);
     ulong ME = as_ulong((uint2)(0x80000000, SWAP4(HASH[ 7])));        // DEC64E(BUFFER.U8[0x0E]);
     ulong MF = 0;
     ROUND_B(0);
     ROUND_B(1);
     ROUND_B(2);
     ROUND_B(3);
     ROUND_B(4);
     ROUND_B(5);
     ROUND_B(6);
     ROUND_B(7);
     ROUND_B(8);
     ROUND_B(9);
     ROUND_B(0);
     ROUND_B(1);
     ROUND_B(2);
     ROUND_B(3);
     ROUND_B(4);
     ROUND_B(5);
     V0 = (RESULT[0] = (BLAKE_IV512[0] ^ V0 ^ V8));
     V1 = (RESULT[1] = (BLAKE_IV512[1] ^ V1 ^ V9));
     V2 = (RESULT[2] = (BLAKE_IV512[2] ^ V2 ^ VA));
     V3 = (RESULT[3] = (BLAKE_IV512[3] ^ V3 ^ VB));
     V4 = (RESULT[4] = (BLAKE_IV512[4] ^ V4 ^ VC));
     V5 = (RESULT[5] = (BLAKE_IV512[5] ^ V5 ^ VD));
     V6 = (RESULT[6] = (BLAKE_IV512[6] ^ V6 ^ VE));
     V7 = (RESULT[7] = (BLAKE_IV512[7] ^ V7 ^ VF));
     V8 = CB0;
     V9 = CB1;
     VA = CB2;
     VB = CB3;
     VC = CB4;
     VD = CB5;
     VE = CB6;
     VF = CB7;
     M0 = 0;
     M1 = 0;
     M2 = 0;
     M3 = 0;
     M4 = 0;
     M5 = 0;
     M6 = 0;
     M7 = 0;
     M8 = 0;
     M9 = 0;
     MA = 0;
     MB = 0;
     MC = 0;
     MD = 1;
     ME = 0;
     MF = 0x03A0;
     ROUND_B(0);
     ROUND_B(1);
     ROUND_B(2);
     ROUND_B(3);
     ROUND_B(4);
     ROUND_B(5);
     ROUND_B(6);
     ROUND_B(7);
     ROUND_B(8);
     ROUND_B(9);
     ROUND_B(0);
     ROUND_B(1);
     ROUND_B(2);
     ROUND_B(3);
     ROUND_B(4);
     ROUND_B(5);
     RESULT[0] = SWAP8(RESULT[0] ^ V0 ^ V8);
     RESULT[1] = SWAP8(RESULT[1] ^ V1 ^ V9);
     RESULT[2] = SWAP8(RESULT[2] ^ V2 ^ VA);
     RESULT[3] = SWAP8(RESULT[3] ^ V3 ^ VB);
     RESULT[4] = SWAP8(RESULT[4] ^ V4 ^ VC);
     RESULT[5] = SWAP8(RESULT[5] ^ V5 ^ VD);
     RESULT[6] = SWAP8(RESULT[6] ^ V6 ^ VE);
     RESULT[7] = SWAP8(RESULT[7] ^ V7 ^ VF);
}


  typedef union {
      uint  U4[16];
      ulong U8[8];
  } U_HASH;


 // #define WORKSIZE   64

__attribute__((reqd_work_group_size(WORKSIZE, 1, 1)))
__kernel void search(__global uint * input, volatile __global char * output, const ulong target) {
         uint   gid = get_global_id(0); // SWAP4(get_global_id(0));
         uint   INPUT[21];
         uint   HASH1[8], HASH2[16];
         U_HASH HASH3, HASH4, HASH5;

				 #pragma unroll
	       for (uint u = 0; u < 21; u++) INPUT[u] = input[u];
         INPUT[19] = gid;

         HEFTY1    (INPUT, HASH1); 
         SHA256    (INPUT, HASH1, HASH2);
         KECCAK    (INPUT, HASH1, HASH3.U8);
         GROESTL64 (INPUT, HASH1, HASH4.U8);
         BLAKE     (INPUT, HASH1, HASH5.U8);

         ulong result = 0;
         uint4 check  = (uint4)(HASH2[7], HASH3.U4[7] >> 1, HASH4.U4[7] >> 2, HASH5.U4[7] >> 3);
         check    = rotate(check, 4);
				 #pragma unroll
         for (uint i = 0; i < 16; i++) {
             result <<= 4;
             result  |= ((check.x & 0x08) | (check.y & 0x04) | (check.z & 0x02) | (check.w & 0x01));
             check    = rotate(check, 1);
         }
	       if (result < target) {
            output[output[0xFF]++] = gid;
         }

}

#endif // HEAVYCOIN_CL
