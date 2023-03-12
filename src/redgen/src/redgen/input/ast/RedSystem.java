package redgen.input.ast;

import java.util.*;

import redgen.report.*;

/**
 * An entire reduction system.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class RedSystem extends Node implements Tree {

	/** A set of reductions. */
	public final Nodes<Reduction> reds;

	/**
	 * Constructs a reduction system.
	 *
	 * @param location The location of a reduction system.
	 * @param reds     A set of reductions.
	 */
	private RedSystem(Location location, Vector<Reduction> reds) {
		super(location);
		this.reds = new Nodes<Reduction>(null, reds);
		if (!this.accept(new CheckPositions(), null))
			throw new Report.Error("Fix the reduction system specification.");
	}

	/**
	 * Constructs a reduction system.
	 *
	 * @param reds A set of reductions.
	 */
	public RedSystem(Vector<Reduction> reds) {
		this(new Location(reds.firstElement(), reds.lastElement()), reds);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		RedSystem redSys = this;
		return new RedSystem(new Location(beg, end), redSys.reds.nodes());
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		for (int r = 0; r < reds.size(); r++) {
			buffer.append("\t");
			buffer.append(reds.get(r).toString());
			if (r != reds.size() - 1)
				buffer.append("\n");
		}
		return buffer.toString();
	}

}
