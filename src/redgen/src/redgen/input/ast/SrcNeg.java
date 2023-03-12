package redgen.input.ast;

import redgen.report.*;

/**
 * A negated symbol expression on the left side of a reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class SrcNeg extends Node implements Src {

	/** A symbol expression on the left side of a reduction that is negated. */
	public final Src src;

	/**
	 * Constructs the negated symbol expression on the left side of a reduction.
	 *
	 * @param location The location of the negated symbol expression.
	 * @param src      The symbol expression on the left side of a reduction that is
	 *                 negated.
	 */
	private SrcNeg(Locatable location, Src src) {
		super(location);
		this.src = src;
	}

	/**
	 * Constructs the negated symbol expression on the left side of a reduction.
	 *
	 * @param src The symbol expression on the left side of a reduction that is
	 *            negated.
	 */
	public SrcNeg(Src src) {
		this(src, src);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		SrcNeg neg = this;
		return new SrcNeg(new Location(beg, end), neg.src);
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public boolean equals(Object object) {
		if (object.getClass() != this.getClass())
			return false;
		SrcNeg that = (SrcNeg) object;
		return this.src.equals(that.src);
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		buffer.append("!");
		if ((src instanceof SrcConc) || (src instanceof SrcDisj))
			buffer.append("(");
		buffer.append(src.toString());
		if ((src instanceof SrcConc) || (src instanceof SrcDisj))
			buffer.append(")");
		return buffer.toString();
	}

}
