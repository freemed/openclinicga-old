package be.chuk;

import java.io.IOException;

import be.mxs.common.util.db.MedwanQuery;

import uk.org.primrose.GeneralException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class SyncSage {
    public static void main(String[] args){
    	try {
			PrimroseLoader.load(args[0], true);
		}
    	catch (Exception e) {
			e.printStackTrace();
		}
        Sage.synchronizeInsurars();
        Sage.synchronizePrestations();
        Sage.synchronizeReimbursements();
        Sage.synchronizeFamilyReimbursements();
        System.exit(0);
    }
}
