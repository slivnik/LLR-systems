package redgen.input.ast;

import java.util.*;

import redgen.report.*;

/**
 * A node containing a sequence of subtrees.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 * @param <T> The kind of AST classes that can represent subtrees.
 */
public class Nodes<T extends Tree> extends Node {

	/** A sequence of subtrees. */
	private final Vector<T> nodes;

	/**
	 * Constructs a node containing a sequence of subtrees.
	 *
	 * @param location The location of all subtrees.
	 * @param nodes    The subtrees.
	 */
	protected Nodes(Locatable location, Vector<T> nodes) {
		super(location);
		this.nodes = new Vector<T>(nodes);
	}

	/**
	 * Constructs a node containing a sequence of subtrees.
	 *
	 * @param nodes The subtrees.
	 */
	public Nodes(Vector<T> nodes) {
		this(nodes.size() == 0 ? new Location(0, 0) : new Location(nodes.firstElement(), nodes.lastElement()), nodes);
	}

	@Override
	public Node clone(Locatable beg, Locatable end) {
		Nodes<T> nodes = this;
		return new Nodes<T>(new Location(beg, end), nodes.nodes);
	}

	@Override
	public <Result, Parameter> Result accept(Visitor<Result, Parameter> visitor, Parameter parameter) {
		return visitor.visit(this, parameter);
	}

	/**
	 * Returns the vector of all subtrees.
	 *
	 * @return The vector of all subtrees.
	 */
	public Vector<T> nodes() {
		return new Vector<T>(nodes);
	}

	/**
	 * Returns the subtree specified by an index.
	 *
	 * @param index The index of a subtree to be returned.
	 * @return The subtree returned.
	 */
	public T get(int index) {
		return nodes.get(index);
	}

	/**
	 * Returns the number of subtrees.
	 *
	 * @return The number of subtrees.
	 */
	public int size() {
		return nodes.size();
	}

}
