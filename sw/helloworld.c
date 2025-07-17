// Copyright (c) 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0/
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

#include "uart.h"
#include "print.h"
#include "timer.h"
#include "gpio.h"
#include "util.h"

#include "config.h"
#include <string.h>
#include <stdint.h>

#define BYTES 32


/// @brief Example integer square root
/// @return integer square root of n
uint32_t isqrt(uint32_t n) {
    uint32_t res = 0;
    uint32_t bit = (uint32_t)1 << 30;

    while (bit > n) bit >>= 2;

    while (bit) {
        if (n >= res + bit) {
            n -= res + bit;
            res = (res >> 1) + bit;
        } else {
            res >>= 1;
        }
        bit >>= 2;
    }
    return res;
}


// Helper to encode R-type instruction
#define ENCODE_MAC(rd, rs1, rs2) \
    ( (0x40 << 25) | ((rs2) << 20) | ((rs1) << 15) | (0x0 << 12) | ((rd) << 7) | 0x33 )

static inline int mac(int a, int b, int c) {
    int result = c;
    asm volatile (
        "mv a0, %1\n"
        "mv a1, %2\n"
        "mv a2, %3\n"
        ".word %4\n"
        "mv %0, a2\n"
        : "=r"(result)
        : "r"(a), "r"(b), "r"(c), "i"(ENCODE_MAC(12, 10, 11))
        : "a0", "a1", "a2"
    );
    return result;
}

char receive_buff[16] = {0};

int main() {
    uart_init(); // setup the uart peripheral

    // // simple printf support (only prints text and hex numbers)
    // printf("Hello World!\n");
    // // wait until uart has finished sending
    // uart_write_flush();

    // // uart loopback
    // uart_loopback_enable();
    // printf("internal msg\n");
    // sleep_ms(1);
    // for(uint8_t idx = 0; idx<15; idx++) {
    //     receive_buff[idx] = uart_read();
    //     if(receive_buff[idx] == '\n') {
    //         break;
    //     }
    // }
    // uart_loopback_disable();

    // printf("Loopback received: ");
    // printf(receive_buff);
    // uart_write_flush();

    // // toggling some GPIOs
    // gpio_set_direction(0xFFFF, 0x000F); // lowest four as outputs
    // gpio_write(0x0A);  // ready output pattern
    // gpio_enable(0xFF); // enable lowest eight
    // // wait a few cycles to give GPIO signal time to propagate
    // asm volatile ("nop; nop; nop; nop; nop;");
    // printf("GPIO (expect 0xA0): 0x%x\n", gpio_read());

    // gpio_toggle(0x0F); // toggle lower 8 GPIOs
    // asm volatile ("nop; nop; nop; nop; nop;");
    // printf("GPIO (expect 0x50): 0x%x\n", gpio_read());
    // uart_write_flush();

    // // doing some compute
    // uint32_t start = get_mcycle();
    // uint32_t res   = isqrt(1234567890UL);
    // uint32_t end   = get_mcycle();
    // printf("Result: 0x%x, Cycles: 0x%x\n", res, end - start);
    // uart_write_flush();

    // // using the timer
    // printf("Tick\n");
    // sleep_ms(10);
    // printf("Tock\n");
    // uart_write_flush();

    // Userrom test
    printf("BEGIN User Rom Test\n");
    uart_write_flush();

    printf("The content of the ROM (interpreted as ASCII) is:\n");
    for(int i = 0; i < BYTES; i++) {
        char c = *reg8(USER_ROM_BASE_ADDR, i);
        if (c == '\0') break;
        printf("%c", c);
    }
   
    uart_write_flush();

    printf("END User Rom Test\n");
    uart_write_flush();

    // MAC Test
    printf("BEGIN MAC Test\n");
    uart_write_flush();

    // Test the MAC instruction
    int a = 7, b = 6, c = 5;
    int expected = a * b + c;
    uint32_t start = get_mcycle();
    int result = mac(a, b, c);
    uint32_t end = get_mcycle();
    printf("MAC test: %x * %x + %x = %x (expected %x)\n", a, b, c, result, expected);
    printf("Cycles: 0x%x\n", end - start);
    uart_write_flush();

    if (result == expected) {
        printf("MAC instruction works!\n");
        uart_write_flush();
    } else {
        printf("MAC instruction FAILED!\n");
        uart_write_flush();
    }
    return 1;
}
