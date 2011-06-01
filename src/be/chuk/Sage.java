package be.chuk;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Insurar;
import be.openclinic.finance.InsuranceCategory;
import be.openclinic.finance.Prestation;
import be.openclinic.common.ObjectReference;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.ResultSet;
import java.util.Date;
import java.util.Vector;
import java.text.SimpleDateFormat;

public class Sage {
    public static void synchronizeInsurars(){
        try {
    		System.out.println("Synchronising insurars");
            Date lastSync= new SimpleDateFormat("yyyyMMddHHmmss").parse("19000101000000");
            try{
                lastSync = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastSageInsurarSync","19000101000000"));
            }
            catch(Exception e4){

            }
            Date maxDate=lastSync;
            Connection oc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
            Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
            PreparedStatement ps = loc_conn.prepareStatement("select * from SageInsurars where cbModification>?");
            ps.setTimestamp(1,new Timestamp(lastSync.getTime()));
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String insuranceCode=rs.getString("CT_Num");
                String insuranceName=rs.getString("CT_Intitule");
                String insurarContact= ScreenHelper.checkString(rs.getString("CT_Adresse"))+"\n"+
                        ScreenHelper.checkString(rs.getString("CT_CodePostal"))+" "+ScreenHelper.checkString(rs.getString("CT_Ville"))+"\n"+
                        ScreenHelper.checkString(rs.getString("CT_Pays"));
                String insurarCatTariff=ScreenHelper.checkString(rs.getString("N_CatTarif"));

                //We zoeken nu deze verzekeraar op
                boolean bexists=false;
                System.out.println("Checking SAGE insurar "+insuranceCode);
                Vector insurars = Insurar.getInsurarsByName("%#"+insuranceCode);
                if(insurars.size()>0){
                    Insurar insurar=null;
                	for(int i=0;i<insurars.size();i++){
                        Insurar ins = (Insurar)insurars.elementAt(i);
                        if(ins.getName().endsWith("#"+insuranceCode)){
                        	insurar=ins;
                        }
                	}
                	if(insurar!=null){
                		System.out.println("Updating");
                		bexists=true;
                        //De verzekeraar bestaat reeds, we gaan de gegevens updaten
	                    insurar.setName(insuranceName+" #"+insuranceCode);
	                    insurar.setOfficialName(insuranceName);
	                    insurar.setContact(insurarContact.trim());
	                    insurar.setContactPerson((ScreenHelper.checkString(rs.getString("CT_Contact"))+" "+ScreenHelper.checkString(rs.getString("CT_Email"))).trim());
	                    insurar.setLanguage("FR");
	                    int reimbursement=rs.getInt("CT_Taux01");
	                    if(reimbursement==0){
	                        //Let's checkout if there is no default reimbursement to be found in the SageFamilyReimbursements
	                        String sQuery2="select count(*),FC_Remise from SageFamilyReimbursements where CT_Num=? group by FC_Remise order by count(*) desc";
	                        PreparedStatement ps2=oc_conn.prepareStatement(sQuery2);
	                        try{
	                            ps2.setString(1,insuranceCode);
	                            ResultSet rs2=ps2.executeQuery();
	                            if(rs2.next()){
	                                reimbursement=rs2.getInt("FC_Remise");
	                            }
	                            rs2.close();
	                            ps2.close();
	                        }
	                        catch (Exception e){
	                            e.printStackTrace();
	                        }
	                    }
	                    String patientShare=reimbursement+"";
	                    if (insurarCatTariff.equalsIgnoreCase("1")){
	                        insurarCatTariff="A";
	                        insurar.setInsuraceCategories(new Vector());
	                        insurar.addInsuranceCategory("1.-1","A","Default",MedwanQuery.getInstance().getConfigString("defaultInsuranceCategoryPatientShare"+insurarCatTariff.toUpperCase(),patientShare));
	                    }
	                    else if(insurarCatTariff.equalsIgnoreCase("2")){
	                        insurarCatTariff="B";
	                        insurar.setInsuraceCategories(new Vector());
	                        insurar.addInsuranceCategory("1.-1","B","Default",MedwanQuery.getInstance().getConfigString("defaultInsuranceCategoryPatientShare"+insurarCatTariff.toUpperCase(),patientShare));
	                    }
	                    else {
	                        insurarCatTariff="C";
	                        insurar.setInsuraceCategories(new Vector());
	                        insurar.addInsuranceCategory("1.-1","C","Default",MedwanQuery.getInstance().getConfigString("defaultInsuranceCategoryPatientShare"+insurarCatTariff.toUpperCase(),patientShare));
	                    }
	                    insurar.setType(insurarCatTariff);
	                    insurar.setUpdateDateTime(rs.getTimestamp("cbModification"));
	                    if(insurar.getUpdateDateTime().after(maxDate)){
	                        maxDate=insurar.getUpdateDateTime();
	                    }
	                    insurar.setUpdateUser("4");
	                    insurar.store();
                	}
                }
                if(!bexists) {
            		System.out.println("Creating");
                    //De verzekeraar bestaat nog niet, we gaan hem toevoegen
                    Insurar insurar = new Insurar();
                    insurar.setUid("1.-1");
                    insurar.setName(insuranceName+" #"+insuranceCode);
                    insurar.setCreateDateTime(new Date());
                    insurar.setOfficialName(insuranceName);
                    insurar.setContact(insurarContact.trim());
                    insurar.setContactPerson((ScreenHelper.checkString(rs.getString("CT_Contact"))+" "+ScreenHelper.checkString(rs.getString("CT_Email"))).trim());
                    insurar.setLanguage("FR");
                    int reimbursement=rs.getInt("CT_Taux01");
                    if(reimbursement==0){
                        //Let's checkout if there is no default reimbursement to be found in the SageFamilyReimbursements
                        String sQuery2="select count(*),FC_Remise from SageFamilyReimbursements where CT_Num=? group by FC_Remise order by count(*) desc";
                        PreparedStatement ps2=oc_conn.prepareStatement(sQuery2);
                        try{
                            ps2.setString(1,insuranceCode);
                            ResultSet rs2=ps2.executeQuery();
                            if(rs2.next()){
                                reimbursement=rs2.getInt("FC_Remise");
                            }
                            rs2.close();
                            ps2.close();
                        }
                        catch (Exception e){
                            e.printStackTrace();
                        }
                    }
                    String patientShare=reimbursement+"";
                    if (insurarCatTariff.equalsIgnoreCase("1")){
                        insurarCatTariff="A";
                        insurar.setInsuraceCategories(new Vector());
                        insurar.addInsuranceCategory("1.-1","A","Default",MedwanQuery.getInstance().getConfigString("defaultInsuranceCategoryPatientShare"+insurarCatTariff.toUpperCase(),patientShare));
                    }
                    else if(insurarCatTariff.equalsIgnoreCase("2")){
                        insurarCatTariff="B";
                        insurar.setInsuraceCategories(new Vector());
                        insurar.addInsuranceCategory("1.-1","B","Default",MedwanQuery.getInstance().getConfigString("defaultInsuranceCategoryPatientShare"+insurarCatTariff.toUpperCase(),patientShare));
                    }
                    else {
                        insurarCatTariff="C";
                        insurar.setInsuraceCategories(new Vector());
                        insurar.addInsuranceCategory("1.-1","C","Default",MedwanQuery.getInstance().getConfigString("defaultInsuranceCategoryPatientShare"+insurarCatTariff.toUpperCase(),patientShare));
                    }
                    insurar.setType(insurarCatTariff);
                    insurar.setUpdateDateTime(rs.getDate("cbModification"));
                    insurar.setUpdateUser("4");
                    insurar.store();
                }
            }
            rs.close();
            ps.close();
            oc_conn.close();
            loc_conn.close();
            MedwanQuery.getInstance().setConfigString("lastSageInsurarSync",new SimpleDateFormat("yyyyMMddHHmmss").format(maxDate));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void synchronizeReimbursements(){
        try {
    		System.out.println("Synchronizing reimbursements");
            Date lastSync= new SimpleDateFormat("yyyyMMddHHmmss").parse("19000101000000");
            try{
                lastSync = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastSageReimbursementSync","19000101000000"));
            }
            catch(Exception e4){

            }
            Date maxDate = lastSync;
            Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
            PreparedStatement ps = loc_conn.prepareStatement("select * from SageReimbursements where cbModification>?  order by ar_ref");
            ps.setTimestamp(1,new Timestamp(lastSync.getTime()));
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String prestationCode=ScreenHelper.checkString(rs.getString("AR_Ref")).replaceAll("'","");
        		System.out.println("Checking prestation code "+prestationCode);
        		int patientshare=rs.getInt("AC_Remise");
                String insurarCode=ScreenHelper.checkString(rs.getString("CT_Num"));
                Vector insurars = Insurar.getInsurarsByName("%#"+insurarCode);
                Prestation prestation=Prestation.getByCode(prestationCode);
                if(insurars.size()>0 && prestation!=null){
            		System.out.println("Updating");
                    Date d = rs.getTimestamp("cbModification");
                    if(d.after(maxDate)){
                        maxDate=d;
                    }
                    Insurar insurar = (Insurar)insurars.elementAt(0);
                    PreparedStatement ps2 =loc_conn.prepareStatement("delete from OC_PRESTATION_REIMBURSEMENTS where OC_PR_PRESTATIONUID=? and OC_PR_INSURARUID=?");
                    ps2.setString(1,prestation.getUid());
                    ps2.setString(2,insurar.getUid());
                    ps2.executeUpdate();
                    ps2.close();
                    ps2=loc_conn.prepareStatement("insert into OC_PRESTATION_REIMBURSEMENTS(" +
                            "OC_PR_PRESTATIONUID," +
                            "OC_PR_PRESTATIONCODE," +
                            "OC_PR_INSURARUID," +
                            "OC_PR_INSURARCODE," +
                            "OC_PR_PATIENTSHARE) values (?,?,?,?,?)");
                    ps2.setString(1,prestation.getUid());
                    ps2.setString(2,prestation.getCode());
                    ps2.setString(3,insurar.getUid());
                    ps2.setString(4,insurarCode);
                    ps2.setInt(5,patientshare);
                    ps2.executeUpdate();
                    ps2.close();
                }
            }
            rs.close();
            ps.close();
            ps=loc_conn.prepareStatement("delete from OC_PRESTATION_REIMBURSEMENTS where not exists (" +
                    "select * from SageReimbursements where AR_Ref COLLATE DATABASE_DEFAULT=OC_PR_PRESTATIONCODE COLLATE DATABASE_DEFAULT and " +
                    "CT_Num COLLATE DATABASE_DEFAULT=OC_PR_INSURARCODE COLLATE DATABASE_DEFAULT)");
            ps.executeUpdate();
            ps.close();
            MedwanQuery.getInstance().setConfigString("lastSageReimbursementSync",new SimpleDateFormat("yyyyMMddHHmmss").format(maxDate));
            loc_conn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void synchronizeFamilyReimbursements(){
        try {
    		System.out.println("Synchronizing familyreimbursements");
            Date lastSync= new SimpleDateFormat("yyyyMMddHHmmss").parse("19000101000000");
            try{
                lastSync = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastSageFamilyReimbursementSync","19000101000000"));
            }
            catch(Exception e4){

            }
            Date maxDate = lastSync;
            Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
            PreparedStatement ps = loc_conn.prepareStatement("select * from SageFamilyReimbursements where cbModification>?  order by FA_CodeFamille");
            ps.setTimestamp(1,new Timestamp(lastSync.getTime()));
            ResultSet rs = ps.executeQuery();
    		System.out.println("Launching query");
            while(rs.next()){
                String familyCode=ScreenHelper.checkString(rs.getString("FA_CodeFamille")).replaceAll("'","");
        		System.out.println("Checking family code "+familyCode);
                int patientshare=rs.getInt("FC_Remise");
                String insurarCode=ScreenHelper.checkString(rs.getString("CT_Num"));
                Vector insurars = Insurar.getInsurarsByName("%#"+insurarCode);
                if(insurars.size()>0){
            		System.out.println("Updating");
                    Date d = rs.getTimestamp("cbModification");
                    if(d.after(maxDate)){
                        maxDate=d;
                    }
                    Insurar insurar = (Insurar)insurars.elementAt(0);
                    PreparedStatement ps2 =loc_conn.prepareStatement("delete from OC_PRESTATIONFAMILY_REIMBURSEMENTS where OC_PR_PRESTATIONTYPE=? and OC_PR_INSURARUID=?");
                    ps2.setString(1,familyCode);
                    ps2.setString(2,insurar.getUid());
                    ps2.executeUpdate();
                    ps2.close();
                    ps2=loc_conn.prepareStatement("insert into OC_PRESTATIONFAMILY_REIMBURSEMENTS(" +
                            "OC_PR_PRESTATIONTYPE," +
                            "OC_PR_INSURARUID," +
                            "OC_PR_INSURARCODE," +
                            "OC_PR_PATIENTSHARE) values (?,?,?,?)");
                    ps2.setString(1,familyCode);
                    ps2.setString(2,insurar.getUid());
                    ps2.setString(3,insurarCode);
                    ps2.setInt(4,patientshare);
                    ps2.executeUpdate();
                    ps2.close();
                }
            }
            rs.close();
            ps.close();
    		System.out.println("Deleting removed reimbursements");
            ps=loc_conn.prepareStatement("delete from OC_PRESTATIONFAMILY_REIMBURSEMENTS where not exists (" +
                    "select * from SageFamilyReimbursements where FA_CodeFamille COLLATE DATABASE_DEFAULT=OC_PR_PRESTATIONTYPE COLLATE DATABASE_DEFAULT and " +
                    "CT_Num COLLATE DATABASE_DEFAULT=OC_PR_INSURARCODE COLLATE DATABASE_DEFAULT)");
            ps.executeUpdate();
            ps.close();
            MedwanQuery.getInstance().setConfigString("lastSageFamilyReimbursementSync",new SimpleDateFormat("yyyyMMddHHmmss").format(maxDate));
            loc_conn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
		System.out.println("End of synchronizing familyreimbursements");
    }

    public static void synchronizePrestations(){
        try{
    		System.out.println("Synchronising prestations");
            Date lastSync= new SimpleDateFormat("yyyyMMddHHmmss").parse("19000101000000");
            try{
                lastSync = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastSagePrestationSync","19000101000000"));
            }
            catch(Exception e4){

            }
            Date maxDate=lastSync;
            Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
            PreparedStatement ps = loc_conn.prepareStatement("select * from SagePrestations where cbModification>?  order by ar_ref");
            ps.setTimestamp(1,new Timestamp(lastSync.getTime()));
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String prestationCode=ScreenHelper.checkString(rs.getString("AR_Ref")).replaceAll("'","");
        		System.out.println("Checking prestationcode "+prestationCode);

                double prestationPrice=0;
                try{
                    prestationPrice=new Double(ScreenHelper.checkString(rs.getString("AR_PrixVen"))).intValue();
                }
                catch(Exception e2){

                }
                String prestationTypeName=ScreenHelper.checkString(rs.getString("FA_Intitule")).replaceAll("'","");
                String prestationCatTariff=ScreenHelper.checkString(rs.getString("AC_Categorie"));
                if (prestationCatTariff.equalsIgnoreCase("1")){
                    prestationCatTariff="A";
                }
                else if(prestationCatTariff.equalsIgnoreCase("2")){
                    prestationCatTariff="B";
                }
                else {
                    prestationCatTariff="C";
                }
                String prestationCategoryPrice=ScreenHelper.checkString(rs.getString("AC_PrixVen"));
                try{
                    prestationCategoryPrice=new Double(prestationCategoryPrice).intValue()+"";
                }
                catch(Exception e3){

                }
                Prestation prestation=Prestation.getByCode(prestationCode);
                if(prestation.getCode()!=null && prestation.getCode().equalsIgnoreCase(prestationCode)){
            		System.out.println("Updating");
                    //De prestatie bestaat reeds, we gaan ze updaten
                    prestation.setDescription(ScreenHelper.checkString(rs.getString("AR_Design")).replaceAll("'",""));
                    prestation.setPrice(prestationPrice);
                    prestation.setType(ScreenHelper.checkString(rs.getString("FA_CodeFamille")));
                    ObjectReference objectReference = new ObjectReference(ScreenHelper.checkString(rs.getString("FA_RacineRef")),"0");
                    prestation.setReferenceObject(objectReference);
                    if(MedwanQuery.getInstance().getLabel("prestation.type",prestation.getType(),"fr").equalsIgnoreCase(prestation.getType())){
                        MedwanQuery.getInstance().storeLabel("prestation.type",prestation.getType(),"fr",prestationTypeName,4);
                        MedwanQuery.getInstance().storeLabel("prestation.type",prestation.getType(),"en",prestationTypeName,4);
                        MedwanQuery.getInstance().storeLabel("prestation.type",prestation.getType(),"nl",prestationTypeName,4);
                    }
                    prestation.setUpdateDateTime(rs.getTimestamp("cbModification"));
                    if(prestation.getUpdateDateTime().after(maxDate)){
                        maxDate=prestation.getUpdateDateTime();
                    }
                    prestation.setUpdateUser("4");
                    prestation.setCategoryPrice(prestationCatTariff,prestationCategoryPrice);
                    prestation.store();
                }
                else {
            		System.out.println("Creating");
                    //De prestatie bestaat nog niet, toevoegen
                    prestation=new Prestation();
                    prestation.setCode(prestationCode);
                    prestation.setDescription(ScreenHelper.checkString(rs.getString("AR_Design")).replaceAll("'",""));
                    prestation.setPrice(prestationPrice);
                    ObjectReference objectReference = new ObjectReference(ScreenHelper.checkString(rs.getString("FA_RacineRef")),"0");
                    prestation.setReferenceObject(objectReference);
                    prestation.setType(ScreenHelper.checkString(rs.getString("FA_CodeFamille")));
                    if(MedwanQuery.getInstance().getLabel("prestation.type",prestation.getType(),"fr").equalsIgnoreCase(prestation.getType())){
                        MedwanQuery.getInstance().storeLabel("prestation.type",prestation.getType(),"fr",prestationTypeName,4);
                        MedwanQuery.getInstance().storeLabel("prestation.type",prestation.getType(),"en",prestationTypeName,4);
                        MedwanQuery.getInstance().storeLabel("prestation.type",prestation.getType(),"nl",prestationTypeName,4);
                    }
                    prestation.setUpdateDateTime(rs.getTimestamp("cbModification"));
                    if(prestation.getUpdateDateTime().after(maxDate)){
                        maxDate=prestation.getUpdateDateTime();
                    }
                    prestation.setUpdateUser("4");
                    prestation.setCategories(prestationCatTariff+"="+prestationCategoryPrice+";");
                    prestation.setReferenceObject(new ObjectReference());
                    prestation.store();
                }
            }
            rs.close();
            ps.close();
            loc_conn.close();
            MedwanQuery.getInstance().setConfigString("lastSagePrestationSync",new SimpleDateFormat("yyyyMMddHHmmss").format(maxDate));
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
}
