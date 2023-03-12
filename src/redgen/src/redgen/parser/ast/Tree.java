package redgen.parser.ast;

import java.util.*;

import redgen.redsys.*;

/**
 * A single node of the abstract syntax tree produced by a reduction system
 * parser.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Tree {

	public final RedSystem.Symbol symb;

	private final Vector<Tree> subtrees;

	public Tree(RedSystem.Symbol symb, Vector<Tree> subtrees) {
		this.symb = symb;
		this.subtrees = subtrees == null ? null : new Vector<Tree>(subtrees);
	}

	public Vector<Tree> subtrees() {
		if (subtrees == null)
			return null;
		return new Vector<Tree>(subtrees);
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		buffer.append(symb.name);
		if (subtrees != null) {
			buffer.append("(");
			for (int i = 0; i < subtrees.size(); i++) {
				if (i > 0)
					buffer.append(",");
				buffer.append(subtrees.get(i).toString());
			}
			buffer.append(")");
		}
		return buffer.toString();
	}

}
