package redgen.input.ast;

/**
 * A visitor of the abstract syntax trees representing reduction systems that
 * traverses the entire abstract syntax tree.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 * @param <Result>    The type of the result computed by the visitor.
 * @param <Parameter> The type of the parameter carried around by the visitor.
 */
public interface FullVisitor<Result, Parameter> extends Visitor<Result, Parameter> {

	@Override
	default public <T extends Tree> Result visit(Nodes<T> nodes, Parameter par) {
		for (T n : nodes.nodes())
			n.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(RedSystem redSys, Parameter par) {
		redSys.reds.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(Reduction red, Parameter par) {
		red.srcs.accept(this, par);
		red.dsts.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(SrcSymb srcSymb, Parameter par) {
		return null;
	}

	@Override
	default public Result visit(SrcNeg srcNeg, Parameter par) {
		srcNeg.src.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(SrcConc srcConc, Parameter par) {
		for (Src n : srcConc.nodes())
			n.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(SrcDisj srcDisj, Parameter par) {
		for (Src n : srcDisj.nodes())
			n.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(DstSymb dstSymb, Parameter par) {
		dstSymb.poss.accept(this, par);
		return null;
	}

	@Override
	default public Result visit(DstPos dstPos, Parameter par) {
		if (dstPos.src != null)
			dstPos.src.accept(this, par);
		return null;
	}

}
