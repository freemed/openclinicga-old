package be.mxs.common.util.diagnostics;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

import java.sql.*;
import java.text.SimpleDateFormat;

public class CleanNullUpdatetime extends Diagnostic {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public CleanNullUpdatetime(){
        name = "CheckNullUpdatetime";
        id = "MXS.6";
        author = "frank.verbeke@mxs.be";
        description = "Checks if in some synchronisable tables updatetime is null. Corrects if yes.";
        version = "1.0";
        date = "02/03/2006";
    }

    //--- CHECK -----------------------------------------------------------------------------------
    public Diagnosis check(){
        Diagnosis diagnosis = new Diagnosis();
        diagnosis.hasProblems=false;
        Connection occupconnection = MedwanQuery.getInstance().getOpenclinicConnection();
        Connection adminconnection = MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps;
        ResultSet rs;

        try {
            // check all synchronisable tables
            ps = adminconnection.prepareStatement("SELECT COUNT(*) total from Services where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Services'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from OC_LABELS where OC_LABEL_UPDATETIME is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Labels'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = adminconnection.prepareStatement("SELECT COUNT(*) total from EmailDestinations where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'EmailDestinations'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = adminconnection.prepareStatement("SELECT COUNT(*) total from MedicalCenters where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'MedicalCenters'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = adminconnection.prepareStatement("SELECT COUNT(*) total from Personnel where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Personnel'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = adminconnection.prepareStatement("SELECT COUNT(*) total from Providers where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Providers'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from Examinations where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Examinations'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from FunctionCategories where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'FunctionCategories'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from FunctionGroups where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'FunctionGroups'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from LabAnalysis where updatetime is null and deletetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'LabAnalysis'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from LabProfiles where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'LabProfiles'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from LabProfilesAnalysis where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'LabProfilesAnalysis'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from RiskCodes where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'RiskCodes'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from RiskExaminations where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'RiskExaminations'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from Servers where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Servers'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from Workplaces where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Workplaces'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from WorkplaceRisks where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'WorkplaceRisks'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from EnterpriseVisits where updateTime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'EnterpriseVisits'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from FunctionCategoryRisks where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'FunctionCategoryRisks'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from FunctionGroupExaminations where updatetime is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'FunctionGroupExaminations'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
            ps = occupconnection.prepareStatement("SELECT COUNT(*) total from Transactions where ts is null");
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    if(Debug.enabled) Debug.println("! CleanNullUpdatetime.java : null-time in 'Transactions'");
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			occupconnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			adminconnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return diagnosis;
    }

    //--- CORRECT ---------------------------------------------------------------------------------
    public boolean correct(Diagnosis diagnosis){
        boolean correct;
        Connection occupconnection = MedwanQuery.getInstance().getOpenclinicConnection();
        Connection adminconnection = MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps;

        try {
            Date oldDate = new Date(new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2000").getTime());

            // admin
            ps = adminconnection.prepareStatement("update Services set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update OC_LABELS set OC_LABEL_UPDATETIME=? where OC_LABEL_UPDATETIME is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = adminconnection.prepareStatement("update EmailDestinations set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = adminconnection.prepareStatement("update MedicalCenters set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = adminconnection.prepareStatement("update Personnel set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = adminconnection.prepareStatement("update Providers set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            // occup
            ps = occupconnection.prepareStatement("update Examinations set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update FunctionCategories set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update FunctionGroups set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update LabAnalysis set updatetime=? where updatetime is null and deletetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update LabProfiles set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update LabProfilesAnalysis set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update RiskCodes set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update RiskExaminations set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update Servers set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update Workplaces set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update WorkplaceRisks set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update EnterpriseVisits set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update FunctionCategoryRisks set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update FunctionGroupExaminations set updatetime=? where updatetime is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps = occupconnection.prepareStatement("update Transactions set ts=? where ts is null");
            ps.setDate(1,oldDate);
            ps.execute();
            ps.close();
            ps.close();
            correct = true;
        }
        catch (Exception e) {
            correct = false;
            e.printStackTrace();
        }
        
        try {
			occupconnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        try {
			adminconnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        return correct;
    }
}
