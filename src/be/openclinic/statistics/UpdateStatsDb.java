package be.openclinic.statistics;

public class UpdateStatsDb {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("Starting statistics tables update");
		UpdateStats1 updateStats1 = new UpdateStats1();
		updateStats1.execute();
		UpdateStats2 updateStats2 = new UpdateStats2();
		updateStats2.execute();
		UpdateStats3 updateStats3 = new UpdateStats3();
		updateStats3.execute();
		UpdateStats4 updateStats4 = new UpdateStats4();
		updateStats4.execute();
		System.out.println("End of statistics tables update");
	}

}
