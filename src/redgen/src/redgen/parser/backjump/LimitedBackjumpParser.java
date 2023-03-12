package redgen.parser.backjump;

import java.io.*;
import java.util.*;

import redgen.report.*;
import redgen.redsys.*;

/**
 * Limited backward jump parser generator.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class LimitedBackjumpParser extends BackjumpParser {

	protected HashMap<RedSystem.Reduction, Integer> backjump;

	public LimitedBackjumpParser(RedSystem redSys) {
		super(redSys);

		backjump = new HashMap<RedSystem.Reduction, Integer>();
		for (RedSystem.Reduction red : redSys.reds()) {
			// System.out.println("\n\n" + red.toString());

			Vector<RedSystem.Reduction.DstSymbol> beta = red.dstSymbs();
			int betaSize = beta.size();
			int longestBackjump = betaSize;
			for (RedSystem.Reduction redPrime : redSys.reds()) {
				// System.out.print(" " + redPrime + " ");
				Vector<RedSystem.Reduction.SrcSymbol> alphaPrime = redPrime.srcSymbs();
				int alphaPrimeSize = alphaPrime.size();

				int fstBackjump = -(alphaPrimeSize - 1);
				int lstBackjump = betaSize;
				// System.out.println(" " + fstBackjump + " " + lstBackjump);
				for (int backjump = fstBackjump; backjump <= lstBackjump; backjump++) {
					int fstCmp = Integer.max(backjump, 0);
					int lstCmp = Integer.min(backjump + alphaPrimeSize, betaSize);

					// System.out.println(" " + fstCmp + " " + lstCmp);
					boolean match = true;
					for (int cmp = fstCmp; cmp < lstCmp; cmp++) {
						match = match && (alphaPrime.get(-backjump + cmp).symb.id == beta.get(cmp).symb.id);
					}
					if (match) {
						// System.out.println(" " + backjump);
						if (backjump < longestBackjump)
							longestBackjump = backjump;
						break;
					}
				}
			}
			// System.out.println(" => " + longestBackjump);
			backjump.put(red, longestBackjump);
		}
	}

	@Override
	public int backjump(int pos, RedSystem.Reduction red) {
		if (!backjump.containsKey(red))
			throw new Report.InternalError();
		pos = pos + backjump.get(red);
		pos = Integer.max(0, pos);
		return pos;
	}

	@Override
	protected void generateC(BufferedWriter file) throws IOException {
		Vector<RedSystem.Reduction> reds = redSys.reds();
		file.write("short int redgen_backjump[" + reds.size() + "] = {");
		for (RedSystem.Reduction red : reds) {
			file.write(backjump.get(red) + ",");
		}
		file.write("};\n\n");
	}

}
