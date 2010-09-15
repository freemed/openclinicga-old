package be.openclinic.pharmacy;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;

import net.admin.AdminPerson;

/**
 * User: stijnsmets
 * Date: 18-dec-2006
 */
public class UserProduct implements Comparable {

    private AdminPerson user;
    private Product product;
    private ProductStock productStock;

    private String userId;
    private String productUid = null;
    private String productStockUid = null;


    //--- SET USER --------------------------------------------------------------------------------
    public void setUser(AdminPerson user){
        this.user = user;
    }

    //--- GET USER --------------------------------------------------------------------------------
    public AdminPerson getUser(){
        if(this.userId!=null && this.userId.length() > 0){
            if(this.user==null){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                this.setUser(AdminPerson.getAdminPerson(oc_conn,this.userId));
                try {
					oc_conn.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
        }

        return this.user;
    }

    //--- SET USER ID -----------------------------------------------------------------------------
    public String setUserId(String userId){
        return this.userId = userId;
    }

    //--- GET USER ID -----------------------------------------------------------------------------
    public String getUserId(){
        return this.userId;
    }

    //--- SET PRODUCT -----------------------------------------------------------------------------
    public void setProduct(Product product){
        this.product = product;
    }

    //--- SET PRODUCT UID -------------------------------------------------------------------------
    public String setProductUid(String productUid){
        return this.productUid = productUid;
    }

    //--- GET PRODUCT UID -------------------------------------------------------------------------
    public String getProductUid(){
        return this.productUid;
    }

    //--- GET PRODUCT -----------------------------------------------------------------------------
    public Product getProduct(){
        if(this.productUid!=null && this.productUid.length() > 0){
            if(this.product==null){
                this.setProduct(Product.get(this.productUid));
            }
        }

        return this.product;
    }

    //--- SET PRODUCT STOCK -----------------------------------------------------------------------
    public void setProductStock(ProductStock stock){
        this.productStock = stock;
    }

    //--- GET PRODUCT STOCK -----------------------------------------------------------------------
    public ProductStock getProductStock(){
        if(this.productStockUid!=null && this.productStockUid.length() > 0){
            if(this.productStock==null){
                this.setProductStock(ProductStock.get(this.productStockUid));
            }
        }

        return this.productStock;
    }

    //--- SET PRODUCT STOCK UID -------------------------------------------------------------------
    public String setProductStockUid(String productStockUid){
        return this.productStockUid = productStockUid;
    }

    //--- GET PRODUCT STOCK UID -------------------------------------------------------------------
    public String getProductStockUid(){
        return this.productStockUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static UserProduct get(String userId, String productUid){
        UserProduct userProduct = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PRODUCT_PRODUCTSTOCKUID FROM OC_USERPRODUCTS"+
                             " WHERE OC_PRODUCT_USERID = ? AND OC_PRODUCT_PRODUCTUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,userId);
            ps.setString(2,productUid);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                userProduct = new UserProduct();

                // unique key (instead of uid)
                userProduct.setUserId(userId);
                userProduct.setProductUid(productUid);

                // productStock
                String productStockUid = ScreenHelper.checkString(rs.getString("OC_PRODUCT_PRODUCTSTOCKUID"));
                if(productStockUid.length() > 0){
                    userProduct.setProductStockUid(productStockUid);
                }
            }
            else{
                throw new Exception("ERROR : USERPRODUCT "+userId+","+productUid+" NOT FOUND");
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

        return userProduct;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        store(true);
    }

    public void store(boolean checkExistence){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        boolean productWithSameDataExists = false;

        // check existence if needed
        if(checkExistence){
            productWithSameDataExists = this.exists().length()>0;
        }

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(!productWithSameDataExists){
                sSelect = "INSERT INTO OC_USERPRODUCTS VALUES(?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.userId);
                ps.setString(2,this.productUid);
                ps.setString(3,this.productStockUid);
                ps.executeUpdate();
            }
            else{
                sSelect = "UPDATE OC_USERPRODUCTS SET OC_PRODUCT_PRODUCTSTOCKUID = ?"+
                          " WHERE OC_PRODUCT_USERID = ? AND OC_PRODUCT_PRODUCTUID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.productStockUid);
                ps.setString(2,this.userId);
                ps.setString(3,this.productUid);
                ps.executeUpdate();
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
        if(Debug.enabled) Debug.println("@@@ USERPRODUCT exists ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PRODUCT_PRODUCTSTOCKUID FROM OC_USERPRODUCTS"+
                             " WHERE OC_PRODUCT_USERID = ? AND OC_PRODUCT_PRODUCTUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,this.userId);
            ps.setString(2,this.productUid);

            rs = ps.executeQuery();
            if(rs.next()){
                uid = rs.getString("OC_PRODUCT_PRODUCTSTOCKUID");
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

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String userId, String productUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_USERPRODUCTS "+
                             " WHERE OC_PRODUCT_USERID = ? AND OC_PRODUCT_PRODUCTUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,userId);
            ps.setString(2,productUid);
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

    //--- FIND ------------------------------------------------------------------------------------
    public static Vector find(String userId) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector userProducts = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PRODUCT_PRODUCTUID,OC_PRODUCT_PRODUCTSTOCKUID"+
                             " FROM OC_USERPRODUCTS"+
                             "  WHERE OC_PRODUCT_USERID = ?";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,userId);

            // execute
            rs = ps.executeQuery();

            String sProductUid, sProductStockUid;
            UserProduct userProduct;
            while(rs.next()){
                sProductUid = ScreenHelper.checkString(rs.getString("OC_PRODUCT_PRODUCTUID"));
                userProduct = UserProduct.get(userId,sProductUid);
                if(userProduct!=null){
                    sProductStockUid = ScreenHelper.checkString(rs.getString("OC_PRODUCT_PRODUCTSTOCKUID"));
                    if(sProductStockUid.length() > 0){
                        userProduct.setProductStockUid(sProductStockUid);
                    }

                    userProducts.add(userProduct);
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

        return userProducts;
    }

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object obj){
        UserProduct otherUserProduct = (UserProduct)obj;
        if(getProduct()==null || otherUserProduct.getProduct()==null) return 1;
        return this.getProduct().getName().compareTo(otherUserProduct.getProduct().getName());
    }

}
