package be.mxs.common.util.diagnostics;

import java.util.Vector;

/**
 * User: frank
 * Date: 7-okt-2005
 */
public class Diagnosis {

    //--- DECLARATIONS -----------------------------------------------------------------------------
    public boolean hasProblems;
    public String diagnosis;
    public Vector values;


    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public Diagnosis(){
        hasProblems = false;
        values = new Vector();
    }

}
