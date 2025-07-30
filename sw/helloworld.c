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
    register int a0 asm("a0") = a;
    register int a1 asm("a1") = b;
    register int a2 asm("a2") = c;
    asm volatile (
        ".word %3\n"       // MAC instruction: rd=a2, rs1=a0, rs2=a1
        : "+r"(a2)
        : "r"(a0), "r"(a1), "i"(ENCODE_MAC(12, 10, 11))
    );
    return a2;
}


// static inline int mul(int a, int b) {
//     int result;
//     asm volatile (
//         "mul %0, %1, %2"
//         : "=r"(result)      // output operand
//         : "r"(a), "r"(b)    // input operands
//     );
//     return result;
// }

static inline int mul(int a, int b) {
    register int a5 asm("a5") = a;
    register int a6 asm("a6") = b;
    asm volatile (
        "mul a5, a5, a6"
        : "+r"(a5)      // a5 is both input and output
        : "r"(a6)       // a6 is input
    );
    return a5;
}

static inline int add(int x, int y){
    int result;
    asm volatile (
        "add %0, %1, %2"
        : "=r"(result)
        : "r"(x), "r"(y)
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

    // // ================Userrom test===============
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
    // // ==============END Userrom test==============

    // ==============MAC Test==============
    

    // Test the MAC instruction
    int a = 50, b = 23, c = 11;
    int d = 50, e = 23, f = 11;
    int expected;
    printf("BEGIN Without MAC\n");
    uart_write_flush();
    
    uint32_t start = get_mcycle();
    expected = mul(a, b);
    expected = add(expected, c); // expected result is a * b + c
    uint32_t end = get_mcycle();
    
        
    printf("END Without MAC\n, Expected result: 0x%x, Cycles without MAC: 0x%x\n", expected, end - start);
    uart_write_flush();
    int true_res = d * e + f;
    // MAC not returning because of the return loop
    int result;
    printf("BEGIN With MAC\n");
    uart_write_flush();
    uint32_t start_mac = get_mcycle();
    // asm volatile ("mv a2, %0" : : "r"(c) : "a2");
    
    result = mac(a, b, c);
    asm volatile ("nop;"
                  "nop;"); // ensure MAC retires before reading mcycle
    // printf("\n");
    // uart_write_flush();
    uint32_t end_mac = get_mcycle();
    printf("END With MAC\n");
    uart_write_flush();
    printf("MAC result: 0x%x, expected: 0x%x\n", result, true_res);
    uart_write_flush();
    uint32_t start_nop = get_mcycle();
    asm volatile ("nop;");
    uint32_t end_nop = get_mcycle();
    uint32_t nop_cycles = end_nop - start_nop;
    printf("NOP cycles: 0x%x\n", nop_cycles);
    uart_write_flush();
    printf("MAC cycles: 0x%x\n", end_mac - start_mac - nop_cycles - nop_cycles);
    uart_write_flush();

    if (result == true_res) {
        printf("MAC instruction works!\n");
        uart_write_flush();
    } else {
        printf("MAC instruction FAILED!\n");
        uart_write_flush();
    }
    return 1;
}
