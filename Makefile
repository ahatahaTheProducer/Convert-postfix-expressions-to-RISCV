default:
	as -o postfix_translator.o main.s
	ld -o postfix_translator postfix_translator.o
