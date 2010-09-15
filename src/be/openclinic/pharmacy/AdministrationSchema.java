package be.openclinic.pharmacy;

import be.openclinic.medical.Prescription;
import be.openclinic.common.KeyValue;
import be.openclinic.common.Util;
import be.mxs.common.util.db.MedwanQuery;
import java.util.*;
import java.text.SimpleDateFormat;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

public class AdministrationSchema {
    private Date date;
    private String personuid;
    private Vector prescriptionSchemas=new Vector();

    public class AdministrationSchemaLine{
        private Prescription prescription;
        private Vector timeQuantities=new Vector();
        private Hashtable timeAdministrations=new Hashtable();

        public Prescription getPrescription() {
            return prescription;
        }
        
        public void setPrescription(Prescription prescription) {
            this.prescription = prescription;
        }

        public Hashtable getTimeAdministrations() {
            return timeAdministrations;
        }

        public Vector getTimeQuantities() {
            return timeQuantities;
        }

        public void setTimeQuantities(Vector timeQuantities) {
            this.timeQuantities = timeQuantities;
        }

        public void setTimeAdministrations(Hashtable timeAdministrations) {
            this.timeAdministrations = timeAdministrations;
        }

        public AdministrationSchemaLine(Prescription prescription) {
            this.prescription = prescription;
        }

        public String getTimeAdministration(String datetime){
            String quantity = (String)timeAdministrations.get(datetime);
            if(quantity!=null){
                return quantity;
            }
            else {
                return "";
            }
        }
    }


    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getPersonuid() {
        return personuid;
    }

    public void setPersonuid(String personuid) {
        this.personuid = personuid;
    }

    public Vector getPrescriptionSchemas() {
        return prescriptionSchemas;
    }

    public void setPrescriptionSchemas(Vector prescriptionSchemas) {
        this.prescriptionSchemas = prescriptionSchemas;
    }

    public AdministrationSchema(Date date, String personuid) {
        this.date = date;
        this.personuid = personuid;
        SortedMap schemaTimes = new TreeMap();
        Vector prescriptions= Prescription.find(personuid,"","",new SimpleDateFormat("dd/MM/yyyy").format(new Date(date.getTime()+24*3600*1000)),new SimpleDateFormat("dd/MM/yyyy").format(date),"","","");
        //We inventariseren eerst alle noodzakelijke tijdstippen
        for (int n=0;n<prescriptions.size();n++){
            Prescription prescription= (Prescription)prescriptions.elementAt(n);
            PrescriptionSchema prescriptionSchema = PrescriptionSchema.getPrescriptionSchema(prescription.getUid());
            Vector timequantities = prescriptionSchema.getTimequantities();
            for(int i=0;i<timequantities.size();i++){
                KeyValue keyValue = (KeyValue)timequantities.elementAt(i);
                schemaTimes.put(new Integer(keyValue.getKey()),"");
            }
        }
        //Voor elk van de voorschriften gaan we nu de eenheden invullen die bij het betreffende uur horen
        for (int n=0;n<prescriptions.size();n++){
            Prescription prescription= (Prescription)prescriptions.elementAt(n);
            PrescriptionSchema prescriptionSchema = PrescriptionSchema.getPrescriptionSchema(prescription.getUid());
            AdministrationSchemaLine administrationSchemaLine = new AdministrationSchemaLine(prescription);
            Iterator iterator = schemaTimes.keySet().iterator();
            while (iterator.hasNext()){
                Integer time = (Integer)iterator.next();
                administrationSchemaLine.getTimeQuantities().add(new KeyValue(time.toString(),prescriptionSchema.getQuantity(time.toString())+""));
            }
            prescriptionSchemas.add(administrationSchemaLine);
        }
    }

    public AdministrationSchema(Date dateBegin, Date dateEnd, String personuid) {
        this.date = dateBegin;
        this.personuid = personuid;
        SortedMap schemaTimes = new TreeMap();
        Vector prescriptions= Prescription.find(personuid,"","",new SimpleDateFormat("dd/MM/yyyy").format(dateBegin),new SimpleDateFormat("dd/MM/yyyy").format(dateEnd),"","","");
        //We inventariseren eerst alle noodzakelijke tijdstippen
        for (int n=0;n<prescriptions.size();n++){
            Prescription prescription= (Prescription)prescriptions.elementAt(n);
            PrescriptionSchema prescriptionSchema = PrescriptionSchema.getPrescriptionSchema(prescription.getUid());
            Vector timequantities = prescriptionSchema.getTimequantities();
            for(int i=0;i<timequantities.size();i++){
                KeyValue keyValue = (KeyValue)timequantities.elementAt(i);
                schemaTimes.put(new Integer(keyValue.getKey()),"");
            }
        }
        //Voor elk van de voorschriften gaan we nu de eenheden invullen die bij het betreffende uur horen
        for (int n=0;n<prescriptions.size();n++){
            Prescription prescription= (Prescription)prescriptions.elementAt(n);
            PrescriptionSchema prescriptionSchema = PrescriptionSchema.getPrescriptionSchema(prescription.getUid());
            AdministrationSchemaLine administrationSchemaLine = new AdministrationSchemaLine(prescription);
            Iterator iterator = schemaTimes.keySet().iterator();
            while (iterator.hasNext()){
                Integer time = (Integer)iterator.next();
                administrationSchemaLine.getTimeQuantities().add(new KeyValue(time.toString(),prescriptionSchema.getQuantity(time.toString())+""));
            }
            //Nu zoeken we voor betreffende geneesmiddelen de toedieningen op
            Connection dbConnection= MedwanQuery.getInstance().getOpenclinicConnection();
            try {
                PreparedStatement ps = dbConnection.prepareStatement("select * from OC_PRESCRIPTION_ADMINISTRATION where OC_PRESCR_SERVERID=? and OC_PRESCR_OBJECTID=?");
                ps.setInt(1, Util.getServerid(prescription.getUid()));
                ps.setInt(2, Util.getObjectid(prescription.getUid()));
                ResultSet rs = ps.executeQuery();
                while (rs.next()){
                    administrationSchemaLine.getTimeAdministrations().put(new SimpleDateFormat("yyyyMMdd").format(rs.getDate("OC_SCHEMA_DATE"))+"."+rs.getString("OC_SCHEMA_TIME"),rs.getString("OC_SCHEMA_QUANTITY"));
                }
                rs.close();
                ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            try {
				dbConnection.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            prescriptionSchemas.add(administrationSchemaLine);
        }
    }

    public static void storeAdministration(String prescriptionUid,Date date,int time,int quantity){
        Connection dbConnection= MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = dbConnection.prepareStatement("delete from OC_PRESCRIPTION_ADMINISTRATION where OC_PRESCR_SERVERID=? and OC_PRESCR_OBJECTID=? and OC_SCHEMA_DATE=? and OC_SCHEMA_TIME=?");
            ps.setInt(1,Util.getServerid(prescriptionUid));
            ps.setInt(2,Util.getObjectid(prescriptionUid));
            ps.setDate(3,new java.sql.Date(date.getTime()));
            ps.setInt(4,time);
            ps.execute();
            ps.close();
            if(quantity>0){
                ps = dbConnection.prepareStatement("insert into OC_PRESCRIPTION_ADMINISTRATION (OC_PRESCR_SERVERID,OC_PRESCR_OBJECTID,OC_SCHEMA_DATE,OC_SCHEMA_TIME,OC_SCHEMA_QUANTITY) values(?,?,?,?,?)");
                ps.setInt(1,Util.getServerid(prescriptionUid));
                ps.setInt(2,Util.getObjectid(prescriptionUid));
                ps.setDate(3,new java.sql.Date(date.getTime()));
                ps.setInt(4,time);
                ps.setInt(5,quantity);
                ps.execute();
                ps.close();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			dbConnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
}
