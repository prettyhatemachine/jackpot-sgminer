

__constant ulong RC[] = {
  0x0000000000000001UL, 0x0000000000008082UL, 0x800000000000808AUL, 0x8000000080008000UL,
  0x000000000000808BUL, 0x0000000080000001UL, 0x8000000080008081UL, 0x8000000000008009UL,
  0x000000000000008AUL, 0x0000000000000088UL, 0x0000000080008009UL, 0x000000008000000AUL,
  0x000000008000808BUL, 0x800000000000008BUL, 0x8000000000008089UL, 0x8000000000008003UL,
  0x8000000000008002UL, 0x8000000000000080UL, 0x000000000000800AUL, 0x800000008000000AUL,
  0x8000000080008081UL, 0x8000000000008080UL, 0x0000000080000001UL, 0x8000000080008008UL  };

#define THETA(b00, b01, b02, b03, b04, b10, b11, b12, b13, b14, b20, b21, b22, b23, b24, b30, b31, b32, b33, b34, b40, b41, b42, b43, b44) \
		c0x = b40 ^ b41 ^ b42 ^ b43 ^ b44 ^ rotate(b10 ^ b11 ^ b12 ^ b13 ^ b14, 1UL); \
		c1x = b00 ^ b01 ^ b02 ^ b03 ^ b04 ^ rotate(b20 ^ b21 ^ b22 ^ b23 ^ b24, 1UL); \
		c2x = b10 ^ b11 ^ b12 ^ b13 ^ b14 ^ rotate(b30 ^ b31 ^ b32 ^ b33 ^ b34, 1UL); \
		c3x = b20 ^ b21 ^ b22 ^ b23 ^ b24 ^ rotate(b40 ^ b41 ^ b42 ^ b43 ^ b44, 1UL); \
		c4x = b30 ^ b31 ^ b32 ^ b33 ^ b34 ^ rotate(b00 ^ b01 ^ b02 ^ b03 ^ b04, 1UL); \
		b00 = rotate(b00 ^ c0x,  0UL); \
		b01 = rotate(b01 ^ c0x, 36UL); \
		b02 = rotate(b02 ^ c0x,  3UL); \
		b03 = rotate(b03 ^ c0x, 41UL); \
		b04 = rotate(b04 ^ c0x, 18UL); \
		b10 = rotate(b10 ^ c1x,  1UL); \
		b11 = rotate(b11 ^ c1x, 44UL); \
		b12 = rotate(b12 ^ c1x, 10UL); \
		b13 = rotate(b13 ^ c1x, 45UL); \
		b14 = rotate(b14 ^ c1x,  2UL); \
		b20 = rotate(b20 ^ c2x, 62UL); \
		b21 = rotate(b21 ^ c2x,  6UL); \
		b22 = rotate(b22 ^ c2x, 43UL); \
		b23 = rotate(b23 ^ c2x, 15UL); \
		b24 = rotate(b24 ^ c2x, 61UL); \
		b30 = rotate(b30 ^ c3x, 28UL); \
		b31 = rotate(b31 ^ c3x, 55UL); \
		b32 = rotate(b32 ^ c3x, 25UL); \
		b33 = rotate(b33 ^ c3x, 21UL); \
		b34 = rotate(b34 ^ c3x, 56UL); \
		b40 = rotate(b40 ^ c4x, 27UL); \
		b41 = rotate(b41 ^ c4x, 20UL); \
		b42 = rotate(b42 ^ c4x, 39UL); \
		b43 = rotate(b43 ^ c4x,  8UL); \
		b44 = rotate(b44 ^ c4x, 14UL);

#define KHI(b00, b01, b02, b03, b04, b10, b11, b12, b13, b14, b20, b21, b22, b23, b24, b30, b31, b32, b33, b34, b40, b41, b42, b43, b44) \
		c0x = ( b00 ^ ( b10 |  b20)); \
		c1x = ( b10 ^ (~b20 |  b30)); \
        b20 = ( b20 ^ ( b30 &  b40)); \
		b30 = ( b30 ^ ( b40 |  b00)); \
		b40 = ( b40 ^ ( b00 &  b10)); \
		b00 = c0x; \
		b10 = c1x; \
		c0x = ( b01 ^ ( b11 |  b21)); \
		c1x = ( b11 ^ ( b21 &  b31)); \
		b21 = ( b21 ^ ( b31 | ~b41)); \
		b31 = ( b31 ^ ( b41 |  b01)); \
		b41 = ( b41 ^ ( b01 &  b11)); \
		b01 = c0x; \
		b11 = c1x; \
		c0x = ( b02 ^ ( b12 |  b22)); \
		c1x = ( b12 ^ ( b22 &  b32)); \
		b22 = ( b22 ^ (~b32 &  b42)); \
		b32 = (~b32 ^ ( b42 |  b02)); \
		b42 = ( b42 ^ ( b02 &  b12)); \
		b02 = c0x; \
		b12 = c1x; \
		c0x = ( b03 ^ ( b13 &  b23)); \
		c1x = ( b13 ^ ( b23 |  b33)); \
		b23 = ( b23 ^ (~b33 |  b43)); \
		b33 = (~b33 ^ ( b43 &  b03)); \
		b43 = ( b43 ^ ( b03 |  b13)); \
		b03 = c0x; \
		b13 = c1x; \
		c0x = ( b04 ^ (~b14 &  b24)); \
		c1x = (~b14 ^ ( b24 |  b34)); \
		b24 = ( b24 ^ ( b34 &  b44)); \
		b34 = ( b34 ^ ( b44 |  b04)); \
		b44 = ( b44 ^ ( b04 &  b14)); \
		b04 = c0x; \
		b14 = c1x;

#define P0    a00, a01, a02, a03, a04, a10, a11, a12, a13, a14, a20, a21, a22, a23, a24, a30, a31, a32, a33, a34, a40, a41, a42, a43, a44
#define P1    a00, a30, a10, a40, a20, a11, a41, a21, a01, a31, a22, a02, a32, a12, a42, a33, a13, a43, a23, a03, a44, a24, a04, a34, a14
#define P2    a00, a33, a11, a44, a22, a41, a24, a02, a30, a13, a32, a10, a43, a21, a04, a23, a01, a34, a12, a40, a14, a42, a20, a03, a31
#define P3    a00, a23, a41, a14, a32, a24, a42, a10, a33, a01, a43, a11, a34, a02, a20, a12, a30, a03, a21, a44, a31, a04, a22, a40, a13
#define P4    a00, a12, a24, a31, a43, a42, a04, a11, a23, a30, a34, a41, a03, a10, a22, a21, a33, a40, a02, a14, a13, a20, a32, a44, a01
#define P5    a00, a21, a42, a13, a34, a04, a20, a41, a12, a33, a03, a24, a40, a11, a32, a02, a23, a44, a10, a31, a01, a22, a43, a14, a30
#define P6    a00, a02, a04, a01, a03, a20, a22, a24, a21, a23, a40, a42, a44, a41, a43, a10, a12, a14, a11, a13, a30, a32, a34, a31, a33
#define P7    a00, a10, a20, a30, a40, a22, a32, a42, a02, a12, a44, a04, a14, a24, a34, a11, a21, a31, a41, a01, a33, a43, a03, a13, a23
#define P8    a00, a11, a22, a33, a44, a32, a43, a04, a10, a21, a14, a20, a31, a42, a03, a41, a02, a13, a24, a30, a23, a34, a40, a01, a12
#define P9    a00, a41, a32, a23, a14, a43, a34, a20, a11, a02, a31, a22, a13, a04, a40, a24, a10, a01, a42, a33, a12, a03, a44, a30, a21
#define P10   a00, a24, a43, a12, a31, a34, a03, a22, a41, a10, a13, a32, a01, a20, a44, a42, a11, a30, a04, a23, a21, a40, a14, a33, a02
#define P11   a00, a42, a34, a21, a13, a03, a40, a32, a24, a11, a01, a43, a30, a22, a14, a04, a41, a33, a20, a12, a02, a44, a31, a23, a10
#define P12   a00, a04, a03, a02, a01, a40, a44, a43, a42, a41, a30, a34, a33, a32, a31, a20, a24, a23, a22, a21, a10, a14, a13, a12, a11
#define P13   a00, a20, a40, a10, a30, a44, a14, a34, a04, a24, a33, a03, a23, a43, a13, a22, a42, a12, a32, a02, a11, a31, a01, a21, a41
#define P14   a00, a22, a44, a11, a33, a14, a31, a03, a20, a42, a23, a40, a12, a34, a01, a32, a04, a21, a43, a10, a41, a13, a30, a02, a24
#define P15   a00, a32, a14, a41, a23, a31, a13, a40, a22, a04, a12, a44, a21, a03, a30, a43, a20, a02, a34, a11, a24, a01, a33, a10, a42
#define P16   a00, a43, a31, a24, a12, a13, a01, a44, a32, a20, a21, a14, a02, a40, a33, a34, a22, a10, a03, a41, a42, a30, a23, a11, a04
#define P17   a00, a34, a13, a42, a21, a01, a30, a14, a43, a22, a02, a31, a10, a44, a23, a03, a32, a11, a40, a24, a04, a33, a12, a41, a20
#define P18   a00, a03, a01, a04, a02, a30, a33, a31, a34, a32, a10, a13, a11, a14, a12, a40, a43, a41, a44, a42, a20, a23, a21, a24, a22
#define P19   a00, a40, a30, a20, a10, a33, a23, a13, a03, a43, a11, a01, a41, a31, a21, a44, a34, a24, a14, a04, a22, a12, a02, a42, a32
#define P20   a00, a44, a33, a22, a11, a23, a12, a01, a40, a34, a41, a30, a24, a13, a02, a14, a03, a42, a31, a20, a32, a21, a10, a04, a43
#define P21   a00, a14, a23, a32, a41, a12, a21, a30, a44, a03, a24, a33, a42, a01, a10, a31, a40, a04, a13, a22, a43, a02, a11, a20, a34
#define P22   a00, a31, a12, a43, a24, a21, a02, a33, a14, a40, a42, a23, a04, a30, a11, a13, a44, a20, a01, a32, a34, a10, a41, a22, a03
#define P23   a00, a13, a21, a34, a42, a02, a10, a23, a31, a44, a04, a12, a20, a33, a41, a01, a14, a22, a30, a43, a03, a11, a24, a32, a40

#define LPAR   (
#define RPAR   )

#define KF_ELT(r, s, k)     \
		THETA LPAR P ## r RPAR; \
		KHI   LPAR P ## s RPAR; \
		a00 ^= k;

#define DO(x)           x
#define KECCAK_F_1600   DO(KECCAK_F_1600_)

#define KECCAK_F_1600_          \
		KF_ELT( 0,  1, RC[ 0]); \
		KF_ELT( 1,  2, RC[ 1]); \
		KF_ELT( 2,  3, RC[ 2]); \
		KF_ELT( 3,  4, RC[ 3]); \
		KF_ELT( 4,  5, RC[ 4]); \
		KF_ELT( 5,  6, RC[ 5]); \
		KF_ELT( 6,  7, RC[ 6]); \
		KF_ELT( 7,  8, RC[ 7]); \
		KF_ELT( 8,  9, RC[ 8]); \
		KF_ELT( 9, 10, RC[ 9]); \
		KF_ELT(10, 11, RC[10]); \
		KF_ELT(11, 12, RC[11]); \
		KF_ELT(12, 13, RC[12]); \
		KF_ELT(13, 14, RC[13]); \
		KF_ELT(14, 15, RC[14]); \
		KF_ELT(15, 16, RC[15]); \
		KF_ELT(16, 17, RC[16]); \
		KF_ELT(17, 18, RC[17]); \
		KF_ELT(18, 19, RC[18]); \
		KF_ELT(19, 20, RC[19]); \
		KF_ELT(20, 21, RC[20]); \
		KF_ELT(21, 22, RC[21]); \
		KF_ELT(22, 23, RC[22]); \
		KF_ELT(23,  0, RC[23]);





