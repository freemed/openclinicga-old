package be.chuk;

import java.io.IOException;

import uk.org.primrose.GeneralException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class SyncSage {
    public static void main(String[] args){
    	try {
			PrimroseLoader.load(args[0], true);
		} catch (GeneralException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        Sage.synchronizeInsurars();
        Sage.synchronizePrestations();
        Sage.synchronizeReimbursements();
        Sage.synchronizeFamilyReimbursements();
    }
}
