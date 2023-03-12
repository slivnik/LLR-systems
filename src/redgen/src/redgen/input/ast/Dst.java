package redgen.input.ast;

/**
 * A kind that all AST classes describing symbol expression onthe right side of
 * a reduction belong to.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public interface Dst extends Tree {

	/**
	 * Checks whether positions refer to valid symbol expressions on the left side
	 * of a reduction.
	 *
	 * @param red The reduction.
	 * @return Indication whether positions refer to valid symbol expressions on the
	 *         left side of a reduction.
	 */
	public boolean check(Reduction red);

}
