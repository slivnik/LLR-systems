package redgen.input.ast;

import redgen.report.*;
import redgen.input.*;

/**
 * A position of a symbol on the left side of a reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class DstPos extends Node implements Dst {

	/**
	 * The index of the symbol on the left side of a reduction (starting with
	 * <code>1</code>).
	 */
	public final Token number;

	/**
	 * The value of the index of the symbol on the left side of a reduction
	 * (starting with <code>1</code>).
	 */
	public final int index;

	/** The symbol on the left side of a reduction (might be <code>null</code>). */
	public final Src src;

	/**
	 * Constructs a position of a symbol on the left side of a reduction.
	 *
	 * @param location The location of the position.
	 * @param number   The index of the symbol on the left side of a reduction
	 *                 (starting with <code>1</code>).
	 * @param src      The symbol on the left side of a reduction (might be
	 *                 <code>null</code>).
	 */
	private DstPos(Locatable location, Token number, Src src) {
		super(location);
		if (number.kind != Token.Kind.NUMBER)
			throw new Report.InternalError();
		this.number = number;
		try {
			this.index = Integer.parseInt(number.lexeme);
		} catch (NumberFormatException __) {
			throw new Report.InternalError();
		}
		this.src = src;
	}

	/**
	 * Constructs a position of a symbol on the left side of a reduction.
	 *
	 * @param number The index of the symbol on the left side of a reduction
	 *               (starting with <code>1</code>).
	 * @param src    The symbol on the left side of a reduction (might be
	 *               <code>null</code>).
	 */
	public DstPos(Token number, Src src) {
		this(new Location(number, src == null ? number : src), number, src);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		DstPos pos = this;
		return new DstPos(new Location(beg, end), pos.number, pos.src);
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public boolean check(Reduction red) {
		if ((index < 1) || (index > red.srcs.size())) {
			Report.warning(location, "Nonexistent position '" + index + "'.");
			return false;
		}
		if ((src != null) && (!(src.equals(red.srcs.get(index - 1))))) {
			Report.warning(location, "'" + src + "' does not match position " + index + ".");
			return false;
		} else
			return true;
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		buffer.append(Integer.toString(index));
		if (src != null) {
			buffer.append("=");
			buffer.append(src.toString());
		}
		return buffer.toString();
	}

}
