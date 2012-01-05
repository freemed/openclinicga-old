package be.openclinic.pharmacy;
import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.util.Date;
import java.util.Vector;
import java.util.GregorianCalendar;
import java.util.Calendar;
import java.sql.*;

import net.admin.Service;
/**
 * User: Frank Verbeke, Stijn Smets
 * Date: 10-sep-2006
 */
public class ProductStock extends OC_Object implements Comparable {
    private ServiceStock serviceStock;
    private Product product;
    private int level = -1;
    private int minimumLevel = -1;
    private int maximumLevel = -1;
    private int orderLevel = -1;
    private Date begin;
    private Date end;
    private String defaultImportance; // (native|high|low)
    private Service supplier;
    // non-db data
    private String serviceStockUid;
    private String productUid;
    private String supplierUid;
    //--- SERVICE STOCK ---------------------------------------------------------------------------
    public ServiceStock getServiceStock() {
        if (serviceStockUid != null && serviceStockUid.length() > 0) {
            if (serviceStock == null) {
                this.setServiceStock(ServiceStock.get(serviceStockUid));
            }
        }
        return serviceStock;
    }
    public void setServiceStock(ServiceStock serviceStock) {
        this.serviceStock = serviceStock;
    }
    //--- PRODUCT ---------------------------------------------------------------------------------
    public Product getProduct() {
        if (productUid != null && productUid.length() > 0) {
            if (product == null) {
                this.setProduct(Product.get(productUid));
            }
        }
        return product;
    }
    public void setProduct(Product product) {
        this.product = product;
    }
    //--- LEVEL -----------------------------------------------------------------------------------
    public int getLevel() {
        return level;
    }
    public int getLevelIncludingOpenCommands() {
        int level = getLevel();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sQuery = "select SUM(OC_ORDER_PACKAGESORDERED) as total from OC_PRODUCTORDERS" +
                    " where" +
                    " OC_ORDER_PRODUCTSTOCKUID=? and" +
                    " OC_ORDER_DATEDELIVERED is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1, getUid());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                level += rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return level;
    }
    public void setLevel(int level) {
        this.level = level;
    }
    //--- MINIMUM LEVEL ---------------------------------------------------------------------------
    public int getMinimumLevel() {
        return minimumLevel;
    }
    public void setMinimumLevel(int minimumLevel) {
        this.minimumLevel = minimumLevel;
    }
    //--- MAXIMUM LEVEL ---------------------------------------------------------------------------
    public int getMaximumLevel() {
        return maximumLevel;
    }
    public void setMaximumLevel(int maximumLevel) {
        this.maximumLevel = maximumLevel;
    }
    //--- ORDER LEVEL -----------------------------------------------------------------------------
    public int getOrderLevel() {
        return orderLevel;
    }
    public void setOrderLevel(int orderLevel) {
        this.orderLevel = orderLevel;
    }
    //--- DATE BEGIN ------------------------------------------------------------------------------
    public Date getBegin() {
        return begin;
    }
    public void setBegin(Date begin) {
        this.begin = begin;
    }
    //--- DATE END --------------------------------------------------------------------------------
    public Date getEnd() {
        return end;
    }
    public void setEnd(Date end) {
        this.end = end;
    }
    //--- DEFAULT IMPORTANCE ----------------------------------------------------------------------
    public String getDefaultImportance() {
        return defaultImportance;
    }
    public void setDefaultImportance(String defaultImportance) {
        this.defaultImportance = defaultImportance;
    }
    //--- SUPPLIER --------------------------------------------------------------------------------
    public Service getSupplier() {
        if (supplierUid != null && supplierUid.length() > 0) {
            if (supplier == null) {
                this.setSupplier(Service.getService(supplierUid));
            }
        }
        return this.supplier;
    }
    public void setSupplier(Service supplier) {
        this.supplier = supplier;
    }
    //--- NON-DB DATA : SERVICE STOCK UID ---------------------------------------------------------
    public void setServiceStockUid(String uid) {
        this.serviceStockUid = uid;
    }
    public String getServiceStockUid() {
        return this.serviceStockUid;
    }
    //--- NON-DB DATA : PRODUCT UID ---------------------------------------------------------------
    public void setProductUid(String uid) {
        this.productUid = uid;
    }
    public String getProductUid() {
        return this.productUid;
    }
    //--- NON-DB DATA : SUPPLIER UID --------------------------------------------------------------
    public void setSupplierUid(String uid) {
        this.supplierUid = uid;
    }
    public String getSupplierUid() {
        return this.supplierUid;
    }
    //--- GET -------------------------------------------------------------------------------------
    public static ProductStock get(String stockUid) {
        ProductStock stock = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_PRODUCTSTOCKS" +
                    " WHERE OC_STOCK_SERVERID = ? AND OC_STOCK_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(stockUid.substring(0, stockUid.indexOf("."))));
            ps.setInt(2, Integer.parseInt(stockUid.substring(stockUid.indexOf(".") + 1)));
            rs = ps.executeQuery();

            // get data from DB
            if (rs.next()) {
                stock = new ProductStock();
                stock.setUid(stockUid);
                stock.setServiceStockUid(rs.getString("OC_STOCK_SERVICESTOCKUID"));
                stock.setProductUid(rs.getString("OC_STOCK_PRODUCTUID"));
                stock.setDefaultImportance(rs.getString("OC_STOCK_DEFAULTIMPORTANCE")); // (native|high|low)
                stock.setSupplierUid(rs.getString("OC_STOCK_SUPPLIERUID"));

                // levels
                stock.setLevel(rs.getInt("OC_STOCK_LEVEL"));
                stock.setMinimumLevel(rs.getInt("OC_STOCK_MINIMUMLEVEL"));

                // maximumLevel
                String tmpValue = rs.getString("OC_STOCK_MAXIMUMLEVEL");
                if (tmpValue != null) {
                    stock.setMaximumLevel(Integer.parseInt(tmpValue));
                }

                // orderLevel
                tmpValue = rs.getString("OC_STOCK_ORDERLEVEL");
                if (tmpValue != null) {
                    stock.setOrderLevel(Integer.parseInt(tmpValue));
                }

                // dates
                stock.setBegin(rs.getDate("OC_STOCK_BEGIN"));
                stock.setEnd(rs.getDate("OC_STOCK_END"));

                // OBJECT variables
                stock.setCreateDateTime(rs.getTimestamp("OC_STOCK_CREATETIME"));
                stock.setUpdateDateTime(rs.getTimestamp("OC_STOCK_UPDATETIME"));
                stock.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_STOCK_UPDATEUID")));
                stock.setVersion(rs.getInt("OC_STOCK_VERSION"));
            } else {
                throw new Exception("ERROR : PRODUCTSTOCK " + stockUid + " NOT FOUND");
            }
        }
        catch (Exception e) {
            if (e.getMessage().endsWith("NOT FOUND")) {
                Debug.println(e.getMessage());
            } else {
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
    //--- GET (2 parameters) ----------------------------------------------------------------------
    public static ProductStock get(String productUid, String supplyingServiceUid) {
        ProductStock productStock = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            // compose query
            String sSelect = "SELECT * FROM OC_PRODUCTSTOCKS" +
                    " WHERE OC_STOCK_PRODUCTUID = ?" +
                    "  AND OC_STOCK_SERVICESTOCKUID = ?";

            // set questionmark values
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, productUid);
            ps.setString(2, supplyingServiceUid);

            // execute
            rs = ps.executeQuery();
            if (rs.next()) {
                productStock = ProductStock.get(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID"));
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
        return productStock;
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
                if (Debug.enabled) Debug.println("@@@ PRODUCTSTOCK INSERT @@@");
                sSelect = "INSERT INTO OC_PRODUCTSTOCKS (OC_STOCK_SERVERID, OC_STOCK_OBJECTID," +
                        "  OC_STOCK_SERVICESTOCKUID, OC_STOCK_PRODUCTUID, OC_STOCK_LEVEL," +
                        "  OC_STOCK_MINIMUMLEVEL, OC_STOCK_MAXIMUMLEVEL, OC_STOCK_ORDERLEVEL," +
                        "  OC_STOCK_BEGIN, OC_STOCK_END, OC_STOCK_DEFAULTIMPORTANCE, OC_STOCK_SUPPLIERUID," +
                        "  OC_STOCK_CREATETIME, OC_STOCK_UPDATETIME, OC_STOCK_UPDATEUID, OC_STOCK_VERSION)" +
                        " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)";
                ps = oc_conn.prepareStatement(sSelect);
                int questionMarkIdx = 1;

                // set new servicestockuid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int productStockCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRODUCTSTOCKS");
                ps.setInt(questionMarkIdx++, serverId);
                ps.setInt(questionMarkIdx++, productStockCounter);
                this.setUid(serverId + "." + productStockCounter);
                ps.setString(questionMarkIdx++, this.getServiceStockUid());
                ps.setString(questionMarkIdx++, this.getProductUid());
                ps.setInt(questionMarkIdx++, this.getLevel());
                ps.setInt(questionMarkIdx++, this.getMinimumLevel());

                // if maximumLevel not specified, do not save it
                if (this.getMaximumLevel() > -1) ps.setInt(questionMarkIdx++, this.getMaximumLevel());
                else ps.setNull(questionMarkIdx++, Types.INTEGER);

                // if orderLevel not specified, do not save it
                if (this.getOrderLevel() > -1) ps.setInt(questionMarkIdx++, this.getOrderLevel());
                else ps.setNull(questionMarkIdx++, Types.INTEGER);

                // date begin
                if (this.begin != null)
                    ps.setTimestamp(questionMarkIdx++, new java.sql.Timestamp(this.begin.getTime()));
                else ps.setNull(questionMarkIdx++, Types.TIMESTAMP);

                // date end
                if (this.end != null) ps.setTimestamp(questionMarkIdx++, new java.sql.Timestamp(end.getTime()));
                else ps.setNull(questionMarkIdx++, Types.TIMESTAMP);

                // default importance
                if (this.getDefaultImportance().length() > 0)
                    ps.setString(questionMarkIdx++, this.getDefaultImportance());
                else ps.setNull(questionMarkIdx++, Types.VARCHAR);

                // supplier
                if (this.getSupplierUid().length() > 0) ps.setString(questionMarkIdx++, this.getSupplierUid());
                else ps.setNull(questionMarkIdx++, Types.VARCHAR);

                // OBJECT variables
                ps.setTimestamp(questionMarkIdx++, new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(questionMarkIdx++, new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(questionMarkIdx++, this.getUpdateUser());
                ps.executeUpdate();
            } else {
                //***** UPDATE *****
                if (Debug.enabled) Debug.println("@@@ PRODUCTSTOCK UPDATE @@@");
                sSelect = "UPDATE OC_PRODUCTSTOCKS SET" +
                        "  OC_STOCK_SERVICESTOCKUID=?, OC_STOCK_PRODUCTUID=?, OC_STOCK_LEVEL=?," +
                        "  OC_STOCK_MINIMUMLEVEL=?, OC_STOCK_MAXIMUMLEVEL=?, OC_STOCK_ORDERLEVEL=?," +
                        "  OC_STOCK_BEGIN=?, OC_STOCK_END=?, OC_STOCK_DEFAULTIMPORTANCE=?, OC_STOCK_SUPPLIERUID=?," +
                        "  OC_STOCK_UPDATETIME=?, OC_STOCK_UPDATEUID=?, OC_STOCK_VERSION=(OC_STOCK_VERSION+1)" +
                        " WHERE OC_STOCK_SERVERID=? AND OC_STOCK_OBJECTID=?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1, this.getServiceStockUid());
                ps.setString(2, this.getProductUid());
                ps.setInt(3, this.getLevel());
                ps.setInt(4, this.getMinimumLevel());

                // if maximumLevel not specified, do not save it
                if (this.getMaximumLevel() > -1) ps.setInt(5, this.getMaximumLevel());
                else ps.setNull(5, Types.INTEGER);

                // if orderLevel not specified, do not save it
                if (this.getOrderLevel() > -1) ps.setInt(6, this.getOrderLevel());
                else ps.setNull(6, Types.INTEGER);

                // date begin
                if (this.begin != null) ps.setTimestamp(7, new java.sql.Timestamp(this.begin.getTime()));
                else ps.setNull(7, Types.TIMESTAMP);

                // date end
                if (this.end != null) ps.setTimestamp(8, new java.sql.Timestamp(end.getTime()));
                else ps.setNull(8, Types.TIMESTAMP);

                // default importance
                if (this.getDefaultImportance().length() > 0) ps.setString(9, this.getDefaultImportance());
                else ps.setNull(9, Types.VARCHAR);

                // supplier
                if (this.getSupplierUid().length() > 0) ps.setString(10, this.getSupplierUid());
                else ps.setNull(10, Types.VARCHAR);

                // OBJECT variables
                ps.setTimestamp(11, new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(12, this.getUpdateUser());

                // where
                ps.setInt(13, Integer.parseInt(this.getUid().substring(0, this.getUid().indexOf("."))));
                ps.setInt(14, Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".") + 1)));
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
        if (Debug.enabled) Debug.println("@@@ PRODUCTSTOCK exists ? @@@");
        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            //***** check existence *****
            String sSelect = "SELECT OC_STOCK_SERVERID,OC_STOCK_OBJECTID FROM OC_PRODUCTSTOCKS" +
                    " WHERE OC_STOCK_SERVICESTOCKUID=?" +
                    "  AND OC_STOCK_PRODUCTUID=?" +
                    "  AND OC_STOCK_END=?";
            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++, this.getServiceStockUid());
            ps.setString(questionmarkIdx++, this.getProductUid());
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
        if (Debug.enabled) Debug.println("@@@ PRODUCTSTOCK changed ? @@@");
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            //***** check existence *****
            String sSelect = "SELECT OC_STOCK_SERVERID,OC_STOCK_OBJECTID FROM OC_PRODUCTSTOCKS" +
                    " WHERE OC_STOCK_SERVICESTOCKUID=?" +
                    "  AND OC_STOCK_PRODUCTUID=?" +
                    "  AND OC_STOCK_LEVEL=?" +
                    "  AND OC_STOCK_MINIMUMLEVEL=?" +
                    "  AND OC_STOCK_MAXIMUMLEVEL=?" +
                    "  AND OC_STOCK_ORDERLEVEL=?" +
                    "  AND OC_STOCK_BEGIN=?" +
                    "  AND OC_STOCK_END=?" +
                    "  AND OC_STOCK_DEFAULTIMPORTANCE=?" +
                    "  AND OC_STOCK_SUPPLIERUID=?";
            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++, this.getServiceStockUid()); // required
            ps.setString(questionmarkIdx++, this.getProductUid()); // required
            ps.setInt(questionmarkIdx++, this.getLevel()); // required
            ps.setInt(questionmarkIdx++, this.getMinimumLevel()); // required

            // if maximumLevel not specified, do not set it
            if (this.getMaximumLevel() > -1) ps.setInt(questionmarkIdx++, this.getMaximumLevel());
            else ps.setNull(questionmarkIdx++, Types.INTEGER);

            // if orderLevel not specified, do not set it
            if (this.getOrderLevel() > -1) ps.setInt(questionmarkIdx++, this.getOrderLevel());
            else ps.setNull(questionmarkIdx++, Types.INTEGER);

            // date begin
            if (this.begin != null) ps.setTimestamp(questionmarkIdx++, new java.sql.Timestamp(this.begin.getTime()));
            else ps.setNull(questionmarkIdx++, Types.TIMESTAMP);

            // date end
            if (this.end != null) ps.setTimestamp(questionmarkIdx++, new java.sql.Timestamp(end.getTime()));
            else ps.setNull(questionmarkIdx++, Types.TIMESTAMP);

            // default importance
            if (this.getDefaultImportance().length() > 0) ps.setString(questionmarkIdx++, this.getDefaultImportance());
            else ps.setNull(questionmarkIdx++, Types.VARCHAR);

            // supplier
            if (this.getSupplierUid().length() > 0) ps.setString(questionmarkIdx++, this.getSupplierUid());
            else ps.setNull(questionmarkIdx++, Types.VARCHAR);
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
    //--- GET DELIVERIES TO PATIENT ---------------------------------------------------------------
    // Return vector containing all deliveries (type of ProductStockOperation) to the specified patient.
    public Vector getDeliveriesToPatient(String patientId) {
        Vector deliveries = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            // compose query
            String sSelect = "SELECT * FROM OC_PRODUCTSTOCKOPERATIONS " +
                    "  WHERE OC_OPERATION_SRCDESTUID = ?" +
                    "   AND OC_OPERATION_PRODUCTSTOCKUID = ?" +
                    "   AND OC_OPERATION_SRCDESTTYPE = 'type2patient'" +
                    "   AND OC_OPERATION_DESCRIPTION LIKE 'medicationdelivery.%'" +
                    " ORDER BY OC_OPERATION_DATE ASC";

            // set questionmark values
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, patientId);
            ps.setString(2, this.getUid());

            // execute
            rs = ps.executeQuery();
            ProductStockOperation delivery = null;
            while (rs.next()) {
                delivery = ProductStockOperation.get(rs.getString("OC_OPERATION_SERVERID") + "." + rs.getString("OC_OPERATION_OBJECTID"));
                deliveries.add(delivery);
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
        return deliveries;
    }
    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String productStockUid) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "DELETE FROM OC_PRODUCTSTOCKS" +
                    " WHERE OC_STOCK_SERVERID = ? AND OC_STOCK_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(productStockUid.substring(0, productStockUid.indexOf("."))));
            ps.setInt(2, Integer.parseInt(productStockUid.substring(productStockUid.indexOf(".") + 1)));
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
    //--- FIND ------------------------------------------------------------------------------------
    public static Vector find(String sFindServiceStockUid, String sFindProductUid, String sFindLevel,
                              String sFindMinimumLevel, String sFindMaximumLevel, String sFindOrderLevel,
                              String sFindBegin, String sFindEnd, String sFindDefaultImportance,
                              String sFindSupplierUid, String sFindServiceUid, String sSortCol, String sSortDir) {
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT ps.OC_STOCK_SERVERID, ps.OC_STOCK_OBJECTID" +
                    " FROM OC_PRODUCTSTOCKS ps, OC_PRODUCTS p ";
            if (sFindServiceUid.length() > 0) {
                sSelect += ", OC_SERVICESTOCKS ss ";
            }
            sSelect += "WHERE ";

            // bind the serviceStock table
            String convertServerId = MedwanQuery.getInstance().convert("varchar(16)", "p.OC_PRODUCT_SERVERID");
            String convertObjectId = MedwanQuery.getInstance().convert("varchar(16)", "p.OC_PRODUCT_OBJECTID");
            sSelect += " p.OC_PRODUCT_OBJECTID=replace(ps.OC_STOCK_PRODUCTUID,'" +  MedwanQuery.getInstance().getConfigInt("serverId") + ".','') ";

            // match search criteria
            if (sFindServiceStockUid.length() > 0 || sFindProductUid.length() > 0 || sFindLevel.length() > 0 ||
                    sFindMinimumLevel.length() > 0 || sFindMaximumLevel.length() > 0 || sFindOrderLevel.length() > 0 ||
                    sFindBegin.length() > 0 || sFindEnd.length() > 0 || sFindDefaultImportance.length() > 0 ||
                    sFindSupplierUid.length() > 0 || sFindServiceUid.length() > 0) {
                sSelect += "AND ";
                if (sFindServiceUid.length() > 0) {
                    // bind the serviceStock table
                    convertServerId = MedwanQuery.getInstance().convert("varchar(16)", "ss.OC_STOCK_SERVERID");
                    convertObjectId = MedwanQuery.getInstance().convert("varchar(16)", "ss.OC_STOCK_OBJECTID");
                    sSelect += " ps.OC_STOCK_SERVICESTOCKUID = (" + convertServerId + MedwanQuery.getInstance().concatSign() + "'.'" + MedwanQuery.getInstance().concatSign() + convertObjectId + ") AND ";
                }
                if (sFindServiceUid.length() > 0) {
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindServiceUid);
                    childIds.add(sFindServiceUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds, ",", "'");
                    if (sChildIds.length() > 0) {
                        sSelect += " ss.OC_STOCK_SERVICEUID IN (" + sChildIds + ") AND ";
                    } else {
                        sSelect += " ss.OC_STOCK_SERVICEUID IN ('') AND ";
                    }
                }
                if (sFindServiceStockUid.length() > 0) sSelect += "ps.OC_STOCK_SERVICESTOCKUID = ? AND ";
                if (sFindProductUid.length() > 0) sSelect += "ps.OC_STOCK_PRODUCTUID = ? AND ";
                if (sFindLevel.length() > 0) sSelect += "ps.OC_STOCK_LEVEL >= ? AND ";
                if (sFindMinimumLevel.length() > 0) sSelect += "ps.OC_STOCK_MINIMUMLEVEL = ? AND ";
                if (sFindMaximumLevel.length() > 0) sSelect += "ps.OC_STOCK_MAXIMUMLEVEL = ? AND ";
                if (sFindOrderLevel.length() > 0) sSelect += "ps.OC_STOCK_ORDERLEVEL = ? AND ";
                if (sFindBegin.length() > 0) sSelect += "ps.OC_STOCK_BEGIN = ? AND ";
                if (sFindEnd.length() > 0) sSelect += "ps.OC_STOCK_END = ? AND ";
                if (sFindDefaultImportance.length() > 0) sSelect += "ps.OC_STOCK_DEFAULTIMPORTANCE = ? AND ";
                if (sFindSupplierUid.length() > 0) {
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindSupplierUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds, ",", "'");
                    if (sChildIds.length() > 0) {
                        sSelect += "ps.OC_STOCK_SUPPLIERUID IN (" + sChildIds + ") AND ";
                    } else {
                        sSelect += "ps.OC_STOCK_SUPPLIERUID IN ('') AND ";
                    }
                }

                // remove last AND if any
                if (sSelect.indexOf("AND ") > -1) {
                    sSelect = sSelect.substring(0, sSelect.lastIndexOf("AND "));
                }
            }

            // order by selected col or default col
            sSelect += "ORDER BY " + sSortCol + " " + sSortDir;
            System.out.println(sSelect);
            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if (sFindServiceStockUid.length() > 0) ps.setString(questionMarkIdx++, sFindServiceStockUid);
            if (sFindProductUid.length() > 0) ps.setString(questionMarkIdx++, sFindProductUid);
            if (sFindLevel.length() > 0) ps.setInt(questionMarkIdx++, Integer.parseInt(sFindLevel));
            if (sFindMinimumLevel.length() > 0) ps.setInt(questionMarkIdx++, Integer.parseInt(sFindMinimumLevel));
            if (sFindMaximumLevel.length() > 0) ps.setInt(questionMarkIdx++, Integer.parseInt(sFindMaximumLevel));
            if (sFindOrderLevel.length() > 0) ps.setInt(questionMarkIdx++, Integer.parseInt(sFindOrderLevel));
            if (sFindBegin.length() > 0) ps.setDate(questionMarkIdx++, ScreenHelper.getSQLDate(sFindBegin));
            if (sFindEnd.length() > 0) ps.setDate(questionMarkIdx++, ScreenHelper.getSQLDate(sFindEnd));
            if (sFindDefaultImportance.length() > 0) ps.setString(questionMarkIdx++, sFindDefaultImportance);

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
    //--- IS ACTIVE -------------------------------------------------------------------------------
    public boolean isActive() {
        boolean isActive = false;
        if (this.getEnd() == null || this.getEnd().after(new java.util.Date())) {
            isActive = true;
        }
        return isActive;
    }
    //--- GET TOTAL UNITS IN FOR DATE -------------------------------------------------------------
    public int getTotalUnitsInForDate(java.util.Date date) {
        int units = 0;
        java.util.Date dateUntill = new java.util.Date(date.getTime() + (24 * 3600 * 1000) - 1); // add one day
        Vector receipts = ProductStockOperation.getReceipts(getUid(), "", date, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation receipt;
        for (int i = 0; i < receipts.size(); i++) {
            receipt = (ProductStockOperation) receipts.get(i);
            units += receipt.getUnitsChanged();
        }
        return units;
    }
    //--- GET TOTAL UNITS OUT FOR DATE ------------------------------------------------------------
    public int getTotalUnitsOutForDate(java.util.Date date) {
        int units = 0;
        java.util.Date dateUntill = new java.util.Date(date.getTime() + (24 * 3600 * 1000) - 1); // add one day
        Vector deliveries = ProductStockOperation.getDeliveries(getUid(), "", date, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation delivery;
        for (int i = 0; i < deliveries.size(); i++) {
            delivery = (ProductStockOperation) deliveries.get(i);
            units += delivery.getUnitsChanged();
        }
        return units;
    }
    //--- GET TOTAL UNITS IN FOR MONTH ------------------------------------------------------------
    public int getTotalUnitsInForMonth(java.util.Date dateFrom) {
        int units = 0;

        // date from : begin of specified month
        Calendar calendar = new GregorianCalendar();
        calendar.setTime(dateFrom);
        calendar.set(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), 0, 0, 0, 0);
        dateFrom = calendar.getTime();

        // date untill : end of specified month
        calendar.add(Calendar.MONTH, 1);
        java.util.Date dateUntill = calendar.getTime();
        Vector receipts = ProductStockOperation.getReceipts(getUid(), "", dateFrom, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation receipt;
        for (int i = 0; i < receipts.size(); i++) {
            receipt = (ProductStockOperation) receipts.get(i);
            units += receipt.getUnitsChanged();
        }
        return units;
    }
    //--- GET TOTAL UNITS OUT FOR MONTH -----------------------------------------------------------
    public int getTotalUnitsOutForMonth(java.util.Date dateFrom) {
        int units = 0;

        // date from : begin of specified month
        Calendar calendar = new GregorianCalendar();
        calendar.setTime(dateFrom);
        calendar.set(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), 0, 0, 0, 0);
        dateFrom = calendar.getTime();

        // date untill : end of specified month
        calendar.add(Calendar.MONTH, 1);
        java.util.Date dateUntill = calendar.getTime();
        Vector deliveries = ProductStockOperation.getDeliveries(getUid(), "", dateFrom, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation receipt;
        for (int i = 0; i < deliveries.size(); i++) {
            receipt = (ProductStockOperation) deliveries.get(i);
            units += receipt.getUnitsChanged();
        }
        return units;
    }
    //--- GET TOTAL UNITS IN FOR YEAR -------------------------------------------------------------
    public int getTotalUnitsInForYear(java.util.Date dateFrom) {
        int units = 0;

        // date from : begin of specified month
        Calendar calendar = new GregorianCalendar();
        calendar.setTime(dateFrom);
        calendar.set(calendar.get(Calendar.YEAR), 0, 0, 0, 0, 0);
        dateFrom = calendar.getTime();

        // date untill : end of specified month
        calendar.add(Calendar.YEAR, 1);
        java.util.Date dateUntill = calendar.getTime();
        Vector deliveries = ProductStockOperation.getReceipts(getUid(), "", dateFrom, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation receipt;
        for (int i = 0; i < deliveries.size(); i++) {
            receipt = (ProductStockOperation) deliveries.get(i);
            units += receipt.getUnitsChanged();
        }
        return units;
    }
    //--- GET TOTAL UNITS OUT FOR YEAR ------------------------------------------------------------
    public int getTotalUnitsOutForYear(java.util.Date dateFrom) {
        int units = 0;

        // date from : begin of specified month
        Calendar calendar = new GregorianCalendar();
        calendar.setTime(dateFrom);
        calendar.set(calendar.get(Calendar.YEAR), 0, 0, 0, 0, 0);
        dateFrom = calendar.getTime();

        // date untill : end of specified month
        calendar.add(Calendar.YEAR, 1);
        java.util.Date dateUntill = calendar.getTime();
        Vector deliveries = ProductStockOperation.getDeliveries(getUid(), "", dateFrom, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation delivery;
        for (int i = 0; i < deliveries.size(); i++) {
            delivery = (ProductStockOperation) deliveries.get(i);
            units += delivery.getUnitsChanged();
        }
        return units;
    }
    //--- GET LEVEL -------------------------------------------------------------------------------
    // Count level at a given time starting from the initial level (0), based on the operations
    // done on this productStock,
    //---------------------------------------------------------------------------------------------
    public int getLevel(java.util.Date dateUntill) {
        java.util.Date dateFrom = new java.util.Date(0); // begin of time
        dateUntill = new java.util.Date(dateUntill.getTime() + (24 * 3600 * 1000));

        // IN
        int unitsIn = 0;
        Vector receipts = ProductStockOperation.getReceipts(getUid(), "", dateFrom, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation receipt;
        for (int i = 0; i < receipts.size(); i++) {
            receipt = (ProductStockOperation) receipts.get(i);
            unitsIn += receipt.getUnitsChanged();
        }

        // OUT
        int unitsOut = 0;
        Vector deliveries = ProductStockOperation.getDeliveries(getUid(), "", dateFrom, dateUntill, "OC_OPERATION_DATE", "ASC");
        ProductStockOperation delivery;
        for (int i = 0; i < deliveries.size(); i++) {
            delivery = (ProductStockOperation) deliveries.get(i);
            unitsOut += delivery.getUnitsChanged();
        }
        return unitsIn - unitsOut;
    }
    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object obj) {
        ProductStock otherProductStock = (ProductStock) obj;
        if (getProduct() == null || otherProductStock.getProduct() == null) return 1;
        return this.getProduct().compareTo(otherProductStock.getProduct());
    }
    public static Vector getProducts(String stockId, String sFindProductName) {
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT ps.OC_STOCK_SERVERID, ps.OC_STOCK_OBJECTID" +
                    " FROM OC_PRODUCTSTOCKS ps, OC_PRODUCTS p WHERE 1=1";
            // bind the serviceStock table
            String convertServerId = MedwanQuery.getInstance().convert("varchar(16)", "p.OC_PRODUCT_SERVERID");
            String convertObjectId = MedwanQuery.getInstance().convert("varchar(16)", "p.OC_PRODUCT_OBJECTID");
            sSelect += " AND ps.OC_STOCK_PRODUCTUID = (" + convertServerId + MedwanQuery.getInstance().concatSign() + "'.'" + MedwanQuery.getInstance().concatSign() + convertObjectId + ") ";
            sSelect += "AND ps.OC_STOCK_SERVICESTOCKUID = (" + stockId + ")";
            if (sFindProductName.trim().length() > 0) {
                sSelect += "AND p.OC_PRODUCT_NAME LIKE '%" + sFindProductName + "%'";

            }
            sSelect+=" ORDER BY OC_PRODUCT_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            // execute
            rs = ps.executeQuery();
            while (rs.next()) {
                foundObjects.add(get(rs.getString("OC_STOCK_SERVERID") + "." + rs.getString("OC_STOCK_OBJECTID")));
            }
        } catch (Exception e) {
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
}
