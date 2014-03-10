package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.common.KeyValue;
import be.openclinic.common.Util;
import be.openclinic.pharmacy.ProductSchema;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class CarePrescriptionSchema {
    private String careprescriptionuid;
    private Vector timequantities=new Vector();

    public String getCarePrescriptionUid() {
        return careprescriptionuid;
    }

    public void setCarePrescriptionUid(String schemauid) {
        this.careprescriptionuid = schemauid;
    }

    public Vector getTimequantities() {
        return timequantities;
    }

    public void setTimequantities(Vector timequantities) {
        this.timequantities = timequantities;
    }

    //--- GET TIME QUANTITY -----------------------------------------------------------------------
    public KeyValue getTimeQuantity(int n){
        if(n>timequantities.size()-1){
            return new KeyValue("","");
        }
        else {
            return (KeyValue)timequantities.elementAt(n);
        }
    }

    //--- GET QUANTITY ----------------------------------------------------------------------------
    public int getQuantity(String time){
        try{
            for(int n=0;n<timequantities.size();n++){
                KeyValue keyValue = (KeyValue)timequantities.elementAt(n);
                if(keyValue.getKey().equalsIgnoreCase(time)){
                    return Integer.parseInt(keyValue.getValue());
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return 0;
    }

    //--- GET CARE PRESCRIPTION SCHEMA ------------------------------------------------------------
    public static CarePrescriptionSchema getCarePrescriptionSchema(String careprescriptionuid){
        CarePrescriptionSchema careprescriptionSchema=new CarePrescriptionSchema();
        try{
            Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = dbConnection.prepareStatement("select * from OC_CAREPRESCRIPTION_SCHEMA where OC_CAREPRESCR_SERVERID=? and OC_CAREPRESCR_OBJECTID=? ORDER BY OC_CARESCHEMA_TIME");
            ps.setInt(1, Util.getServerid(careprescriptionuid));
            ps.setInt(2,Util.getObjectid(careprescriptionuid));
            ResultSet rs = ps.executeQuery();
            int counter=0;
            while (rs.next()){
                counter++;
                careprescriptionSchema.getTimequantities().add(new KeyValue(rs.getString("OC_CARESCHEMA_TIME"),rs.getString("OC_CARESCHEMA_QUANTITY")));
            }
            if(counter==0){
                Prescription prescription=Prescription.get(careprescriptionuid);
                if(prescription !=null && prescription.getProduct()!=null){
                    careprescriptionSchema.setTimequantities(ProductSchema.getSingleProductSchema(prescription.getProduct().getUid()).getTimequantities());
                }
            }
            rs.close();
            ps.close();
            dbConnection.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        return careprescriptionSchema;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        try{
            if(careprescriptionuid!=null && careprescriptionuid.length()>0 && careprescriptionuid.indexOf(".")>0){
                Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbConnection.prepareStatement("delete from OC_CAREPRESCRIPTION_SCHEMA where OC_CAREPRESCR_SERVERID=? and OC_CAREPRESCR_OBJECTID=?");
                ps.setInt(1, Util.getServerid(careprescriptionuid));
                ps.setInt(2,Util.getObjectid(careprescriptionuid));
                ps.execute();
                ps.close();
                KeyValue keyValue;
                for(int n=0;n<timequantities.size();n++){
                    keyValue=(KeyValue)timequantities.elementAt(n);
                    ps = dbConnection.prepareStatement("insert into OC_CAREPRESCRIPTION_SCHEMA(OC_CAREPRESCR_SERVERID,OC_CAREPRESCR_OBJECTID,OC_CARESCHEMA_TIME,OC_CARESCHEMA_QUANTITY) values(?,?,?,?)");
                    ps.setInt(1,Util.getServerid(careprescriptionuid));
                    ps.setInt(2,Util.getObjectid(careprescriptionuid));
                    ps.setInt(3,keyValue.getKeyInt());
                    ps.setInt(4,keyValue.getValueInt());
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

    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(){
        try{
            if(careprescriptionuid!=null && careprescriptionuid.length()>0 && careprescriptionuid.indexOf(".")>0){
                Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbConnection.prepareStatement("delete from OC_CAREPRESCRIPTION_SCHEMA where OC_CAREPRESCR_SERVERID=? and OC_CAREPRESCR_OBJECTID=?");
                ps.setInt(1, Util.getServerid(careprescriptionuid));
                ps.setInt(2,Util.getObjectid(careprescriptionuid));
                ps.execute();
                ps.close();
                dbConnection.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- GET CARE PRESCRIPTION -------------------------------------------------------------------
    public CarePrescription getCarePrescription(String careprescriptionUid){
        if(careprescriptionuid!=null && careprescriptionuid.length()>0 && careprescriptionuid.indexOf(".")>0){
            return CarePrescription.get(careprescriptionUid);
        }
        else {
            return null;
        }
    }

}
