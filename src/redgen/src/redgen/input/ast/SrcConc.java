package redgen.input.ast;

import java.util.*;

import redgen.report.*;

/**
 * A concatenation of symbol expressions on the left side of a reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class SrcConc extends Nodes<Src> implements Src {

	/**
	 * Constructs a concatenation of symbol expressions on the left side of a
	 * reduction.
	 *
	 * @param location The location of symbol expressions on the left side of a
	 *                 reduction.
	 * @param srcs     Symbol expressions on the left side of a reduction.
	 */
	private SrcConc(Locatable location, Vector<Src> srcs) {
		super(location, srcs);
	}

	/**
	 * Constructs a concatenation of symbol expressions on the left side of a
	 * reduction.
	 *
	 * @param srcs Symbol expressions on the left side of a reduction.
	 */
	public SrcConc(Vector<Src> srcs) {
		this(new Location(srcs.firstElement(), srcs.lastElement()), srcs);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		SrcConc conc = this;
		return new SrcConc(new Location(beg, end), conc.nodes());
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public boolean equals(Object object) {
		if (object.getClass() != this.getClass())
			return false;
		SrcConc that = (SrcConc) object;
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
				buffer.append(" ");
			if (get(s) instanceof SrcDisj)
				buffer.append("(");
			buffer.append(get(s).toString());
			if (get(s) instanceof SrcDisj)
				buffer.append(")");
		}
		return buffer.toString();
	}

}
