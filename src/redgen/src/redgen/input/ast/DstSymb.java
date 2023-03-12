package redgen.input.ast;

import java.util.*;

import redgen.report.*;
import redgen.input.*;

/**
 * A symbol on the right side of a reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class DstSymb extends Node implements Dst {

	/** The name of a symbol on the right side of a reduction. */
	public final Token name;

	/**
	 * The positions of symbols on the left side of the reduction that this symbol
	 * is composed of.
	 */
	public final Nodes<DstPos> poss;

	/**
	 * Constructs a symbol on the right side of a reduction.
	 *
	 * @param location The location of the name of a symbol on the right side of a
	 *                 reduction.
	 * @param name     The name of a symbol on the right side of a reduction.
	 * @param poss     The positions of symbols on the left side of the reduction
	 *                 that this symbol is composed of.
	 */
	private DstSymb(Locatable location, Token name, Vector<DstPos> poss) {
		super(location);
		this.name = name;
		this.poss = new Nodes<DstPos>(null, poss);
	}

	/**
	 * Constructs a symbol on the right side of a reduction.
	 *
	 * @param name The name of a symbol on the right side of a reduction.
	 * @param poss The positions of symbols on the left side of the reduction that
	 *             this symbol is composed of.
	 */
	public DstSymb(Token name, Vector<DstPos> poss) {
		this(new Location(name, poss.size() == 0 ? name : poss.lastElement()), name, poss);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		DstSymb symb = this;
		return new DstSymb(new Location(beg, end), symb.name, symb.poss.nodes());
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public boolean check(Reduction red) {
		boolean test = true;
		for (int p = 0; p < poss.size(); p++)
			test = test && poss.get(p).check(red);
		return test;
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		buffer.append(name.lexeme);
		if (poss.size() > 0) {
			buffer.append("(");
			for (int p = 0; p < poss.size(); p++) {
				if (p > 0)
					buffer.append(",");
				buffer.append(poss.get(p).toString());
			}
			buffer.append(")");
		}
		return buffer.toString();
	}

}
