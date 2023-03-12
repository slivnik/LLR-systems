package redgen.input;

import java.io.*;
import java.util.*;

import redgen.report.*;
import redgen.input.ast.*;

/**
 * Parser for the syntax analysis of the source file.
 *
 * <br/>
 * The context-free grammar describing valid specifications of reduction systems
 * contains the following productions:
 *
 * <pre>
 * <code>
 * redsystem --> reductions
 *
 * reductions -> reduction reductions'
 * reductions' ->
 * reductions' -> reduction reductions'
 *
 * reduction -> srcs ARROW dsts SEMIC
 *
 * srcs -> srcNeg srcs'
 * srcs' ->
 * srcs' -> srcNeg srcs'
 *
 * srcDisj -> srcConc srcDisj'
 * srcDisj' ->
 * srcDisj' -> DISJ srcConc srcDisj'
 *
 * srcConc -> srcNeg srcConc'
 * srcConc' ->
 * srcConc' -> srcNeg srcConc'
 *
 * srcNeg -> srcAtom
 * srcNeg -> NOT srcNeg
 *
 * srcAtom -> IDENTIFIER
 * srcAtom -> LPAR srcDisj RPAR
 *
 * dsts ->
 * dsts -> dst dsts
 *
 * dst -> pos
 * dst -> IDENTIFIER dst'
 * dst' ->
 * dst' -> LPAR poss RPAR
 *
 * poss -> pos poss'
 * poss' ->
 * poss' -> COMMA pos poss'
 *
 * pos -> NUMBER pos'
 * pos' ->
 * pos' -> EQU srcAtom
 * </code>
 * </pre>
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class Parser implements Closeable {

	/** The underlying lexer. */
	private final Lexer lexer;

	/**
	 * Constructs a new parser by preparing the underlying lexer.
	 *
	 * @param srcFileName The name of the source file name.
	 */
	public Parser(String srcFileName) {
		lexer = new Lexer(srcFileName);
	}

	/**
	 * Closes the parser (and the underlying lexer).
	 */
	@Override
	public void close() {
		lexer.close();
	}

	/** The lookahead buffer (<code>null</code> if empty). */
	private Token token = null;

	/**
	 * Ensures the lookahead buffer contains a valid token and return is while
	 * keeping it in the buffer.
	 *
	 * @return The token currently in the lookahead buffer.
	 */
	private Token ensureToken() {
		if (token == null)
			token = lexer.nextToken();
		return token;
	}

	/**
	 * Parses the source file containing a specification of a reduction system.
	 *
	 * @return The reduction system.
	 */
	public RedSystem parse() {
		Vector<Reduction> reds = parseReductions();
		if (reds == null)
			throw new Report.Error("No reductions found.");
		if (ensureToken().kind != Token.Kind.EOF)
			throw new Report.Error(token, "Unexpected symbol '" + token.lexeme + "' found at the end of file.");
		return new RedSystem(reds);
	}

	/**
	 * Parses a non-empty list of reductions.
	 *
	 * @return The list of reductions (or <code>null</code> if none found).
	 */
	private Vector<Reduction> parseReductions() {
		Vector<Reduction> reds = new Vector<Reduction>();
		Reduction red = parseReduction(reds.size());
		if (red == null)
			return null;
		reds.add(red);
		reds = parseReductions_(reds);
		return reds;
	}

	/**
	 * Parses a possibly empty list of reductions.
	 *
	 * @param reds The reductions parsed so far.
	 * @return The list of reductions.
	 */
	private Vector<Reduction> parseReductions_(Vector<Reduction> reds) {
		Reduction red = parseReduction(reds.size());
		if (red == null)
			return reds;
		reds.add(red);
		reds = parseReductions_(reds);
		return reds;
	}

	/**
	 * Parses a single reduction.
	 *
	 * @param id The number of the new reduction.
	 * @return The reduction (or <code>null</code> if it is not found).
	 */
	private Reduction parseReduction(int id) {
		Vector<Src> srcs = parseSrcs();
		if (srcs == null)
			return null;
		if (ensureToken().kind != Token.Kind.ARROW)
			throw new Report.Error(token, "'" + token.lexeme + "' found in a reduction instead of '-->'.");
		token = null;
		Vector<Dst> dsts = parseDsts(new Vector<Dst>());
		if (ensureToken().kind != Token.Kind.SEMIC)
			throw new Report.Error(token, "'" + token.lexeme + "' found at the end of a reduction instead of ';'.");
		Token semic = token;
		token = null;
		Reduction red = new Reduction(id, srcs, dsts);
		return (Reduction) (red.clone(red, semic));
	}

	/**
	 * Parses a non-empty list of symbol expressions on the left side of a
	 * reduction.
	 *
	 * @return The list of symbol expressions (or <code>null</code> if none found).
	 */
	private Vector<Src> parseSrcs() {
		Vector<Src> srcs = new Vector<Src>();
		Src src = parseSrcNeg();
		if (src == null)
			return null;
		srcs.add(src);
		srcs = parseSrcs_(srcs);
		return srcs;
	}

	/**
	 * Parses a possibly empty list of symbol expressions on the left side of a
	 * reduction.
	 *
	 * @param srcs The symbol expressions parsed so far.
	 * @return The list of symbol expressions.
	 */
	private Vector<Src> parseSrcs_(Vector<Src> srcs) {
		Src src = parseSrcNeg();
		if (src == null)
			return srcs;
		else {
			srcs.add(src);
			srcs = parseSrcs_(srcs);
			return srcs;
		}
	}

	/**
	 * Parses a disjunctive symbol expression.
	 *
	 * @return The disjunctive symbol expression (or <code>null</code> if it is not
	 *         found).
	 */
	private Src parseSrcDisj() {
		Vector<Src> disj = new Vector<Src>();
		Src conc = parseSrcConc();
		if (conc == null)
			return null;
		disj.add(conc);
		disj = parseSrcDisj_(disj);
		return disj.size() == 1 ? disj.get(0) : new SrcDisj(disj);
	}

	/**
	 * Parses the rest of a disjunctive symbol expression.
	 *
	 * @param disj The part of the disjunctive symbol expression parsed so far.
	 * @return The complete disjunctive symbol expression.
	 */
	private Vector<Src> parseSrcDisj_(Vector<Src> disj) {
		switch (ensureToken().kind) {
		case DISJ: {
			token = null;
			Src conc = parseSrcConc();
			if (conc == null)
				throw new Report.Error(token,
						"'" + token.lexeme + "'" + " found instead of a symbol expression after '|'.");
			disj.add(conc);
			disj = parseSrcDisj_(disj);
			return disj;
		}
		default: {
			return disj;
		}
		}
	}

	/**
	 * Parses a concatenative symbol expression.
	 *
	 * @return The concatenative symbol expression (or <code>null</code> if it is
	 *         not found).
	 */
	private Src parseSrcConc() {
		Vector<Src> conc = new Vector<Src>();
		Src src = parseSrcNeg();
		if (src == null)
			return null;
		conc.add(src);
		conc = parseSrcConc_(conc);
		return conc.size() == 1 ? conc.get(0) : new SrcConc(conc);
	}

	/**
	 * Parses the rest of a concatenative symbol expression.
	 *
	 * @param conc The part of the concatenative symbol expression parsed so far.
	 * @return The complete concatenative symbol expression.
	 */
	private Vector<Src> parseSrcConc_(Vector<Src> conc) {
		Src src = parseSrcNeg();
		if (src == null)
			return conc;
		else {
			conc.add(src);
			conc = parseSrcConc_(conc);
			return conc;
		}
	}

	/**
	 * Parses a negated symbol expression.
	 *
	 * @return The negated symbol expression (or <code>null</code> if it is not
	 *         found).
	 */
	private Src parseSrcNeg() {
		switch (ensureToken().kind) {
		case NOT: {
			Token not = token;
			token = null;
			Src src = parseSrcNeg();
			if (src == null)
				throw new Report.Error(token, "'" + token.lexeme + "'" + " found instead of a symbol expression.");
			SrcNeg neg = new SrcNeg(src);
			return (Src) (neg.clone(not, src));
		}
		default: {
			Src src = parseSrcAtom();
			if (src == null)
				return null;
			return src;
		}
		}
	}

	/**
	 * Parses a single indivisible symbol expression.
	 *
	 * @return The indivisible symbol expression (or <code>null</code> if it is not
	 *         found).
	 */
	private Src parseSrcAtom() {
		switch (ensureToken().kind) {
		case IDENTIFIER: {
			SrcSymb symb = new SrcSymb(token);
			token = null;
			return symb;
		}
		case LPAR: {
			Token lpar = token;
			token = null;
			Src disj = parseSrcDisj();
			if (disj == null)
				throw new Report.Error(token, "'" + token.lexeme + "'" + " found instead of a symbol expression.");
			if (ensureToken().kind != Token.Kind.RPAR)
				throw new Report.Error(token,
						"'" + token.lexeme + "'" + " found instead of ')' in a symbol expression.");
			Token rpar = token;
			token = null;
			return (Src) (disj.clone(lpar, rpar));
		}
		default: {
			return null;
		}
		}
	}

	/**
	 * Parses a possibly empty list of symbol expressions on the right side of a
	 * reduction.
	 *
	 * @param dsts The symbol expressions parsed so far.
	 * @return The list of symbol expressions.
	 */
	private Vector<Dst> parseDsts(Vector<Dst> dsts) {
		Dst dst = parseDst();
		if (dst == null)
			return dsts;
		else {
			dsts.add(dst);
			dsts = parseDsts(dsts);
			return dsts;
		}
	}

	/**
	 * Parses a symbol expression on the right side of a reduction.
	 *
	 * @return The symbol expression (or <code>null</code> if it is not found).
	 */
	private Dst parseDst() {
		switch (ensureToken().kind) {
		case IDENTIFIER: {
			Token identifier = token;
			token = null;
			Dst dst = parseDst_(identifier);
			return dst;
		}
		default: {
			DstPos pos = parsePos();
			if (pos == null)
				return null;
			return pos;
		}
		}
	}

	/**
	 * Parses the positions of the symbols found on the left side of a reduction and
	 * associated with a given symbol on the right side of a reduction.
	 *
	 * @param identifier The name of the symbol.
	 * @return The symbol expression.
	 */
	private Dst parseDst_(Token identifier) {
		switch (ensureToken().kind) {
		case LPAR: {
			token = null;
			Vector<DstPos> poss = parsePoss();
			if (poss == null)
				throw new Report.Error(token,
						"'" + token.lexeme + "'" + "found instead of a sequence of positions after '('.");
			if (ensureToken().kind != Token.Kind.RPAR)
				throw new Report.Error(token,
						"'" + token.lexeme + "'" + "found instead of ')' after a sequence of positions.");
			Token rpar = token;
			token = null;
			DstSymb symb = new DstSymb(identifier, poss);
			return (DstSymb) (symb.clone(identifier, rpar));
		}
		default: {
			return new DstSymb(identifier, new Vector<DstPos>());
		}
		}
	}

	/**
	 * Parses a non-empty list of positions of the symbols found on the left side of
	 * a reduction.
	 *
	 * @return The list of positions (or <code>null</code> if none found).
	 */
	private Vector<DstPos> parsePoss() {
		Vector<DstPos> poss = new Vector<DstPos>();
		DstPos pos = parsePos();
		if (pos == null)
			return null;
		poss.add(pos);
		poss = parsePoss_(poss);
		return poss;
	}

	/**
	 * Parses a possibly empty list of positions of the symbols found on the left
	 * side of a reduction.
	 *
	 * @param poss The positions parsed so far.
	 * @return The list of positions.
	 */
	private Vector<DstPos> parsePoss_(Vector<DstPos> poss) {
		switch (ensureToken().kind) {
		case COMMA: {
			token = null;
			DstPos pos = parsePos();
			if (pos == null)
				throw new Report.Error(token, "'" + token.lexeme + "'" + "found instead of a position after ','.");
			poss.add(pos);
			poss = parsePoss_(poss);
			return poss;
		}
		default: {
			return poss;
		}
		}
	}

	/**
	 * Parses a single position of a symbol found on the left side of a reduction.
	 *
	 * @return The position (or <code>null</code> if it is not found).
	 */
	private DstPos parsePos() {
		switch (ensureToken().kind) {
		case NUMBER:
			Token index = token;
			token = null;
			DstPos pos = parsePos_(index);
			return pos;
		default:
			return null;
		}
	}

	/**
	 * Parses the symbol expression of a single position of a symbol found on the
	 * left side of a reduction, if present.
	 *
	 * @param index The index of a symbol expression on the left side of a
	 *              reduction.
	 * @return The position.
	 */
	private DstPos parsePos_(Token index) {
		switch (ensureToken().kind) {
		case EQU:
			token = null;
			Src src = parseSrcAtom();
			if (src == null)
				throw new Report.Error(token,
						"'" + token.lexeme + "'" + "found instead of symbol expression after '='.");
			return new DstPos(index, src);
		default:
			return new DstPos(index, null);
		}
	}

}
