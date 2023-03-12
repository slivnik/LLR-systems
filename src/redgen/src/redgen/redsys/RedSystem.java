package redgen.redsys;

import java.util.*;

import redgen.report.*;

/**
 * A reduction system.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class RedSystem {

	/** All symbols. */
	private final HashMap<String, Symbol> symbs;

	/** All productions. */
	private final Vector<Reduction> reds;

	/**
	 * Constructs a new reduction system based on the original reduction system read
	 * from the input file.
	 *
	 * @param astRedSys The AST representing the original reduction system read from
	 *                  the input file.
	 */
	public RedSystem(redgen.input.ast.RedSystem astRedSys) {

		// Create all symbols.
		redgen.input.ast.FullVisitor<Object, Object> enumAllSymbs = new redgen.input.ast.FullVisitor<Object, Object>() {
			// This visitor traverses the original reduction system, identifies all its
			// symbols and creates their counterparts in this reduction system.

			@Override
			public Object visit(redgen.input.ast.SrcSymb astSrcSymb, Object __) {
				if (symbs.get(astSrcSymb.name.lexeme) == null)
					new Symbol(astSrcSymb.name.lexeme);
				return null;
			}

			@Override
			public Object visit(redgen.input.ast.DstSymb astDstSymb, Object __) {
				if (symbs.get(astDstSymb.name.lexeme) == null)
					new Symbol(astDstSymb.name.lexeme);
				return null;
			}

		};
		symbs = new HashMap<String, Symbol>();
		new Symbol("[");
		new Symbol("]");
		astRedSys.accept(enumAllSymbs, null);

		// Create all reductions.
		redgen.input.ast.FullVisitor<Set<Vector<String>>, Object> enumAllSforms = new redgen.input.ast.FullVisitor<Set<Vector<String>>, Object>() {
			// This visitor traverses a symbol expression on the left side of the original
			// reduction and produces a set of all sentential forms derived from it.

			@Override
			public Set<Vector<String>> visit(redgen.input.ast.SrcSymb astSrcSymb, Object __) {
				Set<Vector<String>> sforms = new HashSet<Vector<String>>();
				Vector<String> sform = new Vector<String>();
				sform.add(astSrcSymb.name.lexeme);
				sforms.add(sform);
				return sforms;
			}

			@Override
			public Set<Vector<String>> visit(redgen.input.ast.SrcNeg astSrcNeg, Object __) {
				if (astSrcNeg.src == null)
					throw new Report.InternalError();
				if (astSrcNeg.src instanceof redgen.input.ast.SrcSymb astInnerSrcSymb) {
					Set<Vector<String>> sforms = new HashSet<Vector<String>>();
					for (String symb : symbs.keySet()) {
						if (/* symb.equals("[") || symb.equals("]") || */ symb.equals(astInnerSrcSymb.name.lexeme))
							continue;
						Vector<String> sform = new Vector<String>();
						sform.add(symb);
						sforms.add(sform);
					}
					return sforms;
				}
				if (astSrcNeg.src instanceof redgen.input.ast.SrcNeg astInnerSrcNeg) {
					return astInnerSrcNeg.src.accept(this, null);
				}
				if (astSrcNeg.src instanceof redgen.input.ast.SrcConc astInnerSrcConc) {
					Set<Vector<String>> sforms = new HashSet<Vector<String>>();
					sforms.add(new Vector<String>());
					for (redgen.input.ast.Src src : astInnerSrcConc.nodes()) {
						Set<Vector<String>> extSforms = new HashSet<Vector<String>>();
						for (Vector<String> ext : (new redgen.input.ast.SrcNeg(src)).accept(this, null)) {
							for (Vector<String> sform : sforms) {
								Vector<String> extSform = new Vector<String>();
								extSform.addAll(sform);
								extSform.addAll(ext);
								extSforms.add(extSform);
							}
						}
						sforms = extSforms;
					}
					return sforms;
				}
				if (astSrcNeg.src instanceof redgen.input.ast.SrcDisj astInnerSrcDisj) {
					Set<Vector<String>> sforms = null;
					boolean fst = true;
					for (redgen.input.ast.Src src : astInnerSrcDisj.nodes()) {
						if (fst) {
							sforms = (new redgen.input.ast.SrcNeg(src)).accept(this, null);
							fst = false;
						} else {
							sforms.retainAll((new redgen.input.ast.SrcNeg(src)).accept(this, null));
						}
					}
					return sforms;
				}
				return null;
			}

			@Override
			public Set<Vector<String>> visit(redgen.input.ast.SrcConc astSrcConc, Object __) {
				if (astSrcConc.size() == 0)
					throw new Report.InternalError();
				Set<Vector<String>> sforms = new HashSet<Vector<String>>();
				sforms.add(new Vector<String>());
				for (redgen.input.ast.Src astSrc : astSrcConc.nodes()) {
					Set<Vector<String>> extSforms = new HashSet<Vector<String>>();
					for (Vector<String> ext : astSrc.accept(this, null)) {
						for (Vector<String> sform : sforms) {
							Vector<String> extSform = new Vector<String>();
							extSform.addAll(sform);
							extSform.addAll(ext);
							extSforms.add(extSform);
						}
					}
					sforms = extSforms;
				}
				return sforms;
			}

			@Override
			public Set<Vector<String>> visit(redgen.input.ast.SrcDisj astSrcDisj, Object __) {
				if (astSrcDisj.size() == 0)
					throw new Report.InternalError();
				Set<Vector<String>> sforms = new HashSet<Vector<String>>();
				for (redgen.input.ast.Src astSrc : astSrcDisj.nodes()) {
					sforms.addAll(astSrc.accept(this, null));
				}
				return sforms;
			}

		};

		this.reds = new Vector<Reduction>();
		for (redgen.input.ast.Reduction astRed : astRedSys.reds.nodes()) {

			Vector<Set<Vector<String>>> sformSets = new Vector<Set<Vector<String>>>();
			Vector<Iterator<Vector<String>>> sformSetIters = new Vector<Iterator<Vector<String>>>();

			// Prepare sets of sentential forms generated by symbol expressions of the left
			// side of the AST reduction and iterators over these sets.
			for (int src = 0; src < astRed.srcs.size(); src++) {
				sformSets.add(astRed.srcs.nodes().get(src).accept(enumAllSforms, null));
				sformSetIters.add(sformSets.get(src).iterator());
			}

			// Prepare the first combination of sentential forms generated by symbol
			// expressions of the left side of the AST reduction.
			Vector<Vector<String>> sforms = new Vector<Vector<String>>();
			for (int src = 0; src < astRed.srcs.size(); src++) {
				sforms.add(sformSetIters.get(src).next());
			}

			do {
				reds.add(new Reduction(astRed, sforms));

				// Prepare the next combination of sentential forms generated by symbol
				// expressions of the left side of the AST reduction.
				int src = 0;
				while ((src < astRed.srcs.size()) && (!sformSetIters.get(src).hasNext()))
					src++;
				if (src < astRed.srcs.size()) {
					sforms.set(src, sformSetIters.get(src).next());
					src--;
					while (src >= 0) {
						sformSetIters.set(src, sformSets.get(src).iterator());
						sforms.set(src, sformSetIters.get(src).next());
						src--;
					}
				} else
					break;
			} while (true);
		}
	}

	/**
	 * Returns all symbols.
	 *
	 * @return All symbols.
	 */
	public Vector<Symbol> symbs() {
		return new Vector<Symbol>(symbs.values());
	}

	/**
	 * Returns a symbol with a specified name.
	 *
	 * @param name The name of a symbol.
	 * @return The symbol with the specified name.
	 */
	public Symbol symb(String name) {
		return symbs.get(name);
	}

	/**
	 * Returns all reductions.
	 *
	 * @return All reductions.
	 */
	public Vector<Reduction> reds() {
		return new Vector<Reduction>(reds);
	}

	@Override
	public String toString() {
		StringBuffer buffer = new StringBuffer();
		for (int r = 0; r < reds.size(); r++) {
			buffer.append("\t");
			buffer.append(reds.get(r).toString());
			buffer.append("\n");
		}
		return buffer.toString();
	}

	/**
	 * The acceptor.
	 *
	 * @param <Result> The type of the result.
	 * @param visitor  The visitor.
	 * @return The value computed by the visitor.
	 */
	public <Result> Result accept(Visitor<Result> visitor) {
		return visitor.visit(this);
	}

	/**
	 * A symbol.
	 *
	 * @author bostjan.slivnik@fri.uni-lj.si
	 */
	public class Symbol {

		/**
		 * The unique number of a symbol.
		 *
		 * Unique numbers are sequential numbers and run from 0 to
		 * <code>symbs.size()</code>-1.
		 */
		public final int id;

		/** The unique name of a symbol. */
		public final String name;

		/**
		 * Constructs a new symbol and stores it into a set of all symbols of this
		 * reduction system.
		 *
		 * @param name The name of a symbol.
		 * @throws Report.InternalError If a symbol with this name already exists.
		 */
		private Symbol(String name) throws Report.InternalError {
			if (symbs.containsKey(name))
				throw new Report.InternalError();
			this.id = symbs.size() + 1;
			this.name = name;
			symbs.put(name, this);
		}

		@Override
		public String toString() {
			return name;
		}

		/**
		 * The acceptor.
		 *
		 * @param <Result> The type of the result.
		 * @param visitor  The visitor.
		 * @return The value computed by the visitor.
		 */
		public <Result> Result accept(Visitor<Result> visitor) {
			return visitor.visit(this);
		}

	}

	/**
	 * A reduction.
	 *
	 * @author bostjan.slivnik@fri.uni-lj.si
	 */
	public class Reduction {

		/**
		 * The unique number of a reduction.
		 *
		 * Unique numbers are sequential numbers and run from 0 to
		 * <code>reds.size()</code>-1. Different reductions can share the same original
		 * reduction as a single original reduction can result in many different
		 * reductions.
		 */
		public final int id;

		/** The original reduction. */
		public final redgen.input.ast.Reduction origRed;

		/** The symbols on the left side of a reduction. */
		private final Vector<SrcSymbol> srcSymbs;

		/** The symbols on the right side of a reduction. */
		private final Vector<DstSymbol> dstSymbs;

		private Reduction(redgen.input.ast.Reduction origRed, Vector<Vector<String>> sforms) {
			this.id = reds.size();
			this.origRed = origRed;
			this.srcSymbs = new Vector<SrcSymbol>();
			this.dstSymbs = new Vector<DstSymbol>();
			Vector<Integer> start = new Vector<Integer>();
			for (int sform = 0; sform < sforms.size(); sform++) {
				start.add(srcSymbs.size());
				for (int name = 0; name < sforms.get(sform).size(); name++) {
					srcSymbs.add(new SrcSymbol(symbs.get(sforms.get(sform).get(name)), sform));
				}
			}
			for (int dst = 0; dst < origRed.dsts.size(); dst++) {
				if (origRed.dsts.get(dst) instanceof redgen.input.ast.DstPos astPos) {
					int sform = astPos.index - 1;
					for (int name = 0; name < sforms.get(sform).size(); name++) {
						dstSymbs.add(new LeftDstSymbol(symbs.get(sforms.get(sform).get(name)), dst,
								start.get(sform) + name));
					}
					continue;
				}
				if (origRed.dsts.get(dst) instanceof redgen.input.ast.DstSymb astSymb) {
					Vector<Integer> poss = new Vector<Integer>();
					for (redgen.input.ast.DstPos astPos : astSymb.poss.nodes()) {
						int sform = astPos.index - 1;
						for (int name = 0; name < sforms.get(sform).size(); name++) {
							poss.add(start.get(sform) + name);
						}
					}
					dstSymbs.add(
							new ConsDstSymbol(symbs.get(astSymb.name.lexeme), dst, poss.size() == 0 ? null : poss));
					continue;
				}
				throw new Report.InternalError();
			}
		}

		/**
		 * Returns all symbols on the left side of a reduction.
		 *
		 * @return All symbols on the left side of a reduction.
		 */
		public Vector<SrcSymbol> srcSymbs() {
			return new Vector<SrcSymbol>(srcSymbs);
		}

		/**
		 * Returns all symbols on the right side of a reduction.
		 *
		 * @return All symbols on the right side of a reduction.
		 */
		public Vector<DstSymbol> dstSymbs() {
			return new Vector<DstSymbol>(dstSymbs);
		}

		@Override
		public String toString() {
			StringBuffer buffer = new StringBuffer();
			buffer.append("[");
			buffer.append(origRed.id);
			buffer.append("]");
			for (int src = 0; src < srcSymbs.size(); src++)
				buffer.append(" " + srcSymbs.get(src));
			buffer.append(" -->");
			for (int dst = 0; dst < dstSymbs.size(); dst++)
				buffer.append(" " + dstSymbs.get(dst));
			return buffer.toString();
		}

		/**
		 * The acceptor.
		 *
		 * @param <Result> The type of the result.
		 * @param visitor  The visitor.
		 * @return The value computed by the visitor.
		 */
		public <Result> Result accept(Visitor<Result> visitor) {
			return visitor.visit(this);
		}

		public abstract class RedSymbol {

			public final Symbol symb;

			public final int origPos;

			private RedSymbol(Symbol symb, int origPos) {
				this.symb = symb;
				this.origPos = origPos;
			}

			@Override
			public String toString() {
				return symb.name; // + "{" + origPos + "}";
			}

		}

		public class SrcSymbol extends RedSymbol {

			private SrcSymbol(Symbol symb, int origPos) {
				super(symb, origPos);
			}

			/**
			 * The acceptor.
			 *
			 * @param <Result> The type of the result.
			 * @param visitor  The visitor.
			 * @return The value computed by the visitor.
			 */
			public <Result> Result accept(Visitor<Result> visitor) {
				return visitor.visit(this);
			}

		}

		public abstract class DstSymbol extends RedSymbol {

			private DstSymbol(Symbol symb, int origPos) {
				super(symb, origPos);
			}

			/**
			 * The acceptor.
			 *
			 * @param <Result> The type of the result.
			 * @param visitor  The visitor.
			 * @return The value computed by the visitor.
			 */
			public abstract <Result> Result accept(Visitor<Result> visitor);

		}

		public class LeftDstSymbol extends DstSymbol {

			public final int pos;

			private LeftDstSymbol(Symbol symb, int origPos, int pos) {
				super(symb, origPos);
				this.pos = pos;
			}

			@Override
			public String toString() {
				return symb.toString() + "=" + pos;
			}

			@Override
			public <Result> Result accept(Visitor<Result> visitor) {
				return visitor.visit(this);
			}

		}

		public class ConsDstSymbol extends DstSymbol {

			private final Vector<Integer> poss;

			private ConsDstSymbol(Symbol symb, int origPos, Vector<Integer> poss) {
				super(symb, origPos);
				this.poss = poss == null ? null : new Vector<Integer>(poss);
			}

			public Vector<Integer> poss() {
				if (poss == null)
					return null;
				return new Vector<Integer>(poss);
			}

			@Override
			public String toString() {
				StringBuffer buffer = new StringBuffer();
				buffer.append(symb.toString());
				if (poss != null) {
					buffer.append("(");
					for (int pos = 0; pos < poss.size(); pos++) {
						if (pos > 0)
							buffer.append(",");
						buffer.append(poss.get(pos));
					}
					buffer.append(")");
				}
				return buffer.toString();
			}

			@Override
			public <Result> Result accept(Visitor<Result> visitor) {
				return visitor.visit(this);
			}

		}

	}

}
