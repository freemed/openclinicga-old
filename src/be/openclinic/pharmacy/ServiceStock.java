package be.openclinic.pharmacy;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import net.admin.AdminPerson;
import net.admin.Service;

import java.sql.*;
import java.util.*;
import java.util.Date;

public class ServiceStock extends OC_Object {
    private String name;
    private Service service;
    private Date begin;
    private Date end;
    private AdminPerson stockManager;
    private Vector authorizedUsers;
    private String authorizedUserIds;
    private Service defaultSupplier;
    private int orderPeriodInMonths = -1;
    private int nosync=1;
    
    // non-db data
    private String serviceUid;
    private String stockManagerUid;
    private String defaultSupplierUid;
    
	
	//--- CONSTRUCTOR -----------------------------------------------------------------------------
    public ServiceStock() {
        this.authorizedUsers = new Vector();
    }
    
    //--- NO SYNC ---------------------------------------------------------------------------------
    public int getNosync() {
		return nosync;
	}
	public void setNosync(int nosync) {
		this.nosync = nosync;
	}
	
    //--- NAME ------------------------------------------------------------------------------------
    public String getName() {
        return this.name;
    }
    public void setName(String name) {
        this.name = name;
    }
    
    //--- SERVICE ---------------------------------------------------------------------------------
    public Service getService() {
        if (serviceUid != null && serviceUid.length() > 0) {
            if (service == null) {
                this.setService(Service.getService(serviceUid));
            }
        }
        return this.service;
    }
    public void setService(Service service) {
        this.service = service;
    }
    
    //--- BEGIN -----------------------------------------------------------------------------------
    public Date getBegin() {
        return this.begin;
    }
    public void setBegin(Date begin) {
        this.begin = begin;
    }
    
    //--- END -------------------------------------------------------------------------------------
    public Date getEnd() {
        return this.end;
    }
    public void setEnd(Date end) {
        this.end = end;
    }
    
    //--- STOCK MANAGER ---------------------------------------------------------------------------
    public AdminPerson getStockManager() {
        if (stockManagerUid != null && stockManagerUid.length() > 0) {
            if (stockManager == null) {
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setStockManager(AdminPerson.getAdminPerson(ad_conn, MedwanQuery.getInstance().getPersonIdFromUserId(Integer.parseInt(stockManagerUid)) + ""));
                try {
					ad_conn.close();
				} 
                catch (SQLException e) {
					e.printStackTrace();
				}
            }
        }
        return this.stockManager;
    }
    public void setStockManager(AdminPerson stockManager) {
        this.stockManager = stockManager;
    }
    
    //--- AUTHORISED USERS ------------------------------------------------------------------------
    public Vector getAuthorizedUsers() {
        AdminPerson user;
        if (authorizedUserIds != null && authorizedUserIds.length() > 0) {
            StringTokenizer idTokenizer = new StringTokenizer(authorizedUserIds, "$");
            String authorizedUserId;
            while (idTokenizer.hasMoreTokens()) {
                authorizedUserId = idTokenizer.nextToken();
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                user = AdminPerson.getAdminPerson(ad_conn, authorizedUserId);
                try {
					ad_conn.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
                this.authorizedUsers.add(user);
            }
        }
        return this.authorizedUsers;
    }
    
    public void setAuthorizedUsers(Vector authorizedUsers) {
        this.authorizedUsers = authorizedUsers;
    }
    public void addAuthorizedUser(AdminPerson user) {
        this.authorizedUsers.addElement(user);
    }
    public void removeAuthorizedUser(AdminPerson user) {
        this.authorizedUsers.removeElement(user);
    }
    public void setAuthorizedUserIds(String ids) {
        this.authorizedUserIds = ids;
    }
    public String getAuthorizedUserIds() {
        return this.authorizedUserIds;
    }
    
    public boolean isAuthorizedUser(String userid) {
        if (userid.equalsIgnoreCase(this.getStockManagerUid())) return true;
        if (authorizedUserIds != null && authorizedUserIds.length() > 0) {
            StringTokenizer tokenizer = new StringTokenizer(authorizedUserIds, "$");
            while (tokenizer.hasMoreTokens()) {
                if (userid.equalsIgnoreCase(tokenizer.nextToken())) {
                    return true;
                }
            }
        }
        return false;
    }
    
    public boolean isAuthorizedUserNotManager(String userid) {
        if (authorizedUserIds != null && authorizedUserIds.length() > 0) {
            StringTokenizer tokenizer = new StringTokenizer(authorizedUserIds, "$");
            while (tokenizer.hasMoreTokens()) {
                if (userid.equalsIgnoreCase(tokenizer.nextToken())) {
                    return true;
                }
            }
        }
        return false;
    }
    
    //--- DEFAULT SUPPLIER ------------------------------------------------------------------------
    public Service getDefaultSupplier() {
        if (defaultSupplierUid != null && defaultSupplierUid.length() > 0) {
            if (defaultSupplier == null) {
                this.setDefaultSupplier(Service.getService(defaultSupplierUid));
            }
        }
        return this.defaultSupplier;
    }
    public void setDefaultSupplier(Service supplier) {
        this.defaultSupplier = supplier;
    }
    
    //--- ORDER PERIOD IN MONTHS ------------------------------------------------------------------
    public int getOrderPeriodInMonths() {
        return this.orderPeriodInMonths;
    }
    public void setOrderPeriodInMonths(int orderPeriodInMonths) {
        this.orderPeriodInMonths = orderPeriodInMonths;
    }
    
    //--- NON-DB DATA : SERVICE UID ---------------------------------------------------------------
    public String getServiceUid() {
        return this.serviceUid;
    }
    public void setServiceUid(String uid) {
        this.serviceUid = uid;
    }
    
    //--- NON-DB DATA : STOCK MANAGER UID ---------------------------------------------------------
    public void setStockManagerUid(String uid) {
        this.stockManagerUid = uid;
    }
    public String getStockManagerUid() {
        return this.stockManagerUid;
    }
    
    //--- NON-DB DATA : DEFAULT SUPPLIER UID ------------------------------------------------------
    public void setDefaultSupplierUid(String uid) {
        this.defaultSupplierUid = uid;
    }
    public String getDefaultSupplierUid() {
        return this.defaultSupplierUid;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static ServiceStock get(String stockUid) {
        ServiceStock stock = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        if (stockUid.indexOf(".") == -1) return null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_SERVICESTOCKS" +
                             " WHERE OC_STOCK_SERVERID = ? AND OC_STOCK_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(stockUid.substring(0, stockUid.indexOf("."))));
            ps.setInt(2, Integer.parseInt(stockUid.substring(stockUid.indexOf(".") + 1)));
            rs = ps.executeQuery();

            // get data from DB
            if (rs.next()) {
                stock = new ServiceStock();
                stock.setUid(stockUid);
                stock.setName(rs.getString("OC_STOCK_NAME"));
                stock.setServiceUid(rs.getString("OC_STOCK_SERVICEUID"));
                stock.setStockManagerUid(rs.getString("OC_STOCK_STOCKMANAGERUID"));
                stock.setAuthorizedUserIds(rs.getString("OC_STOCK_AUTHORIZEDUSERS"));
                stock.setDefaultSupplierUid(rs.getString("OC_STOCK_DEFAULTSUPPLIERUID"));

                // orderPeriodInMonths
                String tmpValue = rs.getString("OC_STOCK_ORDERPERIODINMONTHS");
                if (tmpValue != null) {
                    stock.setOrderPeriodInMonths(Integer.parseInt(tmpValue));
                }
                stock.setNosync(rs.getInt("OC_STOCK_NOSYNC"));

                // dates
                stock.setBegin(rs.getDate("OC_STOCK_BEGIN"));
                stock.setEnd(rs.getDate("OC_STOCK_END"));

                // OBJECT variables
                stock.setCreateDateTime(rs.getTimestamp("OC_STOCK_CREATETIME"));
                stock.setUpdateDateTime(rs.getTimestamp("OC_STOCK_UPDATETIME"));
                stock.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_STOCK_UPDATEUID")));
                stock.setVersion(rs.getInt("OC_STOCK_VERSION"));
            } 
            else {
                throw new Exception("ERROR : SERVICESTOCK " + stockUid + " NOT FOUND");
            }
        }
        catch (Exception e) {
            if (e.getMessage().endsWith("NOT FOUND")) {
                Debug.println(e.getMessage());
            }
            else {
                e.printStackTrace();
            }
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return stock;
    }
    
    //--- OPEN DELIVERIES -------------------------------------------------------------------------
    public boolean hasOpenDeliveries(){
    	return ProductStockOperation.getOpenServiceStockDeliveries(this.getUid()).size()>0;
    }
    
    public Vector getOpenDeliveries(){
   	    return ProductStockOperation.getOpenServiceStockDeliveries(this.getUid());
    }
   
    //--- STORE -----------------------------------------------------------------------------------
    public void store() {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (this.getUid().equals("-1")) {
                // insert new version of stock into current stocks
                Debug.println("@@@ SERVICESTOCK insert @@@");
                
                sSelect = "INSERT INTO OC_SERVICESTOCKS (OC_STOCK_SERVERID, OC_STOCK_OBJECTID," +
                          "  OC_STOCK_NAME, OC_STOCK_SERVICEUID, OC_STOCK_BEGIN, OC_STOCK_END," +
                          "  OC_STOCK_STOCKMANAGERUID, OC_STOCK_AUTHORIZEDUSERS, OC_STOCK_DEFAULTSUPPLIERUID," +
                          "  OC_STOCK_ORDERPERIODINMONTHS, OC_STOCK_CREATETIME, OC_STOCK_UPDATETIME,"+
                          "  OC_STOCK_UPDATEUID, OC_STOCK_VERSION, OC_STOCK_NOSYNC)" +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,1,?)";
                ps = oc_conn.prepareStatement(sSelect);

                // set new servicestockuid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int serviceStockCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_SERVICESTOCKS");
                ps.setInt(1, serverId);
                ps.setInt(2, serviceStockCounter);
                this.setUid(serverId + "." + serviceStockCounter);
                ps.setString(3, this.getName());
                ps.setString(4, this.getServiceUid());

                // date begin
                if (this.begin != null) ps.setTimestamp(5, new java.sql.Timestamp(this.begin.getTime()));
                else                    ps.setNull(5, Types.TIMESTAMP);

                // date end
                if (this.end != null) ps.setTimestamp(6, new java.sql.Timestamp(this.end.getTime()));
                else                  ps.setNull(6, Types.TIMESTAMP);

                // stockManagerUid
                if (this.getStockManagerUid().length() > 0) ps.setString(7, this.getStockManagerUid());
                else                                        ps.setNull(7, Types.VARCHAR);

                // authorized users
                AdminPerson user;
                StringBuffer authorizedUserIds = new StringBuffer();
                for (int i = 0; i < this.getAuthorizedUsers().size(); i++) {
                    user = (AdminPerson) this.getAuthorizedUsers().elementAt(i);
                    authorizedUserIds.append(user.getActivePerson().personid + "$");
                }
                
                if (authorizedUserIds.length() > 0) ps.setString(8, authorizedUserIds.toString());
                else                                ps.setNull(8, Types.VARCHAR);

                // default supplier
                if (this.getDefaultSupplierUid().length() > 0) ps.setString(9, this.getDefaultSupplierUid());
                else                                           ps.setNull(9, Types.VARCHAR);

                // orderPeriodInMonths
                if (this.getOrderPeriodInMonths() > -1) ps.setInt(10, this.getOrderPeriodInMonths());
                else                                    ps.setNull(10, Types.INTEGER);

                // OBJECT variables
                ps.setTimestamp(11, new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(12, new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(13, this.getUpdateUser());
                ps.setInt(14, this.getNosync());
                ps.executeUpdate();
            }
            else {
                //***** UPDATE *****
                Debug.println("@@@ SERVICESTOCK update @@@");
                
                sSelect = "UPDATE OC_SERVICESTOCKS SET OC_STOCK_NAME=?, OC_STOCK_SERVICEUID=?," +
                        "  OC_STOCK_BEGIN=?, OC_STOCK_END=?, OC_STOCK_STOCKMANAGERUID=?," +
                        "  OC_STOCK_AUTHORIZEDUSERS=?, OC_STOCK_DEFAULTSUPPLIERUID=?, OC_STOCK_ORDERPERIODINMONTHS=?," +
                        "  OC_STOCK_UPDATETIME=?, OC_STOCK_UPDATEUID=?, OC_STOCK_VERSION=(OC_STOCK_VERSION+1), OC_STOCK_NOSYNC=?" +
                        " WHERE OC_STOCK_SERVERID=? AND OC_STOCK_OBJECTID=?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1, this.getName());
                ps.setString(2, this.getServiceUid());

                // date begin
                if (this.begin != null) ps.setTimestamp(3, new java.sql.Timestamp(this.begin.getTime()));
                else                    ps.setNull(3, Types.TIMESTAMP);

                // date end
                if (this.end != null) ps.setTimestamp(4, new java.sql.Timestamp(end.getTime()));
                else                  ps.setNull(4, Types.TIMESTAMP);

                // stockManagerUid
                if (this.getStockManagerUid().length() > 0) ps.setString(5, this.getStockManagerUid());
                else                                        ps.setNull(5, Types.VARCHAR);

                // authorized users
                AdminPerson user;
                StringBuffer authorizedUserIds = new StringBuffer();
                for (int i = 0; i < this.getAuthorizedUsers().size(); i++) {
                    user = (AdminPerson) this.getAuthorizedUsers().elementAt(i);
                    authorizedUserIds.append(user.getActivePerson().personid + "$");
                }
                if (authorizedUserIds.length() > 0) ps.setString(6, authorizedUserIds.toString());
                else                                ps.setNull(6, Types.VARCHAR);

                // default supplier
                if (this.getDefaultSupplierUid().length() > 0) ps.setString(7, this.getDefaultSupplierUid());
                else                                           ps.setNull(7, Types.VARCHAR);

                // orderPeriodInMonths
                if (this.getOrderPeriodInMonths() > -1) ps.setInt(8, this.getOrderPeriodInMonths());
                else                                    ps.setNull(8, Types.INTEGER);

                // OBJECT variables
                ps.setTimestamp(9, new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(10, this.getUpdateUser());
                ps.setInt(11, this.getNosync());
                
                // where
                ps.setInt(12, Integer.parseInt(this.getUid().substring(0, this.getUid().indexOf("."))));
                ps.setInt(13, Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".") + 1)));
                ps.executeUpdate();
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    
    //--- EXISTS ----------------------------------------------------------------------------------
    // checks the database for a record with the same UNIQUE KEYS as 'this'.
    public String exists() {
        Debug.println("@@@ SERVICESTOCK exists ? @@@");
        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            //***** check existence *****
            String sSelect = "SELECT OC_STOCK_SERVERID, OC_STOCK_OBJECTID FROM OC_SERVICESTOCKS" +
                    " WHERE OC_STOCK_NAME=?" +
                    "  AND OC_STOCK_SERVICEUID=?" +
                    "  AND OC_STOCK_END=?";
            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++, this.getName());
            ps.setString(questionmarkIdx++, this.getServiceUid());

            // date end
            if (this.end != null) ps.setTimestamp(questionmarkIdx++, new java.sql.Timestamp(end.getTime()));
            else ps.setNull(questionmarkIdx++, Types.TIMESTAMP);

            rs = ps.executeQuery();
            if (rs.next()) {
                uid = rs.getInt("OC_STOCK_SERVERID") + "." + rs.getInt("OC_STOCK_OBJECTID");
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return uid;
    }
    
    //--- CHANGED ---------------------------------------------------------------------------------
    // checks the database for a record with the same DATA as 'this'.
    public boolean changed() {
        Debug.println("@@@ SERVICESTOCK changed ? @@@");
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            //***** check existence *****
            String sSelect = "SELECT OC_STOCK_SERVERID, OC_STOCK_OBJECTID FROM OC_SERVICESTOCKS" +
                    " WHERE OC_STOCK_NAME=?" +
                    "  AND OC_STOCK_SERVICEUID=?" +
                    "  AND OC_STOCK_BEGIN=?" +
                    "  AND OC_STOCK_END=?" +
                    "  AND OC_STOCK_STOCKMANAGERUID=?" +
                    "  AND OC_STOCK_AUTHORIZEDUSERS=?" +
                    "  AND OC_STOCK_DEFAULTSUPPLIERUID=?" +
                    "  AND OC_STOCK_ORDERPERIODINMONTHS=?" +
                    "  AND OC_STOCK_NOSYNC=?";
            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++, this.getName()); // required
            ps.setString(questionmarkIdx++, this.getServiceUid()); // required

            // date begin
            if (this.begin != null) ps.setTimestamp(questionmarkIdx++, new java.sql.Timestamp(this.begin.getTime()));
            else ps.setNull(questionmarkIdx++, Types.TIMESTAMP);

            // date end
            if (this.end != null) ps.setTimestamp(questionmarkIdx++, new java.sql.Timestamp(end.getTime()));
            else ps.setNull(questionmarkIdx++, Types.TIMESTAMP);

            // stockManagerUid
            if (this.getStockManagerUid().length() > 0) ps.setString(questionmarkIdx++, this.getStockManagerUid());
            else ps.setNull(questionmarkIdx++, Types.VARCHAR);

            // authorized users
            AdminPerson user;
            StringBuffer authorizedUserIds = new StringBuffer();
            for (int i = 0; i < this.getAuthorizedUsers().size(); i++) {
                user = (AdminPerson) this.getAuthorizedUsers().elementAt(i);
                authorizedUserIds.append(user.getActivePerson().personid + "$");
            }
            if (authorizedUserIds.length() > 0) ps.setString(questionmarkIdx++, authorizedUserIds.toString());
            else ps.setNull(questionmarkIdx++, Types.VARCHAR);

            // default supplier
            if (this.getDefaultSupplierUid().length() > 0)
                ps.setString(questionmarkIdx++, this.getDefaultSupplierUid());
            else ps.setNull(questionmarkIdx++, Types.VARCHAR);

            // orderPeriodInMonths
            if (this.getOrderPeriodInMonths() > -1) ps.setInt(questionmarkIdx++, this.getOrderPeriodInMonths());
            else ps.setNull(questionmarkIdx++, Types.INTEGER);
            
            // NoSync
            if (this.getNosync() > -1) ps.setInt(questionmarkIdx++, this.getNosync());
            else ps.setNull(questionmarkIdx++, Types.INTEGER);
            
            rs = ps.executeQuery();
            if (rs.next()) changed = false;
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return changed;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String serviceStockUid) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "DELETE FROM OC_SERVICESTOCKS" +
                    " WHERE OC_STOCK_SERVERID = ? AND OC_STOCK_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(serviceStockUid.substring(0, serviceStockUid.indexOf("."))));
            ps.setInt(2, Integer.parseInt(serviceStockUid.substring(serviceStockUid.indexOf(".") + 1)));
            ps.executeUpdate();
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    
    //--- DELETE PRODUCTSTOCKS --------------------------------------------------------------------
    public static void deleteProductStocks(String serviceStockUid) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "DELETE FROM OC_PRODUCTSTOCKS" +
                             " WHERE OC_STOCK_SERVICESTOCKUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, serviceStockUid);
            ps.executeUpdate();
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    
    //--- GET PRODUCT STOCK IDS -------------------------------------------------------------------
    public Vector getProductStockIds() {
        Vector ids = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT OC_STOCK_SERVERID, OC_STOCK_OBJECTID FROM OC_PRODUCTSTOCKS"+
                             " WHERE (OC_STOCK_END < ? OR OC_STOCK_END IS NULL)"+
                             "  AND OC_STOCK_SERVICESTOCKUID = ?";
            ps = oc_conn.prepareStatement(sSelect);

            // set stock-end-date with hour and minutes = 0
            Calendar today = new GregorianCalendar();
            today.setTime(new java.util.Date());
            today.set(today.get(Calendar.YEAR), today.get(Calendar.MONTH), today.get(Calendar.DATE), 0, 0, 0);
            ps.setTimestamp(1, new Timestamp(today.getTimeInMillis()));
            ps.setString(2, this.getUid());

            // execute
            rs = ps.executeQuery();

            // run thru found productStocks
            while (rs.next()) {
                ids.add(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID"));
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return ids;
    }
    
    //--- GET PRODUCTSTOCKS -----------------------------------------------------------------------
    public Vector getProductStocks() throws SQLException {
        Vector stockIds = getProductStockIds();
        Vector stocks = new Vector();
        SortedMap map = new TreeMap();
        ProductStock productStock;
        for (int i = 0; i < stockIds.size(); i++) {
            productStock = ProductStock.get((String) stockIds.get(i));
            if(productStock!=null && productStock.getProduct()!=null){
	            map.put(productStock.getProduct().getName().toUpperCase()+"."+productStock.getUid(), productStock);
            }
        }
        Iterator i = map.keySet().iterator();
        String sKey;
        while(i.hasNext()){
            sKey=(String)i.next();
        	stocks.add(map.get(sKey));
        }
        
        return stocks;
    }

    //--- GET PRODUCTSTOCK ------------------------------------------------------------------------
    public ProductStock getProductStock(String productUid) {
        Vector stockIds = getProductStockIds();
        for (int i = 0; i < stockIds.size(); i++) {
            ProductStock productStock = ProductStock.get((String) stockIds.get(i));
            if (productUid.equalsIgnoreCase(productStock.getProductUid())) {
                return ProductStock.get((String) stockIds.get(i));
            }
        }
        return null;
    }
    
    //--- GET PRODUCTSTOCKS IN SERVICE STOCK ------------------------------------------------------
    public static Vector getProductStocks(String sServiceStockUid) {
        Vector productStocks = new Vector();
        ProductStock productStock;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT OC_STOCK_SERVERID, OC_STOCK_OBJECTID" +
                             " FROM OC_PRODUCTSTOCKS" +
                             "  WHERE OC_STOCK_SERVICESTOCKUID = ?" +
                             " ORDER BY OC_STOCK_LEVEL ASC";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sServiceStockUid);
            rs = ps.executeQuery();

            // add productStocks to vector
            while (rs.next()) {
                productStock = ProductStock.get(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID"));
                productStocks.add(productStock);
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return productStocks;
    }
    
    //--- GET PRODUCTSTOCK COUNT ------------------------------------------------------------------
    // Count number of productStocks belonging to the specified ServiceStock
    public static int getProductStockCount(String serviceStockUid) {
        int productStockCount = 0;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT COUNT(*) AS pstockcount FROM OC_PRODUCTSTOCKS a,OC_PRODUCTS b" +
                             " WHERE OC_PRODUCT_OBJECTID=replace(OC_STOCK_PRODUCTUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_STOCK_SERVICESTOCKUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, serviceStockUid);
            rs = ps.executeQuery();

            // get data from DB
            if (rs.next()) {
                productStockCount = rs.getInt("pstockcount");
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return productStockCount;
    }
    
    //--- FIND (1) --------------------------------------------------------------------------------
    public static Vector find(String sFindStockName, String sFindServiceUid, String sFindBegin, String sFindEnd,
                              String sFindManagerUid, String sFindDefaultSupplierUid, String sSortCol, String sSortDir) {
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT OC_STOCK_SERVERID,OC_STOCK_OBJECTID" +
                    " FROM OC_SERVICESTOCKS";
            if (sFindStockName.length() > 0 || sFindServiceUid.length() > 0 || sFindBegin.length() > 0 ||
                    sFindEnd.length() > 0 || sFindManagerUid.length() > 0 || sFindDefaultSupplierUid.length() > 0) {
                sSelect += " WHERE ";
                if (sFindServiceUid.length() > 0) {
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindServiceUid);
                    childIds.add(sFindServiceUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds, ",", "'");
                    if (sChildIds.length() > 0) {
                        sSelect += "OC_STOCK_SERVICEUID IN (" + sChildIds + ") AND ";
                    } else {
                        sSelect += "OC_STOCK_SERVICEUID IN ('') AND ";
                    }
                }
                if (sFindStockName.length() > 0) {
                    String sLowerStockName = MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_STOCK_NAME");
                    sSelect += sLowerStockName + " LIKE ? AND ";
                }
                if (sFindBegin.length() > 0) sSelect += "OC_STOCK_BEGIN = ? AND ";
                if (sFindEnd.length() > 0) sSelect += "OC_STOCK_END = ? AND ";
                if (sFindManagerUid.length() > 0) sSelect += "OC_STOCK_STOCKMANAGERUID = ? AND ";
                if (sFindDefaultSupplierUid.length() > 0) {
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindDefaultSupplierUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds, ",", "'");
                    if (sChildIds.length() > 0) {
                        sSelect += "OC_STOCK_DEFAULTSUPPLIERUID IN (" + sChildIds + ") AND ";
                    } else {
                        sSelect += "OC_STOCK_DEFAULTSUPPLIERUID IN ('') AND ";
                    }
                }

                // remove last AND if any
                if (sSelect.indexOf("AND ") > 0) {
                    sSelect = sSelect.substring(0, sSelect.lastIndexOf("AND "));
                }
            }

            // order
            sSelect += " ORDER BY " + sSortCol + " " + sSortDir;
            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if (sFindStockName.length() > 0) ps.setString(questionMarkIdx++, sFindStockName.toLowerCase() + "%");
            if (sFindBegin.length() > 0) ps.setDate(questionMarkIdx++, ScreenHelper.getSQLDate(sFindBegin));
            if (sFindEnd.length() > 0) ps.setDate(questionMarkIdx++, ScreenHelper.getSQLDate(sFindEnd));
            if (sFindManagerUid.length() > 0) ps.setString(questionMarkIdx++, sFindManagerUid);

            // execute
            rs = ps.executeQuery();
            while (rs.next()) {
                foundObjects.add(get(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID")));
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return foundObjects;
    }
    
    //--- FIND (2:serviceid) ----------------------------------------------------------------------
    public static Vector find(String sFindServiceUid) {
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT OC_STOCK_SERVERID,OC_STOCK_OBJECTID" +
                    " FROM OC_SERVICESTOCKS where OC_STOCK_SERVICEUID=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sFindServiceUid);
            // execute
            rs = ps.executeQuery();
            while (rs.next()) {
                foundObjects.add(get(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID")));
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return foundObjects;
    }
    
    //--- GET STOCKS BY USER ----------------------------------------------------------------------
    public static Vector getStocksByUser(String sUserId) {
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_SERVICESTOCKS b where exists (select * from OC_PRODUCTSTOCKS a where a.OC_STOCK_SERVICESTOCKUID="+MedwanQuery.getInstance().convert("varchar", "b.OC_STOCK_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "b.OC_STOCK_OBJECTID")+") order by OC_STOCK_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            // execute
            rs = ps.executeQuery();
            ServiceStock stock = null;
            while (rs.next()) {
                /*if (rs.getString("OC_STOCK_STOCKMANAGERUID") != null && rs.getString("OC_STOCK_STOCKMANAGERUID").equals(sUserId)) {
                    stock = new ServiceStock();
                    stock.setUid(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID"));
                    stock.setName(rs.getString("OC_STOCK_NAME"));
                    foundObjects.add(stock);
                } else {*/
                    if (rs.getString("OC_STOCK_AUTHORIZEDUSERS") != null) {
                        String[] s = rs.getString("OC_STOCK_AUTHORIZEDUSERS").split("\\$");
                        for (int i = 0; i < s.length; i++) {
                            if (s[i].equals(sUserId)) {
                                stock = new ServiceStock();
                                stock.setUid(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID"));
                                stock.setName(rs.getString("OC_STOCK_NAME"));
                                stock.setServiceUid(rs.getString("OC_STOCK_SERVICEUID"));
                                stock.setAuthorizedUserIds(rs.getString("OC_STOCK_AUTHORIZEDUSERS"));
                                foundObjects.add(stock);
                            }
                        }
                    }
                //}
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
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        
        return foundObjects;
    }
    
    //--- IS ACTIVE -------------------------------------------------------------------------------
    public boolean isActive() {
        boolean isActive = false;
        if (this.getEnd() == null || this.getEnd().after(new java.util.Date())) {
            isActive = true;
        }
        return isActive;
    }
    
}