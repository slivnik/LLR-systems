package redgen.report;

/**
 * Implemented by classes describing parts of the source file.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public interface Locatable {

	/**
	 * Returns the location of a part of the source file.
	 *
	 * @return The location of a part of the source file.
	 */
	public Location location();

	/**
	 * Modifies the existing location.
	 *
	 * @param location The new location.
	 */
	public default void relocate(Location location) {
		throw new Report.InternalError();
	}

}
