package redgen.input.ast;

import java.util.*;

import redgen.report.*;

/**
 * A reduction.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Reduction extends Node implements Tree {

	/** The sequential number of a reduction. */
	public final int id;

	/** Symbol expressions on the left side of a reduction. */
	public final Nodes<Src> srcs;

	/** Symbol epxressions on the right side of a reduction. */
	public final Nodes<Dst> dsts;

	/**
	 * Constructs a reduction.
	 *
	 * @param location The location of a reduction.
	 * @param id       The sequential number of a reduction
	 * @param srcs     Symbol expressions on the left side of a reduction.
	 * @param dsts     Symbol expressions on the right side of a reduction.
	 */
	private Reduction(Locatable location, int id, Vector<Src> srcs, Vector<Dst> dsts) {
		super(location);
		this.id = id;
		this.srcs = new Nodes<Src>(srcs);
		this.dsts = new Nodes<Dst>(dsts);
	}

	/**
	 * Constructs a reduction.
	 *
	 * @param id   The sequential number of a reduction
	 * @param srcs Symbol expressions on the left side of a reduction.
	 * @param dsts Symbol expressions on the right side of a reduction.
	 */
	public Reduction(int id, Vector<Src> srcs, Vector<Dst> dsts) {
		this(new Location(srcs.firstElement(), dsts.size() == 0 ? srcs.lastElement() : dsts.lastElement()), id, srcs,
				dsts);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		Reduction red = this;
		return new Reduction(new Location(beg, end), red.id, red.srcs.nodes(), red.dsts.nodes());
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		buffer.append("[");
		buffer.append(id);
		buffer.append("] ");
		for (int s = 0; s < srcs.size(); s++) {
			Src src = srcs.get(s);
			if ((src instanceof SrcConc) || (src instanceof SrcDisj))
				buffer.append("(");
			buffer.append(src.toString());
			if ((src instanceof SrcConc) || (src instanceof SrcDisj))
				buffer.append(")");
			buffer.append(" ");
		}
		buffer.append("-->");
		for (int d = 0; d < dsts.size(); d++) {
			buffer.append(" ");
			Dst dst = dsts.get(d);
			buffer.append(dst.toString());
		}
		return buffer.toString();
	}

}
