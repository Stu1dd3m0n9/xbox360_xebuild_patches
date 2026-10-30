# ============================================================================
# RGLoader additions for devkit kernel 15574 (SE 15574)
#
# Included at the end of 15574_RGLoader/inc/khv_15574.S (which is the
# 15574_XDKBuild base). Brings the 15574 kernel up to what 17489_RGLoader adds
# on top of 17489_XDKBuild.
#
# Source: RGLoader 0v305 patches\KHV\15574-dev\RGLoader-15574-dev.S
#         (identical to RGLoader/RGLoader-Patches @ d21cbcc). Addresses are
#         15574-dev native; nothing here is ported from another kernel.
#
# Left out on purpose (already in the base, or replaced by it):
#   0x80006C08 li r3,0         - identical to base "Bypass CD check"
#   0x80030C2C nop             - identical to base HvxExpansionInstall patch
#   0x800A2C08 / 0x800A0C6C    - identical to base XEX restrictions patches
#   0x801A6870 li r3,1         - base SataDiskAuthenticateDevice set covers it
#   0x8000AC00 + 0x800018B8    - RGL flag fixer; base has the vfuse-aware
#                                flag fixer (0x18C0 -> 0xB188 + FixFuses 0xB400)
#   0x8008180C / 0x80081348    - RGL "disable shadowboot"; we follow
#                                17489_XDKBuild, which leaves shadowboot enabled
#   RGL sysroot_hdd option     - base sysroot_hdd.S (string fixed to 15574-dev)
#
# Verified against live 15574 dev kernel dump (0x80100000-0x801B0000):
#   0x80127CD4 0x80147E08 0x80147E3C 0x80147EDC 0x80149ED4(+0x128 = li r3,1)
#   0x801837F0 0x80183B04 - original instructions match each patch's intent.
# Everything below 0x80100000 (HV + low kernel) is NOT yet byte-verified.
#
# Branch operands (b 0x18 etc.) are relative, same convention as the base
# (e.g. WgcAddDevice "b 0x10" -> 48000010 in the live dump).
# ============================================================================

# ============================================================================
#   Hypervisor
# ============================================================================

# ============================================================================
#   Retail XEX2 AES key (lets retail-signed xex decrypt on the dev kernel)
#   note: should be static
# ============================================================================
KMAKEPATCH 0x800000F0
0:
   .long 0x20B185A5
   .long 0x9D28FDC3
   .long 0x40583FBB
   .long 0x0896BF91
9:

# ============================================================================
#   Check if XEX decrypted properly, if not swap to the other key
# ============================================================================
KMAKEPATCH 0x80029AD0
0:
   cmpldi  cr6, %r28, 0
   beq     cr6, 0x30
   cmpwi   cr6, %r3, 0
   bne     cr6, 0x10
   li      %r4, 0xF0
   b       0x18
   nop
9:

# ============================================================================
#   KV check patches - HvxKeysHmacSha
# ============================================================================
KMAKEPATCH 0x80004D54
0:
   nop
9:

# ============================================================================
#   HV flag check (RGL: "nop out machine check")
#   REVIEW: sits 3 instructions after the base CB bypass at 0x6A5C
# ============================================================================
.ifndef rgl_skip_6a68
KMAKEPATCH 0x80006A68
0:
   nop
9:
.endif

# ============================================================================
#   Patch XEX flag
# ============================================================================
KMAKEPATCH 0x80006D40
0:
   li %r3, 0
9:

KMAKEPATCH 0x800070CC
0:
   li %r4, 0x8
   li %r3, 0
9:

# ============================================================================
#   HV Patch blow fuses
# ============================================================================
KMAKEPATCH 0x80009B80
0:
   li %r3, 1
   blr
9:

# ============================================================================
#   MachineCheck (mfspr r3, LPCR)
#   REVIEW: base also NOPs a MachineCheck at 0x6C8C; this is a different site
# ============================================================================
.ifndef rgl_skip_218
KMAKEPATCH 0x80000218
0:
   .long 0x00000000
9:
.endif

# ============================================================================
#   DVDAuth2 retail key
#   note: should stay constant
# ============================================================================
KMAKEPATCH 0x80010B38
0:
   .long 0xD1E3B33A
   .long 0x6C1EF770
   .long 0x5F6DE93B
   .long 0xB6C0DC71
9:

# ============================================================================
#   HvxDvdAuthRecordXControl
# ============================================================================
KMAKEPATCH 0x80026B4C
0:
   li %r3, 1
9:

# ============================================================================
#   HV DAE
# ============================================================================
KMAKEPATCH 0x80028ECC
0:
   li %r3, 0
   nop
9:

# ============================================================================
#   HvxSetImagePageTableEntry memory addr check
# ============================================================================
KMAKEPATCH 0x80029C88
0:
   nop
9:

# ============================================================================
#   HvxCreateImageMapping hash check
# ============================================================================
KMAKEPATCH 0x8002C664
0:
   b 0x10
9:

# ============================================================================
#   HvxCreateImageMapping HV XEX region check
# ============================================================================
KMAKEPATCH 0x8002C75C
0:
   nop
9:

# ============================================================================
#   HvxExpansionInstall sig check
# ============================================================================
KMAKEPATCH 0x80030BAC
0:
   nop
9:

# ============================================================================
#   Kernel
# ============================================================================

# ============================================================================
#   Fix controller desync bug in 15574 (RGLoader 0v305 fix)
#   orig: lbz r9,0x6F(r31) / rlwinm. / beq   -> force bit 3 and store
# ============================================================================
KMAKEPATCH 0x80127CD4
0:
   ori %r9, %r9, 8
   stb %r9, 0x6F(%r31)
9:

# ============================================================================
#   XexpVerifyMediaType
# ============================================================================
KMAKEPATCH 0x8009EB9C
0:
   li %r3, 1
9:

# ============================================================================
#   XexpVerifyXexHeaders
# ============================================================================
KMAKEPATCH 0x800A0654
0:
   li %r3, 1
9:

KMAKEPATCH 0x800A06B0
0:
   li %r3, 1
9:

# ============================================================================
#   XexpVerifyMinimumVersion
# ============================================================================
KMAKEPATCH 0x800A1470
0:
   li %r3, 1
9:

# ============================================================================
#   XexpLoadFile
# ============================================================================
KMAKEPATCH 0x800A2D6C
0:
   li %r3, 1
9:

# ============================================================================
#   SataCdRomVerifyDVDX2AuthoringSignature
# ============================================================================
KMAKEPATCH 0x800C3170
0:
   li %r3, 1
9:

# ============================================================================
#   SataCdRomActivateHCDFRuntimePatch TSST signature check
# ============================================================================
KMAKEPATCH 0x800C4BE4
0:
   b 0x184
9:

# ============================================================================
#   SataCdRomActivateHCDFRuntimePatch blacklisted drive check
# ============================================================================
KMAKEPATCH 0x800C4C00
0:
   b 0x168
9:

# ============================================================================
#   SataCdRomAuthenticationExSequence
# ============================================================================
KMAKEPATCH 0x800C51D0
0:
   b 0x38
9:

# ============================================================================
#   StfsMapNewBlock hash mismatch
# ============================================================================
KMAKEPATCH 0x800E1D34
0:
   b 0x34
9:

# ============================================================================
#   XeKeysVerifyRSASignature  (verified: beq -> nop, li r3,0 -> li r3,1)
# ============================================================================
KMAKEPATCH 0x80147E08
0:
   nop
9:

KMAKEPATCH 0x80147E3C
0:
   li %r3, 1
9:

# ============================================================================
#   XeKeysVerifyPIRSSignature  (verified: li r3,0 -> li r3,1)
# ============================================================================
KMAKEPATCH 0x80147EDC
0:
   li %r3, 1
9:

# ============================================================================
#   XeKeysConsoleSignatureVerification
#   (verified: +0x128 lands on li r3,1 @ 0x80149FFC)
# ============================================================================
KMAKEPATCH 0x80149ED4
0:
   b 0x128
9:

# ============================================================================
#   SvodMapNewBlock hash mismatch  (verified: beq +0x30 -> b +0x30)
# ============================================================================
KMAKEPATCH 0x801837F0
0:
   b 0x30
9:

# ============================================================================
#   SvodPartiallyCachedRead hash mismatch  (verified: blt -> nop)
# ============================================================================
KMAKEPATCH 0x80183B04
0:
   nop
9:

# ============================================================================
#   Options (RGLoader 0v311 defaults: kd_1retry=1, disable_bootanim=1)
# ============================================================================

.ifdef kd_1retry
# KdpRetryCount (default 5) / KdNetRetryCount (default 3) -> 1, faster boot
KMAKEPATCH 0x801CD88C
0:
   .long 0x00000001
9:

KMAKEPATCH 0x801CD89C
0:
   .long 0x00000001
9:
.endif

.ifdef disable_bootanim
# nop out AniStartBootAnimation (needed for RGLoader custom boot animation)
KMAKEPATCH 0x800817DC
0:
   nop
9:
.endif

# ============================================================================
#   NOTE: RGLoader.xex loading
#   17489_RGLoader hooks the kernel to load RGLoader.xex after XAM. There is no
#   15574 version of that hook. RGLoader 0v305 instead ships a patched xam.xex
#   (patches.txt: XtweakXam path -> \SystemRoot\RGLoader.xex), so use the 0v305
#   15574-dev xam.xex + RGLoader.xex in the filesystem.
# ============================================================================
