#include <stdio.h>

__attribute__((constructor))
void myplugin_initialize(void) {
  printf("myplugin initialized\n");
}
