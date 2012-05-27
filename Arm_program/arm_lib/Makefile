CC=arm-linux-gcc
AS=arm-linux-as
LD=arm-linux-ld

OBJCOPY=arm-linux-objcopy
OBJCFLAGS=--gap-fill=0xff

src_c = $(wildcard *.c)
src_s = $(wildcard *.s)
obj_c = $(patsubst %.c, %.o, $(src_c))
obj_s = $(patsubst %.s, %.o, $(src_s))
obj = $(obj_s) $(obj_c)

target = app

$(target).bin:$(target)
	$(OBJCOPY) $(OBJCFLAGS) -O binary  $< $@

$(target):$(obj)
	$(LD) -e 0x21000000  -Ttext 0x21000000 $^ -o $@
%.o:%.c
	$(CC) -o $@ -c $<
%.o:%.s
	$(AS) -o $@ $<

clean:
	-rm -f $(target)
	-rm -f $(target).bin
	-rm -f $(obj_s)
	-rm -f $(obj_c)
	-rm -f *~

.PHONY: clean

