# LLR-system: source code

**Tools needed:**

- Java: <code>javac</code> and <code>java</code>
- <code>flex</code> and <code>bison</code>

**Compiling:** Just type <code>make</code> to produce the <code>class</code> files inside<code>redgen/bin</code>.

**Running:** The program, i.e., <code>redgen.Main</code>, takes two arguments:

- the name of the algorithm (<code>full</code>, <code>lim</code> or <code>dfa</code>) and
- the name of the file containing the LLR-system.

**LLR-system specification:** An LLR-system is specified by a list of reductions.  For instance:
```
a b c --> S ;
a S Q --> S ;
b b c c --> b Q c ;
Q c --> c Q ;
```
The symbols on the left side of each reduction are numbered (starting with 1).  On the right side of the reduction the symbols, which are created by a reduction, might be augmented by a list of numbers denoting symbols reduced to that symbol.  Likewise, symbols that are not modified by the reduction but perhaps change places can also be specified by a number.  The last two reduction can therefore be rewritten to
```
b b c c --> b Q(2,3) c ;
Q c --> 2 1 ;
```
Furthermore, reductions like
```
c a c --> c a
c b c --> c b
```
can be written as
```
c (a|b) c --> c 2
```
Symbol <code>[</code> and <code>]</code> denote the left and the right marker.

