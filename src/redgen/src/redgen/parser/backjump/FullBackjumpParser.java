package redgen.parser.backjump;

import java.io.*;

import redgen.redsys.RedSystem;

/**
 * Full backward jump parser generator.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class FullBackjumpParser extends BackjumpParser {

	public FullBackjumpParser(RedSystem redSys) {
		super(redSys);
	}

	@Override
	protected int backjump(int pos, RedSystem.Reduction red) {
		return 0;
	}

	@Override
	protected void generateC(BufferedWriter file) throws IOException {
	}

}
