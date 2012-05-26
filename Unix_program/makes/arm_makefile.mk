all:
	arm-linux-as *.s
	arm-linux-gcc -c *.c
	arm-linux-ld -e 0x21000000  -Ttext 0x21000000 uart_start.o uart.o -o app
	arm-linux-objcopy --gap-fill=0xff -O binary app app.bin 
clean:
	-rm -f $(target)
	-rm -f $(target).bin
	-rm -f $(obj_s)
	-rm -f $(obj_c)
	-rm -f *~

.PHONY: clean
