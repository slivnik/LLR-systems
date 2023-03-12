package redgen.input.ast;

import redgen.report.*;

/**
 * A kind that all AST classes belong to.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public interface Tree extends Locatable {

	/**
	 * Creates a clone of this node but with a new location.
	 *
	 * @param beg The location of the beginning.
	 * @param end The location of the end.
	 * @return The relocCloned node.
	 */
	public abstract Node clone(Locatable beg, Locatable end);

	/**
	 * The acceptor.
	 *
	 * @param <Result>    The type of the result.
	 * @param <Parameter> The type of the parameter.
	 * @param visitor     The visitor to be accepted.
	 * @param parameter   The value of the parameter.
	 * @return The value computed by the visitor.
	 */
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter);

}
