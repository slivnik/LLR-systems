package redgen.input;

import redgen.report.*;

/**
 * Token.
 * 
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Token implements Locatable {

	/** Token kinds. */
	public static enum Kind {
		/** End-of-file. */
		EOF,
		/** Identifier. */
		IDENTIFIER,
		/** Decimal nonnegative number. */
		NUMBER,
		/** Semicolon. */
		SEMIC,
		/** Comma: '<code>,</code>'. */
		COMMA,
		/** Disjunction: '<code>|</code>'. */
		DISJ,
		/** Negation: '<code>!</code>'. */
		NOT,
		/** Equality: '<code>=</code>'. */
		EQU,
		/** The left parenthesis: '<code>(</code>'. */
		LPAR,
		/** The right parenthesis: '<code>)</code>'. */
		RPAR,
		/** Arrow: '<code>--></code>'. */
		ARROW
	};

	/** The kind of this token. */
	public final Kind kind;

	/** The character representation of this token. */
	public final String lexeme;

	/** The location of this token. */
	public final Location location;

	/**
	 * Constructs a new token.
	 * 
	 * @param kind     The kind of this token.
	 * @param lexeme   The character representation of this token.
	 * @param location The location of this token.
	 */
	public Token(Kind kind, String lexeme, Location location) {
		this.kind = kind;
		this.lexeme = lexeme;
		this.location = location;
	}

	@Override
	public String toString() {
		if (kind == Kind.EOF)
			return "(" + kind + ")";
		return "(" + kind + ",'" + lexeme + "'," + location + ")";
	}

	@Override
	public Location location() {
		return location;
	}

}
