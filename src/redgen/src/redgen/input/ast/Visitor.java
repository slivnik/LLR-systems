package redgen.input.ast;

import redgen.report.*;

/**
 * A visitor of the abstract syntax trees representing reduction systems.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 * @param <Result>    The type of the result computed by the visitor.
 * @param <Parameter> The type of the parameter carried around by the visitor.
 */
public interface Visitor<Result, Parameter> {

	/**
	 * A visit method.
	 *
	 * @param <T>   The type parameter of the class of object this visitor visits.
	 * @param nodes The object this visitor visits.
	 * @param par   The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public <T extends Tree> Result visit(Nodes<T> nodes, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param redSys The object this visitor visits.
	 * @param par    The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem redSys, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param red The object this visitor visits.
	 * @param par The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(Reduction red, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param srcSymb The object this visitor visits.
	 * @param par     The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(SrcSymb srcSymb, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param srcNeg The object this visitor visits.
	 * @param par    The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(SrcNeg srcNeg, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param srcConc The object this visitor visits.
	 * @param par     The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(SrcConc srcConc, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param srcDisj The object this visitor visits.
	 * @param par     The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(SrcDisj srcDisj, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param dstSymb The object this visitor visits.
	 * @param par     The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(DstSymb dstSymb, Parameter par) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param dstPos The object this visitor visits.
	 * @param par    The visitor's extra parameter.
	 * @return The visitor's return value.
	 */
	default public Result visit(DstPos dstPos, Parameter par) {
		throw new Report.InternalError();
	}

}
