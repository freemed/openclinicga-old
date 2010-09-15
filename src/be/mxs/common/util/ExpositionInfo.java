package be.mxs.common.util;

import java.util.Vector;

/**
 * User: stijn smets
 * Date: 31-okt-2005
 */

//==================================================================================================
// Data Transfer Object (DTO) containing nuclear (internal and external) exposition data of a specified person.
// (Dosimetry = external exposition)
//==================================================================================================
public class ExpositionInfo {

    // declarations
    private int month;
    private String site, personId;
    private double externalGlobalExpoDose, externalPartialExpoDose;
    private Vector internalExpoOrgans, internalExpoContaminants, internalExpoDoses, internalExpoRemarks;


    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public ExpositionInfo(String personId, int month, String site){
        this.personId = personId;
        this.month = month;
        this.site = site;

        // difference between 0 and no value !
        this.externalGlobalExpoDose = -1;
        this.externalPartialExpoDose = -1;

        // initialize vectors
        internalExpoOrgans = new Vector();
        internalExpoContaminants = new Vector();
        internalExpoDoses = new Vector();
        internalExpoRemarks = new Vector();
    }


    //####################################### SETTERS ##############################################
    public void setExternalGlobalExpositionDose(double value){
        this.externalGlobalExpoDose = value;
    }

    public void setExternalPartialExpositionDose(double value){
        this.externalPartialExpoDose = value;
    }

    public void addInternalExpositionOrgan(String organ){
        if(!internalExpoOrgans.contains(organ)){
            internalExpoOrgans.add(organ);
        }
    }

    public void addInternalExpositionContaminant(String contaminant){
        if(!internalExpoContaminants.contains(contaminant)){
            internalExpoContaminants.add(contaminant);
        }
    }

    public void addInternalExpositionDose(String dose){
        internalExpoDoses.add(new Integer(dose));
    }

    public void addInternalExpositionRemark(String remark){
        if(!internalExpoRemarks.contains(remark)){
            internalExpoRemarks.add(remark);
        }
    }


    //######################################## GETTERS #############################################
    public String getPersonId(){ return this.personId; }
    public int getMonth(){ return this.month; }
    public String getSite(){ return this.site; }

    public double getExternalGlobalExpositionDose(){
        return this.externalGlobalExpoDose;
    }

    public double getExternalPartialExpositionDose(){
        return this.externalPartialExpoDose;
    }

    public Vector getInternalExpositionOrgans(){
        return this.internalExpoOrgans;
    }

    public Vector getInternalExpositionContaminants(){
        return this.internalExpoContaminants;
    }

    public Vector getInternalExpositionDoses(){
        return this.internalExpoDoses;
    }

    public Vector getInternalExpositionRemarks(){
        return this.internalExpoRemarks;
    }

}
