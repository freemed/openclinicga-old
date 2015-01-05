package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import org.jnp.interfaces.java.javaURLContextFactory;


public class LabRequest {
    private Hashtable analyses = new Hashtable();
    private int serverid;
    private int transactionid;
    private int userid;
    private int personid;
    private String patientname;
    private String patientgender;
    private String servicename="";
    private Date requestdate;
    private String comment;
    private Date patientdateofbirth;
    private boolean confirmed=true;

    public boolean isConfirmed() {
        return confirmed;
    }

    public void setConfirmed(boolean confirmed) {
        this.confirmed = confirmed;
    }

    public Date getPatientdateofbirth() {
        return patientdateofbirth;
    }

    public void setPatientdateofbirth(Date patientdateofbirth) {
        this.patientdateofbirth = patientdateofbirth;
    }

    public Hashtable getAnalyses() {
        return analyses;
    }

    public SortedMap getSortedAnalyses() {
        SortedMap s = new TreeMap();
        s.putAll(analyses);
        return s;
    }

    public void setAnalyses(Hashtable analyses) {
        this.analyses = analyses;
    }

    public int getServerid() {
        return serverid;
    }

    public void setServerid(int serverid) {
        this.serverid = serverid;
    }

    public int getTransactionid() {
        return transactionid;
    }

    public void setTransactionid(int transactionid) {
        this.transactionid = transactionid;
    }

    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public int getPersonid() {
        return personid;
    }

    public void setPersonid(int personid) {
        this.personid = personid;
    }

    public String getPatientname() {
        return patientname;
    }

    public void setPatientname(String patientname) {
        this.patientname = patientname;
    }

    public String getPatientgender() {
        return patientgender;
    }

    public void setPatientgender(String patientgender) {
        this.patientgender = patientgender;
    }

    public String getServicename() {
        return servicename;
    }

    public void setServicename(String servicename) {
        this.servicename = servicename;
    }

    public java.util.Date getRequestdate() {
        return requestdate;
    }

    public void setRequestdate(java.util.Date requestdate) {
        this.requestdate = requestdate;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void loadRequestAnalyses(String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.labgroup from RequestedLabAnalyses a,LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+")";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                RequestedLabAnalysis requestedLabAnalysis = new RequestedLabAnalysis();
                requestedLabAnalysis.setLabgroup(rs.getString("labgroup"));
                requestedLabAnalysis.setAnalysisCode(rs.getString("analysiscode"));
                requestedLabAnalysis.setComment(getComment());
                requestedLabAnalysis.setPatientId(rs.getString("patientid"));
                requestedLabAnalysis.setRequestDate(new java.sql.Date(getRequestdate().getTime()));
                requestedLabAnalysis.setRequestUserId(getUserid()+"");
                requestedLabAnalysis.setResultComment(rs.getString("resultcomment"));
                requestedLabAnalysis.setResultDate(rs.getTimestamp("resultdate"));
                requestedLabAnalysis.setResultModifier(rs.getString("resultmodifier"));
                requestedLabAnalysis.setResultProvisional(rs.getString("resultprovisional"));
                setConfirmed(isConfirmed() && ScreenHelper.checkString(rs.getString("resultprovisional")).equalsIgnoreCase(""));
                requestedLabAnalysis.setResultRefMax(rs.getString("resultrefmax"));
                requestedLabAnalysis.setResultRefMin(rs.getString("resultrefmin"));
                requestedLabAnalysis.setResultUnit(rs.getString("resultunit"));
                requestedLabAnalysis.setResultUserId(rs.getString("resultuserid"));
                requestedLabAnalysis.setResultValue(rs.getString("resultvalue"));
                requestedLabAnalysis.setTechnicalvalidation(rs.getInt("technicalvalidator"));
                requestedLabAnalysis.setFinalvalidation(rs.getInt("finalvalidator"));
                java.util.Date d= rs.getTimestamp("technicalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setTechnicalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("finalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setFinalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("sampletakendatetime");
                if(d!=null){
                    requestedLabAnalysis.setSampletakendatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("samplereceptiondatetime");
                if(d!=null){
                    requestedLabAnalysis.setSamplereceptiondatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("worklisteddatetime");
                if(d!=null){
                    requestedLabAnalysis.setWorklisteddatetime(new java.sql.Date(d.getTime()));
                }
                requestedLabAnalysis.setSampler(rs.getInt("sampler"));
                getAnalyses().put(requestedLabAnalysis.getAnalysisCode(),requestedLabAnalysis);
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
			e.printStackTrace();
		}
    }
    public void loadRequestAnalyses(Date date){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.labgroup from RequestedLabAnalyses a,LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and finalvalidationdatetime >= ?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ps.setTimestamp(3,new java.sql.Timestamp(date.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                RequestedLabAnalysis requestedLabAnalysis = new RequestedLabAnalysis();
                requestedLabAnalysis.setLabgroup(rs.getString("labgroup"));
                requestedLabAnalysis.setAnalysisCode(rs.getString("analysiscode"));
                requestedLabAnalysis.setComment(getComment());
                requestedLabAnalysis.setPatientId(rs.getString("patientid"));
                requestedLabAnalysis.setRequestDate(new java.sql.Date(getRequestdate().getTime()));
                requestedLabAnalysis.setRequestUserId(getUserid()+"");
                requestedLabAnalysis.setResultComment(rs.getString("resultcomment"));
                requestedLabAnalysis.setResultDate(rs.getTimestamp("resultdate"));
                requestedLabAnalysis.setResultModifier(rs.getString("resultmodifier"));
                requestedLabAnalysis.setResultProvisional(rs.getString("resultprovisional"));
                setConfirmed(isConfirmed() && ScreenHelper.checkString(rs.getString("resultprovisional")).equalsIgnoreCase(""));
                requestedLabAnalysis.setResultRefMax(rs.getString("resultrefmax"));
                requestedLabAnalysis.setResultRefMin(rs.getString("resultrefmin"));
                requestedLabAnalysis.setResultUnit(rs.getString("resultunit"));
                requestedLabAnalysis.setResultUserId(rs.getString("resultuserid"));
                requestedLabAnalysis.setResultValue(rs.getString("resultvalue"));
                requestedLabAnalysis.setTechnicalvalidation(rs.getInt("technicalvalidator"));
                requestedLabAnalysis.setFinalvalidation(rs.getInt("finalvalidator"));
                java.util.Date d= rs.getTimestamp("technicalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setTechnicalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("finalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setFinalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("sampletakendatetime");
                if(d!=null){
                    requestedLabAnalysis.setSampletakendatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("samplereceptiondatetime");
                if(d!=null){
                    requestedLabAnalysis.setSamplereceptiondatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("worklisteddatetime");
                if(d!=null){
                    requestedLabAnalysis.setWorklisteddatetime(new java.sql.Date(d.getTime()));
                }
                requestedLabAnalysis.setSampler(rs.getInt("sampler"));
                getAnalyses().put(requestedLabAnalysis.getAnalysisCode(),requestedLabAnalysis);
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
			e.printStackTrace();
		}
    }

    public LabRequest(){

    }

    public static LabRequest getUnsampledRequest(int serverid,String transactionid,String language){
        LabRequest labRequest = new LabRequest();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and a.serverid=? and a.transactionid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,Integer.parseInt(transactionid.split("\\.")[0]));
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
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
			e.printStackTrace();
		}
        return labRequest;
    }

    public LabRequest(int serverid,int transactionid){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct d.language,a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and a.serverid=? and a.transactionid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,transactionid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                String language=rs.getString("language");
                if(language==null){
                    language="f";
                }
                //For every transaction ID, let's create a Labrequest
                setServerid(rs.getInt("serverid"));
                setTransactionid(rs.getInt("transactionid"));
                setPersonid(rs.getInt("patientid"));
                setPatientgender(rs.getString("gender"));
                setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                setRequestdate(rs.getTimestamp("updatetime"));
                setUserid(rs.getInt("userid"));
                setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        setServicename(encounter.getService().getLabel(language));
                    }
                }
                loadRequestAnalyses();
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
			e.printStackTrace();
		}
    }

    public void loadRequestAnalyses(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.labgroup from RequestedLabAnalyses a,LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                RequestedLabAnalysis requestedLabAnalysis = new RequestedLabAnalysis();
                requestedLabAnalysis.setLabgroup(rs.getString("labgroup"));
                requestedLabAnalysis.setAnalysisCode(rs.getString("analysiscode"));
                requestedLabAnalysis.setComment(getComment());
                requestedLabAnalysis.setPatientId(rs.getString("patientid"));
                requestedLabAnalysis.setRequestDate(new java.sql.Date(getRequestdate().getTime()));
                requestedLabAnalysis.setRequestUserId(getUserid()+"");
                requestedLabAnalysis.setResultComment(rs.getString("resultcomment"));
                requestedLabAnalysis.setResultDate(rs.getTimestamp("resultdate"));
                requestedLabAnalysis.setResultModifier(rs.getString("resultmodifier"));
                requestedLabAnalysis.setResultProvisional(rs.getString("resultprovisional"));
                setConfirmed(isConfirmed() && ScreenHelper.checkString(rs.getString("resultprovisional")).equalsIgnoreCase(""));
                requestedLabAnalysis.setResultRefMax(rs.getString("resultrefmax"));
                requestedLabAnalysis.setResultRefMin(rs.getString("resultrefmin"));
                requestedLabAnalysis.setResultUnit(rs.getString("resultunit"));
                requestedLabAnalysis.setResultUserId(rs.getString("resultuserid"));
                requestedLabAnalysis.setResultValue(rs.getString("resultvalue"));
                requestedLabAnalysis.setTechnicalvalidation(rs.getInt("technicalvalidator"));
                requestedLabAnalysis.setFinalvalidation(rs.getInt("finalvalidator"));
                java.util.Date d= rs.getTimestamp("technicalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setTechnicalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("finalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setFinalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("sampletakendatetime");
                if(d!=null){
                    requestedLabAnalysis.setSampletakendatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("samplereceptiondatetime");
                if(d!=null){
                    requestedLabAnalysis.setSamplereceptiondatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("worklisteddatetime");
                if(d!=null){
                    requestedLabAnalysis.setWorklisteddatetime(new java.sql.Date(d.getTime()));
                }
                requestedLabAnalysis.setSampler(rs.getInt("sampler"));
                getAnalyses().put(requestedLabAnalysis.getAnalysisCode(),requestedLabAnalysis);
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
			e.printStackTrace();
		}
    }

    public void loadUnvalidatedRequestAnalyses(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.labgroup from RequestedLabAnalyses a,LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and finalvalidator is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                RequestedLabAnalysis requestedLabAnalysis = new RequestedLabAnalysis();
                requestedLabAnalysis.setLabgroup(rs.getString("labgroup"));
                requestedLabAnalysis.setAnalysisCode(rs.getString("analysiscode"));
                requestedLabAnalysis.setComment(getComment());
                requestedLabAnalysis.setPatientId(rs.getString("patientid"));
                requestedLabAnalysis.setRequestDate(new java.sql.Date(getRequestdate().getTime()));
                requestedLabAnalysis.setRequestUserId(getUserid()+"");
                requestedLabAnalysis.setResultComment(rs.getString("resultcomment"));
                requestedLabAnalysis.setResultDate(rs.getTimestamp("resultdate"));
                requestedLabAnalysis.setResultModifier(rs.getString("resultmodifier"));
                requestedLabAnalysis.setResultProvisional(rs.getString("resultprovisional"));
                setConfirmed(isConfirmed() && ScreenHelper.checkString(rs.getString("resultprovisional")).equalsIgnoreCase(""));
                requestedLabAnalysis.setResultRefMax(rs.getString("resultrefmax"));
                requestedLabAnalysis.setResultRefMin(rs.getString("resultrefmin"));
                requestedLabAnalysis.setResultUnit(rs.getString("resultunit"));
                requestedLabAnalysis.setResultUserId(rs.getString("resultuserid"));
                requestedLabAnalysis.setResultValue(rs.getString("resultvalue"));
                requestedLabAnalysis.setTechnicalvalidation(rs.getInt("technicalvalidator"));
                requestedLabAnalysis.setFinalvalidation(rs.getInt("finalvalidator"));
                java.util.Date d= rs.getTimestamp("technicalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setTechnicalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("finalvalidationdatetime");
                if(d!=null){
                    requestedLabAnalysis.setFinalvalidationdatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("sampletakendatetime");
                if(d!=null){
                    requestedLabAnalysis.setSampletakendatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("samplereceptiondatetime");
                if(d!=null){
                    requestedLabAnalysis.setSamplereceptiondatetime(new java.sql.Date(d.getTime()));
                }
                d= rs.getTimestamp("worklisteddatetime");
                if(d!=null){
                    requestedLabAnalysis.setWorklisteddatetime(new java.sql.Date(d.getTime()));
                }
                requestedLabAnalysis.setSampler(rs.getInt("sampler"));
                getAnalyses().put(requestedLabAnalysis.getAnalysisCode(),requestedLabAnalysis);
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
			e.printStackTrace();
		}
    }

    public static Vector findOpenRequests(String worklistAnalyses,String language){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and analysiscode in ("+worklistAnalyses+") and worklisteddatetime is not null and finalvalidator is null and (resultvalue is null or resultvalue='' or technicalvalidator is null)";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses(worklistAnalyses);
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findMyValidatedRequestsSince(int userid,Date date,String language,int maxresults){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and b.userid=? and finalvalidationdatetime >= ?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,userid);
            ps.setTimestamp(2,new Timestamp(date.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next() && results.size()<maxresults){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses();
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findServiceValidatedRequestsSince(String serviceid,Date date,String language,int maxresults){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime " +
                    " from RequestedLabAnalyses a, Transactions b, AdminView d, OC_ENCOUNTERS e, OC_ENCOUNTER_SERVICES f" +
                    " where" +
                    " e.OC_ENCOUNTER_SERVERID=f.OC_ENCOUNTER_SERVERID AND" +
                    " e.OC_ENCOUNTER_OBJECTID=f.OC_ENCOUNTER_OBJECTID AND"+
                    " a.patientid="+ MedwanQuery.getInstance().convert("int","e.OC_ENCOUNTER_PATIENTUID")+" and" +
                    " e.OC_ENCOUNTER_ENDDATE is null and" +
                    " f.OC_ENCOUNTER_SERVICEUID like ? and" +
                    " f.OC_ENCOUNTER_SERVICEENDDATE is null and" +
                    " a.serverid=b.serverid and" +
                    " a.transactionId=b.transactionId and" +
                    " a.patientid=d.personid and" +
                    " finalvalidationdatetime >= ?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,serviceid+"%");
            ps.setTimestamp(2,new Timestamp(date.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next() && results.size()<maxresults){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getServiceUID()+" "+encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses();
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findUnvalidatedRequests(String worklistAnalyses,String language,int type){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and analysiscode in ("+worklistAnalyses+") and worklisteddatetime is not null and not (resultvalue is null or resultvalue='')";
            if(type==1){
                 sQuery+=" and finalvalidator is null";
            }
            else if(type==0) {
                sQuery+=" and technicalvalidator is null";
            }
            System.out.println(sQuery);
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses(worklistAnalyses);
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findUntreatedRequests(String language,int personid){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d, Labanalysis e where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and a.analysiscode=e.labcode and e.editor not in ('calculated','virtual') and finalvalidationdatetime is null and patientid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses();
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findMyUntreatedRequests(String language,int userid){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and finalvalidationdatetime is null and b.userid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,userid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadUnvalidatedRequestAnalyses();
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findNotOnWorklistRequests(String worklistAnalyses,String language){
        Vector results = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and analysiscode in ("+worklistAnalyses+") and worklisteddatetime is null and finalvalidationdatetime is null and samplereceptiondatetime is not null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses(worklistAnalyses);
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findRequestList(int personid){
        Vector results=new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,b.updatetime from RequestedLabAnalyses a, Transactions b where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=? order by b.updatetime desc";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findRequestsSince(String worklistAnalyses,Date date,String language){
                Vector results = new Vector();
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //First let's find all transactionid's for which at least one result is open
            String sQuery="select distinct a.serverid,a.transactionid,a.patientid,d.gender,d.firstname,d.lastname,b.userid,d.dateofbirth,b.updatetime from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and analysiscode in ("+worklistAnalyses+") and worklisteddatetime>?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                //For every transaction ID, let's create a Labrequest
                LabRequest labRequest = new LabRequest();
                labRequest.setServerid(rs.getInt("serverid"));
                labRequest.setTransactionid(rs.getInt("transactionid"));
                labRequest.setPersonid(rs.getInt("patientid"));
                labRequest.setPatientgender(rs.getString("gender"));
                labRequest.setPatientname(rs.getString("firstname")+" "+rs.getString("lastname"));
                labRequest.setRequestdate(rs.getTimestamp("updatetime"));
                labRequest.setUserid(rs.getInt("userid"));
                labRequest.setPatientdateofbirth(rs.getDate("dateofbirth"));
                Encounter encounter = Encounter.getActiveEncounter(labRequest.getPersonid()+"");
                if(encounter!=null){
                    if(encounter.getService()!=null){
                        labRequest.setServicename(encounter.getService().getLabel(language));
                    }
                }
                labRequest.loadRequestAnalyses(worklistAnalyses);
                results.add(labRequest);
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
			e.printStackTrace();
		}
        return results;
    }

    public static Vector findUnsampledRequests(String service,String language){
        Hashtable transactions = new Hashtable();
    	Vector requests=new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	String sQuery="select serverid,transactionid,requestdatetime " +
                    " from RequestedLabAnalyses a, OC_ENCOUNTERS b,OC_ENCOUNTER_SERVICES c" +
                    " where" +
                    " b.OC_ENCOUNTER_SERVERID=c.OC_ENCOUNTER_SERVERID AND" +
                    " b.OC_ENCOUNTER_OBJECTID=c.OC_ENCOUNTER_OBJECTID AND"+
                    " a.patientid="+ MedwanQuery.getInstance().convert("int","b.OC_ENCOUNTER_PATIENTUID")+" and" +
                    " sampletakendatetime is null and" +
                    " samplereceptiondatetime is null and"+
                    " requestdatetime>? and"+
                    " c.OC_ENCOUNTER_SERVICEUID like ?" +
                    " order by requestdatetime desc";
            if (service==null || service.length()==0){
            	sQuery="select serverid,transactionid,requestdatetime" +
                " from RequestedLabAnalyses" +
                " where" +
                " sampletakendatetime is null and" +
                " samplereceptiondatetime is null and"+
                " requestdatetime >?"+
                " order by requestdatetime desc";
            }
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            long oneWeekAgo= new Date().getTime();
            oneWeekAgo-=1000*3600*24*7;
            ps.setDate(1,new java.sql.Date(oneWeekAgo));
            if (service!=null && service.length()>0){
            	ps.setString(2,service+"%");
            }
            ResultSet rs = ps.executeQuery();
            int serverid,transactionid;
            while (rs.next()){
            	serverid=rs.getInt("serverid");
            	transactionid=rs.getInt("transactionid");
            	if(transactions.get(serverid+"."+transactionid)==null){
            		requests.add(LabRequest.getUnsampledRequest(serverid,transactionid+"",language));
            		transactions.put(serverid+"."+transactionid, "1");
            	}
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
			e.printStackTrace();
		}
        return requests;
    }

    public static Vector findUnreceivedRequests(String language){
        Vector requests=new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct serverid,transactionid" +
                    " from RequestedLabAnalyses a" +
                    " where" +
                    " samplereceptiondatetime is null and (resultvalue is null or resultvalue='') and finalvalidationdatetime is null and requestdatetime>?" +
                    " order by serverid,transactionid,requestdatetime";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            long week = 60000*60*24*7;
            ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-week));
            ResultSet rs = ps.executeQuery();
            String activerequest="";
            while (rs.next()){
                int serverid=rs.getInt("serverid");
                int transactionid=rs.getInt("transactionid");
                if(!activerequest.equalsIgnoreCase(serverid+"."+transactionid)){
                    requests.add(LabRequest.getUnsampledRequest(serverid,transactionid+"",language));
                    activerequest=serverid+"."+transactionid;
                }
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
			e.printStackTrace();
		}
        return requests;
    }

    public Hashtable findOpenSamples(String language){
        Hashtable samples = new Hashtable();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.monster from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and sampletakendatetime is null and samplereceptiondatetime is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                String monster=rs.getString("monster");
                if(monster==null || monster.trim().length()==0){
                    monster="?";
                }
                LabSample labSample=(LabSample)samples.get(monster);
                if(labSample==null){
                    labSample=new LabSample();
                }
                labSample.analyses.add(MedwanQuery.getInstance().getLabel("labanalysis",rs.getString("analysiscode"),language));
                labSample.type=ScreenHelper.checkDbString(monster);
                samples.put(monster,labSample);
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
			e.printStackTrace();
		}
        return samples;
    }

    public Hashtable findUnreceivedSamples(String language){
        Hashtable samples = new Hashtable();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.monster from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and samplereceptiondatetime is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                String monster=rs.getString("monster");
                if(monster==null || monster.trim().length()==0){
                    monster="?";
                }
                LabSample labSample=(LabSample)samples.get(monster);
                if(labSample==null){
                    labSample=new LabSample();
                }
                labSample.analyses.add(MedwanQuery.getInstance().getLabel("labanalysis",rs.getString("analysiscode"),language));
                labSample.type=ScreenHelper.checkDbString(monster);
                samples.put(monster,labSample);
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
			e.printStackTrace();
		}
        return samples;
    }

    public Hashtable findAllSamples(String language){
        Hashtable samples = new Hashtable();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select a.*,b.monster from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,getServerid());
            ps.setInt(2,getTransactionid());
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                String monster=rs.getString("monster");
                if(monster==null || monster.trim().length()==0){
                    monster="?";
                }
                LabSample labSample=(LabSample)samples.get(monster);
                if(labSample==null){
                    labSample=new LabSample();
                }
                labSample.analyses.add(MedwanQuery.getInstance().getLabel("labanalysis",rs.getString("analysiscode"),language));
                labSample.type=ScreenHelper.checkDbString(monster);
                samples.put(monster,labSample);
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
			e.printStackTrace();
		}
        return samples;
    }

    public static void setSampleTaken(int serverid,int transactionid,String sample,int userid){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sample!=null && !sample.equalsIgnoreCase("?")){
            	try {
	            	String sQuery="update RequestedLabAnalyses set sampletakendatetime=?,sampler=? from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and b.monster=? and sampletakendatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,userid);
	                ps.setInt(3,serverid);
	                ps.setInt(4,transactionid);
	                ps.setString(5,sample);
	                ps.executeUpdate();
	                ps.close();
            	}
            	catch (Exception es){
	            	String sQuery="update RequestedLabAnalyses a, LabAnalysis b set a.sampletakendatetime=?,a.sampler=? where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and b.monster=? and sampletakendatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,userid);
	                ps.setInt(3,serverid);
	                ps.setInt(4,transactionid);
	                ps.setString(5,sample);
	                ps.executeUpdate();
	                ps.close();
            	}
            }
            else {
            	try {
	                String sQuery="update RequestedLabAnalyses set sampletakendatetime=?,sampler=? from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and (b.monster is null or b.monster='') and sampletakendatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,userid);
	                ps.setInt(3,serverid);
	                ps.setInt(4,transactionid);
	                ps.executeUpdate();
	                ps.close();
            	}
            	catch (Exception es){
	                String sQuery="update RequestedLabAnalyses a, LabAnalysis b set sampletakendatetime=?,sampler=? where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and (b.monster is null or b.monster='') and sampletakendatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,userid);
	                ps.setInt(3,serverid);
	                ps.setInt(4,transactionid);
	                ps.executeUpdate();
	                ps.close();
            	}
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
    }

    public boolean hasBacteriology(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        boolean bBact=false;
        try{
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ANTIBIOGRAMS where OC_AB_REQUESTEDLABANALYSISUID like '"+this.getServerid()+"."+this.getTransactionid()+"%'");
            ResultSet rs = ps.executeQuery();
            bBact=rs.next() && rs.getInt("total")>0;
            rs.close();
            ps.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        finally{
            try{
    			oc_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
        }
        return bBact;
    }
    
    public static void setSampleReceived(int serverid,int transactionid,String sample){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sample!=null && !sample.equalsIgnoreCase("?")){
                try{
                	//basic code Microsoft SQL server
	            	String sQuery="update RequestedLabAnalyses set samplereceptiondatetime=? from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and b.monster=? and samplereceptiondatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,serverid);
	                ps.setInt(3,transactionid);
	                ps.setString(4,sample);
	                ps.executeUpdate();
	                ps.close();
                }
                catch(Exception e2){
                	//alternative code MySQL
	            	String sQuery="update RequestedLabAnalyses a, LabAnalysis b set a.samplereceptiondatetime=?  where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and b.monster=? and samplereceptiondatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,serverid);
	                ps.setInt(3,transactionid);
	                ps.setString(4,sample);
	                ps.executeUpdate();
	                ps.close();
                }
            }
            else {
                try{
                	//basic code Microsoft SQL server
	                String sQuery="update RequestedLabAnalyses set samplereceptiondatetime=? from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and (b.monster is null or b.monster='') and samplereceptiondatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,serverid);
	                ps.setInt(3,transactionid);
	                ps.executeUpdate();
	                ps.close();
                }
                catch(Exception e2){
                	//alternative code MySQL
	                String sQuery="update RequestedLabAnalyses a, LabAnalysis b set a.samplereceptiondatetime=? where a.analysiscode=b.labcode and b.deletetime is null and serverid=? and transactionid=? and (b.monster is null or b.monster='') and samplereceptiondatetime is null";
	                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
	                ps.setInt(2,serverid);
	                ps.setInt(3,transactionid);
	                ps.executeUpdate();
	                ps.close();
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
    }

}
