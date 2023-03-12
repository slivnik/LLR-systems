package redgen.input.ast;

import redgen.report.*;

/**
 * The root of the AST hierarchy.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public abstract class Node implements Tree {

	/** The location of the sentential form represented by this tree. */
	public final Location location;

	/**
	 * Constructs a new tree.
	 *
	 * @param location The location of the sentential form represented by this tree.
	 */
	public Node(Locatable location) {
		this.location = location == null ? null : location.location();
	}

	@Override
	public Location location() {
		return location;
	}

}
