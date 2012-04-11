package be.openclinic.pharmacy;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;
import java.sql.*;

import net.admin.Service;

/**
 * User: Stijn Smets
 * Date: 10-sep-2006
 */
public class ProductOrder extends OC_Object{
    private String description;
    private ProductStock productStock;
    private int packagesOrdered = -1;
    private int packagesDelivered = -1;
    private Date dateOrdered;
    private Date dateDeliveryDue;
    private Date dateDelivered;
    private String importance; // (native|high|low)

    // non-db data
    private String productStockUid;


    //--- DESCRIPTION -----------------------------------------------------------------------------
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    //--- PRODUCT STOCK ---------------------------------------------------------------------------
    public ProductStock getProductStock() {
        if(productStockUid!=null && productStockUid.length() > 0){
            if(productStock==null){
                this.setProductStock(ProductStock.get(productStockUid));
            }
        }

        return productStock;
    }

    public void setProductStock(ProductStock productStock) {
        this.productStock = productStock;
    }

    public static int getOpenOrderedQuantity(String productStockUid){
        int quantity=0;
        PreparedStatement ps = null;
        ResultSet rs=null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select sum(OC_ORDER_PACKAGESORDERED) as total from OC_PRODUCTORDERS" +
                    " where " +
                    " OC_ORDER_DATEDELIVERED IS NULL and" +
                    " OC_ORDER_PRODUCTSTOCKUID=?";
            ps=oc_conn.prepareStatement(sQuery);
            ps.setString(1,productStockUid);
            rs=ps.executeQuery();
            if(rs.next()){
                quantity=rs.getInt("total");
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
        return quantity;
    }

    //--- PACKAGES ORDERED ------------------------------------------------------------------------
    public int getPackagesOrdered() {
        return packagesOrdered;
    }

    public void setPackagesOrdered(int packagesOrdered) {
        this.packagesOrdered = packagesOrdered;
    }

    //--- PACKAGES DELIVERED ----------------------------------------------------------------------
    public int getPackagesDelivered() {
        return packagesDelivered;
    }

    public void setPackagesDelivered(int packagesDelivered) {
        this.packagesDelivered = packagesDelivered;
    }

    //--- DATE ORDERED ----------------------------------------------------------------------------
    public Date getDateOrdered() {
        return dateOrdered;
    }

    public void setDateOrdered(Date dateOrdered) {
        this.dateOrdered = dateOrdered;
    }

    //--- DATE DELIVERY DUE -----------------------------------------------------------------------
    public Date getDateDeliveryDue() {
        return dateDeliveryDue;
    }

    public void setDateDeliveryDue(Date dateDeliveryDue) {
        this.dateDeliveryDue = dateDeliveryDue;
    }

    //--- DATE DELIVERED --------------------------------------------------------------------------
    public Date getDateDelivered() {
        return dateDelivered;
    }

    public void setDateDelivered(Date dateDelivered) {
        this.dateDelivered = dateDelivered;
    }

    //--- IMPORTANCE ------------------------------------------------------------------------------
    public String getImportance() {
        return importance;
    }

    public void setImportance(String importance) {
        this.importance = importance;
    }

    //--- NON-DB DATA : PRODUCT STOCK UID ---------------------------------------------------------
    public void setProductStockUid(String uid){
        this.productStockUid = uid;
    }

    public String getProductStockUid(){
        return this.productStockUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static ProductOrder get(String orderUid){
        ProductOrder order = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_PRODUCTORDERS"+
                             " WHERE OC_ORDER_SERVERID = ? AND OC_ORDER_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(orderUid.substring(0,orderUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(orderUid.substring(orderUid.indexOf(".")+1)));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                order = new ProductOrder();
                order.setUid(orderUid);

                order.setDescription(rs.getString("OC_ORDER_DESCRIPTION"));
                order.setImportance(rs.getString("OC_ORDER_IMPORTANCE")); // (native|high|low)
                order.setProductStockUid(rs.getString("OC_ORDER_PRODUCTSTOCKUID"));

                // packagesOrdered
                String tmpValue = rs.getString("OC_ORDER_PACKAGESORDERED");
                if(tmpValue!=null){
                    order.setPackagesOrdered(Integer.parseInt(tmpValue));
                }

                // packagesDelivered
                tmpValue = rs.getString("OC_ORDER_PACKAGESDELIVERED");
                if(tmpValue!=null){
                    order.setPackagesDelivered(Integer.parseInt(tmpValue));
                }

                // dates
                order.setDateOrdered(rs.getDate("OC_ORDER_DATEORDERED"));
                order.setDateDeliveryDue(rs.getDate("OC_ORDER_DATEDELIVERYDUE"));
                order.setDateDelivered(rs.getDate("OC_ORDER_DATEDELIVERED"));

                // OBJECT variables
                order.setCreateDateTime(rs.getTimestamp("OC_ORDER_CREATETIME"));
                order.setUpdateDateTime(rs.getTimestamp("OC_ORDER_UPDATETIME"));
                order.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ORDER_UPDATEUID")));
                order.setVersion(rs.getInt("OC_ORDER_VERSION"));
            }
            else{
                throw new Exception("ERROR : PRODUCTORDER "+orderUid+" NOT FOUND");
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

        return order;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        store(true);
    }

    public void store(boolean checkExistence){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        boolean orderWithSameDataExists = false;

        // check existence if needed
        if(checkExistence){
            orderWithSameDataExists = this.exists().length()>0;
        }

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid().equals("-1") && !orderWithSameDataExists){
                //***** INSERT *****
                if(Debug.enabled) Debug.println("@@@ PRODUCTORDER insert @@@");

                sSelect = "INSERT INTO OC_PRODUCTORDERS (OC_ORDER_SERVERID, OC_ORDER_OBJECTID,"+
                          "  OC_ORDER_DESCRIPTION, OC_ORDER_PRODUCTSTOCKUID, OC_ORDER_PACKAGESORDERED,"+
                          "  OC_ORDER_PACKAGESDELIVERED, OC_ORDER_DATEORDERED, OC_ORDER_DATEDELIVERYDUE,"+
                          "  OC_ORDER_DATEDELIVERED, OC_ORDER_IMPORTANCE,"+
                          "  OC_ORDER_CREATETIME, OC_ORDER_UPDATETIME, OC_ORDER_UPDATEUID, OC_ORDER_VERSION)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,1)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new uid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int orderCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRODUCTORDERS");
                ps.setInt(1,serverId);
                ps.setInt(2,orderCounter);
                this.setUid(serverId+"."+orderCounter);

                ps.setString(3,this.getDescription());
                ps.setString(4,this.getProductStockUid());
                ps.setInt(5,this.getPackagesOrdered());

                // if packagesDelivered not specified, do not save it
                if(this.packagesDelivered > -1) ps.setInt(6,this.packagesDelivered);
                else                            ps.setNull(6,Types.INTEGER);

                // date ordered
                if(this.dateOrdered!=null) ps.setTimestamp(7,new java.sql.Timestamp(this.dateOrdered.getTime()));
                else                       ps.setNull(7,Types.TIMESTAMP);

                // date delivery due
                if(this.dateDeliveryDue!=null) ps.setTimestamp(8,new java.sql.Timestamp(this.dateDeliveryDue.getTime()));
                else                           ps.setNull(8,Types.TIMESTAMP);

                // date delivered
                if(this.dateDelivered!=null) ps.setTimestamp(9,new java.sql.Timestamp(dateDelivered.getTime()));
                else                         ps.setNull(9,Types.TIMESTAMP);

                ps.setString(10,this.getImportance());

                // OBJECT variables
                ps.setTimestamp(11,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(12,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(13,this.getUpdateUser());

                ps.executeUpdate();
            }
            else{
                if(!orderWithSameDataExists){
                    //***** UPDATE *****
                    if(Debug.enabled) Debug.println("@@@ PRODUCTORDER update @@@");

                    sSelect = "UPDATE OC_PRODUCTORDERS SET "+
                              "  OC_ORDER_DESCRIPTION=?, OC_ORDER_PRODUCTSTOCKUID=?, OC_ORDER_PACKAGESORDERED=?,"+
                              "  OC_ORDER_PACKAGESDELIVERED=?, OC_ORDER_DATEORDERED=?, OC_ORDER_DATEDELIVERYDUE=?,"+
                              "  OC_ORDER_DATEDELIVERED=?, OC_ORDER_IMPORTANCE=?,"+
                              "  OC_ORDER_UPDATETIME=?, OC_ORDER_UPDATEUID=?, OC_ORDER_VERSION=(OC_ORDER_VERSION+1)"+
                              " WHERE OC_ORDER_SERVERID=? AND OC_ORDER_OBJECTID=?";

                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setString(1,this.getDescription());
                    ps.setString(2,this.getProductStockUid());
                    ps.setInt(3,this.getPackagesOrdered());

                    // if packagesDelivered not specified, do not save it
                    if(this.packagesDelivered > -1) ps.setInt(4,this.packagesDelivered);
                    else                            ps.setNull(4,Types.INTEGER);

                    // date ordered
                    if(this.dateOrdered!=null) ps.setTimestamp(5,new java.sql.Timestamp(this.dateOrdered.getTime()));
                    else                       ps.setNull(5,Types.TIMESTAMP);

                    // date delivery due
                    if(this.dateDeliveryDue!=null) ps.setTimestamp(6,new java.sql.Timestamp(this.dateDeliveryDue.getTime()));
                    else                           ps.setNull(6,Types.TIMESTAMP);

                    // date delivered
                    if(this.dateDelivered!=null) ps.setTimestamp(7,new java.sql.Timestamp(dateDelivered.getTime()));
                    else                         ps.setNull(7,Types.TIMESTAMP);

                    ps.setString(8,this.getImportance());

                    // OBJECT variables
                    ps.setTimestamp(9,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(10,this.getUpdateUser());

                    ps.setInt(11,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                    ps.setInt(12,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                    ps.executeUpdate();
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
        if(Debug.enabled) Debug.println("@@@ PRODUCTORDER exists ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_ORDER_SERVERID, OC_ORDER_OBJECTID FROM OC_PRODUCTORDERS"+
                             " WHERE OC_ORDER_DESCRIPTION=?"+
                             "  AND OC_ORDER_PRODUCTSTOCKUID=?"+
                             "  AND OC_ORDER_PACKAGESORDERED=?"+
                             "  AND OC_ORDER_PACKAGESDELIVERED=?"+
                             "  AND OC_ORDER_DATEORDERED=?"+
                             //"  AND OC_ORDER_DATEDELIVERYDUE=?"+
                             "  AND OC_ORDER_DATEDELIVERED=?";
                             //"  AND OC_ORDER_IMPORTANCE=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++,this.getDescription());
            ps.setString(questionmarkIdx++,this.getProductStockUid());

            // packagesOrdered
            if(this.packagesOrdered > -1) ps.setInt(questionmarkIdx++,this.packagesOrdered);
            else                          ps.setNull(questionmarkIdx++,Types.INTEGER);

            // packagesDelivered
            if(this.packagesDelivered > -1) ps.setInt(questionmarkIdx++,this.packagesDelivered);
            else                            ps.setNull(questionmarkIdx++,Types.INTEGER);

            // date ordered
            if(this.dateOrdered!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.dateOrdered.getTime()));
            else                       ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date delivery due
            //if(this.dateDeliveryDue!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.dateDeliveryDue.getTime()));
            //else                           ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date delivered
            if(this.dateDelivered!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(dateDelivered.getTime()));
            else                         ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            //ps.setString(questionmarkIdx++,this.getImportance());

            rs = ps.executeQuery();
            if(rs.next()){
                uid = rs.getInt("OC_ORDER_SERVERID")+"."+rs.getInt("OC_ORDER_OBJECTID");
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
        if(Debug.enabled) Debug.println("@@@ PRODUCTORDER changed ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_ORDER_SERVERID, OC_ORDER_OBJECTID FROM OC_PRODUCTORDERS"+
                             " WHERE OC_ORDER_DESCRIPTION=?"+
                             "  AND OC_ORDER_PRODUCTSTOCKUID=?"+
                             "  AND OC_ORDER_PACKAGESORDERED=?"+
                             "  AND OC_ORDER_PACKAGESDELIVERED=?"+
                             "  AND OC_ORDER_DATEORDERED=?"+
                             "  AND OC_ORDER_DATEDELIVERYDUE=?"+
                             "  AND OC_ORDER_DATEDELIVERED=?"+
                             "  AND OC_ORDER_IMPORTANCE=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;

            ps.setString(questionmarkIdx++,this.getDescription()); // required
            ps.setString(questionmarkIdx++,this.getProductStockUid()); // required

            // packagesOrdered
            if(this.packagesOrdered > -1) ps.setInt(questionmarkIdx++,this.packagesOrdered);
            else                          ps.setNull(questionmarkIdx++,Types.INTEGER);

            // packagesDelivered
            if(this.packagesDelivered > -1) ps.setInt(questionmarkIdx++,this.packagesDelivered);
            else                            ps.setNull(questionmarkIdx++,Types.INTEGER);

            // date ordered
            if(this.dateOrdered!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.dateOrdered.getTime()));
            else                       ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date delivery due
            if(this.dateDeliveryDue!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.dateDeliveryDue.getTime()));
            else                           ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date delivered
            if(this.dateDelivered!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(dateDelivered.getTime()));
            else                         ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // importance
            if(this.getImportance().length() > 0) ps.setString(questionmarkIdx++,this.getImportance());
            else                                  ps.setNull(questionmarkIdx++,Types.VARCHAR);

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
    public static void delete(String orderUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_PRODUCTORDERS"+
                             " WHERE OC_ORDER_SERVERID = ? AND OC_ORDER_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(orderUid.substring(0,orderUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(orderUid.substring(orderUid.indexOf(".")+1)));
            ps.executeUpdate();
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

    //--- FIND ------------------------------------------------------------------------------------
    public static Vector find(boolean searchDelivered, boolean searchUndelivered, String sFindDescription,
                              String sFindServiceUid, String sFindProductStockUid, String sFindPackagesOrdered,
                              String sFindDateDeliveryDue, String sFindDateOrdered, String sFindSupplierUid,
                              String sFindServiceStockUid, String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT OC_ORDER_SERVERID, OC_ORDER_OBJECTID"+
                             " FROM OC_PRODUCTORDERS po";

            if(sFindServiceUid.length()>0 || sFindServiceStockUid.length()>0 || sFindSupplierUid.length()>0){
                sSelect+= ", OC_PRODUCTSTOCKS ps ";
            }

            // delivered, delivered or both types of orders ?
            if(searchDelivered && searchUndelivered){
                sSelect+= "";
            }
            else if(searchDelivered){
                sSelect+= " WHERE OC_ORDER_DATEDELIVERED > ?";
            }
            else if(searchUndelivered){
                sSelect+= " WHERE OC_ORDER_DATEDELIVERED IS NULL ";
            }

            // match search criteria
            if(sFindDescription.length()>0 || sFindServiceUid.length()>0 || sFindProductStockUid.length()>0 ||
               sFindPackagesOrdered.length()>0 || sFindDateDeliveryDue.length()>0 || sFindDateOrdered.length()>0 ||
               sFindSupplierUid.length()>0){
                if(sSelect.indexOf("WHERE") > -1) sSelect+= " AND ";
                else                              sSelect+= " WHERE ";

                if(sFindDescription.length() > 0){
                    String sLowerOrderDescr = MedwanQuery.getInstance().getConfigParam("lowerCompare","po.OC_ORDER_DESCRIPTION");
                    sSelect+= sLowerOrderDescr+" LIKE ? AND ";
                }

                if(sFindSupplierUid.length() > 0){
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindSupplierUid);
                    childIds.add(sFindSupplierUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
                    if(sChildIds.length() > 0){
                        sSelect+= "ps.OC_STOCK_SUPPLIERUID IN ("+sChildIds+") AND ";
                    }
                    else{
                        sSelect+= "ps.OC_STOCK_SUPPLIERUID = '' AND ";
                    }
                }

                if(sFindServiceStockUid.length() > 0){
                    sSelect+= "ps.OC_STOCK_SERVICESTOCKUID = ? AND ";
                }
                else if(sFindServiceUid.length() > 0){
                    Vector serviceStocks = Service.getServiceStocks(sFindServiceUid);
                    String sServiceStockUids = "";
                    for(int i=0; i<serviceStocks.size(); i++){
                        sServiceStockUids+= "'"+((ServiceStock)serviceStocks.get(i)).getUid()+"',";
                    }

                    // remove last comma if one
                    if(sServiceStockUids.indexOf(",") > -1){
                        sServiceStockUids = sServiceStockUids.substring(0,sServiceStockUids.lastIndexOf(","));
                    }

                    // get productstocks with one or more productorders
                    if(sServiceStockUids.length() > 0){
                        sSelect+= "ps.OC_STOCK_SERVICESTOCKUID IN ("+sServiceStockUids+") AND ";
                    }
                }

                // bind 2 tables
                if(sFindServiceUid.length()>0 || sFindServiceStockUid.length()>0 || sFindSupplierUid.length()>0){
                    // remove last AND if any
                    if(sSelect.indexOf("AND ")>0){
                        sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                    }

                    String[] params1 = {"varchar(16)","ps.OC_STOCK_SERVERID"};
                    String convertServerId = ScreenHelper.getConfigParam("convert",params1);
                    String[] params2 = {"varchar(16)","ps.OC_STOCK_OBJECTID"};
                    String convertObjectId = ScreenHelper.getConfigParam("convert",params2);

                    sSelect+= " AND po.OC_ORDER_PRODUCTSTOCKUID = ("+convertServerId+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+convertObjectId+") AND ";
                }

                if(sFindProductStockUid.length() > 0) sSelect+= "po.OC_ORDER_PRODUCTSTOCKUID = ? AND ";
                if(sFindPackagesOrdered.length() > 0) sSelect+= "po.OC_ORDER_PACKAGESORDERED = ? AND ";
                if(sFindDateOrdered.length() > 0)     sSelect+= "po.OC_ORDER_DATEORDERED >= ? AND ";
                if(sFindDateDeliveryDue.length() > 0) sSelect+= "po.OC_ORDER_DATEDELIVERYDUE >= ? AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            // order by selected col or default col
            sSelect+= "ORDER BY po."+sSortCol+" "+sSortDir;
            System.out.println(sSelect);
            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(searchDelivered)                   ps.setDate(questionMarkIdx++,new java.sql.Date(new java.util.Date().getTime()));
            if(sFindDescription.length() > 0)     ps.setString(questionMarkIdx++,sFindDescription.toLowerCase()+"%");
            if(sFindServiceStockUid.length() > 0) ps.setString(questionMarkIdx++,sFindServiceStockUid);
            if(sFindProductStockUid.length() > 0) ps.setString(questionMarkIdx++,sFindProductStockUid);
            if(sFindPackagesOrdered.length() > 0) ps.setString(questionMarkIdx++,sFindPackagesOrdered);
            if(sFindDateOrdered.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateOrdered));
            if(sFindDateDeliveryDue.length() > 0) ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateDeliveryDue));

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_ORDER_SERVERID")+"."+rs.getString("OC_ORDER_OBJECTID")));
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

	//--- FIND ------------------------------------------------------------------------------------
	public static Vector find(boolean searchDelivered, boolean searchUndelivered, String sFindDescription,
	                          String sFindServiceUid, String sFindProductStockUid, String sFindPackagesOrdered,
	                          String sFindDateDeliveryDue, String sFindDateOrdered, String sFindSupplierUid,
	                          String sFindServiceStockUid, String sSortCol, String sSortDir,String sFindDateDeliveredSince){
	    Vector foundObjects = new Vector();
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	
	    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	    try{
	        // compose query
	        String sSelect = "SELECT OC_ORDER_SERVERID, OC_ORDER_OBJECTID"+
	                         " FROM OC_PRODUCTORDERS po";
	
	        if(sFindServiceUid.length()>0 || sFindServiceStockUid.length()>0 || sFindSupplierUid.length()>0){
	            sSelect+= ", OC_PRODUCTSTOCKS ps ";
	        }
	
	        // delivered, delivered or both types of orders ?
	        if(searchDelivered && searchUndelivered){
	            sSelect+= "";
	        }
	        else if(searchDelivered){
	            sSelect+= " WHERE OC_ORDER_DATEDELIVERED > ?";
	        }
	        else if(searchUndelivered){
	            sSelect+= " WHERE OC_ORDER_DATEDELIVERED IS NULL ";
	        }
	
	        // match search criteria
	        if(sFindDescription.length()>0 || sFindServiceUid.length()>0 || sFindProductStockUid.length()>0 ||
	           sFindPackagesOrdered.length()>0 || sFindDateDeliveryDue.length()>0 || sFindDateOrdered.length()>0 ||
	           sFindSupplierUid.length()>0){
	            if(sSelect.indexOf("WHERE") > -1) sSelect+= " AND ";
	            else                              sSelect+= " WHERE ";
	
	            if(sFindDescription.length() > 0){
	                String sLowerOrderDescr = MedwanQuery.getInstance().getConfigParam("lowerCompare","po.OC_ORDER_DESCRIPTION");
	                sSelect+= sLowerOrderDescr+" LIKE ? AND ";
	            }
	
	            if(sFindSupplierUid.length() > 0){
	                // search all service and its child-services
	                Vector childIds = Service.getChildIds(sFindSupplierUid);
	                childIds.add(sFindSupplierUid);
	                String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
	                if(sChildIds.length() > 0){
	                    sSelect+= "ps.OC_STOCK_SUPPLIERUID IN ("+sChildIds+") AND ";
	                }
	                else{
	                    sSelect+= "ps.OC_STOCK_SUPPLIERUID = '' AND ";
	                }
	            }
	
	            if(sFindServiceStockUid.length() > 0){
	                sSelect+= "ps.OC_STOCK_SERVICESTOCKUID = ? AND ";
	            }
	            else if(sFindServiceUid.length() > 0){
	                Vector serviceStocks = Service.getServiceStocks(sFindServiceUid);
	                String sServiceStockUids = "";
	                for(int i=0; i<serviceStocks.size(); i++){
	                    sServiceStockUids+= "'"+((ServiceStock)serviceStocks.get(i)).getUid()+"',";
	                }
	
	                // remove last comma if one
	                if(sServiceStockUids.indexOf(",") > -1){
	                    sServiceStockUids = sServiceStockUids.substring(0,sServiceStockUids.lastIndexOf(","));
	                }
	
	                // get productstocks with one or more productorders
	                if(sServiceStockUids.length() > 0){
	                    sSelect+= "ps.OC_STOCK_SERVICESTOCKUID IN ("+sServiceStockUids+") AND ";
	                }
	            }
	
	            // bind 2 tables
	            if(sFindServiceUid.length()>0 || sFindServiceStockUid.length()>0 || sFindSupplierUid.length()>0){
	                // remove last AND if any
	                if(sSelect.indexOf("AND ")>0){
	                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
	                }
	
	                String[] params1 = {"varchar(16)","ps.OC_STOCK_SERVERID"};
	                String convertServerId = ScreenHelper.getConfigParam("convert",params1);
	                String[] params2 = {"varchar(16)","ps.OC_STOCK_OBJECTID"};
	                String convertObjectId = ScreenHelper.getConfigParam("convert",params2);
	
	                sSelect+= " AND po.OC_ORDER_PRODUCTSTOCKUID = ("+convertServerId+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+convertObjectId+") AND ";
	            }
	
	            if(sFindProductStockUid.length() > 0) sSelect+= "po.OC_ORDER_PRODUCTSTOCKUID = ? AND ";
	            if(sFindPackagesOrdered.length() > 0) sSelect+= "po.OC_ORDER_PACKAGESORDERED = ? AND ";
	            if(sFindDateOrdered.length() > 0)     sSelect+= "po.OC_ORDER_DATEORDERED >= ? AND ";
	            if(sFindDateDeliveryDue.length() > 0) sSelect+= "po.OC_ORDER_DATEDELIVERYDUE >= ? AND ";
	
	            // remove last AND if any
	            if(sSelect.indexOf("AND ")>0){
	                sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
	            }
	        }
	
	        // order by selected col or default col
	        sSelect+= "ORDER BY po."+sSortCol+" "+sSortDir;
	        System.out.println(sSelect);
	        ps = oc_conn.prepareStatement(sSelect);
	
	        // set questionmark values
	        int questionMarkIdx = 1;
	        if(searchDelivered){
	        	java.util.Date referencedate=null;
	        	if(sFindDateDeliveredSince!=null && sFindDateDeliveredSince.length()>0){
	        		try{
	        			referencedate=new SimpleDateFormat("dd/MM/yyyy").parse(sFindDateDeliveredSince);
	        		}
	        		catch(Exception e){};
	        	}
	        	if(referencedate==null){
	        		referencedate= new java.util.Date(new java.util.Date().getTime()-7*24*3600*1000);
	        	}
	        	ps.setDate(questionMarkIdx++,new java.sql.Date(referencedate.getTime()));
	        }
	        if(sFindDescription.length() > 0)     ps.setString(questionMarkIdx++,sFindDescription.toLowerCase()+"%");
	        if(sFindServiceStockUid.length() > 0) ps.setString(questionMarkIdx++,sFindServiceStockUid);
	        if(sFindProductStockUid.length() > 0) ps.setString(questionMarkIdx++,sFindProductStockUid);
	        if(sFindPackagesOrdered.length() > 0) ps.setString(questionMarkIdx++,sFindPackagesOrdered);
	        if(sFindDateOrdered.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateOrdered));
	        if(sFindDateDeliveryDue.length() > 0) ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateDeliveryDue));
	
	        // execute
	        rs = ps.executeQuery();
	
	        while(rs.next()){
	            foundObjects.add(get(rs.getString("OC_ORDER_SERVERID")+"."+rs.getString("OC_ORDER_OBJECTID")));
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

}
