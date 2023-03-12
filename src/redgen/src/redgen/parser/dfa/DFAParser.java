package redgen.parser.dfa;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

import redgen.parser.ast.Tree;
import redgen.redsys.*;
import redgen.report.Report;

/**
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class DFAParser {

	private final RedSystem redSys;

	private final TreeMap<TreeSet<Item>, State> allStates;

	private final Vector<State> states;

	private final TreeSet<Item> initItems;

	private final State initState;

	public DFAParser(RedSystem redSys) {
		this.redSys = redSys;
		this.allStates = new TreeMap<TreeSet<Item>, State>(Item.treeSetItemComparator);
		this.states = new Vector<State>();

		this.initItems = new TreeSet<Item>(Item.itemComparator);
		Vector<RedSystem.Symbol> eps = new Vector<RedSystem.Symbol>();
		for (RedSystem.Reduction red : this.redSys.reds()) {
			Item item = new Item(red, 0, eps);
			this.initItems.add(item);
		}
		this.initState = new State(this.initItems);
		// System.out.println("# states = " + allStates.size());
	}

	private class Item {

		public static final Comparator<Item> itemComparator = new Comparator<Item>() {
			@Override
			public int compare(Item item1, Item item2) {
				int cmp;
				cmp = item1.pos - item2.pos;
				if (cmp != 0)
					return cmp;
				cmp = item1.red.id - item2.red.id;
				if (cmp != 0)
					return cmp;
				cmp = item1.flw.size() - item2.flw.size();
				if (cmp != 0)
					return cmp;
				for (int s = 0; s < item1.flw.size(); s++) {
					cmp = item1.flw.get(s).id - item2.flw.get(s).id;
					if (cmp != 0)
						return cmp;
				}
				return 0;
			}
		};

		public static final Comparator<TreeSet<Item>> treeSetItemComparator = new Comparator<TreeSet<Item>>() {
			@Override
			public int compare(TreeSet<Item> treeSet1, TreeSet<Item> treeSet2) {
				int cmp;
				cmp = treeSet1.size() - treeSet2.size();
				if (cmp != 0)
					return cmp;
				Iterator<Item> iter1 = treeSet1.iterator();
				Iterator<Item> iter2 = treeSet2.iterator();
				while (iter1.hasNext() && iter2.hasNext()) {
					cmp = itemComparator.compare(iter1.next(), iter2.next());
					if (cmp != 0)
						return cmp;
				}
				return 0;
			}
		};

		private final RedSystem.Reduction red;

		private final Vector<RedSystem.Symbol> symbs;

		private final int pos;

		private final Vector<RedSystem.Symbol> flw;

		public Item(RedSystem.Reduction red, int pos, Vector<RedSystem.Symbol> flw) {
			this.red = red;
			this.symbs = new Vector<RedSystem.Symbol>();
			for (RedSystem.Reduction.SrcSymbol symb : red.srcSymbs())
				this.symbs.add(symb.symb);
			this.pos = pos;
			this.flw = flw;
		}

		@Override
		public boolean equals(Object object) {
			if (object instanceof Item item)
				return itemComparator.compare(this, item) == 0;
			else
				return false;
		}

		@Override
		public String toString() {
			StringBuffer buffer = new StringBuffer();
			buffer.append("[");
			buffer.append(red.origRed.id);
			buffer.append("=>");
			buffer.append(red.id);
			buffer.append("]");
			int pos = 0;
			for (RedSystem.Symbol symb : symbs) {
				if (pos == this.pos)
					buffer.append(" *");
				buffer.append(" " + symb);
				pos++;
			}
			if (this.pos == symbs.size())
				buffer.append(" *");
			buffer.append(" ,");
			for (RedSystem.Symbol symb : flw) {
				buffer.append(" " + symb);
			}
			return buffer.toString();
		}

	}

	private class State {

		private final int id;

		private final TreeSet<Item> items;

		private final HashMap<RedSystem.Symbol, State> trans;

		private final HashMap<RedSystem.Symbol, Item> redItems;

		public State(TreeSet<Item> items) {
			this.id = allStates.size();
			this.items = new TreeSet<Item>(items);
			this.trans = new HashMap<RedSystem.Symbol, State>();
			this.redItems = new HashMap<RedSystem.Symbol, Item>();

			allStates.put(this.items, this);
			states.add(this);

			for (RedSystem.Symbol symb : redSys.symbs()) {
				// System.out.println("state " + id + " and " + symb);

				TreeSet<Item> newItems = new TreeSet<Item>(Item.itemComparator);
				newItems.addAll(initItems);
				for (Item item : this.items) {
					if (item.pos < item.symbs.size()) {
						if (item.symbs.get(item.pos) == symb) {
							Item newItem = new Item(item.red, item.pos + 1, item.flw);
							newItems.add(newItem);
						}
					} else {
						Vector<RedSystem.Symbol> newFlw = new Vector<RedSystem.Symbol>(item.flw);
						newFlw.add(symb);
						Item newItem = new Item(item.red, item.pos, newFlw);
						newItems.add(newItem);
					}
				}

				// for (Item newItem : newItems)
				// System.out.println(" " + newItem);
				// System.out.println("---");

				if (Integer.signum(-1) == -1) {
					TreeSet<Item> nonRelevantItems = new TreeSet<Item>(Item.itemComparator);
					for (Item newItem1 : newItems) {
						if (newItem1.pos < newItem1.symbs.size())
							continue;

						for (Item newItem2 : newItems) {
							if (newItem1 == newItem2)
								continue;
							if ((newItem1.pos + newItem1.flw.size() > newItem2.pos + newItem2.flw.size())
									|| ((newItem1.pos + newItem1.flw.size() == newItem2.pos + newItem2.flw.size())
											&& (newItem1.pos > newItem2.symbs.size()))) {
								// System.out.println("eliminate " + newItem2);
								nonRelevantItems.add(newItem2);
							}
						}
					}
					newItems.removeAll(nonRelevantItems);
				}

				// for (Item newItem : newItems)
				// System.out.println(" " + newItem);
				// System.out.println("---");

				if ((newItems.size() == 1) && (newItems.first().pos == newItems.first().symbs.size())) {
					redItems.put(symb, newItems.first());
				} else {
					State newState = allStates.get(newItems);
					if (newState == null) {
						// if (allStates.size() < 15) {
						newState = new State(newItems);
						trans.put(symb, newState);
						// }
					} else {
						trans.put(symb, newState);
					}
				}
			}

			// System.out.println(this);
		}

		@Override
		public String toString() {
			StringBuffer buffer = new StringBuffer();
			buffer.append("STATE " + id + ":\n");
			for (Item item : items) {
				buffer.append("  ");
				buffer.append(item);
				buffer.append("\n");
			}
			buffer.append("  GOTO:");
			for (RedSystem.Symbol symb : redSys.symbs()) {
				State nextState = trans.get(symb);
				if (nextState != null)
					buffer.append(" " + symb + ":" + nextState.id);
			}
			buffer.append("\n");
			if (redItems.size() > 0) {
				buffer.append("  REDS:\n");
				for (RedSystem.Symbol symb : redSys.symbs()) {
					Item redItem = redItems.get(symb);
					if (redItem != null)
						buffer.append("    " + symb + " : " + redItem + "\n");
				}
			}
			return buffer.toString();
		}

	}

	public void parse(Vector<String> input) {
		Vector<Tree> sform = new Vector<Tree>();
		for (String name : input)
			sform.add(new Tree(redSys.symb(name), null));
		Stack<State> states = new Stack<State>();
		states.add(initState);

		int totalCmps = 0;
		int cmps = 0;
		do {
			int pos = states.size() - 1;
			if (pos == sform.size())
				break;

			cmps++;
			totalCmps++;
			State state = states.get(pos);
			Item redItem = state.redItems.get(sform.get(pos).symb);
			if (redItem == null) {
				State newState = state.trans.get(sform.get(pos).symb);
				states.add(newState);

			} else {
				StringBuffer buffer = new StringBuffer();
				Vector<RedSystem.Reduction.SrcSymbol> srcSymbs = redItem.red.srcSymbs();
				int srcSize = srcSymbs.size();
				Vector<RedSystem.Reduction.DstSymbol> dstSymbs = redItem.red.dstSymbs();
				int dstSize = dstSymbs.size();

				int redPos = pos - (srcSize + redItem.flw.size()) + 1;

				{
					buffer.append("\t");
					int ps = states.size();
					for (int p = 0; p < ps; p++) {
						buffer.append(p > 0 ? " " : "");
						buffer.append(p == redPos ? "* " : "");
						buffer.append(states.get(p).id + ":" + sform.get(p).symb);
					}
					buffer.append("\n");
				}

				buffer.append("\t\treduced using " + redItem.red.toString() + "\n");
				buffer.append("\t\tderived from " + redItem.red.origRed.toString() + "\n");
				buffer.append("\t\t" + cmps + " compares" + "\n");
				cmps = 0;
				for (int dst = 0; dst < dstSize; dst++) {
					if (dstSymbs.get(dst) instanceof RedSystem.Reduction.ConsDstSymbol consSymb) {
						Vector<Integer> poss = consSymb.poss();
						if (poss == null)
							sform.add(redPos + srcSize + dst, new Tree(consSymb.symb, null));
						else {
							Vector<Tree> subtrees = new Vector<Tree>();
							for (int p = 0; p < poss.size(); p++)
								subtrees.add(sform.get(pos + poss.get(p)));
							sform.add(redPos + srcSize + dst, new Tree(consSymb.symb, subtrees));
						}
						continue;
					}
					if (dstSymbs.get(dst) instanceof RedSystem.Reduction.LeftDstSymbol leftSymb) {
						sform.add(redPos + srcSize + dst, new Tree(leftSymb.symb, null));
						continue;
					}
					throw new Report.InternalError();
				}
				for (int src = 0; src < srcSize; src++) {
					sform.remove(redPos);
				}
				states.setSize(redPos + 1);

				{
					buffer.append("\t");
					int ps = redPos + dstSize + redItem.flw.size();
					for (int p = 0; p < ps; p++) {
						buffer.append(p > 0 ? " " : "");
						buffer.append(p == redPos ? "* " : "");
						buffer.append((p < states.size() ? states.get(p).id + ":" : "") + sform.get(p).symb);
					}
					buffer.append("\n");
				}

				Report.info(buffer.toString());
			}

		} while (true);
		Report.info("\t" + totalCmps + " total compares\n");
	}

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
				file.write("int redgen_transitions[" + allStates.size() + "][" + (symbs.size() + 1) + "] = {\n");
				for (int state = 0; state < states.size(); state++) {
					file.write("    {0,");
					// System.out.println(state);
					for (int symb = 0; symb < symbs.size(); symb++) {
						State nextState = states.get(state).trans.get(symbs.get(symb));
						if (nextState != null) {
							file.write((nextState.id + 1) + ",");
						} else {
							Item redItem = states.get(state).redItems.get(symbs.get(symb));
							if (redItem != null) {
								// System.out.println(redItem);
								// file.write((-2 - (redItem.red.id + redItem.flw.size() << 16)) + ",");
								file.write("-1-((" + redItem.flw.size() + " << 16)+(" + (redItem.red.id) + ")),");
							} else {
								System.out.println(states.get(state));
								System.out.println("SYMBOL: " + symbs.get(symb));
								System.exit(1);
							}
						}
					}
					file.write("},\n");
				}
				file.write("  };\n\n");

				file.write("#endif\n");
				file.close();
			} catch (IOException __) {
				new Report.Error("IO error while generating '" + filename + "'.");
			}
		}
	}

}
