package redgen.report;

/**
 * Generating reports.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Report {

	/**
	 * (Unused but included to keep javadoc happy.)
	 */
	private Report() {
		throw new Report.InternalError();
	}

	/** Counter of information messages printed out. */
	private static int numOfInfos = 0;

	/**
	 * Returns the number of information messages printed out.
	 *
	 * @return The number of information messages printed out.
	 */
	public static int numOfInfos() {
		return numOfInfos;
	}

	/**
	 * Prints out an information message.
	 *
	 * @param message The information message to be printed.
	 */
	public static void info(String message) {
		numOfInfos++;
		System.out.print(":-) ");
		System.out.println(message);
	}

	/**
	 * Prints out an information message relating to the specified part of the
	 * source file.
	 *
	 * @param location Location the information message is related to.
	 * @param message  The information message to be printed.
	 */
	public static void info(Locatable location, String message) {
		numOfInfos++;
		System.out.print(":-) ");
		if (location.location() != null)
			System.out.print(location.location() + " ");
		System.out.println(message);
	}

	/** Counter of warnings printed out. */
	private static int numOfWarnings = 0;

	/**
	 * Returns the number of warnings printed out.
	 *
	 * @return The number of warnings printed out.
	 */
	public static int numOfWarnings() {
		return numOfWarnings;
	}

	/**
	 * Prints out a warning.
	 *
	 * @param message The warning message.
	 */
	public static void warning(String message) {
		numOfWarnings++;
		System.err.print(":-o ");
		System.err.println(message);
	}

	/**
	 * Prints out a warning relating to the specified part of the source file.
	 *
	 * @param location Location the warning message is related to.
	 * @param message  The warning message to be printed.
	 */
	public static void warning(Locatable location, String message) {
		numOfWarnings++;
		System.err.print(":-o ");
		if (location.location() != null)
			System.err.print(location.location() + " ");
		System.err.println(message);
	}

	/**
	 * An error.
	 *
	 * Thrown whenever the program reaches a situation where any further computing
	 * makes no sense any more because of the erroneous input.
	 */
	@SuppressWarnings("serial")
	public static class Error extends java.lang.Error {

		/**
		 * Constructs a new error.
		 *
		 * @param message The error message.
		 */
		public Error(String message) {
			super(message);
			System.err.print(":-( ");
			System.err.println(message);
			this.printStackTrace();
		}

		/**
		 * Constructs a new error relating to the specified part of the source file.
		 *
		 * @param location Location the error message is related to.
		 * @param message  The error message.
		 */
		public Error(Locatable location, String message) {
			System.err.print(":-( ");
			if (location.location() != null)
				System.err.print(location.location() + " ");
			System.err.println(message);
			this.printStackTrace();
		}

	}

	/**
	 * An internal error.
	 *
	 * Thrown whenever the program encounters internal error.
	 */
	@SuppressWarnings("serial")
	public static class InternalError extends Error {

		/**
		 * Constructs a new internal error.
		 */
		public InternalError() {
			super("Internal error.");
			this.printStackTrace();
		}

	}

}
