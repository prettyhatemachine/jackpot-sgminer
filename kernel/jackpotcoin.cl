/*
 * AdvSHA3 kernel implementation.
 *
 * @author  mkimid
 */

#ifndef ADVSHA3_CL
#define ADVSHA3_CL

#define SPH_ROTL64(x, n)                  rotate(x, (ulong)(n))
#define SPH_ROTR64(x, n)                  SPH_ROTL64(x, (64 - (n)))

#define SWAP4(x)                          as_uint(as_uchar4(x).wzyx)
#define SWAP8(x)                          as_ulong(as_uchar8(x).s76543210)

#include "__keccak.cl"

__attribute__((reqd_work_group_size(WORKSIZE, 1, 1)))
__kernel void search(__global uint * input, volatile __global uint * output, const ulong target,
 const ulong a00_c, const ulong a10_c, const ulong a20_c, const ulong a30_c, const ulong a40_c,
 const ulong a01_c, const ulong a11_c, const ulong a21_c, const ulong a31_c, const ulong a41_c,
 const ulong a02_c, const ulong a12_c, const ulong a22_c, const ulong a32_c, const ulong a42_c,
 const ulong a03_c, const ulong a13_c, const ulong a23_c, const ulong a33_c, const ulong a43_c,
 const ulong a04_c, const ulong a14_c, const ulong a24_c, const ulong a34_c, const ulong a44_c
) {
     uint  gid = get_global_id(0);
     union {
        uint  U4[22];
        ulong U8[11];
     } HASH;

     ulong c0x, c1x, c2x, c3x, c4x;
     ulong a00 = a00_c; ulong a10 = a10_c; ulong a20 = a20_c; ulong a30 = a30_c; ulong a40 = a40_c;
     ulong a01 = a01_c; ulong a11 = a11_c; ulong a21 = a21_c; ulong a31 = a31_c; ulong a41 = a41_c;
     ulong a02 = a02_c; ulong a12 = a12_c; ulong a22 = a22_c; ulong a32 = a32_c; ulong a42 = a42_c;
     ulong a03 = a03_c; ulong a13 = a13_c; ulong a23 = a23_c; ulong a33 = a33_c; ulong a43 = a43_c;
     ulong a04 = a04_c; ulong a14 = a14_c; ulong a24 = a24_c; ulong a34 = a34_c; ulong a44 = a44_c;
   
     a00 ^= ((ulong) SWAP4(gid)) << 32;
     KECCAK_F_1600;
     a10     = ~a10;
     a20     = ~a20;
     HASH.U8[0x00] =  a00;
     HASH.U8[0x01] =  a10;
     HASH.U8[0x02] =  a20;
     HASH.U8[0x03] =  a30;
     HASH.U8[0x04] =  a40;
     HASH.U8[0x05] =  a01;
     HASH.U8[0x06] =  a11;
     HASH.U8[0x07] =  a21;

    if (HASH.U8[3] <= target && (HASH.U4[0x00] & 0x00000007U) == 0) {
       output[output[0xFF]++] = gid;
    }

}

#endif // ADVSHA3_CL
