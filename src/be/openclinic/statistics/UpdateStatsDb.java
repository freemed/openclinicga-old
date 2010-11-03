package be.openclinic.statistics;

import java.io.IOException;

import uk.org.primrose.GeneralException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;
import uk.org.primrose.vendor.standalone.PrimroseWebConsoleLoader;

public class UpdateStatsDb {

	/**
	 * @param args
	 * @throws IOException 
	 * @throws GeneralException 
	 */
	public static void main(String[] args) throws GeneralException, IOException {
		PrimroseLoader.load(args[0], true);
		UpdateStats1 updateStats1 = new UpdateStats1();
		updateStats1.execute();
		PrimroseLoader.stopAllPools();
		PrimroseLoader.load(args[0], true);
		UpdateStats2 updateStats2 = new UpdateStats2();
		updateStats2.execute();
		PrimroseLoader.stopAllPools();
		PrimroseLoader.load(args[0], true);
		UpdateStats3 updateStats3 = new UpdateStats3();
		updateStats3.execute();
		PrimroseLoader.stopAllPools();
		PrimroseLoader.load(args[0], true);
		UpdateStats4 updateStats4 = new UpdateStats4();
		updateStats4.execute();
		PrimroseLoader.stopAllPools();
	}

}
