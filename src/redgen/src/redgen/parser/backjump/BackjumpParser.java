package redgen.parser.backjump;

import java.io.*;
import java.util.*;

import redgen.report.*;
import redgen.redsys.*;
import redgen.parser.ast.*;

/**
 * Backjump parser.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public abstract class BackjumpParser {

	protected final RedSystem redSys;

	protected final Vector<State> states;

	protected final State initState;

	public BackjumpParser(RedSystem redSys) {
		this.redSys = redSys;
		this.states = new Vector<State>();
		this.initState = new State();

		for (RedSystem.Reduction red : redSys.reds()) {
			State state = initState;
			for (RedSystem.Reduction.SrcSymbol srcSymb : red.srcSymbs()) {
				state = state.addTransition(srcSymb.symb);
			}
			state.addReduction(red);
		}
	}

	protected abstract int backjump(int pos, RedSystem.Reduction red);

	public void parse(Vector<String> input) {
		Vector<Tree> sform = new Vector<Tree>();
		for (String name : input)
			sform.add(new Tree(redSys.symb(name), null));

		int totalCmps = 0;
		RedSystem.Reduction red = null;
		int pos = 0;
		do {
			red = null;
			while (pos < sform.size()) {
				int cmps = 0;
				State state = initState;
				red = null;
				int k = 0;
				while (pos + k < sform.size()) {
					if (state.transtition.size() == 0)
						break;
					State nextState = state.transtition.get(sform.get(pos + k).symb);
					cmps++;
					if (nextState == null)
						break;
					if ((nextState != null) && (nextState.red != null))
						red = nextState.red;
					state = nextState;
					k++;
				}
				totalCmps += cmps;
				if (red != null) {
					StringBuffer buffer = new StringBuffer();
					Vector<RedSystem.Reduction.SrcSymbol> srcSymbs = red.srcSymbs();
					int srcSize = srcSymbs.size();
					Vector<RedSystem.Reduction.DstSymbol> dstSymbs = red.dstSymbs();
					int dstSize = dstSymbs.size();

					{
						buffer.append("\t");
						for (int tree = 0; tree < pos + k + 1; tree++) {
							buffer.append(tree > 0 ? " " : "");
							buffer.append(tree == pos ? "* " : "");
							buffer.append(tree == pos + srcSize ? ". " : "");
							if (tree == sform.size())
								break;
							buffer.append(sform.get(tree));
						}
						buffer.append(pos + k + 1 < sform.size() ? " ..." : "");
						buffer.append("\n");
					}

					for (int dst = 0; dst < dstSize; dst++) {
						if (dstSymbs.get(dst) instanceof RedSystem.Reduction.ConsDstSymbol consSymb) {
							Vector<Integer> poss = consSymb.poss();
							if (poss == null)
								sform.add(pos + srcSize + dst, new Tree(consSymb.symb, null));
							else {
								Vector<Tree> subtrees = new Vector<Tree>();
								for (int p = 0; p < poss.size(); p++)
									subtrees.add(sform.get(pos + poss.get(p)));
								sform.add(pos + srcSize + dst, new Tree(consSymb.symb, subtrees));
							}
							continue;
						}
						if (dstSymbs.get(dst) instanceof RedSystem.Reduction.LeftDstSymbol leftSymb) {
							sform.add(pos + srcSize + dst, new Tree(leftSymb.symb, null));
							continue;
						}
						throw new Report.InternalError();
					}
					buffer.append("\t\treduced using " + red.toString() + "\n");
					buffer.append("\t\tderived from " + red.origRed.toString() + "\n");
					buffer.append("\t\t" + cmps + " compares" + "\n");
					for (int src = 0; src < srcSize; src++) {
						sform.remove(pos);
					}

					{
						buffer.append("\t");
						for (int tree = 0; tree < pos + k + 1; tree++) {
							buffer.append(tree > 0 ? " " : "");
							buffer.append(tree == pos ? "* " : "");
							buffer.append(tree == pos + dstSize ? ". " : "");
							if (tree == sform.size())
								break;
							buffer.append(sform.get(tree));
						}
						buffer.append(pos + k + 1 < sform.size() ? " ..." : "");
					}

					Report.info(buffer.toString());

					pos = backjump(pos, red);
					break;
				}

				pos += 1;
			}
		} while (red != null);
		Report.info("\t" + totalCmps + " total compares\n");
	}

	protected abstract void generateC(BufferedWriter file) throws IOException;

	public void generateC(String basename) {
		{
			// GENERATE TOKENS

			String filename = basename + "-redgen.h";
			try {
				BufferedWriter file = new BufferedWriter(new FileWriter(filename));
				file.write("#ifndef _REDGEN_H\n");
				file.write("#define _REDGEN_H\n");
				file.write("\n");
				Vector<RedSystem.Symbol> symbs = redSys.symbs();
				symbs.sort(new Comparator<RedSystem.Symbol>() {
					@Override
					public int compare(RedSystem.Symbol symb1, RedSystem.Symbol symb2) {
						if (symb1.id == symb2.id)
							return 0;
						if (symb1.id < symb2.id)
							return -1;
						else
							return +1;
					}
				});
				file.write("#define SYMB__EOF (0)\n");
				for (RedSystem.Symbol symb : symbs) {
					if (symb.name.equals("[")) {
						file.write("#define SYMB__LM (" + symb.id + ")\n");
						continue;
					}
					if (symb.name.equals("]")) {
						file.write("#define SYMB__RM (" + symb.id + ")\n");
						continue;
					}
					file.write("#define SYMB_" + symb.name + " (" + symb.id + ")\n");
				}
				file.write("\n");
				file.write("#endif\n");
				file.close();
			} catch (IOException __) {
				new Report.Error("IO error while generating '" + filename + "'.");
			}
		}

		{
			// GENERATE REDUCTION SYSTEM

			String filename = basename + "-redgen.c";
			try {
				BufferedWriter file = new BufferedWriter(new FileWriter(filename));
				file.write("#ifndef _REDGEN_C\n");
				file.write("#define _REDGEN_C\n");
				file.write("\n");

				// Generate token names.
				Vector<RedSystem.Symbol> symbs = redSys.symbs();
				symbs.sort(new Comparator<RedSystem.Symbol>() {

					@Override
					public int compare(RedSystem.Symbol symb1, RedSystem.Symbol symb2) {
						if (symb1.id == symb2.id)
							return 0;
						if (symb1.id < symb2.id)
							return -1;
						else
							return +1;
					}
				});
				file.write("char *redgen_token_names[" + (symbs.size() + 1) + "] = {");
				file.write("\"$\",");
				for (RedSystem.Symbol symb : symbs) {
					file.write("\"" + symb.name + "\",");
				}
				file.write("};\n\n");

				// Generate reductions.
				Vector<RedSystem.Reduction> reds = redSys.reds();
				file.write("char *redgen_reduction_names[" + reds.size() + "] = {");
				for (int red = 0; red < reds.size(); red++) {
					file.write("\"" + reds.get(red).toString() + "\",");
				}
				file.write("};\n\n");
				file.write("char *redgen_reduction_orig_names[" + reds.size() + "] = {");
				for (int red = 0; red < reds.size(); red++) {
					file.write("\"" + reds.get(red).origRed.toString() + "\",");
				}
				file.write("};\n\n");
				int max_src_size = 0;
				int max_dst_size = 0;
				for (int red = 0; red < reds.size(); red++) {
					int src_size = reds.get(red).srcSymbs().size();
					int dst_size = reds.get(red).dstSymbs().size();
					if (src_size > max_src_size)
						max_src_size = src_size;
					if (dst_size > max_dst_size)
						max_dst_size = dst_size;
				}
				file.write("short int redgen_reduction_src_side[" + reds.size() + "][" + max_src_size + "] = {\n");
				for (int red = 0; red < reds.size(); red++) {
					Vector<RedSystem.Reduction.SrcSymbol> srcSymbs = reds.get(red).srcSymbs();
					file.write("    {");
					for (int srcSymb = 0; srcSymb < srcSymbs.size(); srcSymb++) {
						file.write(srcSymbs.get(srcSymb).symb.id + ",");
					}
					file.write("},\n");
				}
				file.write("  };\n\n");
				file.write("short int redgen_reduction_src_side_len[" + reds.size() + "] = {");
				for (int red = 0; red < reds.size(); red++) {
					file.write(reds.get(red).srcSymbs().size() + ",");
				}
				file.write("};\n\n");
				file.write("short int redgen_reduction_dst_side[" + reds.size() + "][" + max_dst_size + "] = {\n");
				for (int red = 0; red < reds.size(); red++) {
					Vector<RedSystem.Reduction.DstSymbol> dstSymbs = reds.get(red).dstSymbs();
					file.write("    {");
					for (int dstSymb = 0; dstSymb < dstSymbs.size(); dstSymb++) {
						file.write(dstSymbs.get(dstSymb).symb.id + ",");
					}
					file.write("},\n");
				}
				file.write("  };\n\n");
				file.write("short int redgen_reduction_dst_side_len[" + reds.size() + "] = {");
				for (int red = 0; red < reds.size(); red++) {
					file.write(reds.get(red).dstSymbs().size() + ",");
				}
				file.write("};\n\n");

				// Generate states.
				file.write("short int redgen_transitions[" + states.size() + "][" + (symbs.size() + 1) + "] = {\n");
				for (int state = 0; state < states.size(); state++) {
					file.write("    {-1,");
					for (int symb = 0; symb < symbs.size(); symb++) {
						State nextState = states.get(state).transtition.get(symbs.get(symb));
						file.write(nextState == null ? "-1," : (nextState.id + ","));
					}
					file.write("},\n");
				}
				file.write("  };\n\n");
				file.write("short int redgen_number_of_transitions[" + states.size() + "] = {");
				for (int state = 0; state < states.size(); state++) {
					file.write(states.get(state).transtition.size() + ",");
				}
				file.write("};\n\n");
				file.write("short int redgen_selected_reduction[" + states.size() + "] = {");
				for (int state = 0; state < states.size(); state++) {
					RedSystem.Reduction red = states.get(state).red;
					file.write(red == null ? "-1," : (red.id + ","));
				}
				file.write("};\n\n");

				generateC(file);

				file.write("#endif\n");
				file.close();
			} catch (IOException __) {
				new Report.Error("IO error while generating '" + filename + "'.");
			}
		}
	}

	private class State {

		private final int id;

		private final HashMap<RedSystem.Symbol, State> transtition;

		private RedSystem.Reduction red;

		private State() {
			this.id = states.size();
			this.transtition = new HashMap<RedSystem.Symbol, State>();
			this.red = null;
			states.add(this);
		}

		private State addTransition(RedSystem.Symbol symb) {
			State nextState = transtition.get(symb);
			if (nextState == null) {
				nextState = new State();
				transtition.put(symb, nextState);
			}
			return nextState;
		}

		private void addReduction(RedSystem.Reduction red) {
			if (this.red == null)
				this.red = red;
			else {
				Report.warning(red.origRed, "\n\tReduction " + red.toString() + "\n\t  derived from reduction "
						+ red.origRed.toString() + "\n\t  is never reduced.");
			}
		}

	}

}
