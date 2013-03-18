package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.common.IObjectReference;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Hashtable;
import java.util.Vector;

import net.admin.Service;

public class Prestation extends OC_Object{
    private String description;
    private String code;
    private double price;
    private double supplement;
    private ObjectReference referenceObject; // Product, Examination
    private String automationCode;
    private String type; // (product/service)
    private String categories;
    private String invoicegroup;
    private int mfpPercentage;
    private int renewalInterval;
    private String coveragePlan;
    private String coveragePlanCategory;
    private int variablePrice;
    private int inactive;
    private String performerUid;
    private String prestationClass;
    private String serviceUid;
    private String modifiers; //0=anesthesiaPercentage,1=mfpadmissionpercentage
    
    public String getServiceUid() {
		return serviceUid;
	}

	public void setServiceUid(String serviceUid) {
		this.serviceUid = serviceUid;
	}

	public String getModifiers() {
		return modifiers;
	}

	public void setModifiers(String modifiers) {
		this.modifiers = modifiers;
	}
	
	public double getAnesthesiaPercentage(){
		double pct=0;
		if(getModifiers()!=null){
			try{
				pct=Double.parseDouble(getModifiers().split(";")[0]);
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return pct;
	}
	
	public void setAnesthesiaPercentage(double pct){
		setModifier(0,pct+"");
	}
	
	public double getMfpAdmissionPercentage(){
		double pct=0;
		if(getModifiers()!=null){
			try{
				pct=Double.parseDouble(getModifiers().split(";")[1]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return pct;
	}
	
	public void setMfpAdmissionPercentage(double pct){
		setModifier(1,pct+"");
	}
	
	public void setModifier(int index,String value){
		if(getModifiers()==null){
			setModifiers("");
		}
		String[] m = getModifiers().split(";");
		if(m.length<=index){
			setModifiers(getModifiers()+"; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;".substring(0,(index+1-m.length)*2));
			m = getModifiers().split(";");
		}
		m[index]=value;
		modifiers="";
		for(int n=0;n<m.length;n++){
			modifiers+=m[n]+";";
		}
	}

	public String getPrestationClass() {
		return prestationClass;
	}

	public void setPrestationClass(String prestationClass) {
		this.prestationClass = prestationClass;
	}

	public String getPerformerUid() {
		return performerUid;
	}

	public void setPerformerUid(String performerUid) {
		this.performerUid = performerUid;
	}

	public int getInactive() {
		return inactive;
	}

	public void setInactive(int inactive) {
		this.inactive = inactive;
	}

	public int getVariablePrice() {
		return variablePrice;
	}

	public void setVariablePrice(int variablePrice) {
		this.variablePrice = variablePrice;
	}

	public String getCompanyMinWorkers(){
    	String s="";
    	if(getReferenceObject()!=null && getReferenceObject().getObjectType()!=null && getReferenceObject().getObjectUid().split(";").length>0){
    		s=getReferenceObject().getObjectUid().split(";")[0];
    	}
    	return s;
    }

    public String getCompanyMaxWorkers(){
    	String s="";
    	if(getReferenceObject()!=null && getReferenceObject().getObjectType()!=null && getReferenceObject().getObjectUid().split(";").length>1){
    		s=getReferenceObject().getObjectUid().split(";")[1];
    	}
    	return s;
    }

    public String getCompanyRiskLevel(){
    	String s="";
    	if(getReferenceObject()!=null && getReferenceObject().getObjectType()!=null && getReferenceObject().getObjectUid().split(";").length>2){
    		s=getReferenceObject().getObjectUid().split(";")[2];
    	}
    	return s;
    }

    public String getCoveragePlanCategory() {
		return coveragePlanCategory;
	}

	public void setCoveragePlanCategory(String coveragePlanCategory) {
		this.coveragePlanCategory = coveragePlanCategory;
	}

	public String getInvoicegroup() {
		return invoicegroup;
	}

	public void setInvoicegroup(String invoicegroup) {
		this.invoicegroup = invoicegroup;
	}

	public String getCoveragePlan() {
		return coveragePlan;
	}

	public void setCoveragePlan(String coveragePlan) {
		this.coveragePlan = coveragePlan;
	}

	public int getRenewalInterval() {
		return renewalInterval;
	}

	public void setRenewalInterval(int renewalInterval) {
		this.renewalInterval = renewalInterval;
	}

	public int getMfpPercentage() {
		return mfpPercentage;
	}

	public void setMfpPercentage(int mfpPercentage) {
		this.mfpPercentage = mfpPercentage;
	}

	//--- GETTERS & SETTERS -----------------------------------------------------------------------
    public String getType(){
        return type;
    }
    
    public String getInvoiceGroup(){
    	return invoicegroup;
    }

    public void setInvoiceGroup(String invoiceGroup){
    	this.invoicegroup=invoiceGroup;
    }
    
    public void setType(String type){
        this.type = type;
    }

    public String getAutomationCode(){
        return automationCode;
    }

    public void setAutomationCode(String automationCode){
        this.automationCode = automationCode;
    }

    public String getCode(){
        return code;
    }

    public void setCode(String code){
        this.code = code;
    }

    public String getDescription(){
        return description;
    }

    public void setDescription(String description){
        this.description = description;
    }

    public double getPrice(){
        return price;
    }

    public String getPriceFormatted(String category){
    	String s = (getSupplement()!=0?"<b>(+"+getSupplement()+")</b>":"");
    	if (price==getPrice(category)){
            return "<b>"+price+"</b> "+s;
        }
        else {
            return price+s;
        }
    }

    public void setPrice(double price){
        this.price = price;
    }

    public static void saveInsuranceTariff(String prestationUid, String insurarUid, String insuranceCategory,double price){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sSql = "delete from OC_TARIFFS where OC_TARIFF_PRESTATIONUID=? and " +
    				" OC_TARIFF_INSURARUID=? and " +
    				" OC_TARIFF_INSURANCECATEGORY=?";
			PreparedStatement ps = oc_conn.prepareStatement(sSql);
			ps.setString(1, prestationUid);
			ps.setString(2, insurarUid);
			ps.setString(3, insuranceCategory);
			ps.executeUpdate();
			ps.close();
			if(price>=0){
	    		sSql = "insert into OC_TARIFFS(OC_TARIFF_PRESTATIONUID,OC_TARIFF_INSURARUID,OC_TARIFF_INSURANCECATEGORY,OC_TARIFF_PRICE) values (?,?,?,?)";
				ps = oc_conn.prepareStatement(sSql);
				ps.setString(1, prestationUid);
				ps.setString(2, insurarUid);
				ps.setString(3, insuranceCategory);
				ps.setDouble(4, price);
				ps.executeUpdate();
				ps.close();
			}
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
    
    public static Vector getPrestationsByClass(String prestationClass){
        Vector prestations = new Vector();
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try {
    		String sSql="SELECT * FROM OC_PRESTATIONS WHERE OC_PRESTATION_CLASS=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sSql);
    		ps.setString(1, prestationClass);
    		ResultSet rs = ps.executeQuery();
    		while(rs.next()){
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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                prestations.add(prestation);
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
    	return prestations;
    }
    
    public double getInsuranceTariff(String insurarUid, String insuranceCategory){
    	double p = -1;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try {
    		String sSql = "select * from OC_TARIFFS where OC_TARIFF_PRESTATIONUID=? and " +
    				" OC_TARIFF_INSURARUID=? and " +
    				" OC_TARIFF_INSURANCECATEGORY=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sSql);
    		ps.setString(1, this.getUid());
    		ps.setString(2, insurarUid);
    		ps.setString(3, insuranceCategory);
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			p=rs.getDouble("OC_TARIFF_PRICE");
    		}
    		else {
    			//Let's try it without the insurance category
    			rs.close();
    			ps.close();
        		sSql = "select * from OC_TARIFFS where OC_TARIFF_PRESTATIONUID=? and " +
				" OC_TARIFF_INSURARUID=? and " +
				" (OC_TARIFF_INSURANCECATEGORY is null or OC_TARIFF_INSURANCECATEGORY='')";
				ps = oc_conn.prepareStatement(sSql);
				ps.setString(1, this.getUid());
				ps.setString(2, insurarUid);
				rs = ps.executeQuery();
				if(rs.next()){
					p=rs.getDouble("OC_TARIFF_PRICE");
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
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return p;
    }
    
    public double getPrice(String category){
        double price=getPrice();
        if(categories!=null && categories.length()>0){
	        String[] cats = categories.split(";");
	        for(int n=0;n<cats.length;n++){
	            if(cats[n].indexOf("=")>-1 && cats[n].split("=")[0].equalsIgnoreCase(category)){
	                try{
	                    price=Double.parseDouble(cats[n].split("=")[1]);
	                    if(price>0){
	                        return price;
	                    }
	                }
	                catch(Exception e){
	
	                }
	            }
	        }
        }
        return getPrice();
    }

    public String getCategories(){
        return categories;
    }
    
    public double getPatientPrice(Insurance insurance,String category){
    	double dPatientAmount=getPrice("C")+getSupplement(),dInsurarAmount=0;
        double dPrice = getPrice(category);
        double dInsuranceMaxPrice = getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
        String sShare=ScreenHelper.checkString(getPatientShare(insurance)+"");
        if (sShare.length()>0){
            dPatientAmount = dPrice * Double.parseDouble(sShare) / 100;
            dInsurarAmount = dPrice - dPatientAmount;
            if(dInsuranceMaxPrice>-1){
            	dInsurarAmount=dInsuranceMaxPrice;
           		dPatientAmount=dPrice - dInsurarAmount;
            }
            dPatientAmount+=getSupplement();
        }
        return dPatientAmount;
    }

    public double getInsurarPrice(Insurance insurance,String category){
    	double dPatientAmount=getPrice("C")+getSupplement(),dInsurarAmount=0;
        double dPrice = getPrice(category);
        double dInsuranceMaxPrice = getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
        String sShare=ScreenHelper.checkString(getPatientShare(insurance)+"");
        if (sShare.length()>0){
            dPatientAmount = dPrice * Double.parseDouble(sShare) / 100;
            dInsurarAmount = dPrice - dPatientAmount;
            if(dInsuranceMaxPrice>-1){
            	dInsurarAmount=dInsuranceMaxPrice;
           		dPatientAmount=dPrice - dInsurarAmount;
            }
            dPatientAmount+=getSupplement();
        }
        return dInsurarAmount;
    }

    public int getPatientShare(Insurance insurance){
        int patientShare=100;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //Eerst zoeken of er geen specifieke regeling bestaat voor dit artikel
            String sQuery="select * from OC_PRESTATION_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONUID=?";
            PreparedStatement ps=oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurance.getInsurarUid());
            ps.setString(2,this.getUid());
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                patientShare=rs.getInt("OC_PR_PATIENTSHARE");
            }
            else {
                rs.close();
                ps.close();
                //Zoeken of er geen specifieke regeling bestaat voor de familie van het artikel
                sQuery="select * from OC_PRESTATIONFAMILY_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONTYPE=?";
                ps=oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurance.getInsurarUid());
                ps.setString(2,this.getType());
                rs = ps.executeQuery();
                if(rs.next()){
                    patientShare=rs.getInt("OC_PR_PATIENTSHARE");
                }
                else {
                    patientShare=Integer.parseInt(insurance.getInsuranceCategory().getPatientShare());
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
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return patientShare;
    }

    public int getPatientShare(Insurar insurar,String category){
        int patientShare=100;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //Eerst zoeken of er geen specifieke regeling bestaat voor dit artikel
            String sQuery="select * from OC_PRESTATION_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONUID=?";
            PreparedStatement ps=oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurar.getUid());
            ps.setString(2,this.getUid());
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                patientShare=rs.getInt("OC_PR_PATIENTSHARE");
            }
            else {
                rs.close();
                ps.close();
                //Zoeken of er geen specifieke regeling bestaat voor de familie van het artikel
                sQuery="select * from OC_PRESTATIONFAMILY_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONTYPE=?";
                ps=oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurar.getUid());
                ps.setString(2,this.getType());
                rs = ps.executeQuery();
                if(rs.next()){
                    patientShare=rs.getInt("OC_PR_PATIENTSHARE");
                }
                else {
                    patientShare=Integer.parseInt(insurar.getInsuranceCategory(category).getPatientShare());
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
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return patientShare;
    }

    public String getCategoriesFormatted(){
        String categoriesFormatted="";
        String[] cats = categories.split(";");
        for(int n=0;n<cats.length;n++){
            if(cats[n].indexOf("=")>-1){
                if(n>0){
                    categoriesFormatted+=", ";
                }
                categoriesFormatted+=cats[n].split("=")[0].toUpperCase()+": "+cats[n].split("=")[1];
            }
        }
        return categoriesFormatted;
    }

    public String getCategoriesFormatted(String category){
        String categoriesFormatted="";
        try{
	        if(ScreenHelper.checkString(categories).length()>0){
	            String[] cats = ScreenHelper.checkString(categories).split(";");
	            for(int n=0;n<cats.length;n++){
	                if(cats[n].indexOf("=")>-1){
	                    if(n>0){
	                        categoriesFormatted+=", ";
	                    }
	                    if(cats[n].split("=")[0].equalsIgnoreCase(category)){
	                        categoriesFormatted+="<b>";
	                    }
	                    categoriesFormatted+=cats[n].split("=")[0].toUpperCase()+": "+cats[n].split("=")[1];
	                    if(cats[n].split("=")[0].equalsIgnoreCase(category)){
	                        categoriesFormatted+="</b>";
	                    }
	                }
	            }
	        }
        }
        catch(Exception e){
        	
        }
        return categoriesFormatted;
    }

    public void setCategories(String categories){
        this.categories = categories;
    }

    public ObjectReference getReferenceObject(){
        return referenceObject;
    }

    public void setReferenceObject(ObjectReference referenceObject){
        this.referenceObject = referenceObject;
    }

    public DebetTransaction getDebetTransaction(Date date, IObjectReference balanceOwner,Encounter encounter,IObjectReference referenceObject,ObjectReference supplier){
        Balance balance = Balance.getActiveBalance(balanceOwner.getObjectUid());
        if (balance==null){
            balance = new Balance();
            balance.setBalance(0);
            balance.setDate(new Date());
            balance.setOwner(balanceOwner.getObjectReference());
            balance.setMinimumBalance(MedwanQuery.getInstance().getConfigInt("defaultMinimumBalance",0));
            balance.setMaximumBalance(MedwanQuery.getInstance().getConfigInt("defaultMaximumBalance",999999999));
            balance.store();
            balance = Balance.getActiveBalance(balanceOwner.getObjectUid());
        }
        DebetTransaction debetTransaction = new DebetTransaction();
        debetTransaction.setDate(date);
        debetTransaction.setAmount(this.price);
        debetTransaction.setBalance(balance);
        debetTransaction.setDescription(this.getDescription());
        debetTransaction.setEncounter(encounter);
        debetTransaction.setPrestation(this);
        debetTransaction.setReferenceObject(referenceObject.getObjectReference());
        debetTransaction.setSupplier(supplier);
        debetTransaction.store();
        return debetTransaction;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Prestation get(String uid){
        Prestation prestation = (Prestation)MedwanQuery.getInstance().getObjectCache().getObject("prestation",uid);
        if(prestation!=null){
            return prestation;
        }
        prestation = new Prestation();

        if(uid!=null && uid.length() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String[] ids = uid.split("\\.");

                if(ids.length == 2){
                    String sSelect = "SELECT * FROM OC_PRESTATIONS"+
                                     " WHERE OC_PRESTATION_SERVERID = ?"+
                                     "  AND OC_PRESTATION_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
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
                        prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                        prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                        prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                        prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                        prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                        prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                        prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                        prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                        prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                        prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                        prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                        prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                    }
                }
            }
            catch(Exception e){
                Debug.println("OpenClinic => Prestation.java => get => "+e.getMessage());
                e.printStackTrace();
            }
            finally{
                try{
                    if(ps!=null) ps.close();
                    if(rs!=null) rs.close();
                    oc_conn.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("prestation",prestation);
        return prestation;
    }

    //--- GET PRESTATION CODE ---------------------------------------------------------------------
    public static String getPrestationCode(String uid){
        return getPrestationCode(Integer.parseInt(uid.split("\\.")[0]),Integer.parseInt(uid.split("\\.")[1]));
    }

    public static String getPrestationCode(int serverId, int objectId){
        String sPrestationCode = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PRESTATION_CODE FROM OC_PRESTATIONS"+
                             " WHERE OC_PRESTATION_SERVERID = ?"+
                             "  AND OC_PRESTATION_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,objectId);
            rs = ps.executeQuery();

            if(rs.next()){
                sPrestationCode = rs.getString("OC_PRESTATION_CODE");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return sPrestationCode;
    }

    public static Hashtable getAll(){
    	Hashtable allPrestations = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
            String sSelect = "SELECT * FROM OC_PRESTATIONS";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                allPrestations.put(prestation.getCode(), prestation);
            }
        }
        catch(Exception e){
            Debug.println("OpenClinic => Prestation.java => get => "+e.getMessage());
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    	return allPrestations;
    }
    
    //--- GET BY CODE -----------------------------------------------------------------------------
    public static Prestation getByCode(String code){
        Prestation prestation = new Prestation();

        if(code!=null && code.length() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String sSelect = "SELECT * FROM OC_PRESTATIONS"+
                                 " WHERE OC_PRESTATION_CODE = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,code);
                rs = ps.executeQuery();

                if(rs.next()){
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
                    prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                    prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                    prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                    prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                    prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                    prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                    prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                    prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                    prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                    prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                    prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                    prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                }
            }
            catch(Exception e){
                Debug.println("OpenClinic => Prestation.java => get => "+e.getMessage());
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                    oc_conn.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }

        return prestation;
    }

    public void setCategoryPrice(String category,String price){
        String[] prices = getCategories().split(";");
        boolean updated=false;
        for(int n=0;n<prices.length;n++){
            if(category.equalsIgnoreCase(prices[n].split("=")[0])){
                prices[n]=category+"="+price;
                updated = true;
            }
        }
        if (!updated){
            setCategories(getCategories()+category+"="+price+";");
        }
        else{
            String s ="";
            for(int n=0;n<prices.length;n++){
                s+=prices[n]+";";
            }
            setCategories(s);
        }
    }

    //--- SEARCH PRESTATIONS ----------------------------------------------------------------------
    public static Vector searchPrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice){
    	return searchPrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,"");
	}
    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice){
    	return searchActivePrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,"");
    }
    public static Vector searchPrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice, String sPrestationRefUid){
    	return searchPrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,sPrestationRefUid,"OC_PRESTATION_DESCRIPTION,OC_PRESTATION_CODE");

    }
    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice, String sPrestationRefUid){
    	return searchActivePrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,sPrestationRefUid,"OC_PRESTATION_DESCRIPTION,OC_PRESTATION_CODE");
    }
    public static String getDefaultPerformer(Prestation prestation,Service service){
    	String sPerformerUid="";
    	if(prestation.getPerformerUid()!=null && prestation.getPerformerUid().length()>0){
    		sPerformerUid=prestation.getPerformerUid();
    	}
    	return sPerformerUid;
    }
    
    public static Vector searchPrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice, String sPrestationRefUid, String sPrestationSort){
        Vector prestations = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_PRESTATIONS";
            if(sPrestationCode.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " (OC_PRESTATION_CODE like ? OR UPPER(OC_PRESTATION_CODE) LIKE ?) AND";
            }
            if(sPrestationDescr.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " (OC_PRESTATION_DESCRIPTION LIKE ? OR UPPER(OC_PRESTATION_DESCRIPTION) LIKE ?) AND";
            }
            if(sPrestationType.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PRESTATION_TYPE = ? AND";
            }
            if(sPrestationPrice.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PRESTATION_PRICE = ? AND";
            }
            if(sPrestationRefUid.length() > 0){
                sSql+= " OC_PRESTATION_REFUID LIKE ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY "+sPrestationSort;
            ps = oc_conn.prepareStatement(sSql);
            // set question marks
            int qmIdx = 1;
            if(sPrestationCode.length() > 0)ps.setString(qmIdx++,sPrestationCode+"%");
            if(sPrestationCode.length() > 0)ps.setString(qmIdx++,sPrestationCode.toUpperCase()+"%");
            if(sPrestationDescr.length() > 0)  {
            	ps.setString(qmIdx++,"%"+sPrestationDescr+"%");
            }
            if(sPrestationDescr.length() > 0)  ps.setString(qmIdx++,"%"+sPrestationDescr.toUpperCase()+"%");
            if(sPrestationType.length() > 0)   ps.setString(qmIdx++,sPrestationType);
            if(sPrestationPrice.length() > 0)  {
                float fPrice=0;
                try{
                	fPrice=Float.parseFloat(sPrestationPrice);
                }
                catch(Exception e2){
                	e2.printStackTrace();
                }
            	ps.setFloat(qmIdx++,fPrice);
            }
            if(sPrestationRefUid.length() > 0) ps.setString(qmIdx,sPrestationRefUid+"%");

            // execute query
            rs = ps.executeQuery();

            Prestation prestation;
            while(rs.next()){
                prestation = new Prestation();

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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));

                prestations.add(prestation);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice, String sPrestationRefUid, String sPrestationSort){
        Vector prestations = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_PRESTATIONS WHERE (OC_PRESTATION_INACTIVE IS NULL OR OC_PRESTATION_INACTIVE<>1) AND";
            if(sPrestationCode.length() > 0){
                sSql+= " (OC_PRESTATION_CODE like ? OR UPPER(OC_PRESTATION_CODE) LIKE ?) AND";
            }
            if(sPrestationDescr.length() > 0){
                sSql+= " (OC_PRESTATION_DESCRIPTION LIKE ? OR UPPER(OC_PRESTATION_DESCRIPTION) LIKE ?) AND";
            }
            if(sPrestationType.length() > 0){
                sSql+= " OC_PRESTATION_TYPE = ? AND";
            }
            if(sPrestationPrice.length() > 0){
                sSql+= " OC_PRESTATION_PRICE = ? AND";
            }
            if(sPrestationRefUid.length() > 0){
                sSql+= " OC_PRESTATION_REFUID LIKE ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY "+sPrestationSort;
            ps = oc_conn.prepareStatement(sSql);
            // set question marks
            int qmIdx = 1;
            if(sPrestationCode.length() > 0)ps.setString(qmIdx++,sPrestationCode+"%");
            if(sPrestationCode.length() > 0)ps.setString(qmIdx++,sPrestationCode.toUpperCase()+"%");
            if(sPrestationDescr.length() > 0)  {
            	ps.setString(qmIdx++,"%"+sPrestationDescr+"%");
            }
            if(sPrestationDescr.length() > 0)  ps.setString(qmIdx++,"%"+sPrestationDescr.toUpperCase()+"%");
            if(sPrestationType.length() > 0)   ps.setString(qmIdx++,sPrestationType);
            if(sPrestationPrice.length() > 0)  {
                float fPrice=0;
                try{
                	fPrice=Float.parseFloat(sPrestationPrice);
                }
                catch(Exception e2){
                	e2.printStackTrace();
                }
            	ps.setFloat(qmIdx++,fPrice);
            }
            if(sPrestationRefUid.length() > 0) ps.setString(qmIdx,sPrestationRefUid+"%");

            // execute query
            rs = ps.executeQuery();

            Prestation prestation;
            while(rs.next()){
                prestation = new Prestation();

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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));

                prestations.add(prestation);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        int iVersion;
        String[] ids;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        boolean recordExists;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");

                if(ids.length == 2){
                    //*** EXISTING RECORD ***
                    recordExists = true;

                    // raise version
                    sSql = "SELECT OC_PRESTATION_VERSION FROM OC_PRESTATIONS"+
                           " WHERE OC_PRESTATION_SERVERID = ? AND OC_PRESTATION_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSql);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if(rs.next()){
                        iVersion = rs.getInt("OC_PRESTATION_VERSION")+1;
                        this.setVersion(iVersion);
                    }
                    rs.close();
                    ps.close();
                }
                else{
                    throw new Exception("EXISTING PRESTATION WITHOUT VALID UID !");
                }
            }
            else{
                recordExists = false;

                //*** NON-EXISTING RECORD ***
                ids = new String[]{
                          MedwanQuery.getInstance().getConfigString("serverId"),
                          MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATIONS")+""
                      };
            }

            if(ids.length == 2){
                if(recordExists){
                    //*** UPDATE ***
                    sSql = "UPDATE OC_PRESTATIONS SET" +
                           "  OC_PRESTATION_CODE = ?," +
                           "  OC_PRESTATION_DESCRIPTION = ?," +
                           "  OC_PRESTATION_PRICE = ?," +
                           "  OC_PRESTATION_REFTYPE = ?," +
                           "  OC_PRESTATION_REFUID = ?," +
                           "  OC_PRESTATION_UPDATETIME = ?," +
                           "  OC_PRESTATION_UPDATEUID = ?," +
                           "  OC_PRESTATION_VERSION = ?," +
                           "  OC_PRESTATION_TYPE = ?,"+
                           "  OC_PRESTATION_CATEGORIES = ?,"+
                           "  OC_PRESTATION_MFPPERCENTAGE = ?,"+
                           "  OC_PRESTATION_INVOICEGROUP = ?,"+
                           "  OC_PRESTATION_RENEWALINTERVAL=?," +
                           "  OC_PRESTATION_COVERAGEPLAN=?," +
                           "  OC_PRESTATION_COVERAGEPLANCATEGORY=?," +
                           "  OC_PRESTATION_VARIABLEPRICE=?," +
                           "  OC_PRESTATION_INACTIVE=?," +
                           "  OC_PRESTATION_PERFORMERUID=?," +
                           "  OC_PRESTATION_SUPPLEMENT=?," +
                           "  OC_PRESTATION_CLASS=?," +
                           "  OC_PRESTATION_MODIFIERS=?," +
                           "  OC_PRESTATION_SERVICEUID=?" +
                           " WHERE OC_PRESTATION_SERVERID = ?"+
                           "  AND OC_PRESTATION_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSql);
                    ps.setString(1,this.getCode());
                    ps.setString(2,this.getDescription());
                    ps.setDouble(3,this.getPrice());
                    ps.setString(4,this.getReferenceObject().getObjectType());
                    ps.setString(5,this.getReferenceObject().getObjectUid());
                    ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(7,this.getUpdateUser());
                    ps.setInt(8,this.getVersion());
                    ps.setString(9,this.getType());
                    ps.setString(10,this.getCategories());
                    ps.setInt(11,this.getMfpPercentage());
                    ps.setString(12,this.getInvoiceGroup());
                    ps.setInt(13, this.getRenewalInterval());
                    ps.setString(14, this.getCoveragePlan());
                    ps.setString(15, this.getCoveragePlanCategory());
                    ps.setInt(16, this.getVariablePrice());
                    ps.setInt(17, this.getInactive());
                    ps.setString(18, this.getPerformerUid());
                    ps.setDouble(19, this.getSupplement());
                    ps.setString(20, this.getPrestationClass());
                    ps.setString(21, this.getModifiers());
                    ps.setString(22, this.getServiceUid());
                    ps.setInt(23,Integer.parseInt(ids[0]));
                    ps.setInt(24,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
                else{
                    //*** INSERT ***
                    sSql = "INSERT INTO OC_PRESTATIONS (" +
                           "  OC_PRESTATION_SERVERID," +
                           "  OC_PRESTATION_OBJECTID," +
                           "  OC_PRESTATION_CODE," +
                           "  OC_PRESTATION_DESCRIPTION," +
                           "  OC_PRESTATION_PRICE," +
                           "  OC_PRESTATION_REFTYPE," +
                           "  OC_PRESTATION_REFUID," +
                           "  OC_PRESTATION_CREATETIME," +
                           "  OC_PRESTATION_UPDATETIME," +
                           "  OC_PRESTATION_UPDATEUID," +
                           "  OC_PRESTATION_VERSION," +
                           "  OC_PRESTATION_TYPE," +
                           "  OC_PRESTATION_CATEGORIES," +
                           "  OC_PRESTATION_MFPPERCENTAGE," +
                           "  OC_PRESTATION_INVOICEGROUP," +
                           "  OC_PRESTATION_RENEWALINTERVAL," +
                           "  OC_PRESTATION_COVERAGEPLAN," +
                           "  OC_PRESTATION_COVERAGEPLANCATEGORY," +
                           "  OC_PRESTATION_VARIABLEPRICE," +
                           "  OC_PRESTATION_INACTIVE," +
                           "  OC_PRESTATION_PERFORMERUID," +
                           "  OC_PRESTATION_SUPPLEMENT," +
                           "  OC_PRESTATION_CLASS," +
                           "  OC_PRESTATION_MODIFIERS," +
                           "  OC_PRESTATION_SERVICEUID)"+
                           " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sSql);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.setString(3,this.getCode());
                    ps.setString(4,this.getDescription());
                    ps.setDouble(5,this.getPrice());
                    ps.setString(6,this.getReferenceObject().getObjectType());
                    ps.setString(7,this.getReferenceObject().getObjectUid());
                    ps.setTimestamp(8,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setTimestamp(9,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(10,this.getUpdateUser());
                    ps.setInt(11,1); // first version
                    ps.setString(12,this.getType());
                    ps.setString(13,this.getCategories());
                    ps.setInt(14,this.getMfpPercentage());
                    ps.setString(15,this.getInvoiceGroup());
                    ps.setInt(16, this.getRenewalInterval());
                    ps.setString(17, this.getCoveragePlan());
                    ps.setString(18, this.getCoveragePlanCategory());
                    ps.setInt(19,this.getVariablePrice());
                    ps.setInt(20, this.getInactive());
                    ps.setString(21, this.getPerformerUid());
                    ps.setDouble(22,this.getSupplement());
                    ps.setString(23,this.getPrestationClass());
                    ps.setString(24, this.getModifiers());
                    ps.setString(25, this.getServiceUid());
                    ps.executeUpdate();
                    ps.close();
                    setUid(ids[0]+"."+ids[1]);
                }
                //If MfpPercentage provided, create tariff
                if(getMfpPercentage()>=0){
                	Insurar insurar = Insurar.get(MedwanQuery.getInstance().getConfigString("MFP","-1"));
                	if(insurar!=null && insurar.getUid()!=null){
                		double price = getPrice(insurar.getType());
                    	Vector cats=insurar.getInsuraceCategories();
                    	for(int n=0;n<cats.size();n++){
                    		InsuranceCategory cat = (InsuranceCategory)cats.elementAt(n);
                    		saveInsuranceTariff(getUid(), insurar.getUid(), cat.getCategory(), price*getMfpPercentage()/100);
                    	}
                	}
                }
                if(getMfpAdmissionPercentage()>=0){
                	Insurar insurar = Insurar.get(MedwanQuery.getInstance().getConfigString("MFP","-1"));
                	if(insurar!=null && insurar.getUid()!=null){
                		double price = getPrice(insurar.getType());
                    	Vector cats=insurar.getInsuraceCategories();
                    	for(int n=0;n<cats.size();n++){
                    		InsuranceCategory cat = (InsuranceCategory)cats.elementAt(n);
                    		saveInsuranceTariff(getUid(), insurar.getUid(),"*H", price*getMfpAdmissionPercentage()/100);
                    	}
                	}
                }
            }
            else{
                throw new Exception("PRESTATION WITHOUT VALID UID !");
            }
        }
        catch(Exception e){
            Debug.println("OpenClinic => Prestation.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("prestation",this);
    }

    //--- GET PRESTATIONS BY CODE -----------------------------------------------------------------
    public static Vector getPrestationsByCode(String prestationCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector prestations = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_PRESTATIONS"+
                          " WHERE "+MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(OC_PRESTATION_CODE,?)=1";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,prestationCode);
            rs = ps.executeQuery();

            while(rs.next()){
                prestations.add(Prestation.get(rs.getString("OC_PRESTATION_UID")));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    public void registerPrestationAsDebetTransaction(String balanceuid,Date date,String encounterid,ObjectReference supplier,ObjectReference ref,String userid,String patientuid){
        Balance balance;
        if(balanceuid==null){
            balance = Balance.getActiveBalance(patientuid);
        }
        else{
            balance = Balance.get(balanceuid);
        }
        if (balance==null){
            balance = new Balance();
            balance.setBalance(0);
            balance.setDate(new Date());
            balance.setOwner(new ObjectReference("Person",patientuid));
            balance.setMinimumBalance(MedwanQuery.getInstance().getConfigInt("defaultMinimumBalance",0));
            balance.setMaximumBalance(MedwanQuery.getInstance().getConfigInt("defaultMaximumBalance",999999999));
            balance.store();
        }
        DebetTransaction debetTransaction = new DebetTransaction();
        debetTransaction.setDate(date);
        debetTransaction.setAmount(this.price);
        debetTransaction.setBalance(balance);
        debetTransaction.setDescription(this.getDescription());
        if(encounterid==null){
            Encounter encounter = Encounter.getActiveEncounter(patientuid);
            if(encounter!=null){
                encounterid=encounter.getUid();
            }
        }
        debetTransaction.setEncounterUID(encounterid);
        debetTransaction.setPrestation(this);
        debetTransaction.setReferenceObject(ref);
        debetTransaction.setSupplier(supplier);
        debetTransaction.setUpdateUser(userid);
        debetTransaction.setCreateDateTime(new Date());
        debetTransaction.setUpdateDateTime(new Date());
        debetTransaction.storeUnique();
    }

    public static void registerPrestationsAsDebetTransactions(String prestationCode,String balanceuid,Date date,String encounterid,ObjectReference supplier,ObjectReference ref,String userid,String patientuid){
        Debug.println("Looking for "+prestationCode);
        Vector prestations=getPrestationsByCode(prestationCode);
        Prestation prestation;
        for(int n=0;n<prestations.size();n++){
            prestation = (Prestation)prestations.elementAt(n);
            prestation.registerPrestationAsDebetTransaction(balanceuid,date,encounterid,supplier,ref,userid,patientuid);
        }
    }

    //--- GET ALL PRESTATIONS ---------------------------------------------------------------------
    public static Vector getAllPrestations(){
        return searchPrestations("","","","","");
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String uid){
        delete(Integer.parseInt(uid.split("\\.")[0]),Integer.parseInt(uid.split("\\.")[1]));
    }

    public static void delete(int serverId, int objectId){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_PRESTATIONS"+
                          " WHERE OC_PRESTATION_SERVERID = ?"+
                          "  AND OC_PRESTATION_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,serverId);
            ps.setInt(2,objectId);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Vector getPopularPrestations(String userid){
        Vector vPrestations = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "select "+MedwanQuery.getInstance().topFunction("10")+" count(*),OC_DEBET_PRESTATIONUID from oc_debets WHERE OC_DEBET_UPDATEUID=? group by OC_DEBET_PRESTATIONUID order by count(*) DESC"+MedwanQuery.getInstance().limitFunction("10");
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,userid);
            rs = ps.executeQuery();

            while (rs.next()){
                vPrestations.add(rs.getString("OC_DEBET_PRESTATIONUID"));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return vPrestations;
    }

	public double getSupplement() {
		return supplement;
	}

	public void setSupplement(double supplement) {
		this.supplement = supplement;
	}
}
