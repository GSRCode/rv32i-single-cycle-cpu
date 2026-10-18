#!/usr/bin/env python3
"""Generate deterministic regression machine code (no assembler required)."""
def i(imm,rs1,f3,rd,op):return ((imm&4095)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def r(rs2,rs1,rd):return (rs2<<20)|(rs1<<15)|(rd<<7)|0x33
def s(imm,rs2,rs1):return (((imm>>5)&127)<<25)|(rs2<<20)|(rs1<<15)|(2<<12)|((imm&31)<<7)|0x23
def b(imm,rs2,rs1):return (((imm>>12)&1)<<31)|(((imm>>5)&63)<<25)|(rs2<<20)|(rs1<<15)|(((imm>>1)&15)<<8)|(((imm>>11)&1)<<7)|0x63
def j(imm,rd):return (((imm>>20)&1)<<31)|(((imm>>1)&1023)<<21)|(((imm>>11)&1)<<20)|(((imm>>12)&255)<<12)|(rd<<7)|0x6f
p=[
 i(5,0,0,1,0x13), i(3,1,0,2,0x13),r(2,1,3),s(0,3,0),
 i(0,0,2,4,3),r(0,4,5),r(1,5,6),b(8,6,6),
 i(99,0,0,7,0x13),j(8,8),i(88,0,0,7,0x13),
 i(68,0,0,9,0x13),i(0,9,0,10,0x67),
 i(55,0,0,12,0x13),i(66,0,0,12,0x13),i(77,0,0,12,0x13),i(88,0,0,12,0x13),
 i(44,0,0,11,0x13),0x000016b7,i(7,13,0,13,0x13),i(9,0,0,14,0x13),
 s(4,6,0),i(0,0,2,15,3),i(0,0,0,0,0x13),
 i(0,0,2,16,3),s(8,16,0),i(8,0,2,17,3),i(0,0,0,0,0x13)
]
with open('program.hex','w') as f:
 for x in p:f.write(f'{x:08x}\n')
print(f'Wrote {len(p)} instructions')
