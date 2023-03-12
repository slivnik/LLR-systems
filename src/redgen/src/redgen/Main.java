package redgen;

import java.util.*;

import redgen.report.*;
//import redgen.input.ast.*;
import redgen.redsys.*;
import redgen.parser.backjump.*;
import redgen.parser.dfa.*;

/**
 * The reduction system generator.
 *
 ** <br/>
 * The reduction system generator should be run as
 *
 * <pre>
 * <code>$ java redgen.Main </code><i>command-line-arguments...</i>
 * </pre>
 *
 * The following command line arguments are available:
 *
 * TODO
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Main {

	/**
	 * (Included to keep javadoc happy.)
	 */
	private Main() {
		throw new Report.InternalError();
	}

	// COMMAND LINE ARGUMENTS

	/** Values of command line arguments indexed by their command line switch. */
	private static HashMap<String, String> cmdLineArgs = new HashMap<String, String>();

	/**
	 * Returns the value of a command line argument.
	 *
	 * @param cmdLineArgName Command line argument name.
	 * @return Command line argument value.
	 */
	public static String cmdLineArgValue(String cmdLineArgName) {
		return cmdLineArgs.get(cmdLineArgName);
	}

	// THE REDUCTION SYSTEM GENERATOR'S STARTUP METHOD

	/**
	 * The reduction system generator.
	 *
	 * @param args Command line arguments (see {@link redgen.Main}).
	 */
	public static void main(String[] args) {
		try {
			Report.info("This is a reduction system generator, v0.1:");

			if (args.length != 2)
				throw new Report.Error("Illegal number of comand line arguments: (all|full|lim|dfa) *.rs");

			RedSystem redSys = null;
			{
				redgen.input.Parser inpParser = new redgen.input.Parser(args[1]);
				redgen.input.ast.RedSystem redSysAST = inpParser.parse();
				inpParser.close();
				redSys = new RedSystem(redSysAST);
				{ // if (args[1].matches(".*test.*")) {
					System.out.println();
					System.out.println("AST REDUCTION SYSTEM:");
					System.out.println(redSysAST + "\n");
					System.out.println("REDUCTION SYSTEM:");
					System.out.println(redSys + "\n");
				}
			}

			if ((args[0].equals("full")) || (args[0].equals("all"))) {
				FullBackjumpParser parser = new FullBackjumpParser(redSys);
				parser.generateC(args[1].replaceAll("\\.[^.]*$", ""));
				if (args[1].matches(".*test.*")) {
					String textInput = "[aabbcc]";
					Vector<String> input = new Vector<String>();
					for (int i = 0; i < textInput.length(); i++) {
						input.add("" + textInput.charAt(i));
					}
					System.out.println("***** FULL BACKJUMP PARSER *****\n");
					parser.parse(input);
				}
			}
			if ((args[0].equals("lim")) || (args[0].equals("all"))) {
				LimitedBackjumpParser parser = new LimitedBackjumpParser(redSys);
				parser.generateC(args[1].replaceAll("\\.[^.]*$", ""));
				if (args[1].matches(".*test.*")) {
					String textInput = "[aabbcc]";
					Vector<String> input = new Vector<String>();
					for (int i = 0; i < textInput.length(); i++) {
						input.add("" + textInput.charAt(i));
					}
					System.out.println("***** LIMITED BACKJUMP PARSER *****\n");
					parser.parse(input);
				}
			}
			if ((args[0].equals("dfa")) || (args[0].equals("all"))) {
				DFAParser parser = new DFAParser(redSys);
				parser.generateC(args[1].replaceAll("\\.[^.]*$", ""));
				if (args[1].matches(".*test.*")) {
					String textInput = "[aabbccdd]";
					Vector<String> input = new Vector<String>();
					for (int i = 0; i < textInput.length(); i++) {
						input.add("" + textInput.charAt(i));
					}
					System.out.println("***** DFA PARSER *****\n");
					parser.parse(input);
				}
			}
			Report.info("Done.");
		} catch (Report.Error __) {
			System.exit(1);
		}
	}

}
