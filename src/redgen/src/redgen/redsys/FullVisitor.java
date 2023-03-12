package redgen.redsys;

/**
 * The full visitor of the reduction system.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 * @param <Result> The type of the result computed by the visitor.
 */
public interface FullVisitor<Result> extends Visitor<Result> {

	@Override
	default public Result visit(RedSystem redSys) {
		Result result = null;
		for (RedSystem.Symbol symb : redSys.symbs())
			result = combine(result, symb.accept(this));
		for (RedSystem.Reduction red : redSys.reds())
			result = combine(result, red.accept(this));
		return result;
	}

	@Override
	default public Result visit(RedSystem.Symbol symb) {
		return combine(null, null);
	}

	@Override
	default public Result visit(RedSystem.Reduction red) {
		Result result = null;
		for (RedSystem.Reduction.SrcSymbol symb : red.srcSymbs())
			result = combine(result, symb.accept(this));
		for (RedSystem.Reduction.DstSymbol symb : red.dstSymbs())
			result = combine(result, symb.accept(this));
		return result;
	}

	@Override
	default public Result visit(RedSystem.Reduction.SrcSymbol symb) {
		return combine(null, null);
	}

	@Override
	default public Result visit(RedSystem.Reduction.LeftDstSymbol symb) {
		return combine(null, null);
	}

	@Override
	default public Result visit(RedSystem.Reduction.ConsDstSymbol symb) {
		return combine(null, null);
	}

	/**
	 * The operation used by this visitor to combine results from recursive calls.
	 *
	 * @param result1 The accumulated result during the traversal process (or
	 *                <code>null</code> if nonexistent).
	 * @param result2 To be accumulated result during the traversal process (or
	 *                <code>null</code> if nonexistent).
	 * @return The combined result.
	 */
	default public Result combine(Result result1, Result result2) {
		return null;
	}

}
