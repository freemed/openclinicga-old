package be.openclinic.pharmacy;

import net.admin.Service;
import be.openclinic.common.OC_Object;
import be.openclinic.finance.Prestation;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.*;
import java.util.Vector;
import java.text.SimpleDateFormat;

/**
 * User: Frank Verbeke, Stijn Smets
 * Date: 10-sep-2006
 */
public class Product extends OC_Object implements Comparable {
    private String name;
    private String unit;
    private double unitPrice;
    private int packageUnits;
    private int minimumOrderPackages = -1;
    private Service supplier;
    private String timeUnit; // (Hour|Day|Week|Month)
    private int timeUnitCount = -1;
    private double unitsPerTimeUnit = -1;
    private String productGroup;
    private String productSubGroup;
    private String prescriptionInfo;
    private String barcode;
    private String prestationcode;
    private int prestationquantity;
    private double margin;
    private boolean applyLowerPrices;
    private boolean automaticInvoicing;
    

    public boolean isAutomaticInvoicing() {
		return automaticInvoicing;
	}

	public String getProductSubGroup() {
		return productSubGroup;
	}

	public void setProductSubGroup(String productSubGroup) {
		this.productSubGroup = productSubGroup;
	}
	
	public String getFullProductSubGroupName(String sLanguage){
		String name="";
		if(ScreenHelper.checkString(this.productSubGroup).length()>0){
			Vector parents = DrugCategory.getParentIdsNoReverse(this.productSubGroup);
			for(int n=0;n<parents.size();n++){
				name+=HTMLEntities.htmlentities(ScreenHelper.getTranNoLink("drug.category", (String)parents.elementAt(n), sLanguage))+";";
			}
			name+=HTMLEntities.htmlentities(ScreenHelper.getTranNoLink("drug.category", this.productSubGroup, sLanguage));
		}
		return name;
	}
	
	public void setAutomaticInvoicing(boolean automaticInvoicing) {
		this.automaticInvoicing = automaticInvoicing;
	}

	public double getMargin() {
		return margin;
	}

	public void setMargin(double margin) {
		this.margin = margin;
	}

	public boolean isApplyLowerPrices() {
		return applyLowerPrices;
	}

	public void setApplyLowerPrices(boolean applyLowerPrices) {
		this.applyLowerPrices = applyLowerPrices;
	}

	public String getBarcode() {
		return barcode;
	}

	public void setBarcode(String barcode) {
		this.barcode = barcode;
	}

	public String getPrestationcode() {
		return prestationcode;
	}

	public void setPrestationcode(String prestationcode) {
		this.prestationcode = prestationcode;
	}

	public int getPrestationquantity() {
		return prestationquantity;
	}

	public void setPrestationquantity(int prestationquantity) {
		this.prestationquantity = prestationquantity;
	}

	public String getPrescriptionInfo() {
		return prescriptionInfo;
	}

	public void setPrescriptionInfo(String prescriptionInfo) {
		this.prescriptionInfo = prescriptionInfo;
	}

	// non-db data
    private String supplierUid;


    //--- NAME ------------------------------------------------------------------------------------
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    //--- UNIT ------------------------------------------------------------------------------------
    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    //--- UNIT PRICE ------------------------------------------------------------------------------
    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    //--- PACKAGE UNITS ---------------------------------------------------------------------------
    public int getPackageUnits() {
        return packageUnits;
    }

    public void setPackageUnits(int packageUnits) {
        this.packageUnits = packageUnits;
    }

    //--- MINIMUM ORDER PACKAGES ------------------------------------------------------------------
    public int getMinimumOrderPackages() {
        return minimumOrderPackages;
    }

    public void setMinimumOrderPackages(int minimumOrderPackages) {
        this.minimumOrderPackages = minimumOrderPackages;
    }

    public double getLastYearsAveragePrice(){
    	double price=0;
    	long day = 24*3600*1000;
    	long year = 365*day;
    	double totalprice=0;
    	double count=0;
    	Vector prices = Pointer.getLoosePointers("drugprice."+getUid(), new java.util.Date(new java.util.Date().getTime()-year), new java.util.Date());
    	for(int n=0; n<prices.size();n++){
    		String[] s = ((String)prices.elementAt(n)).split(";");
    		if(s.length>1){
    			totalprice+=Double.parseDouble(s[0])*Double.parseDouble(s[1]);
    			count+=Double.parseDouble(s[0]);
    		}
    	}
    	if(count>0){
    		price=totalprice/count;
    	}
    	return price;
    }
    
    public double getLastYearsAveragePrice(java.util.Date date){
    	double price=0;
    	long day = 24*3600*1000;
    	long year = 365*day;
    	double totalprice=0;
    	double count=0;
    	Vector prices = Pointer.getLoosePointers("drugprice."+getUid(), new java.util.Date(date.getTime()-year), date);
    	for(int n=0; n<prices.size();n++){
    		String[] s = ((String)prices.elementAt(n)).split(";");
    		if(s.length>1){
    			System.out.println("add "+s[0]+" x "+s[1]);
    			totalprice+=Double.parseDouble(s[0])*Double.parseDouble(s[1]);
    			count+=Double.parseDouble(s[0]);
    		}
    	}
    	if(count>0){
    		System.out.println("Total="+totalprice);
    		System.out.println("Count="+count);
    		price=totalprice/count;
    	}
    	return price;
    }
    
    //--- SUPPLIER --------------------------------------------------------------------------------
    public Service getSupplier() {
        if(supplierUid!=null && supplierUid.length() > 0){
            if(supplier==null){
                this.setSupplier(Service.getService(supplierUid));
            }
        }

        return supplier;
    }

    public void setSupplier(Service supplier) {
        this.supplier = supplier;
    }

    //--- TIMEUNIT --------------------------------------------------------------------------------
    public String getTimeUnit() {
        return timeUnit;
    }

    public void setTimeUnit(String timeUnit) {
        this.timeUnit = timeUnit;
    }

    //--- TIMEUNIT COUNT --------------------------------------------------------------------------
    public int getTimeUnitCount() {
        return timeUnitCount;
    }

    public void setTimeUnitCount(int timeUnitCount) {
        this.timeUnitCount = timeUnitCount;
    }

    //--- UNITS PER TIMEUNIT ----------------------------------------------------------------------
    public double getUnitsPerTimeUnit() {
        return unitsPerTimeUnit;
    }

    public void setUnitsPerTimeUnit(double unitsPerTimeUnit) {
        this.unitsPerTimeUnit = unitsPerTimeUnit;
    }

    //--- PRODUCTGROUP ----------------------------------------------------------------------------
    public String getProductGroup() {
        return productGroup;
    }

    public void setProductGroup(String productGroup) {
        this.productGroup = productGroup;
    }

    //--- NON_DB DATA : SUPPLIER UID --------------------------------------------------------------
    public void setSupplierUid(String uid){
        this.supplierUid = uid;
    }

    public String getSupplierUid(){
        return this.supplierUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Product get(String productUid){
        Product product = null;
        String sUids[] = productUid.split("\\.");

        if(sUids.length == 2){
            PreparedStatement ps = null;
            ResultSet rs = null;
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String sSelect = "SELECT * FROM OC_PRODUCTS"+
                                 " WHERE OC_PRODUCT_OBJECTID = ? AND OC_PRODUCT_SERVERID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sUids[1]));
                ps.setInt(2,Integer.parseInt(sUids[0]));
                rs = ps.executeQuery();

                // get data from DB
                if(rs.next()){
                    product = new Product();
                    product.setUid(productUid);

                    product.setName(rs.getString("OC_PRODUCT_NAME"));
                    product.setUnit(rs.getString("OC_PRODUCT_UNIT"));
                    product.setUnitPrice(rs.getDouble("OC_PRODUCT_UNITPRICE"));
                    product.setPackageUnits(rs.getInt("OC_PRODUCT_PACKAGEUNITS"));
                    product.setSupplierUid(rs.getString("OC_PRODUCT_SUPPLIERUID"));
                    product.setProductGroup(rs.getString("OC_PRODUCT_PRODUCTGROUP"));
                    product.setProductSubGroup(rs.getString("OC_PRODUCT_PRODUCTSUBGROUP"));
                    product.setPrescriptionInfo(rs.getString("OC_PRODUCT_PRESCRIPTIONINFO"));
                    product.setBarcode(rs.getString("OC_PRODUCT_BARCODE"));
                    product.setPrestationcode(rs.getString("OC_PRODUCT_PRESTATIONCODE"));
                    product.setPrestationquantity(rs.getInt("OC_PRODUCT_PRESTATIONQUANTITY"));
                    product.setMargin(rs.getDouble("OC_PRODUCT_MARGIN"));
                    product.setApplyLowerPrices(rs.getInt("OC_PRODUCT_APPLYLOWERPRICES")==1);
                    product.setAutomaticInvoicing(rs.getInt("OC_PRODUCT_AUTOMATICINVOICING")==1);
                    

                    // timeUnit
                    String tmpValue = rs.getString("OC_PRODUCT_TIMEUNIT");
                    if(tmpValue!=null){
                        product.setTimeUnit(tmpValue);
                    }

                    // timeUnitCount
                    tmpValue = rs.getString("OC_PRODUCT_TIMEUNITCOUNT");
                    if(tmpValue!=null){
                        product.setTimeUnitCount(Integer.parseInt(tmpValue));
                    }

                    // unitsPerTimeUnit
                    tmpValue = rs.getString("OC_PRODUCT_UNITSPERTIMEUNIT");
                    if(tmpValue!=null){
                        product.setUnitsPerTimeUnit(Double.parseDouble(tmpValue));
                    }

                    // minimumOrderPackages
                    tmpValue = rs.getString("OC_PRODUCT_MINORDERPACKAGES");
                    if(tmpValue!=null){
                        product.setMinimumOrderPackages(Integer.parseInt(tmpValue));
                    }

                    // OBJECT variables
                    product.setCreateDateTime(rs.getTimestamp("OC_PRODUCT_CREATETIME"));
                    product.setUpdateDateTime(rs.getTimestamp("OC_PRODUCT_UPDATETIME"));
                    product.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PRODUCT_UPDATEUID")));
                    product.setVersion(rs.getInt("OC_PRODUCT_VERSION"));
                }
                else{
                    throw new Exception("ERROR : PRODUCT "+productUid+" NOT FOUND");
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
        }

        return product;
    }

    //--- GET PRODUCT FROM HISTORY ----------------------------------------------------------------
    public Product getProductFromHistory(String productUid) {
        Product product = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_PRODUCTS_HISTORY"+
                             " WHERE OC_PRODUCT_SERVERID=? AND OC_PRODUCT_OBJECTID=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(productUid.substring(0,productUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(productUid.substring(productUid.indexOf(".")+1)));

            rs = ps.executeQuery();
            if(rs.next()) {
                product = new Product();
                product.setUid(rs.getString("OC_PRODUCT_SERVERID")+"."+rs.getString("OC_PRODUCT_OBJECTID"));
                product.setName(rs.getString("OC_PRODUCT_NAME"));
                product.setUnit(rs.getString("OC_PRODUCT_UNIT"));
                product.setUnitPrice(rs.getDouble("OC_PRODUCT_UNITPRICE"));
                product.setPackageUnits(rs.getInt("OC_PRODUCT_PACKAGEUNITS"));
                product.setBarcode(rs.getString("OC_PRODUCT_BARCODE"));
                product.setPrestationcode(rs.getString("OC_PRODUCT_PRESTATIONCODE"));
                product.setPrestationquantity(rs.getInt("OC_PRODUCT_PRESTATIONQUANTITY"));
                product.setMargin(rs.getDouble("OC_PRODUCT_MARGIN"));
                product.setApplyLowerPrices(rs.getInt("OC_PRODUCT_APPLYLOWERPRICES")==1);
                product.setAutomaticInvoicing(rs.getInt("OC_PRODUCT_AUTOMATICINVOICING")==1);

                // supplier
                String supplierUid = rs.getString("OC_PRODUCT_SUPPLIERUID");
                if(supplierUid!=null){
                    Service supplier = Service.getService(supplierUid);
                    product.setSupplier(supplier);
                    product.setSupplierUid(supplierUid);
                }

                // timeUnit
                String tmpValue = rs.getString("OC_PRODUCT_TIMEUNIT");
                if(tmpValue!=null){
                    product.setTimeUnit(tmpValue);
                }

                // timeUnitCount
                tmpValue = rs.getString("OC_PRODUCT_TIMEUNITCOUNT");
                if(tmpValue!=null){
                    product.setTimeUnitCount(Integer.parseInt(tmpValue));
                }

                // unitsPerTimeUnit
                tmpValue = rs.getString("OC_PRODUCT_UNITSPERTIMEUNIT");
                if(tmpValue!=null){
                    product.setUnitsPerTimeUnit(Double.parseDouble(tmpValue));
                }

                // minimumOrderPackages
                tmpValue = rs.getString("OC_PRODUCT_MINORDERPACKAGES");
                if(tmpValue!=null){
                    product.setMinimumOrderPackages(Integer.parseInt(tmpValue));
                }

                // productGroup
                product.setProductGroup(rs.getString("OC_PRODUCT_PRODUCTGROUP"));
                product.setProductSubGroup(rs.getString("OC_PRODUCT_PRODUCTSUBGROUP"));

                // OBJECT variables
                product.setCreateDateTime(rs.getTimestamp("OC_PRODUCT_CREATETIME"));
                product.setUpdateDateTime(rs.getTimestamp("OC_PRODUCT_UPDATETIME"));
                product.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PRODUCT_UPDATEUID")));
                product.setVersion(rs.getInt("OC_PRODUCT_VERSION"));
                product.setPrescriptionInfo(rs.getString("OC_PRODUCT_PRESCRIPTIONINFO"));
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

        return product;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        store(true);
    }

    public void store(boolean checkExistence){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        int newVersion = 1;
        boolean productWithSameDataExists = false;

        // set new productuid if needed
        if(this.getUid().equals("-1")){
            int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
            int productCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRODUCTS");
            this.setUid(serverId+"."+productCounter);
        }

        // check existence if needed
        if(checkExistence){
            productWithSameDataExists = this.exists().length()>0;
        }

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(!this.getUid().equals("-1") && !productWithSameDataExists){

                // get version of product that is copied to history and increase it
                sSelect = "SELECT * FROM OC_PRODUCTS WHERE OC_PRODUCT_SERVERID = ? AND OC_PRODUCT_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(2,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));
                rs = ps.executeQuery();
                if(rs.next()){
                    newVersion = rs.getInt("OC_PRODUCT_VERSION")+1;
                }
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();

                // delete product from current products
                Debug.println("@@@ PRODUCT DELETE after TO-HISTORY-COPY @@@");

                sSelect = "DELETE FROM OC_PRODUCTS WHERE OC_PRODUCT_SERVERID = ? AND OC_PRODUCT_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(2,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));
                ps.executeUpdate();
                if(ps!=null) ps.close();
            }

            // insert new version of product into current products
            Debug.println("@@@ PRODUCT insert @@@");

            sSelect = "INSERT INTO OC_PRODUCTS (OC_PRODUCT_SERVERID,OC_PRODUCT_OBJECTID,"+
                      "  OC_PRODUCT_NAME,OC_PRODUCT_UNIT,OC_PRODUCT_UNITPRICE,OC_PRODUCT_PACKAGEUNITS,"+
                      "  OC_PRODUCT_MINORDERPACKAGES,OC_PRODUCT_SUPPLIERUID,OC_PRODUCT_TIMEUNIT,"+
                      "  OC_PRODUCT_TIMEUNITCOUNT,OC_PRODUCT_UNITSPERTIMEUNIT,OC_PRODUCT_PRODUCTGROUP,"+
                      "  OC_PRODUCT_CREATETIME,OC_PRODUCT_UPDATETIME,OC_PRODUCT_UPDATEUID,OC_PRODUCT_VERSION,OC_PRODUCT_PRESCRIPTIONINFO," +
                      "  OC_PRODUCT_BARCODE,OC_PRODUCT_PRESTATIONCODE,OC_PRODUCT_PRESTATIONQUANTITY,OC_PRODUCT_MARGIN,OC_PRODUCT_APPLYLOWERPRICES," +
                      "  OC_PRODUCT_AUTOMATICINVOICING,OC_PRODUCT_PRODUCTSUBGROUP)"+
                      " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

            ps.setString(3,this.getName());
            ps.setString(4,this.getUnit());
            ps.setDouble(5,this.getUnitPrice());
            ps.setInt(6,this.getPackageUnits());

            if(this.getMinimumOrderPackages() > -1) ps.setInt(7,this.getMinimumOrderPackages());
            else                                    ps.setNull(7,Types.INTEGER);

            if(this.getSupplierUid()!=null && this.getSupplierUid().length() > 0) ps.setString(8,this.getSupplierUid());
            else                                                                  ps.setNull(8,Types.VARCHAR);

            if(this.getTimeUnit()!=null && this.getTimeUnit().length() > 0) ps.setString(9,this.getTimeUnit());
            else                                                            ps.setNull(9,Types.VARCHAR);

            if(this.getTimeUnitCount() > -1) ps.setInt(10,this.getTimeUnitCount());
            else                             ps.setNull(10,Types.INTEGER);

            if(this.getUnitsPerTimeUnit() > -1) ps.setDouble(11,this.getUnitsPerTimeUnit());
            else                                ps.setNull(11,Types.DOUBLE);

            if(this.getProductGroup()!=null) ps.setString(12,this.getProductGroup());
            else                             ps.setString(12,"");                             

            // OBJECT variables
            ps.setTimestamp(13,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.setTimestamp(14,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.setString(15,this.getUpdateUser());
            ps.setInt(16,newVersion);
            ps.setString(17, this.getPrescriptionInfo());
            ps.setString(18, this.getBarcode());
            ps.setString(19, this.getPrestationcode());
            ps.setInt(20, this.getPrestationquantity());
            ps.setDouble(21, this.getMargin());
            ps.setInt(22, isApplyLowerPrices()?1:0);
            ps.setInt(23, isAutomaticInvoicing()?1:0);
            if(this.getProductSubGroup()!=null) ps.setString(24,this.getProductSubGroup());
            else                             ps.setString(24,"");                             

            ps.executeUpdate();
            
            //If a health service and a margin were provided, automatically update the health service price
            if(this.getPrestationcode()!=null && this.getPrestationcode().length()>0 && this.getMargin()!=0 && this.getPrestationquantity()>0){
            	Prestation prestation = Prestation.get(this.getPrestationcode());
            	if(prestation!=null){
            		double newPrice=this.getUnitPrice()*(100+this.getMargin())/(100*(this.getPrestationquantity()));
            		if(isApplyLowerPrices()||newPrice>prestation.getPrice()){
	            		prestation.setPrice(newPrice);
	            		prestation.store();
            		}
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
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    // checks the database for a record with the same UNIQUE KEYS as 'this'.
    public String exists(){
        Debug.println("@@@ PRODUCT exists ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_PRODUCT_SERVERID,OC_PRODUCT_OBJECTID FROM OC_PRODUCTS"+
                             " WHERE OC_PRODUCT_NAME=?"+
                             "  AND OC_PRODUCT_UNIT=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++,this.getName());
            ps.setString(questionmarkIdx++,this.getUnit());


            rs = ps.executeQuery();
            if(rs.next()){
                uid = rs.getInt("OC_PRODUCT_SERVERID")+"."+rs.getInt("OC_PRODUCT_OBJECTID");
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

        return uid;
    }

    //--- CHANGED ---------------------------------------------------------------------------------
    // checks the database for a record with the same DATA as 'this'.
    public boolean changed(){
        Debug.println("@@@ PRODUCT changed ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_PRODUCT_SERVERID,OC_PRODUCT_OBJECTID FROM OC_PRODUCTS"+
                             " WHERE OC_PRODUCT_NAME=?"+
                             "  AND OC_PRODUCT_UNIT=?"+
                             "  AND OC_PRODUCT_UNITPRICE=?"+
                             "  AND OC_PRODUCT_PACKAGEUNITS=?"+
                             "  AND OC_PRODUCT_MINORDERPACKAGES=?"+
                             "  AND OC_PRODUCT_SUPPLIERUID=?"+
                             "  AND OC_PRODUCT_TIMEUNIT=?"+
                             "  AND OC_PRODUCT_TIMEUNITCOUNT=?"+
                             "  AND OC_PRODUCT_UNITSPERTIMEUNIT=?"+
                             "  AND OC_PRODUCT_PRODUCTGROUP=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;

            ps.setString(questionmarkIdx++,this.getName()); // required
            ps.setString(questionmarkIdx++,this.getUnit()); // required
            ps.setDouble(questionmarkIdx++,this.getUnitPrice()); // required
            ps.setInt(questionmarkIdx++,this.getPackageUnits()); // required

            // minimumOrderPackages
            if(this.minimumOrderPackages > -1) ps.setInt(questionmarkIdx++,this.minimumOrderPackages);
            else                               ps.setNull(questionmarkIdx++,Types.INTEGER);

            // supplierUid
            if(this.getSupplierUid().length() > 0) ps.setString(questionmarkIdx++,this.getSupplierUid());
            else                                   ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // timeUnit
            if(this.getTimeUnit().length() > 0) ps.setString(questionmarkIdx++,this.getTimeUnit());
            else                                ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // timeUnitCount
            if(this.timeUnitCount > -1) ps.setInt(questionmarkIdx++,this.timeUnitCount);
            else                        ps.setNull(questionmarkIdx++,Types.INTEGER);

            // unitsPerTimeUnit
            if(this.unitsPerTimeUnit > -1) ps.setDouble(questionmarkIdx++,this.unitsPerTimeUnit);
            else                           ps.setNull(questionmarkIdx++,Types.DOUBLE);

            // productGroup
            if(this.getProductGroup().length() > 0) ps.setString(questionmarkIdx++,this.getProductGroup());
            else                                    ps.setNull(questionmarkIdx++,Types.VARCHAR);

            rs = ps.executeQuery();
            if(rs.next()) changed = false;
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

        return changed;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String productUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_PRODUCTS"+
                             " WHERE OC_PRODUCT_SERVERID = ? AND OC_PRODUCT_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(productUid.substring(0,productUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(productUid.substring(productUid.indexOf(".")+1)));
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

    public static Vector getProductGroups(){
        Vector groups = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "select distinct OC_PRODUCT_PRODUCTGROUP from OC_PRODUCTS order by OC_PRODUCT_PRODUCTGROUP";
            ps=oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()){
                groups.add(rs.getString("OC_PRODUCT_PRODUCTGROUP"));
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

        return groups;
    }

    public static Vector getProductSubGroups(){
        Vector groups = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "select distinct OC_PRODUCT_PRODUCTSUBGROUP from OC_PRODUCTS order by OC_PRODUCT_PRODUCTSUBGROUP";
            ps=oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()){
                groups.add(rs.getString("OC_PRODUCT_PRODUCTSUBGROUP"));
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

        return groups;
    }
//--- FIND ------------------------------------------------------------------------------------
    public static Vector find(String sFindProductName, String sFindUnit, String sFindUnitPriceMin,
                              String sFindUnitPriceMax, String sFindPackageUnits, String sFindMinOrderPackages,
                              String sFindSupplierUid, String sFindProductGroup, String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT "+MedwanQuery.getInstance().topFunction(MedwanQuery.getInstance().getConfigString("maxProductsToShow","100"))+" OC_PRODUCT_SERVERID,OC_PRODUCT_OBJECTID"+
                             " FROM OC_PRODUCTS ";

            if(sFindProductName.length()>0 || sFindUnit.length()>0 || sFindUnitPriceMin.length()>0 ||
               sFindUnitPriceMax.length()>0 || sFindPackageUnits.length()>0 || sFindMinOrderPackages.length()>0 ||
               sFindSupplierUid.length()>0 || sFindProductGroup.length()>0){
                sSelect+= "WHERE ";

                if(sFindProductName.length() > 0){
                    String sLowerProductName = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_PRODUCT_NAME");
                    sSelect+= sLowerProductName+" LIKE ? AND ";
                }

                if(sFindUnit.length() > 0)             sSelect+= "OC_PRODUCT_UNIT = ? AND ";
                if(sFindUnitPriceMin.length() > 0)     sSelect+= "OC_PRODUCT_UNITPRICE >= ? AND ";
                if(sFindUnitPriceMax.length() > 0)     sSelect+= "OC_PRODUCT_UNITPRICE <= ? AND ";
                if(sFindPackageUnits.length() > 0)     sSelect+= "OC_PRODUCT_PACKAGEUNITS = ? AND ";
                if(sFindMinOrderPackages.length() > 0) sSelect+= "OC_PRODUCT_MINORDERPACKAGES = ? AND ";
                if(sFindProductGroup.length() > 0)     sSelect+= "OC_PRODUCT_PRODUCTGROUP = ? AND ";

                if(sFindSupplierUid.length() > 0){
                    //Hier moet de stock komen die het product in voorraad moet hebben
                	sSelect+="OC_PRODUCT_OBJECTID in (select replace(OC_STOCK_PRODUCTUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') from OC_PRODUCTSTOCKS where OC_STOCK_SERVICESTOCKUID='"+sFindSupplierUid+"') AND ";
                	/*
                	// search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindSupplierUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
                    if(sChildIds.length() > 0){
                        sSelect+= "OC_PRODUCT_SUPPLIERUID IN ("+sChildIds+") AND ";
                    }
                    else{
                        sSelect+= "OC_PRODUCT_SUPPLIERUID IN ('') AND ";
                    }
                    */
                }

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            // order
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir+MedwanQuery.getInstance().limitFunction(MedwanQuery.getInstance().getConfigString("maxProductsToShow","100"));

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(sFindProductName.length() > 0)      ps.setString(questionMarkIdx++,"%"+sFindProductName.toLowerCase()+"%");
            if(sFindUnit.length() > 0)             ps.setString(questionMarkIdx++,sFindUnit);
            if(sFindUnitPriceMin.length() > 0)     ps.setDouble(questionMarkIdx++,Double.parseDouble(sFindUnitPriceMin));
            if(sFindUnitPriceMax.length() > 0)     ps.setDouble(questionMarkIdx++,Double.parseDouble(sFindUnitPriceMax));
            if(sFindPackageUnits.length() > 0)     ps.setInt(questionMarkIdx++,Integer.parseInt(sFindPackageUnits));
            if(sFindMinOrderPackages.length() > 0) ps.setInt(questionMarkIdx++,Integer.parseInt(sFindMinOrderPackages));
            if(sFindProductGroup.length() > 0)     ps.setString(questionMarkIdx++,sFindProductGroup);

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_PRODUCT_SERVERID")+"."+rs.getString("OC_PRODUCT_OBJECTID")));
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

    public static Vector find(String sFindProductName, String sFindUnit, String sFindUnitPriceMin,
            String sFindUnitPriceMax, String sFindPackageUnits, String sFindMinOrderPackages,
            String sFindSupplierUid, String sFindProductGroup, String sFindProductSubGroup, String sSortCol, String sSortDir){
		Vector foundObjects = new Vector();
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
		String sSelect = "SELECT "+MedwanQuery.getInstance().topFunction(MedwanQuery.getInstance().getConfigString("maxProductsToShow","100"))+" OC_PRODUCT_SERVERID,OC_PRODUCT_OBJECTID"+
		           " FROM OC_PRODUCTS ";
		
		if(sFindProductName.length()>0 || sFindUnit.length()>0 || sFindUnitPriceMin.length()>0 ||
		sFindUnitPriceMax.length()>0 || sFindPackageUnits.length()>0 || sFindMinOrderPackages.length()>0 ||
		sFindSupplierUid.length()>0 || sFindProductGroup.length()>0 || sFindProductSubGroup.length()>0){
		sSelect+= "WHERE ";
		
		if(sFindProductName.length() > 0){
		  String sLowerProductName = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_PRODUCT_NAME");
		  sSelect+= sLowerProductName+" LIKE ? AND ";
		}
		
		if(sFindUnit.length() > 0)             sSelect+= "OC_PRODUCT_UNIT = ? AND ";
		if(sFindUnitPriceMin.length() > 0)     sSelect+= "OC_PRODUCT_UNITPRICE >= ? AND ";
		if(sFindUnitPriceMax.length() > 0)     sSelect+= "OC_PRODUCT_UNITPRICE <= ? AND ";
		if(sFindPackageUnits.length() > 0)     sSelect+= "OC_PRODUCT_PACKAGEUNITS = ? AND ";
		if(sFindMinOrderPackages.length() > 0) sSelect+= "OC_PRODUCT_MINORDERPACKAGES = ? AND ";
		if(sFindProductGroup.length() > 0)     sSelect+= "OC_PRODUCT_PRODUCTGROUP = ? AND ";
		if(sFindProductSubGroup.length() > 0)     sSelect+= "OC_PRODUCT_PRODUCTSUBGROUP like ? AND ";
		
		if(sFindSupplierUid.length() > 0){
		  //Hier moet de stock komen die het product in voorraad moet hebben
			sSelect+="OC_PRODUCT_OBJECTID in (select replace(OC_STOCK_PRODUCTUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') from OC_PRODUCTSTOCKS where OC_STOCK_SERVICESTOCKUID='"+sFindSupplierUid+"') AND ";
			/*
			// search all service and its child-services
		  Vector childIds = Service.getChildIds(sFindSupplierUid);
		  String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
		  if(sChildIds.length() > 0){
		      sSelect+= "OC_PRODUCT_SUPPLIERUID IN ("+sChildIds+") AND ";
		  }
		  else{
		      sSelect+= "OC_PRODUCT_SUPPLIERUID IN ('') AND ";
		  }
		  */
		}
		
		// remove last AND if any
		if(sSelect.indexOf("AND ")>0){
		  sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
		}
		}
		
		// order
		sSelect+= "ORDER BY "+sSortCol+" "+sSortDir+MedwanQuery.getInstance().limitFunction(MedwanQuery.getInstance().getConfigString("maxProductsToShow","100"));
		
		ps = oc_conn.prepareStatement(sSelect);
		
		// set questionmark values
		int questionMarkIdx = 1;
		if(sFindProductName.length() > 0)      ps.setString(questionMarkIdx++,"%"+sFindProductName.toLowerCase()+"%");
		if(sFindUnit.length() > 0)             ps.setString(questionMarkIdx++,sFindUnit);
		if(sFindUnitPriceMin.length() > 0)     ps.setDouble(questionMarkIdx++,Double.parseDouble(sFindUnitPriceMin));
		if(sFindUnitPriceMax.length() > 0)     ps.setDouble(questionMarkIdx++,Double.parseDouble(sFindUnitPriceMax));
		if(sFindPackageUnits.length() > 0)     ps.setInt(questionMarkIdx++,Integer.parseInt(sFindPackageUnits));
		if(sFindMinOrderPackages.length() > 0) ps.setInt(questionMarkIdx++,Integer.parseInt(sFindMinOrderPackages));
		if(sFindProductGroup.length() > 0)     ps.setString(questionMarkIdx++,sFindProductGroup);
		if(sFindProductSubGroup.length() > 0)     ps.setString(questionMarkIdx++,sFindProductSubGroup+"%");
		
		// execute
		rs = ps.executeQuery();
		
		while(rs.next()){
		foundObjects.add(get(rs.getString("OC_PRODUCT_SERVERID")+"."+rs.getString("OC_PRODUCT_OBJECTID")));
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
    public static boolean isInStock(String sProductUID,String sServiceUID){
    	boolean isInStock = false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sServiceUID!=null && sServiceUID.length()>0){
            	//Eerst controleren we of het product in de dienststock bestaat
                String sQuery = "select oc_stock_level" +
                        " from oc_productstocks a,oc_servicestocks b" +
                        " where" +
                        " b.oc_stock_objectid=replace(a.oc_stock_servicestockuid,'"+ MedwanQuery.getInstance().getConfigInt("serverId")+".','') and" +
                        " a.oc_stock_productuid=? and" +
                        " b.oc_stock_serviceuid=?";
                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,sProductUID);
                ps.setString(2,sServiceUID);
                ResultSet rs = ps.executeQuery();
                while(rs.next() && !isInStock){
                	isInStock=rs.getInt("oc_stock_level")>0;
                }
                rs.close();
                ps.close();
            }
            if(!isInStock){
                //Het product bestaat niet in de dienststock, dus testen we de centrale stock
                String sQuery = "select oc_stock_level" +
                        " from oc_productstocks a,oc_servicestocks b" +
                        " where" +
                        " b.oc_stock_objectid=replace(a.oc_stock_servicestockuid,'"+ MedwanQuery.getInstance().getConfigInt("serverId")+".','') and" +
                        " a.oc_stock_productuid=? and" +
                        " b.oc_stock_serviceuid=?";
                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,sProductUID);
                ps.setString(2,MedwanQuery.getInstance().getConfigString("centralPharmacyCode","PHA.PHA"));
                ResultSet rs = ps.executeQuery();
                while(rs.next() && !isInStock){
                	isInStock=rs.getInt("oc_stock_level")>0;
                }
                rs.close();
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
        return isInStock;
    }

    public static int quantityAvailable(String sProductUID,String sServiceStockUID){
        int quantity = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sServiceStockUID!=null && sServiceStockUID.length()>0){
                //Eerst controleren we of het product in de dienststock bestaat
                String sQuery = "select sum(oc_stock_level) total" +
                        " from oc_productstocks" +
                        " where" +
                        " oc_stock_servicestockuid=? and" +
                        " oc_stock_productuid=?";
                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,sServiceStockUID);
                ps.setString(2,sProductUID);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    quantity=rs.getInt("total");
                }
                rs.close();
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
        return quantity;
    }

    public boolean isInStock(String sServiceUID){
        return Product.isInStock(getUid(),sServiceUID);
    }

    public int quantityAvailable(String sServiceUID){
        return Product.quantityAvailable(getUid(),sServiceUID);
    }

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object obj){
        Product otherProduct = (Product)obj;
        return this.name.compareTo(otherProduct.name);
    }

}
