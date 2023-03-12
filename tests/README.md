
# LLR-system: examples

**Parser skeletons:**
- <code>parser-full.c</code>: the skeleton of the full backjumping parser;
- <code>parser-lim.c</code>: the skeleton of the limited backjumping parser;
- <code>parser-dfa.c</code>: the skeleton of the DFA-based parser;

**Examples (inputs):**
- <code>examples-exprs-000</code>: examples of arithmetic expressions;
- <code>examples-pascal-000</code>: the source code of TANGLE, WEAVE. TeX and MetaFont:
	- <code>*.p</code>: the original TANGLE output;
	- <code>*-formatted.p</code>: <code>*.p</code> files stripped of comments and formated with <code>ptop</code>;
	- <code>*-formatted-lower.p</code>: <code>*.p</code> files stripped of comments and formated with <code>ptop</code> and with keywords in lowercase;

**Examples (LLR-systems):** 
- <code>examples-expr-bison</code>: the referential <code>bison</code> parser based on the LALR grammar in Example 6;
- <code>examples-expr-lr</code>: the LALR grammar in Example 6 transformed into an LLR-system
- <code>examples-expr-ll</code>: the LALR grammar in Example 6 transformed into an SLL grammar and transformed into an LLR-system;
- <code>examples-expr-llr</code>: the LLR system in Example 6.
- <code>examples-pascal-bison</code>: the referential <code>bison</code> parser for Pascal;
- <code>examples-pascal-llr1</code>: the handwritten LLR-system for Pascal based on the SLL grammar but with several conflict resolved using techniques desribed in the paper;
- <code>examples-pascal-llr2</code>: the handwritten LLR-system for Pascal ;

<code>bison</code> parsers are compiled and run as
```
make distclean parser TESTS=1
./parser ../example-pascal-000/tex.p
```
LLR-system parsers are compiled as
```
make distclean parser TESTS=1 PARSER=dfa
./parser ../example-pascal-000/tex.p
```
The value of <code>PARSER</code> should be <code>full</code>, <code>lim</code> or <code>dfa</code>.

