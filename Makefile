# orig linking
# cc -Wl,--as-needed -Wl,-z,noexecstack -m64 -o target/c/libtest.so -Wl,--gc-sections -Wl,-zrelro -Wl,-znow -Wl,-O1 -nodefaultlibs -Wl,--start-group -Wl,-Bstatic $(stdlibs) -Wl,--end-group $(builtins) -Wl,-Bdynamic -ldl -lrt -lpthread -lpthread -lgcc_s -lc -lm -lrt -lpthread -lutil -lutil -shared

TARGET:=target/c

all: $(TARGET)/test_cdylib $(TARGET)/libtest_cdylib.so
	@./$<

$(TARGET)/libtest_cdylib.so: $(TARGET)/test_cdylib.o
	@mkdir -p $(TARGET)
	@cc -Wl,--as-needed -Wl,-z,noexecstack -m64 $^ -o $@ -Wl,--gc-sections -Wl,-zrelro -Wl,-znow -Wl,-O1 -nodefaultlibs -Wl,--start-group -Wl,-Bstatic $(stdlibs) -Wl,--end-group $(builtins) -Wl,-Bdynamic -ldl -lrt -lpthread -lpthread -lgcc_s -lc -lm -lrt -lpthread -lutil -lutil -shared

$(TARGET)/test_cdylib.o: src/lib.c
	@mkdir -p $(TARGET)
	@cc -O3 -std=c99 -DTARGET='"$(TARGET)"' -c $< -o $@

$(TARGET)/test_cdylib: src/main.c
	@mkdir -p $(TARGET)
	@cc -O3 -std=c99 -DTARGET='"$(TARGET)"' $< -o $@ -ldl

clean:
	@rm -rf $(TARGET)
