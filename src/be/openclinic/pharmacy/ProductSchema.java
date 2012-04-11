package be.openclinic.pharmacy;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.common.Util;
import be.openclinic.common.KeyValue;

import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ProductSchema {
    private String productuid;
    private String schemauid;
    private Vector timequantities=new Vector();

    public String getProductuid() {
        return productuid;
    }

    public KeyValue getTimeQuantity(int n){
        if(n>timequantities.size()-1){
            return new KeyValue("","");
        }
        else {
            return (KeyValue)timequantities.elementAt(n);
        }
    }

    public String getSchemauid() {
        return schemauid;
    }

    public void setSchemauid(String schemauid) {
        this.schemauid = schemauid;
    }

    public void setProductuid(String productuid) {
        this.productuid = productuid;
    }

    public Vector getTimequantities() {
        return timequantities;
    }

    public void setTimequantities(Vector timequantities) {
        this.timequantities = timequantities;
    }

    public static ProductSchema getProductSchema(String schemauid){
        ProductSchema productSchema=new ProductSchema();
        try{
            productSchema.schemauid=schemauid;
            Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = dbConnection.prepareStatement("select * from OC_PRODUCT_SCHEMA where OC_SCHEMA_SERVERID=? and OC_SCHEMA_OBJECTID=? ORDER BY OC_SCHEMA_TIME");
            ps.setInt(1, Util.getServerid(schemauid));
            ps.setInt(2,Util.getObjectid(schemauid));
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                productSchema.setProductuid(rs.getString("OC_SCHEMA_PRODUCTUID"));
                productSchema.getTimequantities().add(new KeyValue(rs.getString("OC_SCHEMA_TIME"),rs.getString("OC_SCHEMA_QUANTITY")));
            }
            rs.close();
            ps.close();
            dbConnection.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return productSchema;
    }

    public static ProductSchema getSingleProductSchema(String productuid){
        ProductSchema productSchema=new ProductSchema();
        productSchema.setProductuid(productuid);
        try{
            Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = dbConnection.prepareStatement("select * from OC_PRODUCT_SCHEMA where OC_SCHEMA_PRODUCTUID=? ORDER BY OC_SCHEMA_TIME");
            ps.setString(1, productuid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                productSchema.schemauid=Util.makeUID(rs.getInt("OC_SCHEMA_SERVERID"),rs.getInt("OC_SCHEMA_OBJECTID"));
                productSchema.getTimequantities().add(new KeyValue(rs.getString("OC_SCHEMA_TIME"),rs.getString("OC_SCHEMA_QUANTITY")));
            }
            rs.close();
            ps.close();
            dbConnection.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return productSchema;
    }

    public Vector getProductSchemas(String productuid){
        Vector schemas = new Vector();
        //First list all schemas that exist for this product
        try{
            Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = dbConnection.prepareStatement("select * from OC_PRODUCT_SCHEMA where OC_SCHEMA_PRODUCTUID=?");
            ps.setString(1,productuid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                schemas.add(ProductSchema.getProductSchema(Util.makeUID(rs.getInt("OC_SCHEMA_SERVERID"),rs.getInt("OC_SCHEMA_OBJECTID"))));
            }
            rs.close();
            ps.close();
            dbConnection.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return schemas;
    }

    public void store(){
        try{
            if(productuid!=null && productuid.length()>0 && productuid.indexOf(".")>0){
                if(schemauid==null || schemauid.length()==0 || schemauid.indexOf(".")<=0){
                    //Invalid schemauid, create a new one
                    schemauid=Util.makeUID(Util.getServerid(productuid),MedwanQuery.getInstance().getOpenclinicCounter("SchemaID"));
                }
                Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbConnection.prepareStatement("delete from OC_PRODUCT_SCHEMA where OC_SCHEMA_PRODUCTUID=?");
                ps.setString(1, productuid);
                ps.execute();
                ps.close();
                for(int n=0;n<timequantities.size();n++){
                    KeyValue keyValue=(KeyValue)timequantities.elementAt(n);
                    ps = dbConnection.prepareStatement("insert into OC_PRODUCT_SCHEMA(OC_SCHEMA_PRODUCTUID,OC_SCHEMA_SERVERID,OC_SCHEMA_OBJECTID,OC_SCHEMA_TIME,OC_SCHEMA_QUANTITY) values(?,?,?,?,?)");
                    ps.setString(1,productuid);
                    ps.setInt(2,Util.getServerid(schemauid));
                    ps.setInt(3,Util.getObjectid(schemauid));
                    ps.setInt(4,keyValue.getKeyInt());
                    ps.setInt(5,keyValue.getValueInt());
                    ps.execute();
                    ps.close();
                }
                dbConnection.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    public void delete(){
        try{
            if(productuid!=null && productuid.length()>0 && productuid.indexOf(".")>0){
                Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbConnection.prepareStatement("delete from OC_PRODUCT_SCHEMA where OC_SCHEMA_PRODUCTUID=?");
                ps.setString(1, productuid);
                ps.execute();
                ps.close();
                dbConnection.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}
