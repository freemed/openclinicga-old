package be.openclinic.adt;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import be.openclinic.finance.Debet;
import net.admin.AdminPerson;
import net.admin.Service;
import net.admin.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.util.Date;
import java.util.Vector;
import java.util.Hashtable;
import java.text.SimpleDateFormat;
import java.text.ParseException;

public class Encounter extends OC_Object {
    private String type;  //Admission, Visit
    private Date begin;
    private Date end;
    private AdminPerson patient;
    private Bed bed;
    private Service service;
    private User manager;
    private String patientUID;
    private String bedUID = "";
    private String serviceUID = "";
    private String destinationUID;
    private String managerUID = "";
    private String outcome;
    private Service destination;
    private String origin;
    private Date transferDate;
    private String situation;
    private String categories;
    private int newcase;
    private String etiology;

    public int getNewcase() {
		return newcase;
	}

	public void setNewcase(int newcase) {
		this.newcase = newcase;
	}

	public String getEtiology() {
		return etiology;
	}

	public void setEtiology(String etiology) {
		this.etiology = etiology;
	}

    public String getCategories() {
		return categories;
	}

	public void setCategories(String categories) {
		this.categories = categories;
	}

	public String getSituation() {
        return situation;
    }

    public void setSituation(String situation) {
        this.situation = situation;
    }

    public class EncounterService {
        public String serviceUID = "";
        public String managerUID = "";
        public String bedUID = "";
        public java.util.Date begin;
        public java.util.Date end;
    }

    public Date getTransferDate() {
        return transferDate;
    }

    public void setTransferDate(Date transferDate) {
        this.transferDate = transferDate;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getOutcome() {
        return outcome;
    }

    public void setOutcome(String outcome) {
        this.outcome = outcome;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Date getBegin() {
        return begin;
    }

    public void setBegin(Date begin) {
        this.begin = begin;
    }

    public Date getEnd() {
        return end;
    }

    public void setEnd(Date end) {
        this.end = end;
    }
    
    //--- GET COVERAGE ENCOUNTER ------------------------------------------------------------------
    public static Encounter getCoverageEncounter(String patientid,String userid){
    	Encounter encounter = null;
    	Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from OC_ENCOUNTERS where OC_ENCOUNTER_TYPE='coverage' and OC_ENCOUNTER_PATIENTUID=?");
            ps.setString(1, patientid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                encounter = Encounter.get(rs.getString("OC_ENCOUNTER_SERVERID")+"."+rs.getString("OC_ENCOUNTER_OBJECTID"));
            }
            else {
            	encounter = new Encounter();
            	encounter.setBegin(new java.util.Date());
            	encounter.setEnd(new java.util.Date());
            	encounter.setCreateDateTime(new java.util.Date());
            	encounter.setPatientUID(patientid);
            	encounter.setServiceUID(MedwanQuery.getInstance().getConfigString("activeInsuranceServiceUID", "INS"));
            	encounter.setType("coverage");
            	encounter.setUpdateDateTime(new java.util.Date());
            	encounter.setUpdateUser(userid);
            	encounter.setVersion(1);
            	encounter.store();
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
    	return encounter;
    }

    public boolean hasTransactions(){
    	boolean bHasTransactions=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) total from Transactions a,HealthRecord b where a.healthRecordId=b.healthRecordId and b.personid=? and a.updatetime>=? and a.updatetime<=?");
            ps.setInt(1, Integer.parseInt(this.getPatientUID()));
            ps.setDate(2, new java.sql.Date(ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(this.getBegin())).getTime()));
            ps.setTimestamp(3, new java.sql.Timestamp(this.getEnd()==null?new java.util.Date().getTime():this.getEnd().getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                bHasTransactions=rs.getInt("total")>0;
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
    	return bHasTransactions;
    }
    
    public boolean hasInvoices(){
    	boolean bHasInvoices=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) total from OC_PATIENTINVOICES where OC_PATIENTINVOICE_PATIENTUID=? and OC_PATIENTINVOICE_DATE>=? and OC_PATIENTINVOICE_DATE<=?");
            ps.setInt(1, Integer.parseInt(this.getPatientUID()));
            ps.setDate(2, new java.sql.Date(ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(this.getBegin())).getTime()));
            ps.setTimestamp(3, new java.sql.Timestamp(this.getEnd()==null?new java.util.Date().getTime():this.getEnd().getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
            	bHasInvoices=rs.getInt("total")>0;
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
    	return bHasInvoices;
    }
    
    public static Vector getAccountedAccomodations(String encounterUID) {
        Vector invoicedAccomodations = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from OC_DEBETS where OC_DEBET_ENCOUNTERUID=? AND (OC_DEBET_CREDITED IS NULL OR OC_DEBET_CREDITED<>1) AND OC_DEBET_PRESTATIONUID in ('"+MedwanQuery.getInstance().getAccomodationPrestationUIDs().replaceAll(";","','")+"')");
            ps.setString(1, encounterUID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = Debet.get(rs.getInt("OC_DEBET_SERVERID") + "." + rs.getInt("OC_DEBET_OBJECTID"));
                invoicedAccomodations.add(debet);
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return invoicedAccomodations;
    }

    public static int getAdmittedOn(Date date,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE<=? and (OC_ENCOUNTER_ENDDATE IS NULL OR OC_ENCOUNTER_ENDDATE>=?) and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(date.getTime()));
            ps.setDate(2, new java.sql.Date(date.getTime()));
            ps.setString(3,encounterType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getEnteredBetween(Date begin,Date end,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,encounterType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getEnteredBetween(Date begin,Date end,String situation,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=? and OC_ENCOUNTER_SITUATION=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,situation);
            ps.setString(4,encounterType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getLeftBetween(Date begin,Date end,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ENCOUNTERS where OC_ENCOUNTER_ENDDATE>=? and OC_ENCOUNTER_ENDDATE<=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,encounterType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getLeftBetween(Date begin,Date end,String situation,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ENCOUNTERS where OC_ENCOUNTER_ENDDATE>=? and OC_ENCOUNTER_ENDDATE<=? and OC_ENCOUNTER_SITUATION=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,situation);
            ps.setString(4,encounterType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getLeftBetweenForOutcome(Date begin,Date end,String outcome,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(*) as total from OC_ENCOUNTERS where OC_ENCOUNTER_ENDDATE>=? and OC_ENCOUNTER_ENDDATE<=? and OC_ENCOUNTER_OUTCOME=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,outcome);
            ps.setString(4,encounterType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getDaysBetween(Date begin,Date end,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from OC_ENCOUNTERS where (OC_ENCOUNTER_ENDDATE>=? OR OC_ENCOUNTER_ENDDATE IS NULL) and OC_ENCOUNTER_BEGINDATE<=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,encounterType);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date b=rs.getDate("OC_ENCOUNTER_BEGINDATE");
                if(begin.after(b)){
                    b=new java.sql.Date(begin.getTime());
                }
                java.sql.Date e=rs.getDate("OC_ENCOUNTER_ENDDATE");
                if(e==null || e.after(end)){
                    e=new java.sql.Date(end.getTime());
                }
                long durationInDays=e.getTime()-b.getTime();
                durationInDays=1+Math.round(durationInDays/(1000*3600*24));
                total += durationInDays;
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getLeavingDaysBetween(Date begin,Date end,String encounterType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from OC_ENCOUNTERS where OC_ENCOUNTER_ENDDATE>=? and OC_ENCOUNTER_ENDDATE<=? and OC_ENCOUNTER_TYPE=?");
            ps.setDate(1, new java.sql.Date(begin.getTime()));
            ps.setDate(2, new java.sql.Date(end.getTime()));
            ps.setString(3,encounterType);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date b=rs.getDate("OC_ENCOUNTER_BEGINDATE");
                if(begin.after(b)){
                    b=new java.sql.Date(begin.getTime());
                }
                java.sql.Date e=rs.getDate("OC_ENCOUNTER_ENDDATE");
                if(e==null || e.after(end)){
                    e=new java.sql.Date(end.getTime());
                }
                long durationInDays=e.getTime()-b.getTime();
                durationInDays=1+Math.round(durationInDays/(1000*3600*24));
                total += durationInDays;
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    public static int getAccountedAccomodationDays(String encounterUID) {
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	String sQuery="select SUM(OC_DEBET_QUANTITY) as total from OC_DEBETS where OC_DEBET_ENCOUNTERUID=? AND (OC_DEBET_CREDITED IS NULL OR OC_DEBET_CREDITED<>1) AND OC_DEBET_PRESTATIONUID in ('"+MedwanQuery.getInstance().getAccomodationPrestationUIDs().replaceAll(";","','")+"')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1, encounterUID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return total;
    }

    //--- GET PATIENT -----------------------------------------------------------------------------
    public AdminPerson getPatient() {
        if (this.patient == null) {
            if (this.patientUID != null && this.patientUID.length() > 0) {
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPatient(AdminPerson.getAdminPerson(ad_conn, this.patientUID));
                try {
					ad_conn.close();
				} 
                catch (SQLException e) {
					e.printStackTrace();
				}
            } 
            else {
                this.patient = null;
            }
        }
        
        return patient;
    }

    public void setPatient(AdminPerson patient) {
        this.patient = patient;
    }

    public Bed getBed() {
        if (this.bed == null) {
            if (this.bedUID != null && this.bedUID.length() > 0) {
                this.setBed(Bed.get(bedUID));
            } else {
                this.bed = null;
            }
        }
        return this.bed;
    }

    public void setBed(Bed bed) {
        this.bed = bed;
    }

    public Service getService() {
        if (this.service == null) {
            if (this.serviceUID != null && this.serviceUID.length() > 0) {
                this.setService(Service.getService(this.serviceUID));
            } else {
                this.service = null;
            }
        }
        return service;
    }

    public void setService(Service service) {
        this.service = service;
    }

    public Service getDestination() {
        if (this.destination == null) {
            if (this.destinationUID != null && this.destinationUID.length() > 0) {
                this.setDestination(Service.getService(this.destinationUID));
            } else {
                this.destination = null;
            }
        }
        return destination;
    }

    public void setDestination(Service destination) {
        this.destination = destination;
    }

    //--- GET MANAGER -----------------------------------------------------------------------------
    public User getManager() {
        if (this.manager == null) {
            User tmpUser = new User();
            if (this.managerUID != null && this.managerUID.length() > 0) {
                boolean bCheck = tmpUser.initialize(Integer.parseInt(this.managerUID));
                if (bCheck) {
                    this.setManager(tmpUser);
                }
            } else {
                this.manager = null;
            }
        }
        return manager;
    }

    public void setManager(User manager) {
        this.manager = manager;
    }

    public String getManagerUID() {
        return this.managerUID;
    }

    public void setManagerUID(String managerUID) {
        this.managerUID = managerUID;
    }

    public String getServiceUID() {
        return this.serviceUID;
    }

    public void setServiceUID(String serviceUID) {
        this.serviceUID = serviceUID;
    }

    public String getDestinationUID() {
        return this.destinationUID;
    }

    public void setDestinationUID(String destinationUID) {
        this.destinationUID = destinationUID;
    }

    public String getBedUID() {
        return this.bedUID;
    }

    public void setBedUID(String bedUID) {
        this.bedUID = bedUID;
    }

    public String getPatientUID() {
        return patientUID;
    }

    public void setPatientUID(String patientUID) {
        this.patientUID = patientUID;
    }

    //--- GET DURATION IN DAYS --------------------------------------------------------------------
    public int getDurationInDays() throws ParseException {
    	if(MedwanQuery.getInstance().getConfigString("encounterDurationCalculationMethod","simple").equalsIgnoreCase("noLastDay")){
    		return getDurationInDaysNoLastDay();
    	}
        double duration;
        if (getEnd() != null) {
            duration = getEnd().getTime() - getBegin().getTime();
        } else {
            duration = new Date().getTime() - getBegin().getTime();
        }
        return new Double(Math.ceil(duration / (1000 * 60 * 60 * 24))).intValue();
    }

    public int getDurationInDaysNoLastDay() throws ParseException {
        double duration;
        if (getEnd() != null) {
            duration = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(getEnd())).getTime() - getBegin().getTime();
        } else {
            duration = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date())).getTime() - getBegin().getTime();
        }
        return new Double(Math.ceil(duration / (1000 * 60 * 60 * 24))).intValue();
    }

    //--- GET DURATION IN DAYS --------------------------------------------------------------------
    public double getDurationInDays(Date startdate) {
        double duration = 0;
        Date b = startdate;
        if (startdate.before(getBegin())) {
            b = getBegin();
        }
        if (getEnd() != null && getEnd().before(new Date())) {
            duration = getEnd().getTime() - b.getTime();
        } else {
            duration = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date())).getTime() - b.getTime();
        }
        return Math.ceil(duration / (1000 * 60 * 60 * 24));
    }

    public double getDurationInDays(Date startdate, Date enddate) {
        double duration = 0;
        Date b = startdate;
        if (startdate.before(getBegin())) {
            b = getBegin();
        }
        if (getEnd() != null && getEnd().before(enddate)) {
            duration = getEnd().getTime() - b.getTime();
        } else {
            duration = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(enddate)).getTime() - b.getTime();
        }
        return Math.ceil(duration / (1000 * 60 * 60 * 24));
    }

    //--- GET LAST ENCOUNTER SERVICE --------------------------------------------------------------
    public EncounterService getLastEncounterService() {
        EncounterService encounterService = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (getEnd() == null) {
                sSelect = "select * from OC_ENCOUNTER_SERVICES where " +
                        " OC_ENCOUNTER_SERVERID=? AND" +
                        " OC_ENCOUNTER_OBJECTID=? AND" +
                        " OC_ENCOUNTER_SERVICEENDDATE is NULL";
            } else {
                sSelect = "select * from OC_ENCOUNTER_SERVICES where " +
                        " OC_ENCOUNTER_SERVERID=? AND" +
                        " OC_ENCOUNTER_OBJECTID=?" +
                        " ORDER BY OC_ENCOUNTER_SERVICEBEGINDATE DESC";
            }
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
            ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
            rs = ps.executeQuery();
            if (rs.next()) {
                encounterService = new EncounterService();
                encounterService.managerUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_MANAGERUID"));
                encounterService.bedUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEDUID"));
                encounterService.serviceUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVICEUID"));
                encounterService.begin = rs.getTimestamp("OC_ENCOUNTER_SERVICEBEGINDATE");
                encounterService.end = rs.getTimestamp("OC_ENCOUNTER_SERVICEENDDATE");
            }
        } catch (Exception e) {
            Debug.println("OpenClinic => Encounter.java => get => " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return encounterService;
    }

    public void storeLastEncounterService() {
        //First get the actual last encounterservice
        if (getBed() != null) bedUID = getBed().getUid();
        if (getService() != null) serviceUID = getService().code;
        if (getManager() != null) managerUID = getManager().userid;
        EncounterService encounterService = getLastEncounterService();
        if (encounterService == null || !encounterService.serviceUID.equals(serviceUID) || !ScreenHelper.checkString(encounterService.bedUID).equals(ScreenHelper.checkString(bedUID)) || !ScreenHelper.checkString(encounterService.managerUID).equals(ScreenHelper.checkString(managerUID))) {
            PreparedStatement ps = null;
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try {
                //Data have changed, keep track of the changes
                //First check if new data do not conflict with existing data
                //-> if begindate < existing max enddate, refuse service
                if (encounterService != null && encounterService.end!=null && getBegin() != null && getEnd() != null && getBegin().before(encounterService.end)) {
                    return;
                }
                //First close the previous encounterservice
                String sSelect = " UPDATE OC_ENCOUNTER_SERVICES SET OC_ENCOUNTER_SERVICEENDDATE=?" +
                        " WHERE OC_ENCOUNTER_SERVERID = ? " +
                        " AND OC_ENCOUNTER_OBJECTID = ?" +
                        " AND OC_ENCOUNTER_SERVICEENDDATE IS NULL";
                ps = oc_conn.prepareStatement(sSelect);
                if (getTransferDate() == null) {
                    ps.setTimestamp(1, new Timestamp(new Date().getTime()));
                } else {
                    ps.setTimestamp(1, new Timestamp(getTransferDate().getTime()));
                }
                ps.setInt(2, Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(3, Integer.parseInt(getUid().split("\\.")[1]));
                int rows=ps.executeUpdate();
                ps.close();
                //Now insert a new encounterservice
                sSelect = "INSERT INTO OC_ENCOUNTER_SERVICES(OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID,OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_BEDUID,OC_ENCOUNTER_MANAGERUID,OC_ENCOUNTER_SERVICEENDDATE,OC_ENCOUNTER_SERVICEBEGINDATE)" +
                        " values(?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
                ps.setString(3, serviceUID);
                ps.setString(4, bedUID);
                ps.setString(5, managerUID);
                ps.setTimestamp(6, getEnd() != null ? new Timestamp(getEnd().getTime()) : null);
                if (getTransferDate() == null) {
                    ps.setTimestamp(7, new Timestamp(new Date().getTime()));
                } else {
                    ps.setTimestamp(7, new Timestamp(getTransferDate().getTime() + 1));
                }
                ps.execute();
            } catch (Exception e) {
                Debug.println("OpenClinic => Encounter.java => storeLastEncounterService => " + e.getMessage());
                e.printStackTrace();
            } finally {
                try {
                    if (ps != null) ps.close();
                    oc_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
    public void storeSingleEncounterService() {
        //First get the actual last encounterservice
        if (getBed() != null) bedUID = getBed().getUid();
        if (getService() != null) serviceUID = getService().code;
        if (getManager() != null) managerUID = getManager().userid;
        EncounterService encounterService = getLastEncounterService();
        if (encounterService == null || !encounterService.serviceUID.equals(serviceUID) || !ScreenHelper.checkString(encounterService.bedUID).equals(ScreenHelper.checkString(bedUID)) || !ScreenHelper.checkString(encounterService.managerUID).equals(ScreenHelper.checkString(managerUID))) {
            PreparedStatement ps = null;
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try {
                //Data have changed, keep track of the changes
                //First check if new data do not conflict with existing data
                //-> if begindate < existing max enddate, refuse service
                if (encounterService != null && getBegin() != null && getEnd() != null && getBegin().before(encounterService.end)) {
                    return;
                }
                //First delete the previous encounterservices
                String sSelect = " DELETE FROM OC_ENCOUNTER_SERVICES " +
                        " WHERE OC_ENCOUNTER_SERVERID = ? " +
                        " AND OC_ENCOUNTER_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
                ps.executeUpdate();
                ps.close();
                //Now insert a new encounterservice
                sSelect = "INSERT INTO OC_ENCOUNTER_SERVICES(OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID,OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_BEDUID,OC_ENCOUNTER_MANAGERUID,OC_ENCOUNTER_SERVICEENDDATE,OC_ENCOUNTER_SERVICEBEGINDATE)" +
                        " values(?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
                ps.setString(3, serviceUID);
                ps.setString(4, bedUID);
                ps.setString(5, managerUID);
                ps.setTimestamp(6, getEnd() != null ? new Timestamp(getEnd().getTime()) : null);
                if (getTransferDate() == null) {
                    ps.setTimestamp(7, new Timestamp(new Date().getTime()));
                } else {
                    ps.setTimestamp(7, new Timestamp(getTransferDate().getTime() + 1));
                }
                ps.execute();
            } catch (Exception e) {
                Debug.println("OpenClinic => Encounter.java => storeLastEncounterService => " + e.getMessage());
                e.printStackTrace();
            } finally {
                try {
                    if (ps != null) ps.close();
                    oc_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    public Date getMaxTransferDate(){
    	Date maxtransferdate=getBegin();
    	PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT max(OC_ENCOUNTER_BEGINDATE) as maxtransferdate from OC_ENCOUNTERS_VIEW" +
                    " where" +
                    " OC_ENCOUNTER_SERVERID=? AND" +
                    " OC_ENCOUNTER_OBJECTID=? ";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
            ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
            rs = ps.executeQuery();
            if (rs.next()) {
            	maxtransferdate=rs.getDate("maxtransferdate");
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    	return maxtransferdate;
    }
    public Vector getTransferHistory() {
        Vector transferHistory = new Vector();
        if(getUid()!=null){
	        PreparedStatement ps = null;
	        ResultSet rs = null;
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	
	        try {
	            String sSelect = "SELECT * from OC_ENCOUNTER_SERVICES" +
	                    " where" +
	                    " OC_ENCOUNTER_SERVERID=? AND" +
	                    " OC_ENCOUNTER_OBJECTID=? AND" +
	                    " OC_ENCOUNTER_SERVICEENDDATE IS NOT NULL" +
	                    " ORDER BY OC_ENCOUNTER_SERVICEENDDATE DESC";
	            ps = oc_conn.prepareStatement(sSelect);
	            ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
	            ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
	            rs = ps.executeQuery();
	            while (rs.next()) {
	                EncounterService encounterService = new EncounterService();
	                encounterService.begin = rs.getTimestamp("OC_ENCOUNTER_SERVICEBEGINDATE");
	                encounterService.end = rs.getTimestamp("OC_ENCOUNTER_SERVICEENDDATE");
	                encounterService.bedUID = rs.getString("OC_ENCOUNTER_BEDUID");
	                encounterService.serviceUID = rs.getString("OC_ENCOUNTER_SERVICEUID");
	                encounterService.managerUID = rs.getString("OC_ENCOUNTER_MANAGERUID");
	                transferHistory.add(encounterService);
	            }
	        }
	        catch (Exception e) {
	            e.printStackTrace();
	        }
	        finally {
	            try {
	                if (rs != null) rs.close();
	                if (ps != null) ps.close();
	                oc_conn.close();
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
	        }
        }
	    return transferHistory;
    }

    public Vector getFullTransferHistory() {
        Vector transferHistory = new Vector();
        if(getUid()!=null){
	        PreparedStatement ps = null;
	        ResultSet rs = null;
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	
	        try {
	            String sSelect = "SELECT * from OC_ENCOUNTER_SERVICES" +
	                    " where" +
	                    " OC_ENCOUNTER_SERVERID=? AND" +
	                    " OC_ENCOUNTER_OBJECTID=? " +
	                    " ORDER BY OC_ENCOUNTER_SERVICEBEGINDATE ASC";
	            ps = oc_conn.prepareStatement(sSelect);
	            ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
	            ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
	            rs = ps.executeQuery();
	            while (rs.next()) {
	                EncounterService encounterService = new EncounterService();
	                encounterService.begin = rs.getTimestamp("OC_ENCOUNTER_SERVICEBEGINDATE");
	                encounterService.end = rs.getTimestamp("OC_ENCOUNTER_SERVICEENDDATE");
	                encounterService.bedUID = rs.getString("OC_ENCOUNTER_BEDUID");
	                encounterService.serviceUID = rs.getString("OC_ENCOUNTER_SERVICEUID");
	                encounterService.managerUID = rs.getString("OC_ENCOUNTER_MANAGERUID");
	                transferHistory.add(encounterService);
	            }
	        }
	        catch (Exception e) {
	            e.printStackTrace();
	        }
	        finally {
	            try {
	                if (rs != null) rs.close();
	                if (ps != null) ps.close();
	                oc_conn.close();
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
	        }
        }
	    return transferHistory;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Encounter get(String uid) {
        Encounter encounter = (Encounter)MedwanQuery.getInstance().getObjectCache().getObject("encounter",uid);
        if(encounter!=null){
            return encounter;
        }
        PreparedStatement ps = null;
        ResultSet rs = null;

        encounter = new Encounter();

        if (uid != null && uid.length() > 0) {
            String sUids[] = uid.split("\\.");
            if (sUids.length == 2) {
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try {
                    String sSelect = " SELECT * FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ? " +
                            " AND OC_ENCOUNTER_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(sUids[0]));
                    ps.setInt(2, Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if (rs.next()) {
                        encounter.patientUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                        encounter.destinationUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));

                        encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                        encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                        encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                        encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                        encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                        encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                        encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                        encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                        encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                        encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                        encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                        encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));
                        

                        //Now find the most recent service for this encounter
                        EncounterService encounterService = encounter.getLastEncounterService();
                        if (encounterService != null) {
                            encounter.serviceUID = encounterService.serviceUID;
                            encounter.managerUID = encounterService.managerUID;
                            encounter.bedUID = encounterService.bedUID;
                        }
                    }
                } catch (Exception e) {
                    Debug.println("OpenClinic => Encounter.java => get => " + e.getMessage());
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                        oc_conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("encounter",encounter);
        return encounter;
    }

    //--- RESET SERVICE DATES ---------------------------------------------------------------------
    public void resetServiceDates() {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sQuery = "select count(*) total from OC_ENCOUNTER_SERVICES where OC_ENCOUNTER_SERVERID=? AND OC_ENCOUNTER_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1, Integer.parseInt(getUid().split("\\.")[0]));
            ps.setInt(2, Integer.parseInt(getUid().split("\\.")[1]));
            rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getInt("total") == 1) {
                    rs.close();
                    ps.close();
                    sQuery = "update OC_ENCOUNTER_SERVICES set OC_ENCOUNTER_SERVICEBEGINDATE=?,OC_ENCOUNTER_SERVICEENDDATE=?" +
                            " where " +
                            " OC_ENCOUNTER_SERVERID=? AND " +
                            " OC_ENCOUNTER_OBJECTID=?";
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setDate(1, getBegin() != null ? new java.sql.Date(getBegin().getTime()) : null);
                    ps.setDate(2, getEnd() != null ? new java.sql.Date(getEnd().getTime()) : null);
                    ps.setInt(3, Integer.parseInt(getUid().split("\\.")[0]));
                    ps.setInt(4, Integer.parseInt(getUid().split("\\.")[1]));
                    ps.executeUpdate();
                }
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store() {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect, sInsert, sDelete;
        int iVersion = 1;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (this.getUid() != null && this.getUid().length() > 0) {
                ids = this.getUid().split("\\.");
                if (ids.length == 2) {
                    sSelect = " SELECT * FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ? " +
                            " AND OC_ENCOUNTER_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if (rs.next()) {
                        iVersion = rs.getInt("OC_ENCOUNTER_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_ENCOUNTERS_HISTORY(OC_ENCOUNTER_SERVERID," +
                            "OC_ENCOUNTER_OBJECTID," +
                            "OC_ENCOUNTER_TYPE," +
                            "OC_ENCOUNTER_BEGINDATE," +
                            "OC_ENCOUNTER_ENDDATE," +
                            "OC_ENCOUNTER_PATIENTUID," +
                            "OC_ENCOUNTER_CREATETIME," +
                            "OC_ENCOUNTER_UPDATETIME," +
                            "OC_ENCOUNTER_UPDATEUID," +
                            "OC_ENCOUNTER_VERSION," +
                            "OC_ENCOUNTER_OUTCOME," +
                            "OC_ENCOUNTER_DESTINATIONUID," +
                            "OC_ENCOUNTER_ORIGIN," +
                            "OC_ENCOUNTER_SITUATION," +
                            "OC_ENCOUNTER_CATEGORIES) " +
                            " SELECT OC_ENCOUNTER_SERVERID," +
                            " OC_ENCOUNTER_OBJECTID," +
                            " OC_ENCOUNTER_TYPE," +
                            " OC_ENCOUNTER_BEGINDATE," +
                            " OC_ENCOUNTER_ENDDATE," +
                            " OC_ENCOUNTER_PATIENTUID," +
                            " OC_ENCOUNTER_CREATETIME," +
                            " OC_ENCOUNTER_UPDATETIME," +
                            " OC_ENCOUNTER_UPDATEUID," +
                            " OC_ENCOUNTER_VERSION," +
                            " OC_ENCOUNTER_OUTCOME," +
                            " OC_ENCOUNTER_DESTINATIONUID," +
                            " OC_ENCOUNTER_ORIGIN," +
                            " OC_ENCOUNTER_SITUATION," +
                            " OC_ENCOUNTER_CATEGORIES" +
                            " FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ?" +
                            " AND OC_ENCOUNTER_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ? " +
                            " AND OC_ENCOUNTER_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            } else {
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_ENCOUNTERS") + ""};
            }
            if (ids.length == 2) {
                sInsert = " INSERT INTO OC_ENCOUNTERS" +
                        "(" +
                        " OC_ENCOUNTER_SERVERID," +
                        " OC_ENCOUNTER_OBJECTID," +
                        " OC_ENCOUNTER_TYPE," +
                        " OC_ENCOUNTER_BEGINDATE," +
                        " OC_ENCOUNTER_ENDDATE," +
                        " OC_ENCOUNTER_PATIENTUID," +
                        " OC_ENCOUNTER_CREATETIME," +
                        " OC_ENCOUNTER_UPDATETIME," +
                        " OC_ENCOUNTER_UPDATEUID," +
                        " OC_ENCOUNTER_VERSION," +
                        " OC_ENCOUNTER_OUTCOME," +
                        " OC_ENCOUNTER_DESTINATIONUID," +
                        " OC_ENCOUNTER_ORIGIN," +
                        " OC_ENCOUNTER_SITUATION," +
                        " OC_ENCOUNTER_CATEGORIES" +
                        ") " +
                        " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1, Integer.parseInt(ids[0]));
                while(!MedwanQuery.getInstance().validateNewOpenclinicCounter("OC_ENCOUNTERS","OC_ENCOUNTER_OBJECTID",ids[1])){
                    ids[1] =  MedwanQuery.getInstance().getOpenclinicCounter("OC_ENCOUNTERS") + "";
                }
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setString(3, this.getType());
                ps.setTimestamp(4, new Timestamp(this.getBegin().getTime()));
                if (this.getEnd() == null) {
                    ps.setNull(5, java.sql.Types.TIMESTAMP);
                } else {
                    ps.setTimestamp(5, new Timestamp(this.getEnd().getTime()));
                }
                if (this.getPatient() != null) {
                    ps.setString(6, ScreenHelper.checkString(this.getPatient().personid));
                } else {
                    ps.setString(6, "");
                }
                ps.setTimestamp(7, new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(8, new Timestamp(new Date().getTime()));
                ps.setString(9, this.getUpdateUser());
                ps.setInt(10, iVersion);
                ps.setString(11, this.getOutcome());
                if (this.getDestination() != null) {
                    ps.setString(12, ScreenHelper.checkString(this.getDestination().code));
                } else {
                    ps.setString(12, "");
                }
                ps.setString(13, this.getOrigin());
                ps.setString(14, this.getSituation());
                ps.setString(15, this.getCategories());
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
                storeLastEncounterService();
            }
            String sUpdate="";
            int housekeepingcounter = MedwanQuery.getInstance().getOpenclinicCounter("EncounterHouseKeeping");
            if(housekeepingcounter>100){
                ps = oc_conn.prepareStatement("update OC_COUNTERS set OC_COUNTER_VALUE=? where OC_COUNTER_NAME=?");
                ps.setInt(1, 1);
                ps.setString(2, "EncounterHouseKeeping");
                ps.execute();
                ps.close();
                MedwanQuery.getInstance().getUsedCounters().put("EncounterHouseKeeping",1);
	            sUpdate = "update oc_encounter_services set oc_encounter_serviceenddate= " +
	                    " (select max(oc_encounter_enddate)" +
	                    "   from oc_encounters a" +
	                    "   where" +
	                    "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	                    "   a.oc_encounter_enddate<oc_encounter_services.oc_encounter_serviceenddate)" +
	                    "where exists " +
	                    " (select a.oc_encounter_enddate" +
	                    "   from oc_encounters a" +
	                    "   where" +
	                    "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	                    "   a.oc_encounter_enddate<oc_encounter_services.oc_encounter_serviceenddate)";
	            ps = oc_conn.prepareStatement(sUpdate);
	            ps.executeUpdate();
	            ps.close();
	
	            sUpdate = "update oc_encounter_services set oc_encounter_servicebegindate= " +
	                    " (select max(oc_encounter_begindate)" +
	                    "   from oc_encounters a" +
	                    "   where" +
	                    "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	                    "   a.oc_encounter_begindate>oc_encounter_services.oc_encounter_servicebegindate)" +
	                    "where exists " +
	                    " (select a.oc_encounter_begindate" +
	                    "   from oc_encounters a" +
	                    "   where" +
	                    "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	                    "   a.oc_encounter_begindate>oc_encounter_services.oc_encounter_servicebegindate)";
	            ps = oc_conn.prepareStatement(sUpdate);
	            ps.executeUpdate();
	            ps.close();
	
	            sUpdate = "update oc_encounter_services set oc_encounter_serviceenddate= " +
	            " (select max(oc_encounter_enddate) oc_encounter_enddate" +
	            "   from oc_encounters a" +
	            "   where" +
	            "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid)" +
	            "where " +
	            " oc_encounter_serviceenddate is null and" +
	            " exists (" +
	            "  select * from oc_encounters a" +
	            "  where" +
	            "  a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	            "  oc_encounter_enddate is not null)";
				ps = oc_conn.prepareStatement(sUpdate);
				ps.executeUpdate();
				ps.close();
				
				sUpdate = "update oc_encounter_services  set oc_encounter_serviceenddate=(select max(oc_encounter_enddate)"+
				" from oc_encounters a where"+
				" a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid)"+
				" where"+
				" oc_encounter_serviceenddate is null and"+
				" exists (select * from oc_encounters a where"+
				" a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and"+
				" a.oc_encounter_enddate is not null)";
				ps = oc_conn.prepareStatement(sUpdate);
				ps.executeUpdate();
				ps.close();
            }
            resetServiceDates();
            
            try{
            	//Basic syntax (MS SQL Server)
	            sUpdate = "update oc_encounter_services set oc_encounter_serviceenddate= " +
	                    " (select oc_encounter_servicebegindate" +
	                    "   from oc_encounter_services a" +
	                    "   where" +
	                    "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	                    "   a.oc_encounter_servicebegindate<oc_encounter_services.oc_encounter_serviceenddate and" +
	                    "   a.oc_encounter_serviceenddate is null)" +
	                    "where " +
	                    " exists (select oc_encounter_servicebegindate" +
	                    "   from oc_encounter_services a" +
	                    "   where" +
	                    "   a.oc_encounter_objectid=oc_encounter_services.oc_encounter_objectid and" +
	                    "   a.oc_encounter_servicebegindate<oc_encounter_services.oc_encounter_serviceenddate and" +
	                    "   a.oc_encounter_serviceenddate is null) and" +
	                    "   oc_encounter_objectid=?";
	            ps = oc_conn.prepareStatement(sUpdate);
	            ps.setInt(1,Integer.parseInt(getUid().split("\\.")[1]));
	            ps.executeUpdate();
	            ps.close();
            }
            catch(Exception e2){
            	//Alternative syntax (MySQL)
	            sUpdate = "update oc_encounter_services a,oc_encounter_services b set a.oc_encounter_serviceenddate=b.oc_encounter_servicebegindate " +
                "   where" +
                "   b.oc_encounter_objectid=a.oc_encounter_objectid and" +
                "   b.oc_encounter_servicebegindate<a.oc_encounter_serviceenddate and" +
                "   b.oc_encounter_serviceenddate is null and" +
                "   b.oc_encounter_objectid=?";
		        ps = oc_conn.prepareStatement(sUpdate);
		        ps.setInt(1,Integer.parseInt(getUid().split("\\.")[1]));
		        ps.executeUpdate();
		        ps.close();
            }

        } catch (Exception e) {
            Debug.println("OpenClinic => Encounter.java => store => " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("encounter",this);
    }

    public void storeWithoutServiceHistory() {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect, sInsert, sDelete;

        int iVersion = 1;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (this.getUid() != null && this.getUid().length() > 0) {
                ids = this.getUid().split("\\.");
                if (ids.length == 2) {
                    sSelect = " SELECT * FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ? " +
                            " AND OC_ENCOUNTER_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if (rs.next()) {
                        iVersion = rs.getInt("OC_ENCOUNTER_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_ENCOUNTERS_HISTORY(OC_ENCOUNTER_SERVERID," +
                            "OC_ENCOUNTER_OBJECTID," +
                            "OC_ENCOUNTER_TYPE," +
                            "OC_ENCOUNTER_BEGINDATE," +
                            "OC_ENCOUNTER_ENDDATE," +
                            "OC_ENCOUNTER_PATIENTUID," +
                            "OC_ENCOUNTER_CREATETIME," +
                            "OC_ENCOUNTER_UPDATETIME," +
                            "OC_ENCOUNTER_UPDATEUID," +
                            "OC_ENCOUNTER_VERSION," +
                            "OC_ENCOUNTER_OUTCOME," +
                            "OC_ENCOUNTER_DESTINATIONUID," +
                            "OC_ENCOUNTER_ORIGIN," +
                            "OC_ENCOUNTER_SITUATION," +
                            "OC_ENCOUNTER_CATEGORIES) " +
                            " SELECT OC_ENCOUNTER_SERVERID," +
                            " OC_ENCOUNTER_OBJECTID," +
                            " OC_ENCOUNTER_TYPE," +
                            " OC_ENCOUNTER_BEGINDATE," +
                            " OC_ENCOUNTER_ENDDATE," +
                            " OC_ENCOUNTER_PATIENTUID," +
                            " OC_ENCOUNTER_CREATETIME," +
                            " OC_ENCOUNTER_UPDATETIME," +
                            " OC_ENCOUNTER_UPDATEUID," +
                            " OC_ENCOUNTER_VERSION," +
                            " OC_ENCOUNTER_OUTCOME," +
                            " OC_ENCOUNTER_DESTINATIONUID," +
                            " OC_ENCOUNTER_ORIGIN," +
                            " OC_ENCOUNTER_SITUATION," +
                            " OC_ENCOUNTER_CATEGORIES" +
                            " FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ?" +
                            " AND OC_ENCOUNTER_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_ENCOUNTERS " +
                            " WHERE OC_ENCOUNTER_SERVERID = ? " +
                            " AND OC_ENCOUNTER_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            } else {
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_ENCOUNTERS") + ""};
            }
            
            if (ids.length == 2) {
                sInsert = " INSERT INTO OC_ENCOUNTERS" +
                        "(" +
                        " OC_ENCOUNTER_SERVERID," +
                        " OC_ENCOUNTER_OBJECTID," +
                        " OC_ENCOUNTER_TYPE," +
                        " OC_ENCOUNTER_BEGINDATE," +
                        " OC_ENCOUNTER_ENDDATE," +
                        " OC_ENCOUNTER_PATIENTUID," +
                        " OC_ENCOUNTER_CREATETIME," +
                        " OC_ENCOUNTER_UPDATETIME," +
                        " OC_ENCOUNTER_UPDATEUID," +
                        " OC_ENCOUNTER_VERSION," +
                        " OC_ENCOUNTER_OUTCOME," +
                        " OC_ENCOUNTER_DESTINATIONUID," +
                        " OC_ENCOUNTER_ORIGIN," +
                        " OC_ENCOUNTER_SITUATION," +
                        " OC_ENCOUNTER_CATEGORIES" +
                        ") " +
                        " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1, Integer.parseInt(ids[0]));
                while(!MedwanQuery.getInstance().validateNewOpenclinicCounter("OC_ENCOUNTERS","OC_ENCOUNTER_OBJECTID",ids[1])){
                    ids[1] =  MedwanQuery.getInstance().getOpenclinicCounter("OC_ENCOUNTERS") + "";
                }
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setString(3, this.getType());
                ps.setTimestamp(4, new Timestamp(this.getBegin().getTime()));
                if (this.getEnd() == null) {
                    ps.setNull(5, java.sql.Types.TIMESTAMP);
                } else {
                    ps.setTimestamp(5, new Timestamp(this.getEnd().getTime()));
                }
                if (this.getPatient() != null) {
                    ps.setString(6, ScreenHelper.checkString(this.getPatient().personid));
                } else {
                    ps.setString(6, "");
                }
                ps.setTimestamp(7, new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(8, new Timestamp(new Date().getTime()));
                ps.setString(9, this.getUpdateUser());
                ps.setInt(10, iVersion);
                ps.setString(11, this.getOutcome());
                if (this.getDestination() != null) {
                    ps.setString(12, ScreenHelper.checkString(this.getDestination().code));
                } else {
                    ps.setString(12, "");
                }
                ps.setString(13, this.getOrigin());
                ps.setString(14, this.getSituation());
                ps.setString(15, this.getCategories());
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
                storeSingleEncounterService();
            }
            String sUpdate="";
            int housekeepingcounter = MedwanQuery.getInstance().getOpenclinicCounter("EncounterHouseKeeping");
            if(housekeepingcounter>100){
                ps = oc_conn.prepareStatement("update OC_COUNTERS set OC_COUNTER_VALUE=? where OC_COUNTER_NAME=?");
                ps.setInt(1, 1);
                ps.setString(2, "EncounterHouseKeeping");
                ps.execute();
                ps.close();
                MedwanQuery.getInstance().getUsedCounters().put("EncounterHouseKeeping",1);
            }
            resetServiceDates();
        }
        catch (Exception e) {
            Debug.println("OpenClinic => Encounter.java => store => " + e.getMessage());
            e.printStackTrace();
        } 
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } 
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        MedwanQuery.getInstance().getObjectCache().putObject("encounter",this);
    }

    //--- GET ACTIVE ENCOUNTER FOR BED ------------------------------------------------------------
    public static Encounter getActiveEncounterForBed(Bed bed) {
        Encounter activeEncounter = null;
        String sSelect = " SELECT OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID " +
		                 " FROM OC_ENCOUNTER_SERVICES" +
		                 " WHERE OC_ENCOUNTER_BEDUID = ? " +
		                 " AND (OC_ENCOUNTER_SERVICEENDDATE IS NULL" +
		                 " OR OC_ENCOUNTER_SERVICEENDDATE > ?)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, bed.getUid());
            ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime()));

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String sUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
                activeEncounter = Encounter.get(sUID);
            }

            rs.close();
            ps.close();
        } 
        catch (Exception e) {
            e.printStackTrace();
        }

		// close connection
		try{
			oc_conn.close();
		}
		catch(SQLException e){
			e.printStackTrace();
		}
		
        return activeEncounter;
    }

    //--- GET ACTIVE ENCOUNTER --------------------------------------------------------------------
    public static Encounter getActiveEncounter(String patientUID) {
        Encounter activeEncounter = null;
        PreparedStatement ps;
        ResultSet rs;

        String sSelect = " SELECT OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID " +
				         " FROM OC_ENCOUNTERS" +
				         " WHERE OC_ENCOUNTER_PATIENTUID = ? " +
				         " AND OC_ENCOUNTER_ENDDATE IS NULL and NOT OC_ENCOUNTER_TYPE = 'coverage'";

		Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
		    ps = oc_conn.prepareStatement(sSelect);
		    ps.setString(1, patientUID);
		
		    rs = ps.executeQuery();
		
		    if (rs.next()) {
		        String sUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
		        activeEncounter = Encounter.get(sUID);
		    }
		    else {
				sSelect = " SELECT OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID " +
				" FROM OC_ENCOUNTERS" +
				" WHERE OC_ENCOUNTER_PATIENTUID = ? " +
				" AND OC_ENCOUNTER_ENDDATE > ? and NOT OC_ENCOUNTER_TYPE = 'coverage' order by OC_ENCOUNTER_ENDDATE DESC,OC_ENCOUNTER_OBJECTID DESC";
				rs.close();
				ps.close();
				ps = oc_conn.prepareStatement(sSelect);
				ps.setString(1, patientUID);
				ps.setTimestamp(2, new Timestamp(ScreenHelper.getSQLDate(ScreenHelper.getDate()).getTime()));
				rs = ps.executeQuery();
				if (rs.next()) {
					String sUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
					activeEncounter = Encounter.get(sUID);
				}
		    }
		    rs.close();
		    ps.close();
		} 
		catch (Exception e) {
		    e.printStackTrace();
		}

		// close connection
		try{
			oc_conn.close();
		}
		catch(SQLException e){
			e.printStackTrace();
		}
		
        return activeEncounter;
    }
    
    //--- GET INACTIVE ENCOUNTERS -----------------------------------------------------------------
    public static Vector getInactiveEncounters(String sPatientUID, String sType, java.util.Date dLimit){
    	Vector encounters = new Vector();
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try{
            if(sPatientUID!=null && sPatientUID.length() > 0){
                String sSql = "SELECT * FROM OC_ENCOUNTERS"+
                              " WHERE OC_ENCOUNTER_PATIENTUID = ?"+
                              "  AND lower(OC_ENCOUNTER_TYPE) = ?"+
					          "  AND (OC_ENCOUNTER_ENDDATE IS NOT NULL AND OC_ENCOUNTER_ENDDATE < ?)"+
					          " ORDER BY OC_ENCOUNTER_ENDDATE DESC";                
                ps = oc_conn.prepareStatement(sSql);
                ps.setString(1,sPatientUID);
                ps.setString(2,sType);
                ps.setTimestamp(3,new Timestamp(dLimit.getTime()));
                rs = ps.executeQuery();

                Encounter encounter = null;
                while(rs.next()){
                    encounter = new Encounter();
                    encounter.patientUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                    encounter.destinationUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));

                    encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                    encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                    encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                    encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                    encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                    encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                    encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                    encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                    encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                    encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                    encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                    encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                    encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));
                    
                    // find the most recent service for this encounter
                    EncounterService encounterService = encounter.getLastEncounterService();
                    if(encounterService!=null){
                        encounter.serviceUID = encounterService.serviceUID;
                        encounter.managerUID = encounterService.managerUID;
                        encounter.bedUID = encounterService.bedUID;
                    }
                    
                    encounters.add(encounter);
                }
            }            
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
        	try{
        		if(rs!=null) rs.close();
        		if(ps!=null) ps.close();
        	}
        	catch(Exception e){
        		e.printStackTrace();
        	}
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return encounters;
    }

    //--- GET INACTIVE ENCOUNTER BEFORE -----------------------------------------------------------
    public static Encounter getInactiveEncounterBefore(String patientUID, String type, java.util.Date dLimit) {
        Encounter encounter = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps;
            ResultSet rs;

            String sSelectPrevEncounter = " SELECT *" +
					                      " FROM OC_ENCOUNTERS" +
					                      " WHERE OC_ENCOUNTER_PATIENTUID = ? " +
					                      " AND lower(OC_ENCOUNTER_TYPE) = ? " +
					                      " AND (OC_ENCOUNTER_ENDDATE IS NOT NULL" +
					                      " OR OC_ENCOUNTER_ENDDATE < ?)" +
					                      " ORDER BY OC_ENCOUNTER_ENDDATE DESC";
            if (patientUID != null && patientUID.length() > 0) {
                ps = oc_conn.prepareStatement(sSelectPrevEncounter);
                ps.setString(1, patientUID);
                ps.setString(2, type);
                ps.setTimestamp(3, new Timestamp(dLimit.getTime()));


                rs = ps.executeQuery();

                if (rs.next()) {
                    encounter = new Encounter();
                    encounter.patientUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                    encounter.destinationUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));

                    encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                    encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                    encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                    encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                    encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                    encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                    encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                    encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                    encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                    encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                    encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                    encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                    encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));
                    //Now find the most recent service for this encounter
                    EncounterService encounterService = encounter.getLastEncounterService();
                    if (encounterService != null) {
                        encounter.serviceUID = encounterService.serviceUID;
                        encounter.managerUID = encounterService.managerUID;
                        encounter.bedUID = encounterService.bedUID;
                    }
                }

                rs.close();
                ps.close();

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return encounter;
    }

    public String getEncounterDisplayName(String language) {
        String sType = "", sBegin = "", sEnd = "";

        if (ScreenHelper.checkString(this.getType()).length() > 0) {
            sType = ", " + MedwanQuery.getInstance().getLabel("encountertype", this.getType(), language);
        }

        if (this.getBegin() != null) {
            sBegin = ", " + ScreenHelper.stdDateFormat.format(this.getBegin());
        }

        if (this.getEnd() != null) {
            sEnd = " -> " + ScreenHelper.stdDateFormat.format(this.getEnd());
        }

        return this.getUid() + sBegin + sEnd + sType;
    }

    public String getEncounterDisplayNameService(String language) {
        String sType = "", sBegin = "", sEnd = "", sService="";

        if (ScreenHelper.checkString(this.getType()).length() > 0) {
            sType = ", " + MedwanQuery.getInstance().getLabel("encountertype", this.getType(), language);
        }

        if (this.getBegin() != null) {
            sBegin = ", " + ScreenHelper.stdDateFormat.format(this.getBegin());
        }

        if (this.getEnd() != null) {
            sEnd = " -> " + ScreenHelper.stdDateFormat.format(this.getEnd());
        }
        if (ScreenHelper.checkString(this.getServiceUID()).length() > 0) {
            sService = MedwanQuery.getInstance().getLabel("service", this.getServiceUID(), language);
        }


        return sService + sBegin + sEnd + sType;
    }

    public String getEncounterDisplayNameNoDate(String language) {
        String sType = "", sBegin = "", sEnd = "";

        if (ScreenHelper.checkString(this.getType()).length() > 0) {
            sType = ", " + MedwanQuery.getInstance().getLabel("encountertype", this.getType(), language);
        }

        return this.getUid() + sBegin + sEnd + sType+" ("+this.getServiceUID()+")";
    }

    public static Vector selectEncounters(String serverID, String objectID, String beginDate, String endDate, String type,
                                          String managerID, String serviceID, String bedID, String patientID, String sortColumn) {
        PreparedStatement ps;
        ResultSet rs;

        Vector vEncounters = new Vector();

        String sSelect = "SELECT *" +
                " FROM OC_ENCOUNTERS_VIEW" +
                " WHERE" +
                " 1=1 ";

        String sConditions = "";

        if (serverID.length() > 0) {
            sConditions += " OC_ENCOUNTER_SERVERID = ? AND";
        }
        if (objectID.length() > 0) {
            sConditions += " OC_ENCOUNTER_OBJECTID = ? AND";
        }
        if (beginDate.length() > 0) {
            sConditions += " OC_ENCOUNTER_BEGINDATE > ? AND";
        }
        if (endDate.length() > 0) {
            sConditions += " OC_ENCOUNTER_ENDDATE < ? AND";
        }
        if (type.length() > 0) {
            sConditions += " OC_ENCOUNTER_TYPE = ? AND";
        }
        if (managerID.length() > 0) {
            sConditions += " OC_ENCOUNTER_MANAGERUID = ? AND";
        }
        if (serviceID.length() > 0) {
            sConditions += " OC_ENCOUNTER_SERVICEUID = ? AND";
        }
        if (bedID.length() > 0) {
            sConditions += " OC_ENCOUNTER_BEDUID = ? AND";
        }
        if (patientID.length() > 0) {
            sConditions += " OC_ENCOUNTER_PATIENTUID = ? AND";
        }

        if (sConditions.length() > 0) {
            sSelect = sSelect + " AND  " + sConditions;
            sSelect = sSelect.substring(0, sSelect.length() - 3);

	        if (sortColumn.length() > 0) {
	            sSelect += " ORDER BY " + sortColumn;
	        }
	
	        int i = 1;
	
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	        try {
	            ps = oc_conn.prepareStatement(sSelect);
	
	            if (serverID.length() > 0) {
	                ps.setInt(i++, Integer.parseInt(serverID));
	            }
	            if (objectID.length() > 0) {
	                ps.setInt(i++, Integer.parseInt(objectID));
	            }
	            if (beginDate.length() > 0) {
	                ps.setTimestamp(i++, new Timestamp(ScreenHelper.getSQLDate(beginDate).getTime()));
	            }
	            if (endDate.length() > 0) {
	                ps.setTimestamp(i++, new Timestamp(ScreenHelper.getSQLDate(endDate).getTime()));
	            }
	            if (type.length() > 0) {
	                ps.setString(i++, type);
	            }
	            if (managerID.length() > 0) {
	                ps.setString(i++, managerID);
	            }
	            if (serviceID.length() > 0) {
	                ps.setString(i++, serviceID);
	            }
	            if (bedID.length() > 0) {
	                ps.setString(i++, bedID);
	            }
	            if (patientID.length() > 0) {
	                ps.setString(i++, patientID);
	            }
	
	            rs = ps.executeQuery();
	
	            String sTmp, sTmp1;
	
	            Encounter eTmp;
	
	            while (rs.next()) {
	                eTmp = new Encounter();
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID"));
	                sTmp1 = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
	
	                if (sTmp.length() > 0 && sTmp1.length() > 0) {
	                    eTmp.setUid(sTmp + "." + sTmp1);
	                }
	
	                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEGINDATE")).length() > 0) {
	                    eTmp.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
	                }
	
	                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ENDDATE")).length() > 0) {
	                    eTmp.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_MANAGERUID"));
	                if (sTmp.length() > 0) {
	                    eTmp.managerUID = sTmp;
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVICEUID"));
	                if (sTmp.length() > 0) {
	                    eTmp.serviceUID = sTmp;
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));
	                if (sTmp.length() > 0) {
	                    eTmp.destinationUID = sTmp;
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEDUID"));
	                if (sTmp.length() > 0) {
	                    eTmp.bedUID = sTmp;
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
	                if (sTmp.length() > 0) {
	                    eTmp.patientUID = sTmp;
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE"));
	                if (sTmp.length() > 0) {
	                    eTmp.setType(sTmp);
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME"));
	                if (sTmp.length() > 0) {
	                    eTmp.setOutcome(sTmp);
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN"));
	                if (sTmp.length() > 0) {
	                    eTmp.setOrigin(sTmp);
	                }
	
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION"));
	                if (sTmp.length() > 0) {
	                    eTmp.setSituation(sTmp);
	                }
	                
	                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES"));
	                if (sTmp.length() > 0) {
	                    eTmp.setCategories(sTmp);
	                }
	                
	                eTmp.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
	
	                vEncounters.addElement(eTmp);
	            }
	
	            rs.close();
	            ps.close();
	            oc_conn.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
        }
        return vEncounters;
    }

    public static Vector selectEncountersUnique(String serverID, String objectID, String beginDate, String endDate, String type,
                                                String managerID, String serviceID, String bedID, String patientID, String sortColumn) {
        PreparedStatement ps;
        ResultSet rs;

        Vector vEncounters = new Vector();

        String sSelect = "SELECT *" +
                " FROM OC_ENCOUNTERS" +
                " WHERE" +
                " 1=1 ";

        String sConditions = "";

        if (serverID.length() > 0) {
            sConditions += " OC_ENCOUNTER_SERVERID = ? AND";
        }
        if (objectID.length() > 0) {
            sConditions += " OC_ENCOUNTER_OBJECTID = ? AND";
        }
        if (beginDate.length() > 0) {
            sConditions += " OC_ENCOUNTER_BEGINDATE > ? AND";
        }
        if (endDate.length() > 0) {
            sConditions += " OC_ENCOUNTER_ENDDATE < ? AND";
        }
        if (type.length() > 0) {
            sConditions += " OC_ENCOUNTER_TYPE = ? AND";
        }
        if (patientID.length() > 0) {
            sConditions += " OC_ENCOUNTER_PATIENTUID = ? AND";
        }

        if (sConditions.length() > 0) {
            sSelect = sSelect + " AND  " + sConditions;
            sSelect = sSelect.substring(0, sSelect.length() - 3);
        }

        if (sortColumn.length() > 0) {
            sSelect += " ORDER BY " + sortColumn;
        }

        int i = 1;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);

            if (serverID.length() > 0) {
                ps.setInt(i++, Integer.parseInt(serverID));
            }
            if (objectID.length() > 0) {
                ps.setInt(i++, Integer.parseInt(objectID));
            }
            if (beginDate.length() > 0) {
                ps.setTimestamp(i++, new Timestamp(ScreenHelper.getSQLDate(beginDate).getTime()));
            }
            if (endDate.length() > 0) {
                ps.setTimestamp(i++, new Timestamp(ScreenHelper.getSQLDate(endDate).getTime()));
            }
            if (type.length() > 0) {
                ps.setString(i++, type);
            }
            if (patientID.length() > 0) {
                ps.setString(i++, patientID);
            }

            rs = ps.executeQuery();

            String sTmp, sTmp1;

            Encounter eTmp;

            while (rs.next()) {
                eTmp = new Encounter();

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID"));
                sTmp1 = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));

                if (sTmp.length() > 0 && sTmp1.length() > 0) {
                    eTmp.setUid(sTmp + "." + sTmp1);
                }

                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEGINDATE")).length() > 0) {
                    eTmp.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                }

                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ENDDATE")).length() > 0) {
                    eTmp.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));
                if (sTmp.length() > 0) {
                    eTmp.destinationUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                if (sTmp.length() > 0) {
                    eTmp.patientUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE"));
                if (sTmp.length() > 0) {
                    eTmp.setType(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME"));
                if (sTmp.length() > 0) {
                    eTmp.setOutcome(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN"));
                if (sTmp.length() > 0) {
                    eTmp.setOrigin(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION"));
                if (sTmp.length() > 0) {
                    eTmp.setSituation(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES"));
                if (sTmp.length() > 0) {
                    eTmp.setCategories(sTmp);
                }
                
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID"));
                if (sTmp.length() > 0) {
                    eTmp.setUpdateUser(sTmp);
                }
                
                vEncounters.addElement(eTmp);
            }

            rs.close();
            ps.close();
            oc_conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vEncounters;
    }
    
    public static Encounter getLastEncounter(String personid){
    	Encounter encounter=null;
    	PreparedStatement ps;
        ResultSet rs;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	String sSelect = "select * from OC_ENCOUNTERS where OC_ENCOUNTER_PATIENTUID=? order by OC_ENCOUNTER_BEGINDATE DESC";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, personid);
        	rs=ps.executeQuery();
        	if(rs.next()){
        		encounter=Encounter.get(rs.getString("OC_ENCOUNTER_SERVERID")+"."+rs.getString("OC_ENCOUNTER_OBJECTID"));
        	}
        	rs.close();
        	ps.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
    	return encounter;
    }
    
    public static Vector selectLastEncounters(String patientUid){
        PreparedStatement ps,ps2;
        ResultSet rs,rs2;
        Vector vEncounters = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	String sSelect = "select * from OC_ENCOUNTERS where OC_ENCOUNTER_PATIENTUID=? order by OC_ENCOUNTER_BEGINDATE";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, patientUid);
        	rs=ps.executeQuery();
        	while(rs.next()){
                Encounter eTmp = new Encounter();
                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEGINDATE")).length() > 0) {
                    eTmp.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                }
                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ENDDATE")).length() > 0) {
                    eTmp.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                }
                String sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                if (sTmp.length() > 0) {
                    eTmp.patientUID = sTmp;
                }
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE"));
                if (sTmp.length() > 0) {
                    eTmp.setType(sTmp);
                }
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME"));
                if (sTmp.length() > 0) {
                    eTmp.setOutcome(sTmp);
                }
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN"));
                if (sTmp.length() > 0) {
                    eTmp.setOrigin(sTmp);
                }
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION"));
                if (sTmp.length() > 0) {
                    eTmp.setSituation(sTmp);
                }
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES"));
                if (sTmp.length() > 0) {
                    eTmp.setCategories(sTmp);
                }
                
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));
                if (sTmp.length() > 0) {
                    eTmp.destinationUID = sTmp;
                }
                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID"));
                String sTmp1 = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
                if (sTmp.length() > 0 && sTmp1.length() > 0) {
                    eTmp.setUid(sTmp + "." + sTmp1);
                }
                //Try to find the last service
                sSelect="select * from OC_ENCOUNTER_SERVICES where OC_ENCOUNTER_SERVERID=? and OC_ENCOUNTER_OBJECTID=? order by OC_ENCOUNTER_SERVICEBEGINDATE DESC";
                ps2=oc_conn.prepareStatement(sSelect);
                ps2.setInt(1, Integer.parseInt(sTmp));
                ps2.setInt(2, Integer.parseInt(sTmp1));
                rs2=ps2.executeQuery();
                if(rs2.next()){
                    sTmp = ScreenHelper.checkString(rs2.getString("OC_ENCOUNTER_MANAGERUID"));
                    if (sTmp.length() > 0) {
                        eTmp.managerUID = sTmp;
                    }
                    sTmp = ScreenHelper.checkString(rs2.getString("OC_ENCOUNTER_SERVICEUID"));
                    if (sTmp.length() > 0) {
                        eTmp.serviceUID = sTmp;
                    }
                    sTmp = ScreenHelper.checkString(rs2.getString("OC_ENCOUNTER_BEDUID"));
                    if (sTmp.length() > 0) {
                        eTmp.bedUID = sTmp;
                    }
                }
                rs2.close();
                ps2.close();
                vEncounters.addElement(eTmp);
        	}
        	rs.close();
        	ps.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
    	return vEncounters;
    }

    public static Vector selectLastEncounters(String serverID, String objectID, String beginDate, String endDate, String type,
                                              String managerID, String serviceID, String bedID, String patientID, String sortColumn) {
        PreparedStatement ps;
        ResultSet rs;

        Vector vEncounters = new Vector();

        String sSelect = "SELECT A.*" +
                " FROM OC_ENCOUNTERS_VIEW A, (select max(OC_ENCOUNTER_BEGINDATE) OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID" +
                " from OC_ENCOUNTERS_VIEW WHERE 1=1";
        String sSelect2=
                " group by OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID) B" +
                " WHERE" +
                " A.OC_ENCOUNTER_BEGINDATE=B.OC_ENCOUNTER_BEGINDATE AND" +
                " A.OC_ENCOUNTER_SERVERID=B.OC_ENCOUNTER_SERVERID AND" +
                " A.OC_ENCOUNTER_OBJECTID=B.OC_ENCOUNTER_OBJECTID ";

        String sConditions = "";

        if (serverID.length() > 0) {
            sConditions += " OC_ENCOUNTER_SERVERID = ? AND";
        }
        if (objectID.length() > 0) {
            sConditions += " OC_ENCOUNTER_OBJECTID = ? AND";
        }
        if (beginDate.length() > 0) {
            sConditions += " OC_ENCOUNTER_BEGINDATE > ? AND";
        }
        if (endDate.length() > 0) {
            sConditions += " OC_ENCOUNTER_ENDDATE < ? AND";
        }
        if (type.length() > 0) {
            sConditions += " OC_ENCOUNTER_TYPE = ? AND";
        }
        if (managerID.length() > 0) {
            sConditions += " OC_ENCOUNTER_MANAGERUID = ? AND";
        }
        if (serviceID.length() > 0) {
            sConditions += " OC_ENCOUNTER_SERVICEUID = ? AND";
        }
        if (bedID.length() > 0) {
            sConditions += " OC_ENCOUNTER_BEDUID = ? AND";
        }
        if (patientID.length() > 0) {
            sConditions += " OC_ENCOUNTER_PATIENTUID = ? AND";
        }
        
        String sConditions2 = "";

        if (serverID.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_SERVERID = ? AND";
        }
        if (objectID.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_OBJECTID = ? AND";
        }
        if (beginDate.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_BEGINDATE > ? AND";
        }
        if (endDate.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_ENDDATE < ? AND";
        }
        if (type.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_TYPE = ? AND";
        }
        if (managerID.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_MANAGERUID = ? AND";
        }
        if (serviceID.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_SERVICEUID = ? AND";
        }
        if (bedID.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_BEDUID = ? AND";
        }
        if (patientID.length() > 0) {
        	sConditions2 += " A.OC_ENCOUNTER_PATIENTUID = ? AND";
        }

        if (sConditions.length() > 0) {
            sSelect = sSelect + " AND  " + sConditions;
            sSelect = sSelect.substring(0, sSelect.length() - 3);
        }
        if (sConditions2.length() > 0) {
            sSelect2 = sSelect2 + " AND  " + sConditions2;
            sSelect2 = sSelect2.substring(0, sSelect2.length() - 3);
        }
        sSelect = sSelect+" "+sSelect2;
        if (sortColumn.length() > 0) {
            sSelect += " ORDER BY " + sortColumn;
        }

        int i = 1;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);

            for(int n=0;n<2;n++){
	            if (serverID.length() > 0) {
	                ps.setInt(i++, Integer.parseInt(serverID));
	            }
	            if (objectID.length() > 0) {
	                ps.setInt(i++, Integer.parseInt(objectID));
	            }
	            if (beginDate.length() > 0) {
	                ps.setTimestamp(i++, new Timestamp(ScreenHelper.getSQLDate(beginDate).getTime()));
	            }
	            if (endDate.length() > 0) {
	                ps.setTimestamp(i++, new Timestamp(ScreenHelper.getSQLDate(endDate).getTime()));
	            }
	            if (type.length() > 0) {
	                ps.setString(i++, type);
	            }
	            if (managerID.length() > 0) {
	                ps.setString(i++, managerID);
	            }
	            if (serviceID.length() > 0) {
	                ps.setString(i++, serviceID);
	            }
	            if (bedID.length() > 0) {
	                ps.setString(i++, bedID);
	            }
	            if (patientID.length() > 0) {
	                ps.setString(i++, patientID);
	            }
            }
            rs = ps.executeQuery();

            String sTmp, sTmp1;

            Encounter eTmp;

            while (rs.next()) {
                eTmp = new Encounter();

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID"));
                sTmp1 = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));

                if (sTmp.length() > 0 && sTmp1.length() > 0) {
                    eTmp.setUid(sTmp + "." + sTmp1);
                }

                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEGINDATE")).length() > 0) {
                    eTmp.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                }

                if (ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ENDDATE")).length() > 0) {
                    eTmp.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_MANAGERUID"));
                if (sTmp.length() > 0) {
                    eTmp.managerUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVICEUID"));
                if (sTmp.length() > 0) {
                    eTmp.serviceUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID"));
                if (sTmp.length() > 0) {
                    eTmp.destinationUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_BEDUID"));
                if (sTmp.length() > 0) {
                    eTmp.bedUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                if (sTmp.length() > 0) {
                    eTmp.patientUID = sTmp;
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE"));
                if (sTmp.length() > 0) {
                    eTmp.setType(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME"));
                if (sTmp.length() > 0) {
                    eTmp.setOutcome(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN"));
                if (sTmp.length() > 0) {
                    eTmp.setOrigin(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION"));
                if (sTmp.length() > 0) {
                    eTmp.setSituation(sTmp);
                }

                sTmp = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES"));
                if (sTmp.length() > 0) {
                    eTmp.setCategories(sTmp);
                }
                
                vEncounters.addElement(eTmp);
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return vEncounters;
    }

    public static Encounter getActiveEncounterOnDate(Timestamp tOnDate, String sPatientUID) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_ENCOUNTERS WHERE OC_ENCOUNTER_BEGINDATE < ? AND (OC_ENCOUNTER_ENDDATE > ? OR OC_ENCOUNTER_ENDDATE IS NULL) AND OC_ENCOUNTER_PATIENTUID = ? order by OC_ENCOUNTER_BEGINDATE DESC";

        Encounter activeEnc = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if(tOnDate!=null){
                tOnDate=new Timestamp(ScreenHelper.fullDateFormat.parse(ScreenHelper.stdDateFormat.format(tOnDate)+" 23:59").getTime());
            }
            ps = oc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1, tOnDate);
            ps.setTimestamp(2, tOnDate);
            ps.setString(3, sPatientUID);
            rs = ps.executeQuery();
            if (rs.next()) {
                String sUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
                activeEnc = Encounter.get(sUID);
            }
            else {
            	rs.close();
            	ps.close();
                ps = oc_conn.prepareStatement(sSelect);
                Timestamp begin=new Timestamp(tOnDate.getTime());
                begin.setTime(begin.getTime()+24*3600*1000);
                Timestamp end=new Timestamp(tOnDate.getTime());
                end.setTime(end.getTime()-24*3600*1000);
                ps.setTimestamp(1, begin);
                ps.setTimestamp(2, end);
                ps.setString(3, sPatientUID);
                rs = ps.executeQuery();
                if (rs.next()) {
                    String sUID = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
                    activeEnc = Encounter.get(sUID);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return activeEnc;
    }

    public static Hashtable getHospitalizePatients(String sFindBegin, String sFindEnd, String sFindServiceCode) {
        Hashtable hServices = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSQL = "SELECT b.OC_ENCOUNTER_SERVICEUID, a.OC_ENCOUNTER_BEGINDATE, a.OC_ENCOUNTER_ENDDATE, a.OC_ENCOUNTER_OUTCOME "
                    + " FROM OC_ENCOUNTERS a,OC_ENCOUNTER_SERVICES b WHERE "
                    + " a.OC_ENCOUNTER_SERVERID=b.OC_ENCOUNTER_SERVERID AND a.OC_ENCOUNTER_OBJECTID=b.OC_ENCOUNTER_OBJECTID ";

            if (sFindEnd.length() > 0) {
                sSQL += " AND a.OC_ENCOUNTER_BEGINDATE <= ?";
            }

            if (sFindBegin.length() > 0) {
                sSQL += " AND a.OC_ENCOUNTER_BEGINDATE >= ?";
            }

            if (sFindServiceCode.length() > 0) {
                sSQL += " AND OC_ENCOUNTER_SERVICEUID = ? ";
            }
            Debug.println(sSQL);
            ps = oc_conn.prepareStatement(sSQL);

            int iIndex = 1;
            if (sFindEnd.length() > 0) {
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sFindEnd));
            }

            if (sFindBegin.length() > 0) {
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sFindBegin));
            }

            if (sFindServiceCode.length() > 0) {
                ps.setString(iIndex++, sFindServiceCode);
            }

            String sServiceId;
            Hashtable hRow;
            Vector vRows;
            rs = ps.executeQuery();

            while (rs.next()) {
                sServiceId = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVICEUID"));

                hRow = new Hashtable();
                hRow.put("outcome", ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                hRow.put("begin", rs.getDate("OC_ENCOUNTER_BEGINDATE"));

                // end date
                java.sql.Date endDate = rs.getDate("OC_ENCOUNTER_ENDDATE");
                if(endDate!=null) hRow.put("end", endDate);

                vRows = (Vector) hServices.get(sServiceId);

                if (vRows == null) {
                    vRows = new Vector();
                }

                vRows.add(hRow);
                hServices.put(sServiceId, vRows);
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return hServices;
    }

    public static int getHospitalizePatientsAtDate(String sDate, String sFindServiceCode) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSQL = "SELECT count(*) AS TotalPatients "
                    + " FROM OC_ENCOUNTERS a,OC_ENCOUNTER_SERVICES b WHERE "
                    + " a.OC_ENCOUNTER_SERVERID=b.OC_ENCOUNTER_SERVERID AND a.OC_ENCOUNTER_OBJECTID=b.OC_ENCOUNTER_OBJECTID "
                    + " AND a.OC_ENCOUNTER_BEGINDATE <= ? AND a.OC_ENCOUNTER_ENDDATE >= ? AND b.OC_ENCOUNTER_SERVICEUID = ?";
            ps = oc_conn.prepareStatement(sSQL);
            ps.setDate(1, ScreenHelper.getSQLDate(sDate));
            ps.setDate(2, ScreenHelper.getSQLDate(sDate));
            ps.setString(3, sFindServiceCode);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TotalPatients");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void deleteById(String Uid) {

        if (Uid != null && Uid.length() > 0) {
            String sUids[] = Uid.split("\\.");
            if (sUids.length == 2) {
                PreparedStatement ps = null;
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try {
                    String sSelect = "DELETE FROM OC_ENCOUNTERS WHERE OC_ENCOUNTER_SERVERID = ? AND OC_ENCOUNTER_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(sUids[0]));
                    ps.setInt(2, Integer.parseInt(sUids[1]));

                    ps.executeUpdate();
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
                finally {
                    try {
                        if (ps != null) ps.close();
                        oc_conn.close();
                    }
                    catch (SQLException se) {
                        se.printStackTrace();
                    }
                }
            }
        }
    }

    //--- DELETE SERVICE --------------------------------------------------------------------------
    public static void deleteService(String sEncounterUid, String sServiceUid) {
        if ((ScreenHelper.checkString(sEncounterUid).length() > 0 && ScreenHelper.checkString(sServiceUid).length()>0)) {
            String aUids[] = sEncounterUid.split("\\.");
            if (aUids.length == 2) {
                PreparedStatement ps = null;
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try {
                    String sSQL = "DELETE FROM OC_ENCOUNTER_SERVICES where OC_ENCOUNTER_SERVERID=? AND OC_ENCOUNTER_OBJECTID=? "
                        +" AND OC_ENCOUNTER_SERVICEUID = ? ";
                    ps = oc_conn.prepareStatement(sSQL);
                    ps.setInt(1,Integer.parseInt(aUids[0]));
                    ps.setInt(2,Integer.parseInt(aUids[1]));
                    ps.setString(3,sServiceUid);
                    ps.executeUpdate();
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
                finally {
                    try {
                        if (ps != null) ps.close();
                        oc_conn.close();
                    }
                    catch (SQLException se) {
                        se.printStackTrace();
                    }
                }
            }
        }
    }

    //--- CHECK EXISTANCE -------------------------------------------------------------------------
    public static boolean checkExistance(String sEncounterUid){
        boolean bIsGood = true;
        PreparedStatement ps = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	
            String sSQL = "SELECT * FROM OC_CREDITS WHERE OC_CREDIT_ENCOUNTERUID = ?";
            ps = oc_conn.prepareStatement(sSQL);
            ps.setString(1,sEncounterUid);
            ResultSet rs = ps.executeQuery();

            if (rs.next()){
                bIsGood = false;
            }
            rs.close();
            ps.close();

            if (bIsGood){
                sSQL = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_ENCOUNTERUID = ?";
                ps = oc_conn.prepareStatement(sSQL);
                ps.setString(1,sEncounterUid);
                rs = ps.executeQuery();

                if (rs.next()){
                    bIsGood = false;
                }
                rs.close();
                ps.close();
            }

            if (bIsGood){
                sSQL = "SELECT * FROM OC_DIAGNOSES WHERE OC_DIAGNOSIS_ENCOUNTERUID = ?";
                ps = oc_conn.prepareStatement(sSQL);
                ps.setString(1,sEncounterUid);
                rs = ps.executeQuery();

                if (rs.next()){
                    bIsGood = false;
                }
                rs.close();
                ps.close();
            }

            if (bIsGood){
                sSQL = "SELECT * FROM OC_FINANCEDEBETS WHERE OC_FINANCEDEBET_ENCOUNTERUID = ?";
                ps = oc_conn.prepareStatement(sSQL);
                ps.setString(1,sEncounterUid);
                rs = ps.executeQuery();

                if (rs.next()){
                    bIsGood = false;
                }
                rs.close();
                ps.close();
            }

            if (bIsGood){
                sSQL = "SELECT * FROM OC_PATIENTCREDITS WHERE OC_PATIENTCREDIT_ENCOUNTERUID = ?";
                ps = oc_conn.prepareStatement(sSQL);
                ps.setString(1,sEncounterUid);
                rs = ps.executeQuery();

                if (rs.next()){
                    bIsGood = false;
                }
                rs.close();
                ps.close();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        
        return bIsGood;
    }

    //--- GET SERVICE UID -------------------------------------------------------------------------
    public String getServiceUID(Date date){
        try{
            Vector encounterServices = getTransferHistory();
            
            for(int n=0;n<encounterServices.size();n++){
                EncounterService encounterService = (EncounterService)encounterServices.elementAt(n);
                Date begin = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(encounterService.begin));
                Date end = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(encounterService.end));
                if(!begin.after(date) && (end==null || !end.before(date))&& encounterService.serviceUID!=null && encounterService.serviceUID.trim().length()>0){
                    return encounterService.serviceUID;
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return getServiceUID();
    }
    
    //--- GET OVERLAP ENCOUNTERS ------------------------------------------------------------------
    public static Vector getOverlapEncounters(String personid, Date begin, Date end){
    	Vector encounters = new Vector();
    	PreparedStatement ps=null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSQL = "SELECT * from OC_ENCOUNTERS where OC_ENCOUNTER_PATIENTUID=?"+
                          " AND OC_ENCOUNTER_BEGINDATE<? AND (OC_ENCOUNTER_ENDDATE>? OR OC_ENCOUNTER_SERVICEENDDATE IS NULL)"+
            		      "  order by OC_ENCOUNTER_BEGINDATE";
            ps = oc_conn.prepareStatement(sSQL);
            ps.setString(1, personid);
            ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
            ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
            	encounters.add(Encounter.get(rs.getInt("OC_ENCOUNTER_SERVERID")+"."+rs.getInt("OC_ENCOUNTER_OBJECTID")));
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        
    	return encounters;
    }
    
}