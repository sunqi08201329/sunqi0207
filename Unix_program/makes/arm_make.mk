CC = arm-linux-gcc
AS = arm-linux-as
LD = arm-linux-ld

OBJCOPY = arm-linux-objcopy
OBJCFLAGS = --gap-fill=0xff

src_s = $(wildcard *.s)
obj_s = $(patsubst %.s, %.o, $(src_s))

target = app

$(target).bin:$(target)
	$(OBJCOPY) $(OBJCFLAGS) -O binary $< $@

$(target):$(obj_s)
	$(LD) $^ -o $@

%.o:%.s
	$(AS) -o $@ $<
clean:
	-rm -rf $(target)
	-rm -rf $(obj_s)
	-rm -rf $(target).bin

