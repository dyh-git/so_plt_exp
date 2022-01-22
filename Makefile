CC ?= gcc
AR ?= ar

USER_SRCS := malloc_main.c
USER_OBJS := $(patsubst %.c,%.o,$(wildcard $(USER_SRCS)))
USER_D0_SRCS := malloc_so.c
USER_D0_OBJS := $(patsubst %.c,%.o,$(wildcard $(USER_D0_SRCS)))
USER_D1_SRCS := malloc_free_so.c
USER_D1_OBJS := $(patsubst %.c,%.o,$(wildcard $(USER_D1_SRCS)))

OUTPUT_DIR := output

LD0_FLAGS := -lmalloc0
LD1_FLAGS := -lmalloc1

D0_LIB_NAME := libmalloc0.so
D1_LIB_NAME := libmalloc1.so

USER_PROGRAM_NAME := malloc_main

CFLAGS = -Wall -g -fPIC
#CFLAGS += -z norelro		#GOT表被修改

.PHONY: all clean

$(OUTPUT_DIR)/libs/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -o $@ -c $<

$(OUTPUT_DIR)/libs/$(D0_LIB_NAME): $(USER_D0_OBJS)
	mkdir -p $(dir $@)
	$(CC) -fPIC -shared -o $@ $^
	echo "Build $@ is finished"

$(OUTPUT_DIR)/libs/$(D1_LIB_NAME): $(USER_D1_OBJS)
	mkdir -p $(dir $@)
	$(CC) -fPIC -shared -o $@ $^
	echo "Build $@ is finished"

$(USER_PROGRAM_NAME): $(USER_SRCS)
	$(CC) $^ $(CFLAGS) -L./$(OUTPUT_DIR)/libs -Wl,-Bdynamic $(LD0_FLAGS) $(LD1_FLAGS) -o $@

all: $(OUTPUT_DIR)/libs/$(D0_LIB_NAME) \
	$(OUTPUT_DIR)/libs/$(D1_LIB_NAME) \
	$(USER_PROGRAM_NAME)

clean:
	rm *.o -rf
	rm *.a -rf
	rm *.so -rf
	rm -rf $(USER_PROGRAM_NAME)
	rm output -rf