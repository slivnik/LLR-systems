package redgen.redsys;

import redgen.report.*;

/**
 * A visitor of the reduction system.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 * @param <Result> The type of the result computed by the visitor.
 */
public interface Visitor<Result> {

	/**
	 * A visit method.
	 *
	 * @param redSys The object this visitor visits.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem redSys) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param symb The object this visitor visits.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem.Symbol symb) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param red The object this visitor visits.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem.Reduction red) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param symb The object this visitor visits.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem.Reduction.SrcSymbol symb) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param symb The object this visitor visits.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem.Reduction.LeftDstSymbol symb) {
		throw new Report.InternalError();
	}

	/**
	 * A visit method.
	 *
	 * @param symb The object this visitor visits.
	 * @return The visitor's return value.
	 */
	default public Result visit(RedSystem.Reduction.ConsDstSymbol symb) {
		throw new Report.InternalError();
	}

}
