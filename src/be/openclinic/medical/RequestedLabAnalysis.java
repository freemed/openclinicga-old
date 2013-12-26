package be.openclinic.medical;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.system.Config;


import java.sql.*;
import java.sql.Date;
import java.util.*;
import java.text.DecimalFormat;

public class RequestedLabAnalysis {

    // variables
    private String serverId, transactionId, patientId, analysisCode, comment,
                   resultValue, resultUnit, resultModifier, resultComment,
                   resultRefMax, resultRefMin, resultUserId, requestUserId, resultProvisional,labgroup;
    private java.util.Date resultDate,requestDate;
    private int technicalvalidation;
    private java.util.Date technicalvalidationdatetime;
    private int finalvalidation;
    private java.util.Date finalvalidationdatetime;
    private java.util.Date sampletakendatetime;
    private java.util.Date samplereceptiondatetime;
    private java.util.Date worklisteddatetime;
    private int sampler;


    public java.util.Date getWorklisteddatetime() {
        return worklisteddatetime;
    }

    public void setWorklisteddatetime(java.util.Date worklisteddatetime) {
        this.worklisteddatetime = worklisteddatetime;
    }

    public java.util.Date getSampletakendatetime() {
        return sampletakendatetime;
    }

    public void setSampletakendatetime(java.util.Date sampletakendatetime) {
        this.sampletakendatetime = sampletakendatetime;
    }

    public java.util.Date getSamplereceptiondatetime() {
        return samplereceptiondatetime;
    }

    public void setSamplereceptiondatetime(java.util.Date samplereceptiondatetime) {
        this.samplereceptiondatetime = samplereceptiondatetime;
    }

    public int getSampler() {
        return sampler;
    }

    public void setSampler(int sampler) {
        this.sampler = sampler;
    }

    public String getLabgroup() {
        return labgroup==null?"":labgroup;
    }

    public void setLabgroup(String labgroup) {
        this.labgroup = labgroup;
    }

    public int getTechnicalvalidation() {
        return technicalvalidation;
    }

    public void setTechnicalvalidation(int technicalvalidation) {
        this.technicalvalidation = technicalvalidation;
    }

    public java.util.Date getTechnicalvalidationdatetime() {
        return technicalvalidationdatetime;
    }

    public void setTechnicalvalidationdatetime(java.util.Date technicalvalidationdatetime) {
        this.technicalvalidationdatetime = technicalvalidationdatetime;
    }

    public int getFinalvalidation() {
        return finalvalidation;
    }

    public void setFinalvalidation(int finalvalidation) {
        this.finalvalidation = finalvalidation;
    }

    public java.util.Date getFinalvalidationdatetime() {
        return finalvalidationdatetime;
    }

    public void setFinalvalidationdatetime(java.util.Date finalvalidationdatetime) {
        this.finalvalidationdatetime = finalvalidationdatetime;
        
    }//--- CONSTRUCTOR 1 ---------------------------------------------------------------------------
    public RequestedLabAnalysis(){
        serverId      = "";
        transactionId = "";
        patientId     = "";
        analysisCode  = "";
        comment       = "";

        // result..
        resultValue    = "";
        resultUnit     = "";
        resultModifier = "";
        resultComment  = "";
        resultRefMax   = "";
        resultRefMin   = "";
        resultUserId   = "";
        requestUserId  = "";
        resultDate     = new java.util.Date();
        resultProvisional    = "";
    }

    //--- CONSTRUCTOR 2 ---------------------------------------------------------------------------
    public RequestedLabAnalysis(String serverId, String transactionId, String patientId, String analysisCode,
                                String comment, String resultValue, String resultUnit, String resultModifier,
                                String resultComment, String resultRefMax, String resultRefMin,
                                String resultUserId, java.util.Date resultDate, String resultProvisional){
        // lab analysis..
        this.serverId      = serverId;
        this.transactionId = transactionId;
        this.patientId     = patientId;
        this.analysisCode  = analysisCode;
        this.comment       = comment;

        // lab result..
        this.resultValue    = resultValue;
        this.resultUnit     = resultUnit;
        this.resultModifier = resultModifier;
        this.resultComment  = resultComment;
        this.resultRefMax   = resultRefMax;
        this.resultRefMin   = resultRefMin;
        this.resultUserId   = resultUserId;
        this.resultDate     = resultDate;
        this.resultProvisional = resultProvisional;
    }

    //--- CONSTRUCTOR 3 ---Includes: finalvalidationdatetime -------------------------------------------
    public RequestedLabAnalysis(String serverId, String transactionId, String patientId, String analysisCode,
                                String comment, String resultValue, String resultUnit, String resultModifier,
                                String resultComment, String resultRefMax, String resultRefMin,
                                String resultUserId, java.util.Date resultDate, String resultProvisional,java.util.Date finalvalidationdatetime){
        // lab analysis..
        this.serverId      = serverId;
        this.transactionId = transactionId;
        this.patientId     = patientId;
        this.analysisCode  = analysisCode;
        this.comment       = comment;

        // lab result..
        this.resultValue    = resultValue;
        this.resultUnit     = resultUnit;
        this.resultModifier = resultModifier;
        this.resultComment  = resultComment;
        this.resultRefMax   = resultRefMax;
        this.resultRefMin   = resultRefMin;
        this.resultUserId   = resultUserId;
        this.resultDate     = resultDate;
        this.resultProvisional = resultProvisional;
        this.finalvalidationdatetime = finalvalidationdatetime;
    }

    public java.util.Date getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }

    public String getRequestUserId() {
        return requestUserId;
    }

    public void setRequestUserId(String requestUserId) {
        this.requestUserId = requestUserId;
    }//--- SERVER ID -------------------------------------------------------------------------------
    public void setServerId(String value){
        this.serverId = value;
    }

    public String getServerId(){
        return this.serverId;
    }

    //--- TRANSACTION ID --------------------------------------------------------------------------
    public void setTransactionId(String value){
        this.transactionId = value;
    }

    public String getTransactionId(){
        return this.transactionId;
    }

    //--- PATIENT ID ------------------------------------------------------------------------------
    public void setPatientId(String value){
        this.patientId = value;
    }

    public String getPatientId(){
        return this.patientId;
    }

    //--- ANALYSIS CODE ---------------------------------------------------------------------------
    public void setAnalysisCode(String value){
        this.analysisCode = value;
    }

    public String getAnalysisCode(){
        return this.analysisCode;
    }

    //--- COMMENT ---------------------------------------------------------------------------------
    public void setComment(String value){
        this.comment = value;
    }

    public String getComment(){
        return this.comment;
    }

    //--- RESULT VALUE ----------------------------------------------------------------------------
    public void setResultValue(String value){
        this.resultValue = value;
    }

    public String getResultValue(){
        return this.resultValue;
    }

    //--- RESULT UNIT -----------------------------------------------------------------------------
    public void setResultUnit(String value){
        this.resultUnit = value;
    }

    public String getResultUnit(){
        return RequestedLabAnalysis.getAnalysisUnit(this.analysisCode);
    }

    //--- RESULT MODIFIER -------------------------------------------------------------------------
    public void setResultModifier(String value){
        this.resultModifier = value;
    }

    public String getResultModifier(){
        return this.resultModifier;
    }

    //--- RESULT PROVISIONAK -------------------------------------------------------------------------
    public void setResultProvisional(String value){
        this.resultProvisional = value;
    }

    public String getResultProvisional(){
        return this.resultProvisional;
    }

    //--- RESULT COMMENT --------------------------------------------------------------------------
    public void setResultComment(String value){
        this.resultComment = value;
    }

    public String getResultComment(){
        return this.resultComment;
    }

    public String getResultRefMax() {
        if((patientId!=null)&&((resultRefMax==null || resultRefMax.length()==0))){
            //Find age and gender of person
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                PreparedStatement ps=ad_conn.prepareStatement("select dateofbirth,gender from Admin where personid=?");
                ps.setInt(1,Integer.parseInt(patientId));
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    setResultRefMax(getResultRefMax(rs.getString("gender"),new Double(MedwanQuery.getInstance().getNrYears(rs.getDate("dateofbirth"), new java.util.Date())).intValue()));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
            try {
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

        }
        return resultRefMax;
    }

    public void setResultRefMax(String resultRefMax) {
        try{
            this.resultRefMax = new DecimalFormat("#.#####").format(Double.parseDouble(resultRefMax));
        }
        catch (Exception e){

        }
    }

    public String getResultRefMin() {
        if((patientId!=null)&&((resultRefMin==null || resultRefMin.length()==0))){
            //Find age and gender of person
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                PreparedStatement ps=ad_conn.prepareStatement("select dateofbirth,gender from Admin where personid=?");
                ps.setInt(1,Integer.parseInt(patientId));
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    setResultRefMin(getResultRefMin(rs.getString("gender"),new Double(MedwanQuery.getInstance().getNrYears(rs.getDate("dateofbirth"), new java.util.Date())).intValue()));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
            try {
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
        return resultRefMin;
    }

    public void setResultRefMin(String resultRefMin) {
        this.resultRefMin="";
        try{
            this.resultRefMin = new DecimalFormat("#.#####").format(Double.parseDouble(resultRefMin));
        }
        catch(Exception e){

        }
    }

    public String getResultRefMax(String gender, double age){
        String ref = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3, LabAnalysis.idForCode(getAnalysisCode()));
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

    //--- RESULT REF MIN --------------------------------------------------------------------------
    public String getResultRefMin(String gender, int age){
        String ref = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3,LabAnalysis.idForCode(getAnalysisCode()));
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

   //--- RESULT USER ID --------------------------------------------------------------------------
    public void setResultUserId(String value){
        this.resultUserId = value;
    }

    public String getResultUserId(){
        return this.resultUserId;
    }

    //--- RESULT DATE -----------------------------------------------------------------------------
    public void setResultDate(java.util.Date value){
        this.resultDate = value;
    }

    public java.util.Date getResultDate(){
        return this.resultDate;
    }

    //--- GET LAB ANALYSIS TYPE -------------------------------------------------------------------
    public static String getAnalysisType(String analysisCode, String sWebLanguage){
        String type = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT labtype FROM LabAnalysis WHERE labcode = ? and deletetime is null";
            ps = oc_conn.prepareStatement(select);
            ps.setString(1,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                type = ScreenHelper.checkString(rs.getString("labtype"));

                // translate labtype
                     if(type.equals("1")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.blood",sWebLanguage);
                else if(type.equals("2")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.urine",sWebLanguage);
                else if(type.equals("3")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.other",sWebLanguage);
                else if(type.equals("4")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.stool",sWebLanguage);
                else if(type.equals("5")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.sputum",sWebLanguage);
                else if(type.equals("6")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.smear",sWebLanguage);
                else if(type.equals("7")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.liquid",sWebLanguage);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return type;
    }

    //--- GET LAB ANALYSIS TYPE -------------------------------------------------------------------
    public static String getAnalysisUnit(String analysisCode){
        String unit = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT unit FROM LabAnalysis WHERE labcode = ? and deletetime is null";
            ps = oc_conn.prepareStatement(select);
            ps.setString(1,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                unit = ScreenHelper.checkString(rs.getString("unit"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return unit;
    }

    //--- GET LAB ANALYSIS MONSTER ----------------------------------------------------------------
    public static String getAnalysisMonster(String analysisCode){
        String type = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT monster FROM LabAnalysis WHERE labcode = ? and deletetime is null";
            ps = oc_conn.prepareStatement(select);
            ps.setString(1,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                type = ScreenHelper.checkString(rs.getString("monster"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return type;
    }

    //--- GET LABANALYSES FOR REQUEST -------------------------------------------------------------
    public static Hashtable getLabAnalysesForLabRequest(int serverId, int transactionId){
        Hashtable labAnalyses = new Hashtable();
        RequestedLabAnalysis labAnalysis;

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime FROM RequestedLabAnalyses a,Transactions b where a.serverid=b.serverid and a.transactionId=b.transactionId "+
                             " and a.serverid = ? AND a.transactionid = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                labAnalysis = new RequestedLabAnalysis();
                labAnalysis.setServerId(serverId+"");
                labAnalysis.setTransactionId(transactionId+"");

                labAnalysis.patientId    = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.analysisCode = ScreenHelper.checkString(rs.getString("analysiscode"));
                labAnalysis.comment      = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId  = ScreenHelper.checkString(rs.getString("userId"));
                labAnalysis.resultProvisional    = ScreenHelper.checkString(rs.getString("resultprovisional"));
                labAnalysis.finalvalidation = rs.getInt("finalvalidator");

                // result date
                java.util.Date tmpDate = rs.getDate("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getDate("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;

                labAnalyses.put(labAnalysis.analysisCode,labAnalysis);
            }
        }
        catch(Exception e){

            if(e.getMessage().endsWith("NOT FOUND")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalyses;
    }

    //--- DELETE LABANALYSES IN LABREQUEST --------------------------------------------------------
    public static void deleteLabAnalysesInLabRequest(int serverId, int transactionId){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM RequestedLabAnalyses"+
                             " WHERE serverid = ?"+
                             "  AND transactionid = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- REQUIRED DATA SET -----------------------------------------------------------------------
    public boolean requiredDataSet() throws Exception {
        if(this.serverId.length()==0 || this.transactionId.length()==0 ||
           this.patientId.length()==0 || this.analysisCode.length()==0){
            Debug.println("// INFO ////////////////////////////////////////////////");
            Debug.println("*** sServerId      : "+ScreenHelper.checkString(this.serverId));
            Debug.println("*** sTransactionId : "+ScreenHelper.checkString(this.transactionId));
            Debug.println("*** sPatientId     : "+ScreenHelper.checkString(this.patientId));
            Debug.println("*** sPatientId     : "+ScreenHelper.checkString(this.analysisCode)+"\n");

            throw new Exception("RequestedLabAnalysis : store : not all required data is set");
        }

        return true;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        boolean objectExists = exists(Integer.parseInt(this.getServerId()),
                                      Integer.parseInt(this.getTransactionId()),
                                      this.getAnalysisCode());
        store(objectExists);
    }

    public void store(boolean objectExists){
        PreparedStatement ps = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            requiredDataSet();

            // must be a positive transactionid, indicating the transaction to which this analysis belongs allready exists
            if(Integer.parseInt(this.transactionId) < 0){
                throw new Exception("RequestedLabAnalysis : store : transactionId can not be negative ("+this.transactionId+")");
            }

            if(objectExists){
                //***** UPDATE ********************************************************************
                if(Debug.enabled) Debug.println("@@@ RequestedLabAnalysis update @@@");

                sSelect = "UPDATE RequestedLabAnalyses"+
                          " SET serverid=?, transactionid=?, patientid=?, analysiscode=?, "+
                          "  comment=?, resultvalue=?, resultunit=?, resultmodifier=?, resultcomment=?, "+
                          "  resultrefmax=?, resultrefmin=?, resultdate=?, resultuserid=?, resultprovisional=?";

                ps = oc_conn.prepareStatement(sSelect);

                ps.setInt(1,Integer.parseInt(this.serverId));
                ps.setInt(2,Integer.parseInt(this.transactionId));
                ps.setInt(3,Integer.parseInt(this.patientId));
                ps.setString(4,this.analysisCode);
                ps.setString(5,this.comment);

                // result..
                ps.setString(6,this.resultValue);
                ps.setString(7,this.resultUnit);
                ps.setString(8,this.resultModifier);
                ps.setString(9,this.resultComment);
                ps.setString(10,getResultRefMax());
                ps.setString(11,getResultRefMin());

                // date begin
                if(this.resultDate!=null) ps.setTimestamp(12,new java.sql.Timestamp(this.resultDate.getTime()));
                else                      ps.setNull(12,Types.TIMESTAMP);

                // result userid
                if(this.resultUserId.length() > 0) ps.setInt(13,Integer.parseInt(this.resultUserId));
                else                               ps.setNull(13,Types.INTEGER);

                ps.setString(14,this.resultProvisional==""?"1":"0");
                ps.executeUpdate();
            }
            else{
                //***** INSERT ****************************************************************
                if(Debug.enabled) Debug.println("@@@ RequestedLabAnalysis insert @@@");

                sSelect = "INSERT INTO RequestedLabAnalyses (serverid,transactionid,patientid,analysiscode,"+
                          "  comment,resultvalue,resultunit,resultmodifier,resultcomment,resultrefmax,"+
                          "  resultrefmin,resultdate,resultuserid, resultprovisional,requestdatetime)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);

                ps.setInt(1,Integer.parseInt(this.serverId));
                ps.setInt(2,Integer.parseInt(this.transactionId));
                ps.setInt(3,Integer.parseInt(this.patientId));
                ps.setString(4,this.analysisCode);
                ps.setString(5,this.comment);

                // result..
                ps.setString(6,this.resultValue);
                ps.setString(7,this.resultUnit);
                ps.setString(8,this.resultModifier);
                ps.setString(9,this.resultComment);
                ps.setString(10,getResultRefMax());
                ps.setString(11,getResultRefMin());
                // date begin
                if(this.resultDate!=null) ps.setTimestamp(12,new java.sql.Timestamp(this.resultDate.getTime()));
                else                      ps.setNull(12,Types.TIMESTAMP);

                // result userid
                if(this.resultUserId.length() > 0) ps.setInt(13,Integer.parseInt(this.resultUserId));
                else                               ps.setNull(13,Types.INTEGER);

                ps.setString(14,this.resultProvisional.equalsIgnoreCase("")?"1":"0");
                ps.setTimestamp(15,new Timestamp(new java.util.Date().getTime()));
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- STORE COMMENT (only comment) ------------------------------------------------------------
    public void storeComment(){
        PreparedStatement ps = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "UPDATE RequestedLabAnalyses SET comment = ?"+
                      " WHERE serverid = ?"+
                      "  AND transactionid = ?"+
                      "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);

            ps.setString(1,this.comment);
            ps.setInt(2,Integer.parseInt(this.serverId));
            ps.setInt(3,Integer.parseInt(this.transactionId));
            ps.setString(4,this.analysisCode);

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- GET -------------------------------------------------------------------------------------
    public static RequestedLabAnalysis get(int serverId, int transactionId, String analysisCode){
        // create LabRequest and initialize
        RequestedLabAnalysis labAnalysis = new RequestedLabAnalysis();
        labAnalysis.setServerId(serverId+"");
        labAnalysis.setTransactionId(transactionId+"");
        labAnalysis.setAnalysisCode(analysisCode);

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime FROM RequestedLabAnalyses a,Transactions b where a.serverid=b.serverid and a.transactionid=b.transactionId "+
                             "  AND a.serverid = ?"+
                             "  AND a.transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                labAnalysis.patientId = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.comment   = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId   = ScreenHelper.checkString(rs.getString("userId"));
                labAnalysis.resultProvisional   = ScreenHelper.checkString(rs.getString("resultprovisional"));

                // result date
                java.util.Date tmpDate = rs.getDate("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getDate("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+serverId+"."+transactionId+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            labAnalysis = null;

            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalysis;
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    public static boolean exists(int serverId, int transactionId, String analysisCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean objectExists = false;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT 1 FROM RequestedLabAnalyses"+
                             " WHERE serverid = ?"+
                             "  AND transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                objectExists = true;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+serverId+"."+transactionId+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return objectExists;
    }

    //--- FIND ------------------------------------------------------------------------------------

    public static Vector find(String serverId, String transactionId, String patientId, String analysisCode,
                              String comment, String resultValue, String resultUnit, String resultModifier,
                              String resultComment, String resultRefMax, String resultRefMin, String resultUserId,
                              String resultDateMin, String resultDateMax, String sSortCol, String sSortDir, boolean openAnalysesOnly,String sRequestUserId){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        if(sSortCol==null || sSortCol.length()==0){
        	sSortCol="resultdate";
        }
        
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId FROM RequestedLabAnalyses a,Transactions b";

            if(serverId.length()>0 || transactionId.length()>0 || patientId.length()>0 || analysisCode.length()>0 ||
               comment.length()>0 || resultValue.length()>0 || resultUnit.length()>0 || resultModifier.length()>0 ||
               resultComment.length()>0 || resultRefMax.length()>0 || resultRefMin.length()>0 ||
               resultUserId.length()>0 || sRequestUserId.length()>0 || resultDateMin.length()>0 || resultDateMax.length()>0){
                sSelect+= " WHERE a.transactionId=b.transactionId and a.serverid=b.serverid and ";

                String lowerComment       = ScreenHelper.getConfigParam("lowerCompare","comment"),
                       lowerResultComment = ScreenHelper.getConfigParam("lowerCompare","resultcomment");

                if(serverId.length()>0)      sSelect+= "a.serverid = ? AND ";
                if(transactionId.length()>0) sSelect+= "a.transactionid = ? AND ";
                if(patientId.length()>0)     sSelect+= "a.patientid = ? AND ";
                if(analysisCode.length()>0)  sSelect+= "a.analysiscode LIKE ? AND ";
                if(comment.length()>0)       sSelect+= lowerComment+" LIKE ? AND ";
                if(resultValue.length()>0)   sSelect+= "a.resultvalue = ? AND ";
                if(resultUnit.length()>0)    sSelect+= "a.resultunit LIKE ? AND ";

                if(openAnalysesOnly){
                    sSelect+= "(a.resultvalue is null or "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(a.resultValue)=0) AND ";
                }
                else{
                    if(resultModifier.length()>0) sSelect+= "a.resultmodifier = ? AND ";
                }

                if(resultComment.length()>0) sSelect+= lowerResultComment+" LIKE ? AND ";
                if(resultRefMax.length()>0)  sSelect+= "a.resultrefmax = ? AND ";
                if(resultRefMin.length()>0)  sSelect+= "a.resultrefmin = ? AND ";
                if(resultUserId.length()>0)  sSelect+= "a.resultuserid = ? AND ";
                if(sRequestUserId.length()>0)  sSelect+= "b.userId = ? AND ";
                if(resultDateMin.length()>0)    sSelect+= "a.resultdate >= ? AND ";
                if(resultDateMax.length()>0)    sSelect+= "a.resultdate <= ? AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>-1){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(serverId.length()>0)       ps.setInt(questionMarkIdx++,Integer.parseInt(serverId));
            if(transactionId.length()>0 ) ps.setInt(questionMarkIdx++,Integer.parseInt(transactionId));
            if(patientId.length()>0)      ps.setInt(questionMarkIdx++,Integer.parseInt(patientId));
            if(analysisCode.length()>0)   ps.setString(questionMarkIdx++,analysisCode);
            if(comment.length()>0)        ps.setString(questionMarkIdx++,comment.toLowerCase());
            if(resultValue.length()>0)    ps.setString(questionMarkIdx++,resultValue);
            if(resultUnit.length()>0)     ps.setString(questionMarkIdx++,resultUnit);
            if(resultModifier.length()>0) ps.setString(questionMarkIdx++,resultModifier);
            if(resultComment.length()>0)  ps.setString(questionMarkIdx++,resultComment.toLowerCase());
            if(resultRefMax.length()>0)   ps.setString(questionMarkIdx++,resultRefMax);
            if(resultRefMin.length()>0)   ps.setString(questionMarkIdx++,resultRefMin);
            if(resultUserId.length()>0)   ps.setInt(questionMarkIdx++,Integer.parseInt(resultUserId));
            if(sRequestUserId.length()>0)   ps.setInt(questionMarkIdx++,Integer.parseInt(sRequestUserId));
            if(resultDateMin.length()>0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(resultDateMin));
            if(resultDateMax.length()>0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(resultDateMax));

            // execute
            rs = ps.executeQuery();

            RequestedLabAnalysis labAnalysis;
            while(rs.next()){
                    labAnalysis = new RequestedLabAnalysis();
                    labAnalysis.setServerId(rs.getString("serverid"));
                    labAnalysis.setTransactionId(rs.getString("transactionid"));
                    labAnalysis.setAnalysisCode(rs.getString("analysiscode"));
                    labAnalysis.patientId = ScreenHelper.checkString(rs.getString("patientid"));
                    labAnalysis.comment   = ScreenHelper.checkString(rs.getString("comment"));

                    // result..
                    labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                    labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                    labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                    labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                    labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                    labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                    labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                    labAnalysis.requestUserId   = ScreenHelper.checkString(rs.getString("userId"));
                    labAnalysis.requestDate   = rs.getTimestamp("requestdatetime");
                    labAnalysis.resultProvisional   = ScreenHelper.checkString(rs.getString("resultprovisional"));

                    // result date
                    java.util.Date tmpDate = rs.getDate("resultdate");
                    if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                    
                    foundObjects.add(labAnalysis);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundObjects;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(int serverId, int transactionId, String analysisCode){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM RequestedLabAnalyses"+
                             " WHERE serverid = ?"+
                             "  AND transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- GET LAB REQUEST URGENCY -----------------------------------------------------------------
    // stored as an item of the belonging transaction (labRequest)
    //---------------------------------------------------------------------------------------------
    public static String getLabRequestUrgency(String serverId, String transactionId){
        String urgency = "";

        TransactionVO labRequest = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(serverId),Integer.parseInt(transactionId));
        ItemVO urgencyItem = labRequest.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_URGENCY");
        if(urgencyItem!=null) urgency = urgencyItem.getValue();

        return urgency;
    }

    //--- GET LAB REQUEST DATE --------------------------------------------------------------------
    // stored as an item of the belonging transaction (labRequest)
    //---------------------------------------------------------------------------------------------
    public static java.util.Date getLabRequestDate(String serverId, String transactionId){
        TransactionVO labRequest = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(serverId),Integer.parseInt(transactionId));
        return labRequest.getUpdateTime();
    }

    public void update(String sServerId, String sTransactionId, String sAnalysisCode){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE RequestedLabAnalyses"+
                         " SET comment=?, resultvalue=?, resultunit=?, resultmodifier=?, resultcomment=?,"+
                         " resultrefmax=?, resultrefmin=?, resultdate=?, resultuserid=?, resultprovisional=?"+
                         " WHERE serverid = ? AND transactionid = ? AND analysiscode = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setString(1,ScreenHelper.checkString(this.getComment()));
            ps.setString(2,ScreenHelper.checkString(this.getResultValue()));
            ps.setString(3,ScreenHelper.checkString(this.getResultUnit()));
            ps.setString(4,ScreenHelper.checkString(this.getResultModifier()));
            ps.setString(5,ScreenHelper.checkString(this.getResultComment()));
            ps.setString(6,ScreenHelper.checkString(this.getResultRefMax()));
            ps.setString(7,ScreenHelper.checkString(this.getResultRefMin()));
            ps.setDate(8,new java.sql.Date(this.getResultDate().getTime()));
            ps.setInt(9,Integer.parseInt(this.getResultUserId()));
            ps.setString(10,ScreenHelper.checkString(this.getResultProvisional()));
            // where
            ps.setInt(11,Integer.parseInt(sServerId));
            ps.setInt(12,Integer.parseInt(sTransactionId));
            ps.setString(13,sAnalysisCode);
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

    public static void updateValue(int serverid,int transactionid, String analysiscode, String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultvalue=?,resultdate="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode=? and resultvalue<>?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,value);
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.setString(4,analysiscode);
            ps.setString(5,value);
            ps.executeUpdate();
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
    }

    public static int updateValue(int serverid,int transactionid, String analysiscode, String value, int userid){
        int rows=0;
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultvalue=?,resultdate="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+",resultuserid=? where serverid=? and transactionid=? and analysiscode=? and resultvalue<>?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,value);
            ps.setInt(2,userid);
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.setString(5,analysiscode);
            ps.setString(6,value);
            rows=ps.executeUpdate();
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
        return rows;
    }

    public static void updateResultComment(int serverid,int transactionid, String analysiscode, String comment){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultcomment=? where serverid=? and transactionid=? and analysiscode=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,comment);
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.setString(4,analysiscode);
            ps.executeUpdate();
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
    }

    public static void setConfirmed(int serverid,int transactionid, boolean confirmed,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultprovisional=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+")";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,confirmed?"":"1");
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.executeUpdate();
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
    }

    public static void setTechnicalValidation(int serverid,int transactionid, int technicalvalidator,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set technicalvalidator=?,technicalvalidationdatetime=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and technicalvalidator is null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,technicalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
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
    }

    public static void setWorklisted(int serverid,int transactionid,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set worklisteddatetime=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and worklisteddatetime is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.executeUpdate();
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
    }

    public static void setFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and finalvalidator is null and not (resultvalue is null or resultvalue='') ";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
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
    }

    public static void setFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses,String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and finalvalidator is null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
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
    }

    public static void setModifiedFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses,String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
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
    }

    public static void setForcedFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=? where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and finalvalidator is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
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
    }

    public static void unvalidate(int serverid,int transactionid, String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=null,finalvalidationdatetime=null where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+")";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,transactionid);
            ps.executeUpdate();
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
    }

    public static void setFinalValidation(int serverid,int transactionid, int finalvalidator){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=? where serverid=? and transactionid=? and finalvalidator is null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
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
}

    public static String findUnvalidatedAnalyses(){
        String result="";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.analysiscode from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and finalvalidator is null and worklisteddatetime is not null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                if(result.length()>0){
                    result+=",";
                }
                result+="'"+rs.getString("analysiscode")+"'";
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
        return result;
}

    public static String findUntreatedAnalyses(int personid){
        String result="";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.analysiscode from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and finalvalidator is null and patientid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                if(result.length()>0){
                    result+=",";
                }
                result+="'"+rs.getString("analysiscode")+"'";
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
        return result;
    }

    public static String findRequestedAnalysis(String requests){
        String result="",serverids="",transactionids="";
        Hashtable hServerids = new Hashtable();
        Hashtable hTransactionids = new Hashtable();
        String[] requestids = requests.split(",");
        for(int n=0;n<requestids.length;n++){
            hServerids.put(requestids[n].split("\\.")[0],"1");
            hTransactionids.put(requestids[n].split("\\.")[1],"1");
        }
        Enumeration enumeration = hServerids.keys();
        while(enumeration.hasMoreElements()){
            if(serverids.length()>0){
                serverids+=",";
            }
            serverids+=(String)enumeration.nextElement();
        }
        enumeration = hTransactionids.keys();
        while(enumeration.hasMoreElements()){
            if(transactionids.length()>0){
                transactionids+=",";
            }
            transactionids+=(String)enumeration.nextElement();
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.analysiscode,b.labgroup from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid in ("+serverids+") and transactionid in ("+transactionids+") order by labgroup,analysiscode";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                if(result.length()>0){
                    result+=",";
                }
                result+=rs.getString("labgroup")+"."+rs.getString("analysiscode");
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
        return result;
    }
    public static Map getAntibiogrammes(String sUid){
        Map map = new LinkedHashMap();
          PreparedStatement ps = null;
          ResultSet rs = null;
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // delete all items
            String sSelect = "SELECT * FROM OC_ANTIBIOGRAMS"+
                             " WHERE OC_AB_REQUESTEDLABANALYSISUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sUid);

            rs = ps.executeQuery();
           if(rs.next()){
              map.put("germ1",rs.getString("OC_AB_GERM1"));
              map.put("germ2",rs.getString("OC_AB_GERM2"));
              map.put("germ3",rs.getString("OC_AB_GERM3")); 
              map.put("ANTIBIOGRAMME1",rs.getString("OC_AB_ANTIBIOGRAMME1"));
              map.put("ANTIBIOGRAMME2",rs.getString("OC_AB_ANTIBIOGRAMME2"));
              map.put("ANTIBIOGRAMME3",rs.getString("OC_AB_ANTIBIOGRAMME3"));
           }
           rs.close();
           ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

       return map;

    }
    public static void setAntibiogrammes(String sName,String sValue,String userUid){
         PreparedStatement ps = null;

         Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String[] tName = sName.split("\\.");
            if(existsAntibiogrammesByUid(tName[1]+"."+tName[2]+"."+tName[3])){
               String sSelect = "UPDATE OC_ANTIBIOGRAMS SET OC_AB_UPDATETIME = ?,OC_AB_UPDATEUID = ?";
                sSelect+= ",OC_AB_"+tName[4].toUpperCase()+" = ? WHERE OC_AB_REQUESTEDLABANALYSISUID = ?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
                ps.setString(2,userUid);
                ps.setString(3,sValue);
                ps.setString(4,tName[1]+"."+tName[2]+"."+tName[3]);
                ps.executeUpdate();

            }else{
                String sSelect = "INSERT INTO OC_ANTIBIOGRAMS (OC_AB_REQUESTEDLABANALYSISUID,OC_AB_CREATETIME,OC_AB_UPDATEUID";
                sSelect+= ",OC_AB_"+tName[4].toUpperCase()+")";
                sSelect+=" VALUES(?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,tName[1]+"."+tName[2]+"."+tName[3]);
                ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
                ps.setString(3,userUid);
                ps.setString(4,sValue);
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

    }
      public static boolean existsAntibiogrammesByUid(String uid){
         PreparedStatement ps = null;
          ResultSet rs = null;
         boolean exists = false;
         Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_AB_REQUESTEDLABANALYSISUID FROM OC_ANTIBIOGRAMS"+
                             " WHERE OC_AB_REQUESTEDLABANALYSISUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,uid);

            rs = ps.executeQuery();
           if(rs.next()){
              exists = true; 
           }
           rs.close();
           ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

       return exists;
    }
      public boolean existsNonEmptyAntibiogrammesByUid(String uid){
    	  boolean exists=false;
          PreparedStatement ps = null;
          ResultSet rs = null;
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
          try{
        	  String sql="select * from OC_ANTIBIOGRAMS where OC_AB_REQUESTEDLABANALYSISUID=? AND" +
        	  		" "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(OC_AB_GERM1)+"+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(OC_AB_GERM2)+"+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(OC_AB_GERM3)>0";
        	  ps=oc_conn.prepareStatement(sql);
        	  ps.setString(1, uid);
        	  rs = ps.executeQuery();
        	  exists = rs.next();
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
    	  
    	  return exists;
      }
      public static List getAntibiogrammesGerm(String s){
          List l = new LinkedList();
         PreparedStatement ps = null;
          ResultSet rs = null;
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_AB_GERM1,OC_AB_GERM2,OC_AB_GERM3 FROM OC_ANTIBIOGRAMS"+
                             " WHERE LOWER(OC_AB_GERM1) like '"+s.toLowerCase()+"%' OR LOWER(OC_AB_GERM2) like '"+s.toLowerCase()+"%' OR LOWER(OC_AB_GERM3) like '"+s.toLowerCase()+"%'";
            ps = oc_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();
            String sResult = "";
           while(rs.next()){
              if(rs.getString("OC_AB_GERM1")!=null && rs.getString("OC_AB_GERM1").startsWith(s)){

                   sResult = "<b>"+s+"</b>"+rs.getString("OC_AB_GERM1").substring(s.length());
                  if(!l.contains(sResult)){
                      l.add(sResult);
                  }
              }
               if(rs.getString("OC_AB_GERM2")!=null && rs.getString("OC_AB_GERM2").startsWith(s)){
                   sResult = "<b>"+s+"</b>"+rs.getString("OC_AB_GERM2").substring(s.length());
                    if(!l.contains(sResult)){
                      l.add(sResult);
                  }
              }
               if(rs.getString("OC_AB_GERM3")!=null && rs.getString("OC_AB_GERM3").startsWith(s)){
                   sResult = "<b>"+s+"</b>"+rs.getString("OC_AB_GERM3").substring(s.length());
                    if(!l.contains(sResult)){
                      l.add(sResult);
                  }
              }
           }
           rs.close();
           ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

       return l;
    }
      
      public String getNotifyBySMS(){
      //public static String getNotifyBySMS(){
    	  //transactieitem ophalen dat SMS nummer zou kunnen bevatten
    	  ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(this.getServerId()), Integer.parseInt(this.getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS");
    	  //ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(getServerId()), Integer.parseInt(getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS");
    	  if(itemVO!=null){
    		  if(itemVO.getValue().trim().length()>0){
    			  return itemVO.getValue();
    		  }
    	  }
    	  return null;
      }

      public String getNotifyByEmail(){
    	  //transactieitem ophalen dat Email adres zou kunnen bevatten
    	  ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(this.getServerId()), Integer.parseInt(this.getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL");
    	  if(itemVO!=null){
    		  if(itemVO.getValue().indexOf("@")>-1){
    			  return itemVO.getValue();
    		  }
    	  }
    	  return null;
      }
      
}
