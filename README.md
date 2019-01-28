# Lack initialization of dylib when it built with optimization

**FOUND SOLUTION:** Adding `#[used]` directive to symbol.

This repo demonstrates strange behavior of dylibs which built with optimization.

Shared library example (crate_type = "cdylib"):

```rust
#[cfg_attr(target_os = "linux", link_section = ".init_array")]
pub static INITIALIZE: extern "C" fn() = myplugin_initialize;

// constructor function
#[no_mangle]
pub extern "C" fn myplugin_initialize() {
    println!("myplugin initialized");
}
```

_**NOTE1:** Using ".ctors" instead of ".init_array" as **link_section** gives same result._

_**NOTE2:** Changing **crate-type** from "cdylib" to "dylib" solves this issue, but I actually would like to build "cdylib" not "dylib"._

Expected behavior (dev):

```shell
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/test_cdylib`
myplugin initialized
plugins loaded
```

Unexpected behavior (release):

```shell
$ cargo run --release
    Finished release [optimized] target(s) in 0.02s
     Running `target/release/test_cdylib`
plugins loaded
```

Readelf (dev):

```shell
$ readelf -d target/debug/libtest_cdylib.so

Dynamic section at offset 0x2dbc0 contains 28 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [librt.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libpthread.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [ld-linux-x86-64.so.2]
 0x000000000000000c (INIT)               0x2df8
 0x000000000000000d (FINI)               0x214b8
 0x0000000000000019 (INIT_ARRAY)         0x22bf40
 0x000000000000001b (INIT_ARRAYSZ)       16 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x22bf50
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x228
 0x0000000000000005 (STRTAB)             0x8b0
 0x0000000000000006 (SYMTAB)             0x250
 0x000000000000000a (STRSZ)              1236 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000003 (PLTGOT)             0x22ddc0
 0x0000000000000007 (RELA)               0xf20
 0x0000000000000008 (RELASZ)             7896 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000000000001e (FLAGS)              BIND_NOW
 0x000000006ffffffb (FLAGS_1)            Flags: NOW
 0x000000006ffffffe (VERNEED)            0xe10
 0x000000006fffffff (VERNEEDNUM)         5
 0x000000006ffffff0 (VERSYM)             0xd84
 0x000000006ffffff9 (RELACOUNT)          261
 0x0000000000000000 (NULL)               0x0
```

Readelf (release):

```shell
$ readelf -d target/release/libtest_cdylib.so

Dynamic section at offset 0x2dbb8 contains 28 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [librt.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libpthread.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [ld-linux-x86-64.so.2]
 0x000000000000000c (INIT)               0x2de0
 0x000000000000000d (FINI)               0x21448
 0x0000000000000019 (INIT_ARRAY)         0x22bf40
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x22bf48
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x228
 0x0000000000000005 (STRTAB)             0x8b0
 0x0000000000000006 (SYMTAB)             0x250
 0x000000000000000a (STRSZ)              1236 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000003 (PLTGOT)             0x22ddb8
 0x0000000000000007 (RELA)               0xf20
 0x0000000000000008 (RELASZ)             7872 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000000000001e (FLAGS)              BIND_NOW
 0x000000006ffffffb (FLAGS_1)            Flags: NOW
 0x000000006ffffffe (VERNEED)            0xe10
 0x000000006fffffff (VERNEEDNUM)         5
 0x000000006ffffff0 (VERSYM)             0xd84
 0x000000006ffffff9 (RELACOUNT)          261
 0x0000000000000000 (NULL)               0x0
```

The ".init_array" section less by 8 bytes.

Also the `myplugin_initialize` symbol missing in ".symtab" section of optimized shared object.

In addition I added the reference example in C which demonstrates expected behavior:

```c
#include <stdio.h>

__attribute__((constructor))
void myplugin_initialize(void) {
  printf("myplugin initialized\n");
}
```

```shell
$ make
myplugin initialized
plugins loaded
```
