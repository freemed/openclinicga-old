package be.openclinic.pharmacy;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.common.Util;
import be.openclinic.common.KeyValue;
import be.openclinic.medical.Prescription;

import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PrescriptionSchema {
    private String prescriptionuid;
    private Vector timequantities=new Vector();

    public String getPrescriptionUid() {
        return prescriptionuid;
    }

    public void setPrescriptionUid(String schemauid) {
        this.prescriptionuid = schemauid;
    }

    public Vector getTimequantities() {
        return timequantities;
    }

    public void setTimequantities(Vector timequantities) {
        this.timequantities = timequantities;
    }

    public KeyValue getTimeQuantity(int n){
        if(n>timequantities.size()-1){
            return new KeyValue("","");
        }
        else {
            return (KeyValue)timequantities.elementAt(n);
        }
    }

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

    public static PrescriptionSchema getPrescriptionSchema(String prescriptionuid){
        PrescriptionSchema prescriptionSchema=new PrescriptionSchema();
        try{
            Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = dbConnection.prepareStatement("select * from OC_PRESCRIPTION_SCHEMA where OC_PRESCR_SERVERID=? and OC_PRESCR_OBJECTID=? ORDER BY OC_SCHEMA_TIME");
            ps.setInt(1, Util.getServerid(prescriptionuid));
            ps.setInt(2,Util.getObjectid(prescriptionuid));
            ResultSet rs = ps.executeQuery();
            int counter=0;
            while (rs.next()){
                counter++;
                prescriptionSchema.getTimequantities().add(new KeyValue(rs.getString("OC_SCHEMA_TIME"),rs.getString("OC_SCHEMA_QUANTITY")));
            }
            if(counter==0){
                Prescription prescription=Prescription.get(prescriptionuid);
                if(prescription !=null && prescription.getProduct()!=null){
                    prescriptionSchema.setTimequantities(ProductSchema.getSingleProductSchema(prescription.getProduct().getUid()).getTimequantities());
                }
            }
            rs.close();
            ps.close();
            dbConnection.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return prescriptionSchema;
    }

    public void store(){
        try{
            if(prescriptionuid!=null && prescriptionuid.length()>0 && prescriptionuid.indexOf(".")>0){
                Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbConnection.prepareStatement("delete from OC_PRESCRIPTION_SCHEMA where OC_PRESCR_SERVERID=? and OC_PRESCR_OBJECTID=?");
                ps.setInt(1, Util.getServerid(prescriptionuid));
                ps.setInt(2,Util.getObjectid(prescriptionuid));
                ps.execute();
                ps.close();
                KeyValue keyValue;
                for(int n=0;n<timequantities.size();n++){
                    keyValue=(KeyValue)timequantities.elementAt(n);
                    ps = dbConnection.prepareStatement("insert into OC_PRESCRIPTION_SCHEMA(OC_PRESCR_SERVERID,OC_PRESCR_OBJECTID,OC_SCHEMA_TIME,OC_SCHEMA_QUANTITY) values(?,?,?,?)");
                    ps.setInt(1,Util.getServerid(prescriptionuid));
                    ps.setInt(2,Util.getObjectid(prescriptionuid));
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

    public void delete(){
        try{
            if(prescriptionuid!=null && prescriptionuid.length()>0 && prescriptionuid.indexOf(".")>0){
                Connection dbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbConnection.prepareStatement("delete from OC_PRESCRIPTION_SCHEMA where OC_PRESCR_SERVERID=? and OC_PRESCR_OBJECTID=?");
                ps.setInt(1, Util.getServerid(prescriptionuid));
                ps.setInt(2,Util.getObjectid(prescriptionuid));
                ps.execute();
                ps.close();
                dbConnection.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    public Prescription getPrescription(String prescriptionUid){
        if(prescriptionuid!=null && prescriptionuid.length()>0 && prescriptionuid.indexOf(".")>0){
            return Prescription.get(prescriptionUid);
        }
        else {
            return null;
        }
    }

}
