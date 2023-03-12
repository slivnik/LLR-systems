package redgen.input.ast;

import redgen.report.*;

/**
 * Checks the validity of positions on the right side of reduction comprising
 * the reduction system specification.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class CheckPositions implements Visitor<Boolean, Tree> {

	/** Does nothing. */
	public CheckPositions() {
	}

	@Override
	public <T extends Tree> Boolean visit(Nodes<T> nodes, Tree __) {
		boolean check = true;
		for (T n : nodes.nodes())
			check = check && n.accept(this, __);
		return check;
	}

	@Override
	public Boolean visit(RedSystem redSys, Tree __) {
		return redSys.reds.accept(this, __);
	}

	@Override
	public Boolean visit(Reduction red, Tree __) {
		return red.dsts.accept(this, red);
	}

	@Override
	public Boolean visit(DstSymb dstSymb, Tree __) {
		return dstSymb.poss.accept(this, __);
	}

	@Override
	public Boolean visit(DstPos dstPos, Tree __) {
		if (__ instanceof Reduction red) {
			if ((dstPos.index < 1) || (dstPos.index > red.srcs.size())) {
				Report.warning(dstPos.location, "Nonexistent position '" + dstPos.index + "'.");
				return false;
			}
			if ((dstPos.src != null) && (!(dstPos.src.equals(red.srcs.get(dstPos.index - 1))))) {
				System.out.println(dstPos.src);
				Report.warning(dstPos.location, "'" + dstPos.src + "' *does not match position " + dstPos.index + ".");
				return false;
			} else
				return true;
		} else
			throw new Report.InternalError();
	}

}
