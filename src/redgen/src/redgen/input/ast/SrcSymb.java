package redgen.input.ast;

import redgen.report.*;

import redgen.input.*;

/**
 * A symbol on the left side of a reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class SrcSymb extends Node implements Src {

	/** The name of a symbol on the left side of a reduction. */
	public final Token name;

	/**
	 * Constructs the name of a symbol on the left side of a reduction.
	 *
	 * @param location The location of the name of a symbol on the left side of a
	 *                 reduction.
	 * @param name     The name of a symbol on the left side of a reduction.
	 */
	private SrcSymb(Locatable location, Token name) {
		super(location);
		if (name.kind != Token.Kind.IDENTIFIER)
			throw new Report.InternalError();
		this.name = name;
	}

	/**
	 * Constructs the name of a symbol on the left side of a reduction.
	 *
	 * @param name The name of a symbol on the left side of a reduction.
	 */
	public SrcSymb(Token name) {
		this(name, name);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		SrcSymb symb = this;
		return new SrcSymb(new Location(beg, end), symb.name);
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public boolean equals(Object object) {
		if (object.getClass() != this.getClass())
			return false;
		SrcSymb that = (SrcSymb) object;
		return this.name.lexeme.equals(that.name.lexeme);
	}

	@Override
	public String toString() {
		return name.lexeme;
	}

}
