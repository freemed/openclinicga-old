package be.openclinic.finance;
import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.adt.Encounter;
import be.openclinic.adt.Encounter.EncounterService;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;

import java.text.DecimalFormat;
import java.util.Date;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
public class Debet extends OC_Object implements Comparable,Cloneable {
    private Date date;
    private double amount;
    private double insurarAmount;
    private String insuranceUid;
    private Insurance insurance;
    private String prestationUid;
    private Prestation prestation;
    private String encounterUid;
    private Encounter encounter;
    private String supplierUid;
    private String patientInvoiceUid;
    private String insurarInvoiceUid;
    private String comment;
    private int credited;
    private String patientName;
    private int quantity;
    private String extraInsurarUid;
    private String extraInsurarInvoiceUid;
    private double extraInsurarAmount;
    private int renewalInterval;
    private java.util.Date renewalDate;
    private String performeruid;
    private String refUid;
    private String extraInsurarUid2;
    private String extraInsurarInvoiceUid2;
    private String serviceUid;
    
    
    public String getServiceUid() {
		return serviceUid;
	}
	public void setServiceUid(String serviceUid) {
		this.serviceUid = serviceUid;
	}
	public String getExtraInsurarUid2() {
		return extraInsurarUid2;
	}
	public void setExtraInsurarUid2(String extraInsurarUid2) {
		this.extraInsurarUid2 = extraInsurarUid2;
	}
	public String getExtraInsurarInvoiceUid2() {
		return extraInsurarInvoiceUid2;
	}
	public void setExtraInsurarInvoiceUid2(String extraInsurarInvoiceUid2) {
		this.extraInsurarInvoiceUid2 = extraInsurarInvoiceUid2;
	}
	public String getRefUid() {
		return refUid;
	}
	public void setRefUid(String refUid) {
		this.refUid = refUid;
	}
	public String getPerformeruid() {
		return performeruid;
	}
	public void setPerformeruid(String performeruid) {
		this.performeruid = performeruid;
	}
	public double getTotalAmount(){
    	return getAmount()+getInsurarAmount()+getExtraInsurarAmount();
    }
    public double getExtraInsurarAmount() {
        return extraInsurarAmount;
    }
    public java.util.Date getRenewalDate() {
		return renewalDate;
	}
	public void setRenewalDate(java.util.Date renewalDate) {
		this.renewalDate = renewalDate;
	}
	public int getRenewalInterval() {
		return renewalInterval;
	}
	public void setRenewalInterval(int renewalInterval) {
		this.renewalInterval = renewalInterval;
	}
	public void setExtraInsurarAmount(double extraInsurarAmount) {
        this.extraInsurarAmount = extraInsurarAmount;
    }
    public String getExtraInsurarUid() {
        return extraInsurarUid;
    }
    public void setExtraInsurarUid(String extraInsurarUid) {
        this.extraInsurarUid = extraInsurarUid;
    }
    public String getExtraInsurarInvoiceUid() {
        return extraInsurarInvoiceUid;
    }
    public void setExtraInsurarInvoiceUid(String extraInsurarInvoiceUid) {
        this.extraInsurarInvoiceUid = extraInsurarInvoiceUid;
    }
    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o) {
        int comp;
        if (o.getClass().isInstance(this)) {
            comp = this.date.compareTo(((Debet) o).date);
        } else {
            throw new ClassCastException();
        }
        return comp;
    }
    public Debet() {
    }
    public Debet(Date date, double amount, String insuranceUid, String prestationUid, String encounterUid) {
        this.date = date;
        this.amount = amount;
        this.insuranceUid = insuranceUid;
        this.prestationUid = prestationUid;
        this.encounterUid = encounterUid;
    }
    public int getCredited() {
        return credited;
    }
    public void setCredited(int credited) {
        this.credited = credited;
        if (credited == 1) {
            this.amount = 0;
            this.insurarAmount=0;
            this.extraInsurarAmount=0;
        }
    }
    public double getInsurarAmount() {
        if (credited == 1) {
            return 0;
        }
        return insurarAmount;
    }
    public void setInsurarAmount(double amount) {
        this.insurarAmount = amount;
    }
    public double getAmount() {
        if (credited == 1) {
            return 0;
        }
        return amount;
    }
    public void setAmount(double amount) {
        this.amount = amount;
    }
    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }
    public String getPatientName() {
        return patientName;
    }
    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }
    public String getInsuranceUid() {
        return insuranceUid;
    }
    public void setInsuranceUid(String insuranceUid) {
        this.insuranceUid = insuranceUid;
    }
    public Insurance getInsurance() {
    	if(this.insurance==null){
    		insurance=Insurance.get(this.insuranceUid);
    	}
        return insurance;
    }
    public void setInsurance(Insurance insurance) {
        this.insurance = insurance;
    }
    public String getPrestationUid() {
        return prestationUid;
    }
    public void setPrestationUid(String prestationUid) {
        this.prestationUid = prestationUid;
    }
    public Prestation getPrestation() {
        if (this.prestation == null) {
            if (ScreenHelper.checkString(this.prestationUid).length() > 0) {
                this.setPrestation(Prestation.get(this.prestationUid));
            } else {
                this.prestation = null;
            }
        }
        return prestation;
    }
    public void setPrestation(Prestation prestation) {
        this.prestation = prestation;
    }
    public String getEncounterUid() {
        return encounterUid;
    }
    public void setEncounterUid(String encounterUid) {
        this.encounterUid = encounterUid;
    }
    public Encounter getEncounter() {
        if (this.encounter == null) {
            if (ScreenHelper.checkString(this.encounterUid).length() > 0) {
                this.setEncounter(Encounter.get(this.encounterUid));
            } else {
                this.encounter = null;
            }
        }
        return encounter;
    }
    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }
    public String getSupplierUid() {
        return supplierUid;
    }
    public void setSupplierUid(String supplierUid) {
        this.supplierUid = supplierUid;
    }
    public String getPatientInvoiceUid() {
        return patientInvoiceUid;
    }
    public void setPatientInvoiceUid(String patientInvoiceUid) {
        this.patientInvoiceUid = patientInvoiceUid;
    }
    public String getInsurarInvoiceUid() {
        return insurarInvoiceUid;
    }
    public void setInsurarInvoiceUid(String insurarInvoiceUid) {
        this.insurarInvoiceUid = insurarInvoiceUid;
    }
    public String getComment() {
        return comment;
    }
    public void setComment(String comment) {
        this.comment = comment;
    }
    public java.util.Date getContributionValidity(){
    	java.util.Date validity = null;
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps=null;
        ResultSet rs = null;
        try{
        	String sSelect="select "+MedwanQuery.getInstance().dateadd("a.OC_DEBET_DATE","MONTH","c.OC_PRESTATION_RENEWALINTERVAL*a.OC_DEBET_QUANTITY")+" validity from OC_DEBETS a,OC_PRESTATIONS c where " +
        			"c.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_TYPE='con.openinsurance' and " +
        			"a.OC_DEBET_SERVERID=? and "+
        			"a.OC_DEBET_OBJECTID=?";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, this.getUid().split("\\.")[0]);
        	ps.setString(2, this.getUid().split("\\.")[1]);
        	rs=ps.executeQuery();
        	if(rs.next()){
        		validity=rs.getTimestamp("validity");
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
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return validity;
    }
    
    public static java.util.Date getContributionValidity(String sPatientId){
    	java.util.Date validity = null;
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps=null;
        ResultSet rs = null;
        try{
        	String sSelect="select max("+MedwanQuery.getInstance().dateadd("a.OC_DEBET_DATE","MONTH","c.OC_PRESTATION_RENEWALINTERVAL*a.OC_DEBET_QUANTITY")+") validity from OC_DEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c where " +
        			"b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_TYPE='con.openinsurance' and " +
        			"b.OC_ENCOUNTER_PATIENTUID=?";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, sPatientId);
        	rs=ps.executeQuery();
        	if(rs.next()){
        		validity=rs.getTimestamp("validity");
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
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return validity;
    }
    
    public boolean hasValidExtrainsurer2(){
    	return getExtraInsurarUid2()!=null && getExtraInsurarUid2().split("\\.").length==2;
    }
    
    public static Debet get(String uid) {
        Debet debet = (Debet) MedwanQuery.getInstance().getObjectCache().getObject("debet", uid);
        if (debet != null && debet.getUid().equalsIgnoreCase(uid)) {
            return debet;
        }
        debet = new Debet();
        if ((uid != null) && (uid.length() > 0)) {
            String[] ids = uid.split("\\.");
            if (ids.length == 2) {
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try {
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        debet.setUid(uid);
                        debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                        debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                        debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                        debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                        debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                        debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                        debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                        debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                        debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                        debet.comment = rs.getString("OC_DEBET_COMMENT");
                        debet.credited = rs.getInt("OC_DEBET_CREDITED");
                        debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                        debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                        debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                        debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                        debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                        debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                        debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                        debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                        debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                        debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                        debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                        debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                        debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                        debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                        debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");
                    }
                }
                catch (Exception e) {
                    Debug.println("OpenClinic => Debet.java => get => " + e.getMessage());
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
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
        return debet;
    }
    public boolean store() {
        boolean bStored = true;
        String ids[];
        int iVersion = 1;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (this.getUid() != null && this.getUid().length() > 0) {
                ids = this.getUid().split("\\.");
                if (ids.length == 2) {
                    sSelect = "SELECT OC_DEBET_VERSION FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        iVersion = rs.getInt("OC_DEBET_VERSION") + 1;
                    }
                    rs.close();
                    ps.close();
                    sSelect = "INSERT INTO OC_DEBETS_HISTORY(OC_DEBET_SERVERID,OC_DEBET_OBJECTID,OC_DEBET_AMOUNT,OC_DEBET_BALANCEUID,OC_DEBET_DATE,OC_DEBET_DESCRIPTION,OC_DEBET_ENCOUNTERUID,OC_DEBET_PRESTATIONUID,OC_DEBET_SUPPLIERTYPE,OC_DEBET_SUPPLIERUID,OC_DEBET_REFTYPE,OC_DEBET_REFUID,OC_DEBET_CREATETIME,OC_DEBET_UPDATETIME,OC_DEBET_UPDATEUID,OC_DEBET_VERSION,OC_DEBET_CREDITED,OC_DEBET_INSURANCEUID,OC_DEBET_PATIENTINVOICEUID,OC_DEBET_INSURARINVOICEUID,OC_DEBET_COMMENT,OC_DEBET_EXTRAINSURARUID,OC_DEBET_EXTRAINSURARINVOICEUID,OC_DEBET_EXTRAINSURARAMOUNT,OC_DEBET_RENEWALINTERVAL,OC_DEBET_RENEWALDATE,OC_DEBET_PERFORMERUID,OC_DEBET_EXTRAINSURARUID2,OC_DEBET_EXTRAINSURARINVOICEUID2) SELECT OC_DEBET_SERVERID,OC_DEBET_OBJECTID,OC_DEBET_AMOUNT,OC_DEBET_BALANCEUID,OC_DEBET_DATE,OC_DEBET_DESCRIPTION,OC_DEBET_ENCOUNTERUID,OC_DEBET_PRESTATIONUID,OC_DEBET_SUPPLIERTYPE,OC_DEBET_SUPPLIERUID,OC_DEBET_REFTYPE,OC_DEBET_REFUID,OC_DEBET_CREATETIME,OC_DEBET_UPDATETIME,OC_DEBET_UPDATEUID,OC_DEBET_VERSION,OC_DEBET_CREDITED,OC_DEBET_INSURANCEUID,OC_DEBET_PATIENTINVOICEUID,OC_DEBET_INSURARINVOICEUID,OC_DEBET_COMMENT,OC_DEBET_EXTRAINSURARUID,OC_DEBET_EXTRAINSURARINVOICEUID,OC_DEBET_EXTRAINSURARAMOUNT,OC_DEBET_RENEWALINTERVAL,OC_DEBET_RENEWALDATE,OC_DEBET_PERFORMERUID,OC_DEBET_EXTRAINSURARUID2,OC_DEBET_EXTRAINSURARINVOICEUID2 FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                    sSelect = " DELETE FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                    sSelect = " DELETE FROM OC_DEBETFEES WHERE OC_DEBETFEE_DEBETUID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setString(1, this.getUid());
                    ps.executeUpdate();
                    ps.close();
                } else {
                    ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_DEBETS") + ""};
                    this.setUid(ids[0] + "." + ids[1]);
                }
            } else {
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_DEBETS") + ""};
                this.setUid(ids[0] + "." + ids[1]);
            }
            if (ids.length == 2 && this.getQuantity()!=0) {
                sSelect = " INSERT INTO OC_DEBETS (" +
                        " OC_DEBET_SERVERID," +
                        " OC_DEBET_OBJECTID," +
                        " OC_DEBET_DATE," +
                        " OC_DEBET_AMOUNT," +
                        " OC_DEBET_INSURANCEUID," +
                        " OC_DEBET_PRESTATIONUID," +
                        " OC_DEBET_ENCOUNTERUID," +
                        " OC_DEBET_SUPPLIERUID," +
                        " OC_DEBET_PATIENTINVOICEUID," +
                        " OC_DEBET_INSURARINVOICEUID," +
                        " OC_DEBET_COMMENT," +
                        " OC_DEBET_CREDITED," +
                        " OC_DEBET_CREATETIME," +
                        " OC_DEBET_UPDATETIME," +
                        " OC_DEBET_UPDATEUID," +
                        " OC_DEBET_VERSION," +
                        " OC_DEBET_INSURARAMOUNT," +
                        " OC_DEBET_QUANTITY," +
                        " OC_DEBET_EXTRAINSURARUID," +
                        " OC_DEBET_EXTRAINSURARINVOICEUID," +
                        " OC_DEBET_EXTRAINSURARAMOUNT," +
                        " OC_DEBET_RENEWALINTERVAL," +
                        " OC_DEBET_RENEWALDATE," +
                        " OC_DEBET_PERFORMERUID," +
                        " OC_DEBET_REFUID," +
                        " OC_DEBET_EXTRAINSURARUID2," +
                        " OC_DEBET_EXTRAINSURARINVOICEUID2," +
                        " OC_DEBET_SERVICEUID" +
                        ") " +
                        " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                while (!MedwanQuery.getInstance().validateNewOpenclinicCounter("OC_DEBETS", "OC_DEBET_OBJECTID", ids[1])) {
                    ids[1] = MedwanQuery.getInstance().getOpenclinicCounter("OC_DEBETS") + "";
                }
                ps.setInt(1, Integer.parseInt(ids[0]));
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setTimestamp(3, new Timestamp(this.getDate().getTime()));
                ps.setDouble(4, this.getAmount());
                if (this.insuranceUid != null) {
                    ps.setString(5, this.insuranceUid);
                } else if (this.getInsurance() != null) {
                    ps.setString(5, this.getInsurance().getUid());
                } else {
                    ps.setString(5, "");
                }
                if (this.prestationUid != null) {
                    ps.setString(6, this.prestationUid);
                } else if (this.getPrestation() != null) {
                    ps.setString(6, this.getPrestation().getUid());
                } else {
                    ps.setString(6, "");
                }
                if (this.encounterUid != null) {
                    ps.setString(7, this.encounterUid);
                } else if (this.getEncounter() != null) {
                    ps.setString(7, this.getEncounter().getUid());
                } else {
                    ps.setString(7, "");
                }
                ps.setString(8, ScreenHelper.checkString(this.getSupplierUid()));
                ps.setString(9, ScreenHelper.checkString(this.getPatientInvoiceUid()));
                ps.setString(10, ScreenHelper.checkString(this.getInsurarInvoiceUid()));
                ps.setString(11, this.getComment());
                ps.setInt(12, this.getCredited());
                ps.setTimestamp(13, new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(14, new Timestamp(new java.util.Date().getTime()));
                ps.setString(15, this.getUpdateUser());
                ps.setInt(16, iVersion);
                ps.setDouble(17, this.getInsurarAmount());
                ps.setInt(18, this.getQuantity());
                ps.setString(19, ScreenHelper.checkString(this.getExtraInsurarUid()));
                ps.setString(20, ScreenHelper.checkString(this.getExtraInsurarInvoiceUid()));
                ps.setDouble(21, this.getExtraInsurarAmount());
                ps.setInt(22, this.getRenewalInterval());
                ps.setTimestamp(23, this.getRenewalDate()==null?null:new java.sql.Timestamp(this.getRenewalDate().getTime()));
                ps.setString(24, ScreenHelper.checkString(this.getPerformeruid()));
                ps.setString(25, this.getRefUid());
                ps.setString(26, ScreenHelper.checkString(this.getExtraInsurarUid2()));
                ps.setString(27, ScreenHelper.checkString(this.getExtraInsurarInvoiceUid2()));
                ps.setString(28, ScreenHelper.checkString(this.getServiceUid()));
                ps.executeUpdate();
                ps.close();
                if(this.getCredited()==1 && this.getRefUid()!=null && this.getRefUid().length()>0){
                	Debet d = Debet.get(this.getRefUid());
                	if(d!=null){
                		d.setCredited(1);
                		d.store();
                	}
                }
                if(this.getPerformeruid()!=null && this.getPerformeruid().length()>0){
                    //Now save the fees
                	String[] performeruids = this.getPerformeruid().split(";");
                	for(int n=0;n<performeruids.length;n++){
                		if(performeruids[n].length()>0){
                			Fee fee = new Fee();
                			fee.calculateFee(this);
	                		ps=oc_conn.prepareStatement("insert into OC_DEBETFEES(OC_DEBETFEE_DEBETUID,OC_DEBETFEE_AMOUNT,OC_DEBETFEE_CALCULATION,OC_DEBETFEE_REASON,OC_DEBETFEE_PERFORMERUID) values(?,?,?,?,?)");
	                		ps.setString(1,this.getUid());
	                		ps.setFloat(2, fee.amount);
	                		ps.setString(3, fee.calculation);
	                		ps.setString(4, fee.reason);
	                		ps.setString(5, this.getPerformeruid());
	                		ps.execute();
	                		ps.close();
	                		if(fee.reason.startsWith("0;")){
	                			//bewaar de fee voor de gebruiker aan wie deze prestatie voorbehouden is
	                			Debet debet = (Debet)this.clone();
	                			debet.setPerformeruid(this.getPrestation().getPerformerUid());
	                			fee.calculateFee(debet);
		                		ps=oc_conn.prepareStatement("insert into OC_DEBETFEES(OC_DEBETFEE_DEBETUID,OC_DEBETFEE_AMOUNT,OC_DEBETFEE_CALCULATION,OC_DEBETFEE_REASON,OC_DEBETFEE_PERFORMERUID) values(?,?,?,?,?)");
		                		ps.setString(1,debet.getUid());
		                		ps.setFloat(2, fee.amount);
		                		ps.setString(3, fee.calculation);
		                		ps.setString(4, fee.reason+";"+this.getPerformeruid());
		                		ps.setString(5, ScreenHelper.checkString(debet.getPerformeruid()));
		                		ps.execute();
		                		ps.close();
	                		}
                		}
                	}
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            bStored = false;
            Debug.println("OpenClinic => Debet.java => store => " + e.getMessage() + " = " + sSelect);
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
        MedwanQuery.getInstance().getObjectCache().putObject("debet", this);
        return bStored;
    }
    
    public class Fee {
    	float amount=0;
    	String calculation="";
    	String reason="";
    	
    	public void calculateFee(Debet debet) throws Exception{
    		//Nu voeren we de berekeningen uit voor de fee
    		//1. controleren of deze prestatie niet voor iemand anders is gereserveerd
    		if(ScreenHelper.checkString(debet.getPrestation().getPerformerUid()).length()>0 && !ScreenHelper.checkString(debet.getPrestation().getPerformerUid()).equalsIgnoreCase(debet.getPerformeruid())){
    			amount=0;
    			calculation="";
    			reason="0;"+debet.getPrestation().getPerformerUid(); //prestation not allowed for this user
    		}
    		else {
    			Vector rules=new Vector();
    			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    			//We laden eerst alle configuraties voor deze gebruiker zodat we maar 1 keer de query moeten uitvoeren
    			PreparedStatement ps=oc_conn.prepareStatement("select * from OC_CAREPROVIDERFEES where OC_CAREPROVIDERFEE_USERID=?");
    			ps.setString(1, debet.getPerformeruid());
    			ResultSet rs = ps.executeQuery();
    			while(rs.next()){
    				String r=rs.getString("OC_CAREPROVIDERFEE_TYPE")+";"+rs.getString("OC_CAREPROVIDERFEE_ID")+";"+rs.getString("OC_CAREPROVIDERFEE_AMOUNT");
    				rules.add(r);
    			}
    			rs.close();
    			ps.close();
    			oc_conn.close();
    			boolean bDone=false;
        		//2. controleren of er een bedrag voor deze prestatie werd geconfigureerd voor deze gebruiker
    			for(int i=0;i<rules.size();i++){
    				String[] rule = ((String)rules.elementAt(i)).split(";");
    				if(rule[0].equalsIgnoreCase("prestation") && rule[1].equalsIgnoreCase(debet.getPrestationUid())){
    					amount=Float.parseFloat(rule[2]);
    					calculation=rule[2]+" "+MedwanQuery.getInstance().getConfigString("currency","");
    					reason="1"; //prestation based fee defined for user
    					bDone=true;
    					break;
    				}
    			}
    			if(!bDone){
            		//3. controleren of er een fee werd geconfigureerd voor het prestatietype
        			for(int i=0;i<rules.size();i++){
        				String[] rule = ((String)rules.elementAt(i)).split(";");
        				if(rule[0].equalsIgnoreCase("prestationtype") && rule[1].equalsIgnoreCase(debet.getPrestation().getType())){
        					amount=(float)(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())*Float.parseFloat(rule[2])/100;
        					calculation=rule[2]+"%";
        					reason="2;"+rule[1]; //prestation type based percentage defined for user
        					bDone=true;
        					break;
        				}
        			}
    			}
    			if(!bDone){
            		//4. controleren of er een fee werd geconfigureerd voor de facturatiegroep
        			for(int i=0;i<rules.size();i++){
        				String[] rule = ((String)rules.elementAt(i)).split(";");
        				if(rule[0].equalsIgnoreCase("invoicegroup") && rule[1].equalsIgnoreCase(debet.getPrestation().getInvoicegroup())){
        					amount=(float)(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())*Float.parseFloat(rule[2])/100;
        					calculation=rule[2]+"%";
        					reason="3;"+rule[1]; //prestation invoicegroup based percentage defined for user
        					bDone=true;
        					break;
        				}
        			}
    			}
    			if(!bDone){
            		//5. controleren of er een default fee werd geconfigureerd 
        			for(int i=0;i<rules.size();i++){
        				String[] rule = ((String)rules.elementAt(i)).split(";");
        				if(rule[0].equalsIgnoreCase("default")){
        					amount=(float)(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())*Float.parseFloat(rule[2])/100;
        					calculation=rule[2]+"%";
        					reason="4"; //default percentage defined for user
        					bDone=true;
        					break;
        				}
        			}
    			}
    			if(!bDone){
            		//6. geen fee regels geconfigureerd 
					amount=0;
					calculation="0";
					reason="5"; //geen fee regels geconfigureerd 
    			}
    			
    		}
    	}
    }
    
    public static Vector getUnassignedPatientDebets(String sPatientId) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_ENCOUNTERS e, OC_DEBETS d WHERE e.OC_ENCOUNTER_PATIENTUID = ? AND d.OC_DEBET_CREDITED=0"
                    + " AND (d.oc_debet_encounteruid="+MedwanQuery.getInstance().convert("varchar", "e.oc_encounter_serverid")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "e.oc_encounter_objectid")+")" 
                    + " AND (d.OC_DEBET_PATIENTINVOICEUID is null OR d.OC_DEBET_PATIENTINVOICEUID = ' ') order by OC_DEBET_DATE DESC";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sPatientId);
            rs = ps.executeQuery();
            while (rs.next()) {
                vUnassignedDebets.add(rs.getInt("OC_DEBET_SERVERID") + "." + rs.getInt("OC_DEBET_OBJECTID"));
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getUnassignedPatientDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    public static Vector getUnassignedPatientDebets(String sPatientId,String serviceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_ENCOUNTERS e, OC_DEBETS d WHERE e.OC_ENCOUNTER_PATIENTUID = ? AND d.OC_DEBET_CREDITED=0 and d.OC_DEBET_SERVICEUID=?"
                    + " AND (d.oc_debet_encounteruid="+MedwanQuery.getInstance().convert("varchar", "e.oc_encounter_serverid")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "e.oc_encounter_objectid")+")" 
                    + " AND (d.OC_DEBET_PATIENTINVOICEUID is null OR d.OC_DEBET_PATIENTINVOICEUID = ' ') order by OC_DEBET_DATE DESC";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sPatientId);
            ps.setString(2, serviceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                vUnassignedDebets.add(rs.getInt("OC_DEBET_SERVERID") + "." + rs.getInt("OC_DEBET_OBJECTID"));
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getUnassignedPatientDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    public static Vector getPatientDebetsViaInvoiceUid(String sPatientId, String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.* FROM OC_ENCOUNTERS e, OC_DEBETS d, OC_PRESTATIONS p WHERE e.OC_ENCOUNTER_PATIENTUID = '" + sPatientId
                    + "' AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND d.OC_DEBET_PATIENTINVOICEUID = '" + sInvoiceUid +
                    "' AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID" +
                    " ORDER BY OC_PRESTATION_REFTYPE,OC_DEBET_DATE";
            ps = loc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getPatientDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getUnassignedInsurarDebets(String sInsurarUid) {
        return getUnassignedInsurarDebets(sInsurarUid, new Date(0), new Date());
    }
    public static Vector getUnassignedInsurarDebets(String sInsurarUid, Date begin, Date end) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.*,e.*,p.*,a.* FROM OC_DEBETS d, OC_INSURANCES i, OC_ENCOUNTERS e, adminview a, OC_PRESTATIONS p"
                    + " WHERE i.OC_INSURANCE_INSURARUID = ?"
                    + " AND d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_INSURANCEUID,'" + serverid + "','')") + " = i.oc_insurance_objectid"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_PATIENTINVOICEUID is not NULL and d.OC_DEBET_PATIENTINVOICEUID <> '')"
                    + " AND (d.OC_DEBET_INSURARINVOICEUID = ' ' or d.OC_DEBET_INSURARINVOICEUID is null)"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid);
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    public static Vector getUnassignedInsurarDebetsWithoutPatientInvoice(String sInsurarUid, Date begin, Date end) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.*,e.*,p.*,a.* FROM OC_DEBETS d, OC_INSURANCES i, OC_ENCOUNTERS e, adminview a, OC_PRESTATIONS p"
                    + " WHERE i.OC_INSURANCE_INSURARUID = ?"
                    + " AND d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_INSURANCEUID,'" + serverid + "','')") + " = i.oc_insurance_objectid"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_INSURARINVOICEUID = ' ' or d.OC_DEBET_INSURARINVOICEUID is null)"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid);
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }

    public static Vector getUnassignedExtraInsurarDebets(String sInsurarUid) {
        return getUnassignedExtraInsurarDebets(sInsurarUid, new Date(0), new Date());
    }
    
    public static Vector getUnassignedExtraInsurar2Debets(String sInsurarUid) {
        return getUnassignedExtraInsurarDebets(sInsurarUid, new Date(0), new Date());
    }
    
    public static Vector getUnassignedExtraInsurarDebets(String sInsurarUid, Date begin, Date end) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	sSelect = "SELECT * FROM OC_DEBETS d, OC_ENCOUNTERS e, adminview a, OC_PRESTATIONS p"
                    + " WHERE d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_EXTRAINSURARINVOICEUID = '' or d.OC_DEBET_EXTRAINSURARINVOICEUID is null)"
                    + " AND (d.OC_DEBET_PATIENTINVOICEUID is not NULL and d.OC_DEBET_PATIENTINVOICEUID <> '')"
                    + " AND d.OC_DEBET_EXTRAINSURARUID=? AND NOT d.OC_DEBET_EXTRAINSURARUID=''"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid);
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }

    public static Vector getUnassignedExtraInsurarDebets2(String sInsurarUid, Date begin, Date end) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	sSelect = "SELECT * FROM OC_DEBETS d, OC_ENCOUNTERS e, adminview a, OC_PRESTATIONS p"
                    + " WHERE d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_EXTRAINSURARINVOICEUID2 = '' or d.OC_DEBET_EXTRAINSURARINVOICEUID2 is null)"
                    + " AND (d.OC_DEBET_PATIENTINVOICEUID is not NULL and d.OC_DEBET_PATIENTINVOICEUID <> '')"
                    + " AND d.OC_DEBET_EXTRAINSURARUID2=? AND NOT d.OC_DEBET_EXTRAINSURARUID2=''"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid);
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }

    public static Vector getInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_INSURARINVOICEUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
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
        return vDebets;
    }
    
    public static Vector getFullInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_DEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c,AdminView d WHERE " +
                    " a.OC_DEBET_INSURARINVOICEUID = ? AND " +
                    MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.oc_encounter_objectid AND " +
                    MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=c.oc_prestation_objectid AND " +
                    MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=d.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    
    public static Vector getFullExtraInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_DEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c,AdminView d WHERE " +
                    " a.OC_DEBET_EXTRAINSURARINVOICEUID = ? AND" +
                    " " + MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.oc_encounter_objectid AND" +
                    " " + MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=c.oc_prestation_objectid AND" +
                    " " + MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=d.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }

    public static Vector getFullExtraInsurarDebetsViaInvoiceUid2(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_DEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c,AdminView d WHERE " +
                    " a.OC_DEBET_EXTRAINSURARINVOICEUID2 = ? AND" +
                    " " + MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.oc_encounter_objectid AND" +
                    " " + MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=c.oc_prestation_objectid AND" +
                    " " + MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=d.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
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
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }

    public static Vector getExtraInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_EXTRAINSURARINVOICEUID = ?";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    
    public static Vector getExtraInsurarDebetsViaInvoiceUid2(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_EXTRAINSURARINVOICEUID2 = ?";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getInt("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                debet.setPerformeruid(rs.getString("OC_DEBET_PERFORMERUID"));
                debet.setRefUid(rs.getString("OC_DEBET_REFUID"));
                debet.extraInsurarUid2 = rs.getString("OC_DEBET_EXTRAINSURARUID2");
                debet.extraInsurarInvoiceUid2 = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID2");
                debet.serviceUid = rs.getString("OC_DEBET_SERVICEUID");
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }

    public static Vector getActiveContributions(String sPatientId){
    	Vector contributions = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps=null;
        ResultSet rs = null;
        try{
        	String sSelect="select c.OC_PRESTATION_SERVERID,c.OC_PRESTATION_OBJECTID from OC_DEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c where " +
        			"b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_TYPE='con.openinsurance' and " +
        			"b.OC_ENCOUNTER_PATIENTUID=? and " +
        			MedwanQuery.getInstance().dateadd("a.OC_DEBET_DATE","MONTH","c.OC_PRESTATION_RENEWALINTERVAL*a.OC_DEBET_QUANTITY")+">=now()";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, sPatientId);
        	rs=ps.executeQuery();
        	while(rs.next()){
        		contributions.add(Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID")));
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
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    	return contributions;
    }
    
    public static Debet getByRefUid(String refUid){
        Debet debet=null;
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps=null;
        ResultSet rs = null;
        try{
        	String sSelect="select * from OC_DEBETS where OC_DEBET_REFUID=?";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, refUid);
        	rs=ps.executeQuery();
        	if(rs.next()){
        		debet=Debet.get(rs.getString("OC_DEBET_SERVERID")+"."+rs.getString("OC_DEBET_OBJECTID"));
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
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    	return debet;
    }
    
    public static Vector getContributions(String sPatientId){
    	Vector contributions = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps=null;
        ResultSet rs = null;
        try{
        	String sSelect="select a.OC_DEBET_SERVERID,a.OC_DEBET_OBJECTID from OC_DEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c where " +
        			"b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_TYPE='con.openinsurance' and " +
        			"b.OC_ENCOUNTER_PATIENTUID=? order by a.OC_DEBET_DATE DESC";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, sPatientId);
        	rs=ps.executeQuery();
        	while(rs.next()){
        		contributions.add(Debet.get(rs.getString("OC_DEBET_SERVERID")+"."+rs.getString("OC_DEBET_OBJECTID")));
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
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    	return contributions;
    }
    
    public static Vector getPatientDebets(String sPatientId, String sDateBegin, String sDateEnd, String sAmountMin, String sAmountMax) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_ENCOUNTERS e, OC_DEBETS d WHERE e.OC_ENCOUNTER_PATIENTUID = ? "
                    + " AND d.oc_debet_encounteruid="+MedwanQuery.getInstance().convert("varchar", "e.oc_encounter_serverid")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "e.oc_encounter_objectid");
            if (sDateBegin.length() > 0) {
                sSelect += " AND d.OC_DEBET_DATE >= ?  ";
            }
            if (sDateEnd.length() > 0) {
                sSelect += " AND d.OC_DEBET_DATE <= ?  ";
            }
            if ((sAmountMin.length() > 0) && (sAmountMax.length() > 0)) {
                sSelect += " AND d.OC_DEBET_AMOUNT >= ? AND OC_DEBET_AMOUNT <= ? ";
            } else if (sAmountMin.length() > 0) {
                sSelect += " AND d.OC_DEBET_AMOUNT >= ?  ";
            } else if (sAmountMax.length() > 0) {
                sSelect += " AND d.OC_DEBET_AMOUNT <= ?  ";
            }
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sPatientId);
            int iIndex = 2;
            if (sDateBegin.length() > 0) {
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sDateBegin));
            }
            if (sDateEnd.length() > 0) {
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sDateEnd));
            }
            if ((sAmountMin.length() > 0) && (sAmountMax.length() > 0)) {
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMin));
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMax));
            } else if (sAmountMin.length() > 0) {
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMin));
            } else if (sAmountMax.length() > 0) {
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMax));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                vUnassignedDebets.add(rs.getInt("OC_DEBET_SERVERID") + "." + rs.getInt("OC_DEBET_OBJECTID"));
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getPatientDebets => " + e.getMessage() + " = " + sSelect);
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
        return vUnassignedDebets;
    }
    public static Vector getPatientDebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM(d.OC_DEBET_AMOUNT) as somme,count(OC_DEBET_OBJECTID) as nb,a.lastname,a.firstname,a.personid FROM  OC_DEBETS d,OC_ENCOUNTERS b,adminview a WHERE OC_DEBET_AMOUNT >0 AND (OC_DEBET_PATIENTINVOICEUID IS NULL OR OC_DEBET_PATIENTINVOICEUID = '0' OR OC_DEBET_PATIENTINVOICEUID = '') AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.OC_ENCOUNTER_OBJECTID AND " + MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=a.personid GROUP BY a.lastname,a.firstname ORDER BY a.lastname,a.firstname,a.personid";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setAmount(rs.getDouble("somme"));
                debet.setComment(rs.getInt("nb") + "");
                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                debet.setEncounterUid(rs.getString("personid"));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getPatientDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
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
        return vDebets;
    }
    public static Vector getInsurarDebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM(d.OC_DEBET_INSURARAMOUNT) as somme,count(OC_DEBET_OBJECTID) as nb,a.OC_INSURAR_NAME FROM  OC_DEBETS d,OC_INSURANCES b,OC_INSURARS a WHERE OC_DEBET_INSURARAMOUNT >0 AND (OC_DEBET_INSURARINVOICEUID IS NULL OR OC_DEBET_INSURARINVOICEUID = '0') AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_INSURANCEUID,'" + serverid + "','')") + "=b.OC_INSURANCE_OBJECTID AND " + MedwanQuery.getInstance().convert("int", "replace(b.OC_INSURANCE_INSURARUID,'" + serverid + "','')") + "=a.OC_INSURAR_OBJECTID GROUP BY a.OC_INSURAR_NAME ORDER BY a.OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setAmount(rs.getDouble("somme"));
                debet.setComment(rs.getInt("nb") + "");
                //*********************
                //add Insurar name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("OC_INSURAR_NAME")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getInsurarDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
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
        return vDebets;
    }
    public static Vector getExtraInsurarDebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM("+MedwanQuery.getInstance().convert("float", "d.OC_DEBET_EXTRAINSURARAMOUNT")+") as somme,count(OC_DEBET_OBJECTID) as nb,a.OC_INSURAR_NAME FROM  OC_DEBETS d,OC_INSURARS a WHERE "+MedwanQuery.getInstance().convert("float", "d.OC_DEBET_EXTRAINSURARAMOUNT")+" >0 AND (d.OC_DEBET_EXTRAINSURARINVOICEUID IS NULL OR d.OC_DEBET_EXTRAINSURARINVOICEUID = '0') AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_EXTRAINSURARUID,'" + serverid + "','')") + "=a.OC_INSURAR_OBJECTID GROUP BY a.OC_INSURAR_NAME ORDER BY a.OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setAmount(rs.getDouble("somme"));
                debet.setComment(rs.getInt("nb") + "");
                //*********************
                //add extrainsurance name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("OC_INSURAR_NAME")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getExtraInsurarDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
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
        return vDebets;
    }
    
    public static Vector getExtraInsurar2DebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM("+MedwanQuery.getInstance().convert("float", "d.OC_DEBET_AMOUNT")+") as somme,count(OC_DEBET_OBJECTID) as nb,a.OC_INSURAR_NAME FROM  OC_DEBETS d,OC_INSURARS a WHERE "+MedwanQuery.getInstance().convert("float", "d.OC_DEBET_AMOUNT")+" >0 AND (d.OC_DEBET_EXTRAINSURARINVOICEUID2 IS NULL OR d.OC_DEBET_EXTRAINSURARINVOICEUID2 = '0') AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_EXTRAINSURARUID2,'" + serverid + "','')") + "=a.OC_INSURAR_OBJECTID GROUP BY a.OC_INSURAR_NAME ORDER BY a.OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                Debet debet = new Debet();
                debet.setAmount(rs.getDouble("somme"));
                debet.setComment(rs.getInt("nb") + "");
                //*********************
                //add extrainsurance name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("OC_INSURAR_NAME")));
                MedwanQuery.getInstance().getObjectCache().putObject("debet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => Debet.java => getExtraInsurarDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
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
        return vDebets;
    }
    
    public static void createAutomaticDebet(String uid, String personid,String prestationUid,String userid){
    	createAutomaticDebet(uid, personid, prestationUid, new java.util.Date(), 1,userid);
    }
    
    public String determineServiceUid(){
    	if(getServiceUid()!=null && getServiceUid().length()>0){
    		return getServiceUid();
    	}
    	if(getPrestation()!=null && getPrestation().getServiceUid()!=null && getPrestation().getServiceUid().length()>0){
    		//The service is determined by the prestation
    		return getPrestation().getServiceUid();
    	}
    	if(getEncounter()!=null){
    		//The service is determined by the encounter
    		return getEncounter().getServiceUID(getDate());
    	}
    	return "";
    }
    
    public String determineServiceUid(String sDefaultServiceUid){
    	if(getServiceUid()!=null && getServiceUid().length()>0){
    		return getServiceUid();
    	}
    	if(getPrestation()!=null && getPrestation().getServiceUid()!=null && getPrestation().getServiceUid().length()>0){
    		//The service is determined by the prestation
    		return getPrestation().getServiceUid();
    	}
    	if(getEncounter()!=null){
    		//The service is determined by the encounter
    		return getEncounter().getServiceUID(getDate());
    	}
    	return sDefaultServiceUid;
    }
    
    public String determineServiceUidWithoutEncounterValidation(String sDefaultServiceUid){
    	if(getServiceUid()!=null && getServiceUid().length()>0){
    		return getServiceUid();
    	}
    	if(getPrestation()!=null && getPrestation().getServiceUid()!=null && getPrestation().getServiceUid().length()>0){
    		//The service is determined by the prestation
    		return getPrestation().getServiceUid();
    	}
    	return sDefaultServiceUid;
    }
    
    public static void createAutomaticDebet(String uid, String personid,String prestationUid,java.util.Date date,int quantity,String userid){
        String type="";
        Insurance insurance=null;
        insurance = Insurance.getMostInterestingInsuranceForPatient(personid);
        Encounter encounter = Encounter.getActiveEncounter(personid);
        Prestation prestation = Prestation.get(prestationUid);
        double dPatientAmount=0,dInsurarAmount=0;
        if(encounter!=null && prestation!=null){
	        if (insurance != null) {
	            type = insurance.getType();
	
	            if (prestation != null) {
	                double dPrice = prestation.getPrice(type);
	                if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==1){
	                	dPrice+=prestation.getSupplement();
	                }
	                double dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
	                if(encounter.getType().equalsIgnoreCase("admission") && prestation.getMfpAdmissionPercentage()>0){
	                	dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),"*H");
	                }
	                String sShare=ScreenHelper.checkString(prestation.getPatientShare(insurance)+"");
	                if (sShare.length()>0){
	                    dPatientAmount = quantity * dPrice * Double.parseDouble(sShare) / 100;
	                    dInsurarAmount = quantity * dPrice - dPatientAmount;
	                    if(dInsuranceMaxPrice>=0){
	                    	dInsurarAmount=quantity * dInsuranceMaxPrice;
	                   		dPatientAmount=quantity * dPrice - dInsurarAmount;
	                    }
	                    if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==0){
	                    	dPatientAmount+=quantity * prestation.getSupplement();
	                    }
	                }
	            }
	        }
	        else {
	            dPatientAmount=quantity * (prestation.getPrice("C")+prestation.getSupplement());
	            dInsurarAmount = 0;
	        }
	        dPatientAmount=Double.parseDouble(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dPatientAmount));
	        dInsurarAmount=Double.parseDouble(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dInsurarAmount));
	        //Create new Debet
	        Debet debet = new Debet();
	        debet.setAmount(dPatientAmount);
	        debet.setCreateDateTime(new java.util.Date());
	        debet.setDate(date);
	        debet.setEncounterUid(encounter.getUid());
	        debet.setInsuranceUid(insurance.getUid());
	        debet.setInsurarAmount(dInsurarAmount);
	        debet.setPrestationUid(prestation.getUid());
	        debet.setQuantity(quantity);
	        debet.setUpdateDateTime(new java.util.Date());
	        debet.setUpdateUser(userid);
	        debet.setVersion(1);
	        debet.setServiceUid(debet.determineServiceUid());
	        debet.store();
	        //Now that we have stored the debet, let's store a reference to it
	        Pointer.storePointer(uid,debet.getUid());
	        
	        
	        //Check if anesthesia prestation must be added
	        if(prestation!=null && prestation.getAnesthesiaPercentage()>0){
	        	Prestation anesthesiaPrestation = Prestation.get(MedwanQuery.getInstance().getConfigString("anesthesiaPrestationUid",""));
	        	if(anesthesiaPrestation!=null){
	                insurance = Insurance.getMostInterestingInsuranceForPatient(personid);
	    	        if (insurance != null) {
		                double dPrice = prestation.getPrice(type)*(prestation.getAnesthesiaPercentage()/100);
	                    if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==1){
	                    	dPrice+=prestation.getSupplement()*(prestation.getAnesthesiaPercentage()/100);
	                    }
		                double dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter())*(prestation.getAnesthesiaPercentage()/100);
		                if(encounter.getType().equalsIgnoreCase("admission") && prestation.getMfpAdmissionPercentage()>0){
		                	dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),"*H");
		                }
		                String sShare=ScreenHelper.checkString(prestation.getPatientShare(insurance)+"");
		                if (sShare.length()>0){
		                    dPatientAmount = quantity * dPrice * Double.parseDouble(sShare) / 100;
		                    dInsurarAmount = quantity * dPrice - dPatientAmount;
		                    if(dInsuranceMaxPrice>=0){
		                    	dInsurarAmount=quantity * dInsuranceMaxPrice;
		                   		dPatientAmount=quantity * dPrice - dInsurarAmount;
		                    }
		                    if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==0){
		                    	dPatientAmount+=quantity*prestation.getSupplement()*(prestation.getAnesthesiaPercentage()/100);
		                    }
		                }
	    	        }
	    	        else {
	    	            dPatientAmount=quantity * (prestation.getPrice("C")+prestation.getSupplement())*(prestation.getAnesthesiaPercentage()/100);
	    	            dInsurarAmount=0;
	    	        }
	    	        dPatientAmount=Double.parseDouble(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dPatientAmount));
	    	        dInsurarAmount=Double.parseDouble(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dInsurarAmount));
	    	        debet = new Debet();
	    	        debet.setAmount(dPatientAmount);
	    	        debet.setCreateDateTime(new java.util.Date());
	    	        debet.setDate(date);
	    	        debet.setEncounterUid(encounter.getUid());
	    	        debet.setInsuranceUid(insurance.getUid());
	    	        debet.setInsurarAmount(dInsurarAmount);
	    	        debet.setPrestationUid(anesthesiaPrestation.getUid());
	    	        debet.setQuantity(quantity);
	    	        debet.setUpdateDateTime(new java.util.Date());
	    	        debet.setUpdateUser(userid);
	    	        debet.setVersion(1);
	    	        debet.store();
	    	        //Now that we have stored the debet, let's store a reference to it
	    	        Pointer.storePointer(uid,debet.getUid());
	        	}
	        }
        }
    }
}
