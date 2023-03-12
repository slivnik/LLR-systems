package redgen.report;

/**
 * Description of a location within a source file.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Location implements Locatable {

	/**
	 * The line number of the first character of the specified part of the source
	 * file.
	 */
	private final int begLine;

	/**
	 * The column number of the first character of the specified part of the source
	 * file.
	 */
	private final int begColumn;

	/**
	 * The line number of the last character of the specified part of the source
	 * file.
	 */
	private final int endLine;

	/**
	 * The column number of the last character of the specified part of the source
	 * file.
	 */
	private final int endColumn;

	/**
	 * Constructs a new location if the position of the first and the last
	 * characters are given.
	 *
	 * @param begLine   The line number of the first character of the specified part
	 *                  of the source file.
	 * @param begColumn The column number of the first character of the specified
	 *                  part of the source file.
	 * @param endLine   The line number of the last character of the specified part
	 *                  of the source file.
	 * @param endColumn The column number of the last character of the specified
	 *                  part of the source file.
	 */
	public Location(int begLine, int begColumn, int endLine, int endColumn) {
		this.begLine = begLine != 0 ? begLine : endLine;
		this.begColumn = begColumn != 0 ? begColumn : endColumn;
		this.endLine = endLine != 0 ? endLine : begLine;
		this.endColumn = endColumn != 0 ? endColumn : begColumn;
	}

	/**
	 * Constructs a new location if the position of a single character is given.
	 *
	 * @param line   The line number of the character of the specified part of the
	 *               source file.
	 * @param column The column number of the character of the specified part of the
	 *               source file.
	 */
	public Location(int line, int column) {
		this(line, column, line, column);
	}

	/**
	 * Constructs a new location given an object relating to a part of a source
	 * file.
	 *
	 * @param that An object relating to a part of a source file.
	 */
	public Location(Locatable that) {
		this(//
				that == null ? 0 : that.location().begLine, that == null ? 0 : that.location().begColumn,
				that == null ? 0 : that.location().endLine, that == null ? 0 : that.location().endColumn);
	}

	/**
	 * Constructs a new location given two objects relating to parts of a source
	 * file.
	 *
	 * @param beg An object relating to the beginning of part of a source file.
	 * @param end An object relating to the end of part of a source file.
	 */
	public Location(Locatable beg, Locatable end) {
		this(//
				beg == null ? 0 : beg.location().begLine, beg == null ? 0 : beg.location().begColumn,
				end == null ? 0 : end.location().endLine, end == null ? 0 : end.location().endColumn);
	}

	@Override
	public Location location() {
		return this;
	}

	@Override
	public String toString() {
		return "[" + begLine + ":" + begColumn + "-" + endLine + ":" + endColumn + "]";
	}

}
