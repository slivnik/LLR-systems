RS=unknown
RDEBUG=0
RTRACE=1

TESTS=1
PARSER=dfa

parser: parser.o lexer.o
	gcc -o parser parser.o lexer.o -lfl
	cp parser parser-$(RS)-$(PARSER)

parser.o: parser-$(PARSER).c $(RS)-redgen.c $(RS)-redgen.h parser-$(PARSER).c timing.h
	gcc -O2 -DTESTS=$(TESTS) -DRDEBUG=$(RDEBUG) -DRTRACE=$(RTRACE) -DRSH=\"$(RS)-redgen.h\" -DRSC=\"$(RS)-redgen.c\" -o parser.o -DMAIN -c parser-$(PARSER).c

lexer: lexer.c $(RS)-redgen.h
	gcc -O2 -DRSH=\"$(RS)-redgen.h\" -DRSC=\"$(RS)-redgen.c\" -o lexer -DMAIN lexer.c $(RS)-redgen.h -lfl
	cp lexer lexer-$(RS)-$(PARSER)

lexer.o: lexer.c $(RS)-redgen.h
	gcc -O2 -DRSH=\"$(RS)-redgen.h\" -DRSC=\"$(RS)-redgen.c\" -c lexer.c

lexer.c: lexer.l
	flex -o lexer.c lexer.l

$(RS)-redgen.c $(RS)-redgen.h: $(RS).rs
	java -classpath ../../src/redgen/bin/ redgen.Main $(PARSER) $(RS).rs

parser-full.c:;	cp ../parser-full.c .
parser-lim.c:;	cp ../parser-lim.c .
parser-dfa.c:;	cp ../parser-dfa.c .
timing.h:;	cp ../timing.h .

clean:
	'rm' -fr parser.o lexer.o lexer.c *-redgen.c *-redgen.h parser-full.c parser-lim.c parser-dfa.c timing.h

distclean: clean
	find . -executable -name 'lexer*' -delete
	find . -executable -name 'parser*' -delete
