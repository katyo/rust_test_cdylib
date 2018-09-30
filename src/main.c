#include <stdio.h>
#include <dlfcn.h>

int main(void) {
  dlopen(TARGET "/libtest_cdylib.so", RTLD_NOW);
  printf("plugins loaded\n");
  return 0;
}
