package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 12-jan-2007
 * Time: 13:13:02
 * To change this template use Options | File Templates.
 */
public class LabAnalysis {
    private int labId;
    private String labgroup;
    private String labcode;
    private String labtype;
    private String monster;
    private String biomonitoring;
    private String medidoccode;
    private String comment;
    private int updateuserid;
    private Timestamp updatetime;
    private Timestamp deletetime;
    private String labcodeother;
    private String alertvalue;
    private String limitvalue;
    private String shorttimevalue;
    private String unit;
    private String editor;
    private String editorparameters;
    private int unavailable;
    private int limitedVisibility;
    private String prestationcode;
    private String procedureUid;
    private LabProcedure procedure;
    private int historydays;
    private int historyvalues;

    public int getHistorydays() {
		return historydays;
	}

	public void setHistorydays(int historydays) {
		this.historydays = historydays;
	}

	public int getHistoryvalues() {
		return historyvalues;
	}

	public void setHistoryvalues(int historyvalues) {
		this.historyvalues = historyvalues;
	}

	public void setProcedure(LabProcedure procedure) {
		this.procedure = procedure;
	}

	public String getProcedureUid() {
		return procedureUid;
	}

	public void setProcedureUid(String procedureUid) {
		this.procedureUid = procedureUid;
	}
	
	public LabProcedure getProcedure(){
		if(procedure==null && procedureUid!=null){
			procedure = LabProcedure.get(procedureUid);
		}
		return procedure;
	}

	public String getPrestationcode() {
		return prestationcode;
	}

	public void setPrestationcode(String prestationcode) {
		this.prestationcode = prestationcode;
	}

	public int getLimitedVisibility() {
		return limitedVisibility;
	}

	public void setLimitedVisibility(int limitedVisibility) {
		this.limitedVisibility = limitedVisibility;
	}

	public String getEditor() {
		return editor;
	}

	public void setEditor(String editor) {
		this.editor = editor;
	}

	public String getEditorparameters() {
		return editorparameters;
	}

	public String getEditorparametersParameter(String parameter) {
  	  	String[] pars=editorparameters.split(";");
  	  	for(int n=0;n<pars.length;n++){
  	  	  	if(pars[n].split(":").length>1 && pars[n].split(":")[0].equals(parameter)){
  	  	  	  	return pars[n].split(":")[1];
  	  	  	}
  	  	}
  	  	return "";
	}

	public void setEditorparameters(String editorparameters) {
		this.editorparameters = editorparameters;
	}

	public int getUnavailable() {
        return unavailable;
    }

    public void setUnavailable(int unavailable) {
        this.unavailable = unavailable;
    }

    public String getAlertvalue() {
        return alertvalue;
    }

    public void setAlertvalue(String alertvalue) {
        this.alertvalue = alertvalue;
    }

    public int getLabId() {
        return labId;
    }

    public void setLabId(int labId) {
        this.labId = labId;
    }

    public String getLabcode() {
        return labcode;
    }

    public void setLabcode(String labcode) {
        this.labcode = labcode;
    }

    public String getLabtype() {
        return labtype;
    }

    public void setLabtype(String labtype) {
        this.labtype = labtype;
    }

    public String getMonster() {
        return monster;
    }

    public void setMonster(String monster) {
        this.monster = monster;
    }

    public String getBiomonitoring() {
        return biomonitoring;
    }

    public void setBiomonitoring(String biomonitoring) {
        this.biomonitoring = biomonitoring;
    }

    public String getMedidoccode() {
        return medidoccode;
    }

    public void setMedidoccode(String medidoccode) {
        this.medidoccode = medidoccode;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getDeletetime() {
        return deletetime;
    }

    public void setDeletetime(Timestamp deletetime) {
        this.deletetime = deletetime;
    }

    public String getLabcodeother() {
        return labcodeother;
    }

    public void setLabcodeother(String labcodeother) {
        this.labcodeother = labcodeother;
    }

    public String getLimitvalue() {
        return limitvalue;
    }

    public void setLimitvalue(String limitvalue) {
        this.limitvalue = limitvalue;
    }

    public String getShorttimevalue() {
        return shorttimevalue;
    }

    public void setShorttimevalue(String shorttimevalue) {
        this.shorttimevalue = shorttimevalue;
    }


    public String getLabgroup() {
        return labgroup;
    }

    public void setLabgroup(String labgroup) {
        this.labgroup = labgroup;
    }


    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public static Vector blurSelectLabAnalysis(String lowerCode,String sSearchCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        LabAnalysis objLA;

        String sSelect = " SELECT distinct la.labID,la.labtype,la.labcode,la.labcodeother,unavailable,limitedvisibility"+
                         " FROM LabAnalysis la, OC_LABELS l"+
                         " WHERE l.OC_LABEL_TYPE = 'labanalysis'"+
                         " AND "+ MedwanQuery.getInstance().convert("varchar(255)","la.labID")+" = l.OC_LABEL_ID"+
                         " AND "+lowerCode+" = ? and deletetime is null";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sSearchCode);
            rs = ps.executeQuery();

            while(rs.next()){
                objLA = new LabAnalysis();
                objLA.setLabId(rs.getInt("labID"));
                objLA.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLA.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLA.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLA.setUnavailable(rs.getInt("unavailable"));
                objLA.setLimitedVisibility(rs.getInt("limitedvisibility"));

                vResults.addElement(objLA);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vResults;
    }

    public static Hashtable getAllLabanalyses(){
        Hashtable hLabAnalysis=new Hashtable();
    	PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect="select * from Labanalysis where deletetime is null";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            LabAnalysis objLabAnalysis;
            String sName;

            while(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLabAnalysis.setLabgroup(ScreenHelper.checkString(rs.getString("labgroup")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setMedidoccode(ScreenHelper.checkString(rs.getString("medidoccode")));
                objLabAnalysis.setMonster(ScreenHelper.checkString(rs.getString("monster")));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));

                hLabAnalysis.put(objLabAnalysis.getLabcode(),objLabAnalysis);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hLabAnalysis;
    }
    
    public static Vector searchByLabCode(String sSearchCode, String sSortColumn, String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector hLabAnalysis = new Vector();

        String sLowerCode = ScreenHelper.getConfigParam("lowerCompare","labcode");

        String sSelect = "SELECT a.historydays,a.historyvalues,a.unavailable,limitedvisibility,a.labID, a.labtype, a.labcode, a.labcodeother, OC_LABEL_VALUE AS name,a.editor,a.editorparameters,a.medidoccode,a.prestationcode,a.procedureuid" +
                " FROM LabAnalysis a, OC_LABELS l" +
                " WHERE a.deletetime IS NULL" +
                "  AND l.OC_LABEL_TYPE = 'labanalysis'" +
                "  AND l.OC_LABEL_LANGUAGE = ?" +
                "  AND "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = l.OC_LABEL_ID" +
                "  AND " + sLowerCode + " LIKE ?" +
                "  AND deletetime IS NULL" +
                " ORDER BY " + sSortColumn;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sWebLanguage.toLowerCase());
            ps.setString(2,sSearchCode.toLowerCase()+"%");
            rs = ps.executeQuery();

            LabAnalysis objLabAnalysis;
            String sName;

            while(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setMedidoccode(ScreenHelper.checkString(rs.getString("medidoccode")));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));

                hLabAnalysis.add(objLabAnalysis);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hLabAnalysis;
    }

    public static Hashtable searchByLabLabel(String sFindText, String sSortCol, String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String lowerLabel = ScreenHelper.checkString(ScreenHelper.getConfigParam("lowerCompare", "OC_LABEL_VALUE"));

        Hashtable hLabAnalysis = new Hashtable();

        String sSelect = " SELECT a.historydays,a.historyvalues,a.unavailable,limitedvisibility,a.labID, a.labtype, a.labcode, a.labcodeother, OC_LABEL_VALUE AS name,a.editor,a.editorparameters,a.prestationcode,a.procedureuid" +
                         " FROM LabAnalysis a, OC_LABELS l" +
                         " WHERE a.deletetime IS NULL" +
                         "  AND l.OC_LABEL_TYPE = 'labanalysis'" +
                         "  AND l.OC_LABEL_LANGUAGE = ?" +
                         "  AND "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = l.OC_LABEL_ID" +
                         "  AND " + lowerLabel + " LIKE ?" +
                         "  AND deletetime IS NULL" +
                         " ORDER BY " + sSortCol;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sWebLanguage.toLowerCase());
            ps.setString(2, "%" + sFindText.toLowerCase() + "%");
            rs = ps.executeQuery();

            LabAnalysis objLabAnalysis;
            String sName;

            while (rs.next()) {
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));
                sName = ScreenHelper.checkString(rs.getString("name"));
                hLabAnalysis.put(sName,objLabAnalysis);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hLabAnalysis;
    }

    public static Vector searchByLabCodeForPatient(String sSearchProfileID, String sSelectedLabCodes, String sSearchCode, String sSortCol, String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        StringBuffer sQuery = new StringBuffer();

        String lowerLabCode    = ScreenHelper.getConfigParam("lowerCompare","a.labcode"),
               lowerLabelValue = ScreenHelper.getConfigParam("lowerCompare","l.OC_LABEL_VALUE"),
               lowerLabelType  = ScreenHelper.getConfigParam("lowerCompare","l.OC_LABEL_TYPE");

        if(sSearchProfileID.equals("")){
            sQuery.append("SELECT a.historydays,a.historyvalues,a.unavailable,limitedvisibility,a.labID,a.labtype AS type,a.labcode AS code,OC_LABEL_VALUE AS name,");
            sQuery.append(" a.labcodeother,'' AS comment,a.monster,a.editor,a.editorparameters,a.medidoccode,a.prestationcode,a.procedureuid");
            sQuery.append(" FROM LabAnalysis a, OC_LABELS l ");

            // leave out allready selected labAnalyses
            if(sSelectedLabCodes.length() > 0){
                sQuery.append("WHERE a.labcode NOT IN('").append(sSelectedLabCodes).append("')")
                      .append(" AND "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = l.OC_LABEL_ID ");
            }
            else{
                sQuery.append("WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = l.OC_LABEL_ID ");
            }

            // search on code ?
            if(sSearchCode.length() > 0){
                sQuery.append("AND ("+lowerLabCode+" LIKE '%"  + ScreenHelper.checkDbString(sSearchCode).toLowerCase()+"%'")
                      .append("OR "+lowerLabelValue+" LIKE '%" + ScreenHelper.checkDbString(sSearchCode).toLowerCase()+"%'" +
                              " OR a.medidoccode = '" + ScreenHelper.checkDbString(sSearchCode).toLowerCase()+"')");
            }

            sQuery.append("  AND a.deletetime IS NULL")
                  .append("  AND l.OC_LABEL_TYPE = 'labanalysis'")
                  .append("  AND l.OC_LABEL_LANGUAGE = ?")
                  .append(" ORDER BY ")
                  .append(sSortCol);

        }
        else{
            sQuery.append("SELECT DISTINCT(a.labID),a.historydays,a.historyvalues,a.unavailable,limitedvisibility,a.medidoccode,,a.editor,a.editorparameters,a.labtype AS type,a.labcode AS code,OC_LABEL_VALUE AS name,")
                  .append(" a.labcodeother,lpa.comment AS comment,a.monster,a.prestationcode,a.procedureuid")
                  .append(" FROM LabAnalysis a, OC_LABELS l, LabProfilesAnalysis lpa ");

            // leave out allready selected labAnalyses
            if(sSelectedLabCodes.length() > 0){
                sQuery.append("WHERE a.labcode NOT IN('").append(sSelectedLabCodes).append("')")
                      .append(" AND lpa.labID = a.labID ");
            }
            else{
                sQuery.append("WHERE lpa.labID = a.labID ");
            }

            sQuery.append("AND "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = l.OC_LABEL_ID ");

            // search on code ?
            if(sSearchCode.length() > 0){
                sQuery.append("AND ("+lowerLabCode+" LIKE '"  + ScreenHelper.checkDbString(sSearchCode).toLowerCase()+"%'")
                      .append("OR "+lowerLabelValue+" LIKE '" + ScreenHelper.checkDbString(sSearchCode).toLowerCase()+"%'")
                      .append(")");
            }

            sQuery.append("  AND a.deletetime IS NULL")
                  .append("  AND "+lowerLabelType+" = 'labanalysis'")
                  .append("  AND l.OC_LABEL_LANGUAGE = ?")
                  .append("  AND lpa.profileID = '").append(ScreenHelper.checkDbString(sSearchProfileID)).append("'")
                  .append(" ORDER BY ").append(sSortCol);
        }


        Vector hLabAnalysis = new Vector();

        Connection loc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery.toString());
            ps.setString(1,sWebLanguage.toLowerCase());
            rs = ps.executeQuery();

            LabAnalysis objLabAnalysis;
            String sName;

            while(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("type")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("code")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setComment(ScreenHelper.checkString(rs.getString("comment")));
                objLabAnalysis.setMonster(ScreenHelper.checkString(rs.getString("monster")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setMedidoccode(ScreenHelper.checkString(rs.getString("medidoccode")));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));

                hLabAnalysis.add(objLabAnalysis);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hLabAnalysis;
    }

    public String getResultRefMax(String gender, double age){
        String ref = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3, LabAnalysis.idForCode(getLabcode()));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                ref=rs.getString("tolerance");
                if(ref==null){
                    ref="";
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        return ref;
    }

    public String getResultRefMin(String gender, int age){
        String ref = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3,LabAnalysis.idForCode(getLabcode()));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                ref=rs.getString("frequency");
                if(ref==null){
                    ref="";
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return ref;
    }

    public static Vector searchByProfileIdForPatient(String sSearchProfileID,String sSelectedLabCodes, String sSortCol, String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        StringBuffer sQuery = new StringBuffer();

        Vector hLabAnalysis = new Vector();

        String lowerLabelType = ScreenHelper.getConfigParam("lowerCompare", "l.OC_LABEL_TYPE");

        sQuery.append("SELECT a.historydays,a.historyvalues,a.unavailable,limitedvisibility,a.labID,a.labtype AS type,a.labcode AS code,OC_LABEL_VALUE AS name,")
                .append("  a.labcodeother,lpa.comment AS comment,a.monster,a.editor,a.editorparameters,a.prestationcode,a.procedureuid")
                .append(" FROM LabAnalysis a, OC_LABELS l, LabProfilesAnalysis lpa");

        // leave out allready selected labAnalyses
        if (sSelectedLabCodes.length() > 0) {
            sQuery.append(" WHERE a.labcode NOT IN('").append(sSelectedLabCodes).append("')")
                    .append("  AND lpa.labID = a.labID");
        } else {
            sQuery.append(" WHERE lpa.labID = a.labID");
        }

        sQuery.append("  AND "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = l.OC_LABEL_ID")
                .append("  AND lpa.profileID = ?")
                .append("  AND a.deletetime IS NULL")
                .append("  AND " + lowerLabelType + " = 'labanalysis'")
                .append("  AND OC_LABEL_LANGUAGE = ?")
                .append(" ORDER BY ").append(sSortCol);
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery.toString());
            ps.setInt(1, Integer.parseInt(sSearchProfileID));
            ps.setString(2, sWebLanguage.toLowerCase());
            rs = ps.executeQuery();
            System.out.println(sQuery);

            LabAnalysis objLabAnalysis;
            String sName;

            while(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("type")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("code")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setComment(ScreenHelper.checkString(rs.getString("comment")));
                objLabAnalysis.setMonster(ScreenHelper.checkString(rs.getString("monster")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));
                sName  = ScreenHelper.checkString(rs.getString("name"));

                hLabAnalysis.add(objLabAnalysis);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hLabAnalysis;
    }

    public static boolean[]  isDeletedByLabCode(String labCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        int deletedRecordFound = 0;
        int unDeletedRecordFound = 1;
        boolean records[] = new boolean[2];
        records[deletedRecordFound] = false;
        records[unDeletedRecordFound] = false;

        String sSelect = "SELECT deletetime FROM LabAnalysis WHERE labcode = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, labCode);
            rs = ps.executeQuery();

            while (rs.next()) {
                if (rs.getDate("deletetime") != null) records[deletedRecordFound] = true;
                else records[unDeletedRecordFound] = true;
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return records;
    }

    public static boolean[] isDeletedByLabID(String labID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        int deletedRecordFound = 0;
        int unDeletedRecordFound = 1;
        boolean records[] = new boolean[2];
        records[deletedRecordFound] = false;
        records[unDeletedRecordFound] = false;

        String sSelect = "SELECT deletetime FROM LabAnalysis WHERE labID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, labID);
            rs = ps.executeQuery();

            while (rs.next()) {
                if (rs.getDate("deletetime") != null) records[deletedRecordFound] = true;
                else records[unDeletedRecordFound] = true;
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return records;
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = " INSERT INTO LabAnalysis(labID,labcode,labtype,monster,biomonitoring," +
                         "  medidoccode,labgroup,comment,updateuserid,updatetime,deletetime,labcodeother," +
                         "  limitvalue,shorttimevalue,unit,alertvalue,unavailable,editor,editorparameters,limitedvisibility,prestationcode,procedureuid,historydays,historyvalues)" +
                         " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);

            ps.setInt(1, this.getLabId());
            ps.setString(2, this.getLabcode());
            ps.setString(3, this.getLabtype());
            ps.setString(4, this.getMonster());
            ps.setString(5, this.getBiomonitoring());
            ps.setString(6, this.getMedidoccode());
            ps.setString(7, this.getLabgroup());
            ps.setString(8, ScreenHelper.setSQLString(this.getComment()));
            ps.setInt(9, this.getUpdateuserid()); // updateuserid
            ps.setTimestamp(10, ScreenHelper.getSQLTime());
            ps.setTimestamp(11, null);
            ps.setString(12, this.getLabcodeother());
            ps.setString(13, this.getLimitvalue());
            ps.setString(14, this.getShorttimevalue());
            ps.setString(15, this.getUnit());
            ps.setString(16, this.getAlertvalue());
            ps.setInt(17,this.getUnavailable());
            ps.setString(18, this.getEditor());
            ps.setString(19, this.getEditorparameters());
            ps.setInt(20, this.getLimitedVisibility());
            ps.setString(21, this.getPrestationcode());
            ps.setString(22, this.getProcedureUid());
            ps.setInt(23,this.getHistorydays());
            ps.setInt(24,this.getHistoryvalues());
            
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public void update(){
        PreparedStatement ps = null;

        String sUpdate =" UPDATE LabAnalysis SET" +
                        "  labID=?, labcode=?, labtype=?, monster=?, biomonitoring=?, medidoccode=?," +
                        "  labgroup=?, comment=?, updateuserid=?, updatetime=?, deletetime=?, labcodeother=?," +
                        "  limitvalue=?, shorttimevalue=?, unit=?, alertvalue=?, unavailable=?,editor=?,editorparameters=?,limitedvisibility=?,prestationcode=?,procedureuid=?,historydays=?,historyvalues=?" +
                        " WHERE labID = ?  and deletetime is null";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);

            ps.setInt(1, this.getLabId());
            ps.setString(2, this.getLabcode());
            ps.setString(3, this.getLabtype());
            ps.setString(4, this.getMonster());
            ps.setString(5, this.getBiomonitoring());
            ps.setString(6, this.getMedidoccode());
            ps.setString(7, this.getLabgroup());
            ps.setString(8, ScreenHelper.setSQLString(this.getComment()));
            ps.setInt(9, this.getUpdateuserid()); // updateuserid
            ps.setTimestamp(10, ScreenHelper.getSQLTime());
            ps.setTimestamp(11, null);
            ps.setString(12, this.getLabcodeother());
            ps.setString(13, this.getLimitvalue());
            ps.setString(14, this.getShorttimevalue());
            ps.setString(15, this.getUnit());
            ps.setString(16, this.getAlertvalue());
            ps.setInt(17,this.getUnavailable());
            ps.setString(18, this.getEditor());
            ps.setString(19, this.getEditorparameters());
            ps.setInt(20, this.getLimitedVisibility());
            ps.setString(21, this.getPrestationcode());
            ps.setString(22, this.getProcedureUid());
            ps.setInt(23,this.getHistorydays());
            ps.setInt(24,this.getHistoryvalues());
            ps.setInt(25,this.getLabId());
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public void delete(){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE LabAnalysis SET deletetime = ?,updatetime = ? WHERE labID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1, ScreenHelper.getSQLTime());
            ps.setTimestamp(2, ScreenHelper.getSQLTime());
            ps.setInt(3, this.getLabId());
            ps.executeUpdate();

            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Vector searchLabAnalyses(String sLabLabelType, String sFindLabCode, String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vAnalyses = new Vector();

        String lowerLabCode   = MedwanQuery.getInstance().getConfigParam("lowerCompare","labcode"),
               lowerLabelType = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE");

        String sSelect = "SELECT historydays,historyvalues,unavailable,limitedvisibility,labID,labtype,labcode,monster,biomonitoring,medidoccode,labcodeother,labgroup,editor,editorparameters,prestationcode,procedureuid"+
                  " FROM LabAnalysis a, OC_LABELS b"+
                  " WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+" = b.OC_LABEL_ID"+
                  "  AND "+lowerLabelType+" = '"+sLabLabelType+"'"+
                  "  AND OC_LABEL_LANGUAGE = ?"+
                  "  AND (OC_LABEL_VALUE LIKE ? OR "+lowerLabCode+" LIKE ?) "+
                  "  AND deletetime IS NULL"+
                  " ORDER BY "+lowerLabCode;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sWebLanguage);
            ps.setString(2,"%"+sFindLabCode+"%");
            ps.setString(3,"%"+sFindLabCode+"%");
            rs = ps.executeQuery();

            LabAnalysis objLabAnalysis;

            while(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLabAnalysis.setMonster(ScreenHelper.checkString(rs.getString("monster")));
                objLabAnalysis.setBiomonitoring(ScreenHelper.checkString(rs.getString("biomonitoring")));
                objLabAnalysis.setMedidoccode(ScreenHelper.checkDbString(rs.getString("medidoccode")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setLabgroup(ScreenHelper.checkString(rs.getString("labgroup")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));

                vAnalyses.addElement(objLabAnalysis);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vAnalyses;
    }

    public static boolean labcodeExists(String sLabelType, String sLabelId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bExists = false;

        String sSelect = "SELECT 1 FROM Labels WHERE labeltype = ? AND labelid = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sLabelType);
            ps.setString(1,sLabelId);

            rs = ps.executeQuery();
            if(rs.next()){
                bExists = true;
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return bExists;
    }

    public static LabAnalysis getLabAnalysisByLabID(String sLabID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = " SELECT * FROM LabAnalysis WHERE labID = ? and deletetime is null";

        LabAnalysis objLabAnalysis = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sLabID);

            rs = ps.executeQuery();

            if(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLabAnalysis.setMonster(ScreenHelper.checkString(rs.getString("monster")));
                objLabAnalysis.setBiomonitoring(ScreenHelper.checkString(rs.getString("biomonitoring")));
                objLabAnalysis.setMedidoccode(ScreenHelper.checkDbString(rs.getString("medidoccode")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setLabgroup(ScreenHelper.checkString(rs.getString("labgroup")));
                objLabAnalysis.setComment(ScreenHelper.checkString(rs.getString("comment")));
                objLabAnalysis.setAlertvalue(ScreenHelper.checkString(rs.getString("alertvalue")));
                objLabAnalysis.setLimitvalue(ScreenHelper.checkString(rs.getString("limitvalue")));
                objLabAnalysis.setShorttimevalue(ScreenHelper.checkString(rs.getString("shorttimevalue")));
                objLabAnalysis.setUnit(ScreenHelper.checkString(rs.getString("unit")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return objLabAnalysis;
    }

    public static LabAnalysis getLabAnalysisByLabcode(String sLabcode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = " SELECT * FROM LabAnalysis WHERE labcode = ? and deletetime is null";

        LabAnalysis objLabAnalysis = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sLabcode);

            rs = ps.executeQuery();

            if(rs.next()){
                objLabAnalysis = new LabAnalysis();
                objLabAnalysis.setLabId(rs.getInt("labID"));
                objLabAnalysis.setLabtype(ScreenHelper.checkString(rs.getString("labtype")));
                objLabAnalysis.setLabcode(ScreenHelper.checkString(rs.getString("labcode")));
                objLabAnalysis.setMonster(ScreenHelper.checkString(rs.getString("monster")));
                objLabAnalysis.setBiomonitoring(ScreenHelper.checkString(rs.getString("biomonitoring")));
                objLabAnalysis.setMedidoccode(ScreenHelper.checkDbString(rs.getString("medidoccode")));
                objLabAnalysis.setLabcodeother(ScreenHelper.checkString(rs.getString("labcodeother")));
                objLabAnalysis.setLabgroup(ScreenHelper.checkString(rs.getString("labgroup")));
                objLabAnalysis.setComment(ScreenHelper.checkString(rs.getString("comment")));
                objLabAnalysis.setAlertvalue(ScreenHelper.checkString(rs.getString("alertvalue")));
                objLabAnalysis.setLimitvalue(ScreenHelper.checkString(rs.getString("limitvalue")));
                objLabAnalysis.setShorttimevalue(ScreenHelper.checkString(rs.getString("shorttimevalue")));
                objLabAnalysis.setUnit(ScreenHelper.checkString(rs.getString("unit")));
                objLabAnalysis.setUnavailable(rs.getInt("unavailable"));
                objLabAnalysis.setLimitedVisibility(rs.getInt("limitedvisibility"));
                objLabAnalysis.setEditor(ScreenHelper.checkString(rs.getString("editor")));
                objLabAnalysis.setEditorparameters(ScreenHelper.checkString(rs.getString("editorparameters")));
                objLabAnalysis.setPrestationcode(ScreenHelper.checkString(rs.getString("prestationcode")));
                objLabAnalysis.setProcedureUid(ScreenHelper.checkString(rs.getString("procedureuid")));
                objLabAnalysis.setHistorydays(rs.getInt("historydays"));
                objLabAnalysis.setHistoryvalues(rs.getInt("historyvalues"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return objLabAnalysis;
    }

    public static String labelForCode(String code,String language){
        String label="";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select labid from labanalysis where labcode=? and deletetime is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,code);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                label=MedwanQuery.getInstance().getLabel("labanalysis",rs.getString("labid"),language);
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return label;
    }
    public static String idForCode(String code){
        String label=code;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select labid from labanalysis where labcode=? and deletetime is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,code);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                label=rs.getString("labid");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return label;
    }
}
