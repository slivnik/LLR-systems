package redgen.redsys;

import java.util.*;

import redgen.report.Report;

/**
 * Checks whether a reduction system is context-sensitive.
 *
 * @author bostjan.slivnik@fri.uni-lj.si
 */
public class CheckCSR implements FullVisitor<Boolean> {

	/** Does nothing. */
	public CheckCSR() {
	}

	@Override
	public Boolean visit(RedSystem.Reduction red) {
		Boolean result = null;
		Vector<RedSystem.Reduction.SrcSymbol> srcSymbs = red.srcSymbs();
		Vector<RedSystem.Reduction.DstSymbol> dstSymbs = red.dstSymbs();
		// Check if either side of a reduction is empty.
		if (srcSymbs.size() == 0) {
			Report.warning(red.origRed, "\n\tReduction " + red.toString() + "\n\t  derived from reduction "
					+ red.origRed.toString() + "\n\t  has an empty left side.");
			result = false;
		}
		if (dstSymbs.size() == 0) {
			Report.warning(red.origRed, "\n\tReduction " + red.toString() + "\n\t  derived from reduction "
					+ red.origRed.toString() + "\n\t  has an empty right side.");
			result = false;
		}
		if ((srcSymbs.size() == 0) || (dstSymbs.size() == 0))
			return false;
		// Check that the right side is not longer then the left side.
		if (dstSymbs.size() > srcSymbs.size()) {
			Report.warning(red.origRed, "\n\tReduction " + red.toString() + "\n\t  derived from "
					+ red.origRed.toString() + "\n\t  has the right side longer than the left side.");
			result = false;
		}
		// Check the position of the left marker.
		if ((srcSymbs.firstElement().symb.name == "[") && (dstSymbs.firstElement().symb.name != "[")) {
			Report.warning(red.origRed, "\n\tThe left marker is deleted in\n\t  reduction " + red.toString()
					+ "\n\t  derived from reduction " + red.origRed.toString() + ".");
			result = false;
		}
		if ((srcSymbs.firstElement().symb.name != "[") && (dstSymbs.firstElement().symb.name == "[")) {
			Report.warning(red.origRed, "\n\tThe left marker is created in\t\n  reduction " + red.toString()
					+ "\n\t  derived from reduction " + red.origRed.toString() + ".");
			result = false;
		}
		for (int src = 1; src < srcSymbs.size(); src++) {
			if (srcSymbs.get(src).symb.name == "[") {
				Report.warning(red.origRed,
						"\n\tThe left marker on the left side of\n\t  reduction " + red.toString()
								+ "\n\t  derived from reduction " + red.origRed.toString()
								+ "\n\t  does not appear as the leftmost symbol.");
				result = false;
			}
		}
		for (int dst = 1; dst < dstSymbs.size(); dst++) {
			if (dstSymbs.get(dst).symb.name == "[") {
				Report.warning(red.origRed,
						"\n\tThe left marker on the right side of\n\t  reduction " + red.toString()
								+ "\n\t  derived from reduction " + red.origRed.toString()
								+ "\n\t  does not appear as the leftmost symbol.");
				result = false;
			}
		}
		// Check the position of the right marker.
		if ((srcSymbs.lastElement().symb.name == "]") && (dstSymbs.lastElement().symb.name != "]")) {
			Report.warning(red.origRed, "\n\tThe right marker is deleted in\n\t  reduction " + red.toString()
					+ "\n\t  derived from reduction " + red.origRed.toString() + ".");
			result = false;
		}
		if ((srcSymbs.lastElement().symb.name != "]") && (dstSymbs.lastElement().symb.name == "]")) {
			Report.warning(red.origRed, "\n\tThe right marker is created in\t\n  reduction " + red.toString()
					+ "\n\t  derived from reduction " + red.origRed.toString() + ".");
			result = false;
		}
		for (int src = 0; src < srcSymbs.size() - 1; src++) {
			if (srcSymbs.get(src).symb.name == "]") {
				Report.warning(red.origRed,
						"\n\tThe right marker on the left side of\n\t  reduction " + red.toString()
								+ "\n\t  derived from reduction " + red.origRed.toString()
								+ "\n\t  does not appear as the rightmost symbol.");
				result = false;
			}
		}
		for (int dst = 0; dst < dstSymbs.size() - 1; dst++) {
			if (dstSymbs.get(dst).symb.name == "]") {
				Report.warning(red.origRed,
						"\n\tThe right marker on the right side of\n\t  reduction " + red.toString()
								+ "\n\t  derived from reduction " + red.origRed.toString()
								+ "\n\t  does not appear as the rightmost symbol.");
				result = false;
			}
		}
		return result;
	}

	@Override
	public Boolean combine(Boolean result1, Boolean result2) {
		return (result1 == null ? true : result1) && (result2 == null ? true : result2);
	}

}
