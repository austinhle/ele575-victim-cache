# Modified by Princeton University on June 9th, 2015
# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: sjm_4.cmd
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
CONFIG id=28 iosyncadr=0x7CF00BEEF00
TIMEOUT 10000000
IOSYNC
#==================================================
#==================================================


LABEL_0:

WRITEBLKIO  0x00000611341f4d80 +
        0x734a78e0 0x6eaeab5f 0xd253c55f 0x81efd726 +
        0xfcef47d9 0x794b268a 0xb09befca 0x456f8a7c +
        0x74c84381 0xa0004a69 0x948f7a07 0xd921cf62 +
        0x8ae91c6b 0x35420b0a 0x01c6e16a 0x43b7082c 

WRITEBLKIO  0x00000612e3cab840 +
        0xb29ceb36 0x830d9e28 0x84d67c84 0x8c46537d +
        0xc3dd93dc 0x3da5cae0 0x350db048 0x3a969f85 +
        0x0df1e384 0x69b120a5 0xe57ef29c 0x72a187ae +
        0xeab5406d 0x2f1e194b 0x140c1a29 0xb72d5e40 

WRITEMSKIO  0x00000601d6c44100 0xfff0  0x4169f137 0x26b294db 0xce6cc932 0x00000000 

WRITEBLK  0x000000037cbd08c0 +
        0x03149d34 0xb67980bd 0x1f52f709 0x07de93ac +
        0x6615db18 0x6c9fb17f 0xcd821ebf 0xd230ae2d +
        0xf9a9d528 0xf2984690 0xd515496a 0x34f0160e +
        0x7df3dda0 0x81dd9c80 0x8bc94386 0xba67635f 

READBLKIO  0x00000611341f4d80 +
        0x734a78e0 0x6eaeab5f 0xd253c55f 0x81efd726 +
        0xfcef47d9 0x794b268a 0xb09befca 0x456f8a7c +
        0x74c84381 0xa0004a69 0x948f7a07 0xd921cf62 +
        0x8ae91c6b 0x35420b0a 0x01c6e16a 0x43b7082c 

WRITEBLK  0x00000010595e5680 +
        0x4456e836 0xb3d61c80 0x2e32bb34 0x73a3a737 +
        0xbf1a9962 0xd90f16e1 0x5e2a336f 0x2035ab03 +
        0x49631f16 0xe6d7ce87 0x1258b82c 0x13430837 +
        0x06fe9614 0x8ed9ad6a 0x2c2f59a1 0xf115d1df 

WRITEMSKIO  0x0000060b7bce7ec0 0x0ff0  0x00000000 0x38850104 0xa2bd10eb 0x00000000 

WRITEMSK  0x000000037cbd08c0 0x000f0f000fff00ff +
        0x00000000 0x00000000 0x00000000 0x5b5581f1 +
        0x00000000 0xc7d78a3e 0x00000000 0x00000000 +
        0x00000000 0xf799e253 0x31a7e19c 0xf0512c6b +
        0x00000000 0x00000000 0x7ef251ae 0xd765dd59 

WRITEIO  0x0000060733049cc0 4 0xa4796eb5 

WRITEBLK  0x00000009e8e6c140 +
        0x6f6bf318 0xd8b6ebb7 0x0d00cb8a 0x1067672d +
        0x8f28c371 0xf38de6de 0x42bf1ef0 0x0355b1e1 +
        0x9f8f4a7b 0x12df32a8 0x5538d820 0xf4eb3c67 +
        0xb3fe3526 0x78c40371 0x183bd180 0x8f6730dc 

WRITEBLKIO  0x0000061bb34f0240 +
        0x58ce5f51 0x96983422 0x29eda4cc 0xc3e5ac17 +
        0x3f9ad308 0x33262a46 0x31504444 0x161925a1 +
        0xf73dc4ad 0x47216856 0x8de3cdb2 0xa16b6321 +
        0xb000248c 0x8e3b6dc6 0xef0c4227 0x4468edf9 

READIO  0x0000060733049cc0 4 0xa4796eb5 
WRITEMSK  0x000000037cbd08c0 0x0ff000f00ffff0ff +
        0x00000000 0x249f8fc5 0xd777fcc7 0x00000000 +
        0x00000000 0x00000000 0x0cc4c2d0 0x00000000 +
        0x00000000 0xa200234b 0x8bc453ec 0x34bd3486 +
        0x6730a92a 0x00000000 0x7a298350 0x8768a923 

WRITEBLKIO  0x0000061ca00b87c0 +
        0xc3c99bba 0xa4746bce 0x0ce54405 0x9cbbcbf8 +
        0xbbe93adf 0x1c7d8348 0x02aa93e8 0xca906004 +
        0xda2086d4 0x3c02aab2 0x352b3276 0xdbc59d88 +
        0xc9e218eb 0x40d63476 0x41a736f5 0x6d4f07db 

WRITEBLKIO  0x0000061a60aa9240 +
        0x233ceb44 0x08b86c9b 0x1333a7e3 0x14986d8e +
        0x23605690 0xaf66ae26 0x254d9513 0x6710349b +
        0xf415ea30 0xbbf9e35b 0x5626fed3 0x2d0789b9 +
        0xfbda4b60 0x24e1305c 0x1d184745 0xcb11eb04 

WRITEMSK  0x000000037cbd08c0 0xfff00fff00ff000f +
        0xdf49b197 0xd9b4793c 0xe1971a24 0x00000000 +
        0x00000000 0x0b71572d 0x58ee4d50 0x383f2fd5 +
        0x00000000 0x00000000 0x205d378e 0xe119a631 +
        0x00000000 0x00000000 0x00000000 0x5ff83673 

WRITEMSK  0x000000037cbd08c0 0xf00f0ffff0ff0f0f +
        0x34c1b118 0x00000000 0x00000000 0x7d128712 +
        0x00000000 0xfc1c2d1b 0xe1dbf600 0x31b29cd3 +
        0xc023d3ff 0x00000000 0xd5204a23 0x7e6d90f8 +
        0x00000000 0x9c3b4581 0x00000000 0xaa08b157 

READMSKIO   0x00000601d6c44100 0xfff0  0x4169f137 0x26b294db 0xce6cc932 0x00000000 

WRITEBLK  0x0000000a4e4bc580 +
        0x55d5515c 0xf3bfb5ec 0xc04a4f7d 0x575088a1 +
        0x890e8915 0x5b42d1e1 0x60e04c39 0x1588b506 +
        0x3e108047 0x36383a43 0x65d296c0 0x781b280e +
        0x6ea9ba3c 0x4cf0421d 0x2644d4cf 0xda0e09ba 

READBLK  0x000000037cbd08c0 +
        0x34c1b118 0xd9b4793c 0xe1971a24 0x7d128712 +
        0x6615db18 0xfc1c2d1b 0xe1dbf600 0x31b29cd3 +
        0xc023d3ff 0xa200234b 0xd5204a23 0x7e6d90f8 +
        0x6730a92a 0x9c3b4581 0x7a298350 0xaa08b157 

WRITEBLK  0x000000099c4075c0 +
        0x520a7e81 0x37fbef42 0xb6345e23 0xb93b3334 +
        0x4f8b4164 0x2d5967cd 0x7a900c3e 0xaf6aa17b +
        0xcefa1c28 0xa3c13bc4 0x0ae95b7b 0x4e651a8d +
        0x23b36e55 0x8cde07bd 0x921758dd 0xf5f123bf 

WRITEBLKIO  0x00000603e7dfc780 +
        0x518941ab 0xde27d5b4 0xc715ab67 0x0bc5e54f +
        0xee2de9aa 0xd00c3170 0x5f108294 0x7314550c +
        0x022c982a 0x99def021 0xf222ad52 0x433fe22a +
        0x5fd47708 0x0b052ef1 0x9db58159 0x85df41d4 

READBLKIO  0x00000612e3cab840 +
        0xb29ceb36 0x830d9e28 0x84d67c84 0x8c46537d +
        0xc3dd93dc 0x3da5cae0 0x350db048 0x3a969f85 +
        0x0df1e384 0x69b120a5 0xe57ef29c 0x72a187ae +
        0xeab5406d 0x2f1e194b 0x140c1a29 0xb72d5e40 

WRITEBLKIO  0x0000060b61880cc0 +
        0x2db5c8fa 0x01c1cba6 0x6c362a9f 0xfcbddcff +
        0x7b9d823b 0xe73b1002 0x2ce81c2f 0xfe29bbc1 +
        0x61ce7972 0xe31190ac 0x7d879387 0xbcc2698d +
        0x7d930619 0x779ef5b6 0xf8c42b54 0x5e44e621 

WRITEMSKIO  0x0000061f550d0c80 0xf0f0  0xba3b3165 0x00000000 0x21b80415 0x00000000 

WRITEMSK  0x00000010595e5680 0x0f0fffff0000000f +
        0x00000000 0xc538bcb8 0x00000000 0x0e2d5aba +
        0x4ab685ef 0x8b320a88 0x0a9286b9 0xb985983a +
        0x00000000 0x00000000 0x00000000 0x00000000 +
        0x00000000 0x00000000 0x00000000 0x0a169f78 

WRITEBLK  0x0000001234225a00 +
        0x816f218f 0xb6cf87f9 0x74cc8e6b 0xf288f349 +
        0xd37a4736 0x8ed3f8b4 0x74174ba2 0xc52b2f8b +
        0x774ddb3f 0xae1ce2df 0x6331cceb 0x9c939cdb +
        0x862fb7eb 0x7f0ca4ef 0x779c8cbf 0xbbc132f9 

WRITEBLK  0x00000014fc997440 +
        0x71f9deeb 0x61ef42c3 0x7ad9194f 0x2cf87f7f +
        0x2f06a9e7 0x878dfd43 0x2d635a3e 0xb1c65fa1 +
        0xa3c0ebdc 0xdf4eb2d6 0x895d8c8b 0x16183786 +
        0x064de1e0 0xb31311f2 0x26fc7fde 0x614b3879 

READBLKIO  0x0000061bb34f0240 +
        0x58ce5f51 0x96983422 0x29eda4cc 0xc3e5ac17 +
        0x3f9ad308 0x33262a46 0x31504444 0x161925a1 +
        0xf73dc4ad 0x47216856 0x8de3cdb2 0xa16b6321 +
        0xb000248c 0x8e3b6dc6 0xef0c4227 0x4468edf9 

READBLK  0x00000010595e5680 +
        0x4456e836 0xc538bcb8 0x2e32bb34 0x0e2d5aba +
        0x4ab685ef 0x8b320a88 0x0a9286b9 0xb985983a +
        0x49631f16 0xe6d7ce87 0x1258b82c 0x13430837 +
        0x06fe9614 0x8ed9ad6a 0x2c2f59a1 0x0a169f78 

WRITEMSK  0x00000009e8e6c140 0x00f0f0f0000ff000 +
        0x00000000 0x00000000 0x410ce30f 0x00000000 +
        0x3f549f4f 0x00000000 0x22e94b4c 0x00000000 +
        0x00000000 0x00000000 0x00000000 0x28c65851 +
        0xb507de4c 0x00000000 0x00000000 0x00000000 

WRITEBLKIO  0x0000061f7fd88c80 +
        0x7a7e1ef1 0x1ab2a4f6 0x7009142f 0x2358719e +
        0xb2140d98 0x05da1b50 0xdfd9b4a8 0x8ab05ae8 +
        0x8787934f 0xf2761c4f 0x7a2b1471 0x8ead77d7 +
        0x3a08c114 0xa409064b 0x97478a2c 0x47a4de1e 

READBLKIO  0x0000061ca00b87c0 +
        0xc3c99bba 0xa4746bce 0x0ce54405 0x9cbbcbf8 +
        0xbbe93adf 0x1c7d8348 0x02aa93e8 0xca906004 +
        0xda2086d4 0x3c02aab2 0x352b3276 0xdbc59d88 +
        0xc9e218eb 0x40d63476 0x41a736f5 0x6d4f07db 

WRITEIO  0x000006176d83a5c0 16 0x6bb67633 0xf948b8cb 0xdb324149 0x3c73aa94 

READBLK  0x00000009e8e6c140 +
        0x6f6bf318 0xd8b6ebb7 0x410ce30f 0x1067672d +
        0x3f549f4f 0xf38de6de 0x22e94b4c 0x0355b1e1 +
        0x9f8f4a7b 0x12df32a8 0x5538d820 0x28c65851 +
        0xb507de4c 0x78c40371 0x183bd180 0x8f6730dc 

WRITEMSKIO  0x0000060bec16ad40 0x0fff  0x00000000 0x2ae9fcb5 0x9804cbc7 0x08dfd83e 

READBLKIO  0x0000061a60aa9240 +
        0x233ceb44 0x08b86c9b 0x1333a7e3 0x14986d8e +
        0x23605690 0xaf66ae26 0x254d9513 0x6710349b +
        0xf415ea30 0xbbf9e35b 0x5626fed3 0x2d0789b9 +
        0xfbda4b60 0x24e1305c 0x1d184745 0xcb11eb04 

READBLKIO  0x00000603e7dfc780 +
        0x518941ab 0xde27d5b4 0xc715ab67 0x0bc5e54f +
        0xee2de9aa 0xd00c3170 0x5f108294 0x7314550c +
        0x022c982a 0x99def021 0xf222ad52 0x433fe22a +
        0x5fd47708 0x0b052ef1 0x9db58159 0x85df41d4 


BA LABEL_0