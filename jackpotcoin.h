#ifndef ADVSHA3_H
#define ADVSHA3_H

#include "miner.h"

extern int  advsha3_test(unsigned char *pdata, const unsigned char *ptarget, uint32_t nonce);
extern void advsha3_regenhash(struct work *work);

#endif /* ADVSHA3_H */
