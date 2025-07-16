// Copyright (c) 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0/
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

#include "config.h"
#include "uart.h"
#include "print.h"
#include "gpio.h"
#include "util.h"

#define TB_FREQUENCY 20000000
#define TB_BAUDRATE    115200

int main() {
    uart_init();

    printf("He%xo World!\n", 0x11);
    uart_write_flush();

    volatile uint32_t *ptr_a, *ptr_b;
    uint32_t a, b;
    ptr_a = *reg32(USER_ROM_BASE_ADDR, 0);
    ptr_b = *reg32(USER_ROM_BASE_ADDR, 4);
    a = *ptr_a;
    b = *ptr_b;
    printf("%x - %x\n", a, b);
    uart_write_flush();

    printf("====> The content of the ROM (interpreted as ASCII) is:\n");
    uart_write_flush();
    for(int i = 0; i < 8*4; i++) {
        char c = *reg8(USER_ROM_BASE_ADDR, i);
        //if (c == '\0') break;  // stop at null terminator
        printf("%c", c);
    }
    printf("\n"); 
    uart_write_flush();

    return 1;
}
