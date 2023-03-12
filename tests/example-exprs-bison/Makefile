GRAMMAR=lr
DEBUGLEXER=0
DEBUGPARSER=0

TESTS=1

all: 	parser lexer

parser:	parser.o lexer.o
	gcc -O2 -o parser parser.o lexer.o -lfl
	cp parser parser-$(GRAMMAR)

lexer: lexer.c parser.tab.h timing.h
	gcc -O2 -o lexer -DTESTS=$(TESTS) -DDEBUGLEXER=$(DEBUGLEXER) -DMAIN lexer.c -lfl

lexer.o: lexer.c parser.tab.h timing.h
	gcc -O2 -DDEBUGLEXER=$(DEBUGLEXER) -o lexer.o -c lexer.c

lexer.c: lexer.l
	flex -o lexer.c lexer.l

parser.o: parser.tab.c parser.tab.h timing.h
	gcc -O2 -o parser.o -DTESTS=$(TESTS) -DDEBUGPARSER=$(DEBUGPARSER) -c parser.tab.c

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

parser.y: rules parser.y.prolog parser.y.epilog
	cat parser.y.prolog rules parser.y.epilog > parser.y

rules: grammar.$(GRAMMAR)
	cat grammar.$(GRAMMAR) | sed 's/->/:/' | sed 's/\.//' | awk '/#.*/{print "";next;}/:/{print $$0"\n\t {printf(\"%s\\n\",\""$$0"\");} ;";}' | awk '/^[a-z]/{for(I=1;I<=NF;I++){if($$I ~ /[A-Z]/)$$I="_"$$I;}};{print;}' > rules

timing.h:;	cp ../timing.h .

clean: distclean
distclean:
	'rm' -fr *~ lexer.c parser.y parser.tab.* rules *.o lexer parser timing.h
	find . -executable -name 'lexer*' -delete
	find . -executable -name 'parser*' -delete
