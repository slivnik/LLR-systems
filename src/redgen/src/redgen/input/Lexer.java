package redgen.input;

import java.io.*;

import redgen.report.*;

/**
 * Lexer for the lexical analysis of the source file.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Lexer implements Closeable {

	/** The name of the source file name. */
	private final String srcFileName;

	/** The reader used for reading the source file name. */
	private final BufferedReader reader;

	/** The buffered character not yet a part of any lexeme (or -1 if empty). */
	private int bufferedChar;

	/** The line of the buffered character. */
	private int bufferedCharLine;

	/** The column of the buffered character. */
	private int bufferedCharColumn;

	/**
	 * Constructs a new lexer.
	 *
	 * The source file is opened and the lexer is ready to be used. In case of any
	 * error a report is generated and {@link Report.Error} is thrown.
	 *
	 * @param srcFileName The name of the source file name.
	 */
	public Lexer(String srcFileName) {
		this.srcFileName = srcFileName;
		try {
			reader = new BufferedReader(new FileReader(this.srcFileName));
		} catch (FileNotFoundException ex) {
			throw new Report.Error("Cannot open file '" + this.srcFileName + "'.");
		}
		bufferedChar = -1;
		bufferedCharLine = 1;
		bufferedCharColumn = 0;
	}

	/**
	 * Closes the lexer.
	 *
	 * The source file is closed. In case of any error a report is generated and
	 * {@link Report.Error} is thrown.
	 */
	@Override
	public void close() {
		try {
			reader.close();
		} catch (IOException ex) {
			throw new Report.Error("Cannot close file '" + this.srcFileName + "'.");
		}
	}

	/**
	 * Returns the next token from the source file.
	 *
	 * @return The next token read from the source file.
	 */
	public Token nextToken() {

		enum State {
			INIT, COMMENT, IDENTIFIER, NUMBER, ARROW_1, ARROW_2, ARROW_3;
		}
		;
		State state = State.INIT;

		StringBuffer lexeme = new StringBuffer("");

		int begLine = -1, begColumn = -1, endLine = -1, endColumn = -1;

		while (true) {
			if (bufferedChar == -1) {
				try {
					bufferedChar = reader.read();
				} catch (IOException ex) {
					throw new Report.Error("IO error while reading file '" + srcFileName + "'.");
				}
				if (bufferedChar != -1)
					bufferedCharColumn += 1;
			}

			switch (state) {

			case INIT:
				// Check for the first character of an identifier.
				if (Character.isLetter(bufferedChar) || (bufferedChar == '_')) {
					state = State.IDENTIFIER;
					begLine = bufferedCharLine;
					begColumn = bufferedCharColumn;
					break;
				}
				// Check for the first character of a number.
				if (Character.isDigit(bufferedChar)) {
					state = State.NUMBER;
					begLine = bufferedCharLine;
					begColumn = bufferedCharColumn;
					break;
				}
				// All other possibilities.
				switch (bufferedChar) {
				// End of file.
				case -1:
					return new Token(Token.Kind.EOF, "", null);
				// Whitespace.
				case '\n':
					bufferedChar = -1;
					bufferedCharLine += 1;
					bufferedCharColumn = 0;
					break;
				case '\t':
				case ' ':
					bufferedChar = -1;
					break;
				// Comments.
				case '%':
				case '#':
					state = State.COMMENT;
					bufferedChar = -1;
					break;
				// Symbols.
				case ';':
					bufferedChar = -1;
					return new Token(Token.Kind.SEMIC, ";", new Location(bufferedCharLine, bufferedCharColumn));
				case ',':
					bufferedChar = -1;
					return new Token(Token.Kind.COMMA, ",", new Location(bufferedCharLine, bufferedCharColumn));
				case '|':
					bufferedChar = -1;
					return new Token(Token.Kind.DISJ, "|", new Location(bufferedCharLine, bufferedCharColumn));
				case '!':
					bufferedChar = -1;
					return new Token(Token.Kind.NOT, "!", new Location(bufferedCharLine, bufferedCharColumn));
				case '=':
					bufferedChar = -1;
					return new Token(Token.Kind.EQU, "=", new Location(bufferedCharLine, bufferedCharColumn));
				case '(':
					bufferedChar = -1;
					return new Token(Token.Kind.LPAR, "(", new Location(bufferedCharLine, bufferedCharColumn));
				case ')':
					bufferedChar = -1;
					return new Token(Token.Kind.RPAR, ")", new Location(bufferedCharLine, bufferedCharColumn));
				case '[':
					bufferedChar = -1;
					return new Token(Token.Kind.IDENTIFIER, "[", new Location(bufferedCharLine, bufferedCharColumn));
				case ']':
					bufferedChar = -1;
					return new Token(Token.Kind.IDENTIFIER, "]", new Location(bufferedCharLine, bufferedCharColumn));
				case '-':
					state = State.ARROW_1;
					begLine = bufferedCharLine;
					begColumn = bufferedCharColumn;
					break;
				// Unexpected characters.
				default:
					throw new Report.Error(new Location(bufferedCharLine, bufferedCharColumn),
							"Unexpected character '" + (char) bufferedChar + "'.");
				}
				break;

			case COMMENT:
				if ((bufferedChar == '\n') || (bufferedChar == -1))
					state = State.INIT;
				else
					bufferedChar = -1;
				break;

			case IDENTIFIER:
				// Check if this character is still a part of the identifier.
				if (Character.isLetter(bufferedChar) || Character.isDigit(bufferedChar) || (bufferedChar == '_')
						|| (bufferedChar == '\'')) {
					lexeme.append((char) bufferedChar);
					endLine = bufferedCharLine;
					endColumn = bufferedCharColumn;
					bufferedChar = -1;
				}
				// End of the identifier.
				else {
					state = State.INIT;
					return new Token(Token.Kind.IDENTIFIER, lexeme.toString(),
							new Location(begLine, begColumn, endLine, endColumn));
				}
				break;

			case NUMBER:
				// Check if this character is still a part of the number.
				if (Character.isDigit(bufferedChar)) {
					lexeme.append((char) bufferedChar);
					endLine = bufferedCharLine;
					endColumn = bufferedCharColumn;
					bufferedChar = -1;
				}
				// End of the number.
				else {
					state = State.INIT;
					return new Token(Token.Kind.NUMBER, lexeme.toString(),
							new Location(begLine, begColumn, endLine, endColumn));
				}
				break;

			case ARROW_1:
				if (bufferedChar == '-') {
					lexeme.append((char) bufferedChar);
					endLine = bufferedCharLine;
					endColumn = bufferedCharColumn;
					state = State.ARROW_2;
					bufferedChar = -1;
					break;
				} else
					throw new Report.Error(new Location(bufferedCharLine, bufferedCharColumn),
							"Unexpected character '" + (char) bufferedChar + "'.");
			case ARROW_2:
				if (bufferedChar == '-') {
					lexeme.append((char) bufferedChar);
					endLine = bufferedCharLine;
					endColumn = bufferedCharColumn;
					state = State.ARROW_3;
					bufferedChar = -1;
					break;
				} else
					throw new Report.Error(new Location(bufferedCharLine, bufferedCharColumn),
							"Unexpected character '" + (char) bufferedChar + "'.");
			case ARROW_3:
				if (bufferedChar == '>') {
					lexeme.append((char) bufferedChar);
					endLine = bufferedCharLine;
					endColumn = bufferedCharColumn;
					state = State.INIT;
					bufferedChar = -1;
					return new Token(Token.Kind.ARROW, lexeme.toString(),
							new Location(begLine, begColumn, endLine, endColumn));
				} else {
					throw new Report.Error(new Location(bufferedCharLine, bufferedCharColumn),
							"Unexpected character '" + (char) bufferedChar + "'.");
				}

			}
		}
	}

}
