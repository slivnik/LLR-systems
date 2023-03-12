package redgen.input.ast;

import java.util.*;

import redgen.report.*;

/**
 * A disjunction of symbol expressions on the left side of a reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class SrcDisj extends Nodes<Src> implements Src {

	/**
	 * Constructs a disjunction of symbol expressions on the left side of a
	 * reduction.
	 *
	 * @param location The location of symbol expressions on the left side of a
	 *                 reduction.
	 * @param srcs     Symbol expressions on the left side of a reduction.
	 */
	private SrcDisj(Locatable location, Vector<Src> srcs) {
		super(location, srcs);
	}

	/**
	 * Constructs a disjunction of symbol expressions on the left side of a
	 * reduction.
	 *
	 * @param srcs Symbol expressions on the left side of a reduction.
	 */
	public SrcDisj(Vector<Src> srcs) {
		this(new Location(srcs.firstElement(), srcs.lastElement()), srcs);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		SrcDisj disj = this;
		return new SrcDisj(new Location(beg, end), disj.nodes());
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public boolean equals(Object object) {
		if (object.getClass() != this.getClass())
			return false;
		SrcDisj that = (SrcDisj) object;
		boolean equ = this.size() == that.size();
		for (int s = 0; (s < this.size()) && equ; s++)
			equ = equ && (this.get(s).equals(that.get(s)));
		return equ;
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		for (int s = 0; s < size(); s++) {
			if (s > 0)
				buffer.append("|");
			buffer.append(get(s).toString());
		}
		return buffer.toString();
	}
}
