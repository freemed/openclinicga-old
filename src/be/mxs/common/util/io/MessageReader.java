package be.mxs.common.util.io;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.io.BufferedReader;
import java.util.Vector;
import java.util.Date;
import java.util.Hashtable;
import java.util.StringTokenizer;
import java.sql.*;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 21-okt-2004
 * Time: 10:21:58
 * To change this template use Options | File Templates.
 */
public abstract class MessageReader {
    //ERROR_CONSTANTS
    public static final int OK = 0;
    public static final int UNDEFINED = 1;
    public static final int USER_UNKNOWN = 2;
    public static final int PATIENT_UNKNOWN = 3;
    public static final int TRANSACTION_DATE_NULL = 4;
    public static final int TO_BE_REMOVED = 5;
    //OPENWORK CONSTANTS
    public static final String ITEM_TYPE_PREFIX="be.mxs.common.model.vo.healthrecord.IConstants.EXT_";
    public static final String TRANSACTION_TYPE_PREFIX="be.mxs.common.model.vo.healthrecord.IConstants.";
    public static final String TRANSACTION_TYPE_LAB="TRANSACTION_TYPE_LAB_RESULT";
    public static final String TRANSACTION_TYPE_LETTER="TRANSACTION_TYPE_LETTER_RESULT";
    public static final String TRANSACTION_TYPE_IMAGING="TRANSACTION_TYPE_IMAGING_RESULT";
    public static final String ITEM_TYPE_REFNUM = "ITEM_TYPE_REFNUM";
    public static final String ITEM_TYPE_REFLAB = "ITEM_TYPE_REFLAB";
    public static final String ITEM_TYPE_FORMAT = "ITEM_TYPE_FORMAT";
    public static final String UNIT_TYPE = "UNIT_";
    //ITEM TYPE CONSTANTS
    public static final String TYPE_NUMERIC = "N";
    public static final String TYPE_COMMENT = "C";
    public static final String TYPE_TITLE = "T";
    public static final String TYPE_DAYS = "D";
    public static final String TYPE_HOURS = "H";
    public static final String TYPE_MINUTES = "M";
    public static final String TYPE_SECONDS = "S";
    //GENDER CONSTANTS
    public static final String MALE = "M";
    public static final String FEMALE = "F";
    public static final String UNKNOWN = "U";
    //PROTOCOL CONSTANTS
    public static final int PARTIAL = 0;
    public static final int COMPLETE = 1;
    public static final int ADDITIONAL = 2;
    //ABNORMALITY CONSTANTS
    public static final String LL="--";
    public static final String L="-";
    public static final String N="";
    public static final String H="+";
    public static final String HH="++";
    //MODIFIER CONSTANTS
    public static final String LESS_THAN="<";
    public static final String EQUALS="";
    public static final String MORE_THAN=">";
    //UPDATE CONSTANTS
    public static final int YES=1;
    public static final int NO=0;

    public String fileType=null;
    public String fileName=null;
    public Date fileDate=null;
    protected BufferedReader file=null;
    public  Vector documents = null;
    public  Lab lab=null;
    public  User user=null;
    public String lastline="";
    private Hashtable hLabels = new Hashtable();
    protected String ITEM_TYPE = "";

    public class Document{
        public Patient patient = new Patient();
        public Transaction transaction = new Transaction();
        public int status =-1;
        public int newdata =NO;

        public int store(){
            int result=OK;
            if (user.userid==-1){
               result=USER_UNKNOWN;
            }
            else if (patient.personid==-1){
               result=PATIENT_UNKNOWN;
            }
            else if (transaction.requestdate==null){
               result=TRANSACTION_DATE_NULL;
            }
            else {
                Date oldRefdate=null;
                int transactionId=-1;
                int serverId=MedwanQuery.getInstance().getConfigInt("serverId");
                int versionServerId=serverId;
                int version=0;
                int healthRecordId;
                Connection occupConnection = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps;
                ResultSet rs;
                //Find previous results
                try {
                    //Verify the existence of a Healthrecord
                    ps = occupConnection.prepareStatement("SELECT healthRecordId from Healthrecord where (dateEnd is null or dateEnd>?) and serverid=? and personId=?");
                    ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()));
                    ps.setInt(2,serverId);
                    ps.setInt(3,patient.personid);
                    rs = ps.executeQuery();
                    if(rs.next())
                    {
                        healthRecordId = rs.getInt("healthRecordId");
                        rs.close();
                        ps.close();
                    } else
                    {
                        healthRecordId = MedwanQuery.getInstance().getOpenclinicCounter("HealthRecordID");
                        rs.close();
                        ps.close();

                        ps = occupConnection.prepareStatement("insert into Healthrecord(healthRecordId,dateBegin,dateEnd,personId,serverid,version,versionserverid) values(?,?,null,?,?,1,?)");
                        ps.setInt(1,healthRecordId);
                        ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
                        ps.setInt(3,patient.personid);
                        ps.setInt(4,serverId);
                        ps.setInt(5,serverId);
                        ps.execute();
                        ps.close();
                    }
                    ps = occupConnection.prepareStatement("select a.updatetime,a.healthRecordId,a.transactionId,a.serverid,a.version,a.versionserverid,a.ts from Transactions a,Items b where a.transactionId=b.transactionId and a.serverid=b.serverid and b.type=? and b."+MedwanQuery.getInstance().getConfigString("valueColumn")+" =? and a.healthRecordId=?");
                    ps.setString(1,ITEM_TYPE_PREFIX+ITEM_TYPE+ITEM_TYPE_REFNUM);
                    ps.setString(2,transaction.refnum);
                    ps.setInt(3,healthRecordId);
                    rs = ps.executeQuery();
                    if (rs.next()){
                        oldRefdate= rs.getDate("updatetime");
                        transactionId = rs.getInt("transactionId");
                        serverId = rs.getInt("serverid");
                        version = rs.getInt("version");
                        versionServerId = rs.getInt("versionserverid");
                    }
                    rs.close();
                    ps.close();
                    //We do not want to treat older results than those in the database
                    if (oldRefdate!=null && !oldRefdate.after(fileDate)){
                        if (transaction.protocolcode!=ADDITIONAL){
                            //Remove previous results
                            ps = occupConnection.prepareStatement("update Transactions set ts=?,version=version+1 where transactionId=? and serverid=?");
                            ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()));
                            ps.setInt(2,transactionId);
                            ps.setInt(3,serverId);
                            ps.execute();
                            ps.close();
                            ps = occupConnection.prepareStatement("delete from Items where transactionId=? and serverid=?");
                            ps.setInt(1,transactionId);
                            ps.setInt(2,serverId);
                            ps.execute();
                            ps.close();
                        }
                    }
                    if (oldRefdate==null || !oldRefdate.after(fileDate)){
                        newdata=YES;
                        if (transactionId==-1){
                            //Insert the transaction data
                            ps = occupConnection.prepareStatement("insert into Transactions(transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,version,versionserverid,ts) values(?,?,?,?,?,?,?,?,?,?,?)");
                            transactionId=MedwanQuery.getInstance().getOpenclinicCounter("TransactionID");
                            ps.setInt(1, transactionId);
                            ps.setDate(2, new java.sql.Date(transaction.requestdate.getTime()));
                            ps.setString(3, TRANSACTION_TYPE_PREFIX+fileType);
                            ps.setDate(4, new java.sql.Date(transaction.requestdate.getTime()));
                            ps.setInt(5, 1);
                            ps.setInt(6, healthRecordId);
                            ps.setInt(7, user.userid);
                            ps.setInt(8, serverId);
                            ps.setInt(9, version+1);
                            ps.setInt(10, versionServerId);
                            ps.setTimestamp(11, new java.sql.Timestamp(new java.util.Date().getTime()));
                            ps.execute();
                            ps.close();
                        }
                        //Insert the Items data
                        String valueColumn = MedwanQuery.getInstance().getConfigString("valueColumn");
                        String dateColumn = MedwanQuery.getInstance().getConfigString("dateColumn");
                        //First we need a numeric reference
                        ps = occupConnection.prepareStatement("insert into Items(itemId,type,"+valueColumn+","+dateColumn+",transactionId,serverid,version,versionserverid) values(?,?,?,?,?,?,?,?)");
                        ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("ItemID"));
                        ps.setString(2, ITEM_TYPE_PREFIX+ITEM_TYPE+ITEM_TYPE_REFNUM);
                        ps.setString(3, transaction.refnum);
                        ps.setDate(4, new java.sql.Date(transaction.requestdate.getTime()));
                        ps.setInt(5, transactionId);
                        ps.setInt(6, serverId);
                        ps.setInt(7, version+1);
                        ps.setInt(8, versionServerId);
                        ps.execute();
                        ps.close();
                        //We also want to know keep track of the sender
                        ps = occupConnection.prepareStatement("insert into Items(itemId,type,"+valueColumn+","+dateColumn+",transactionId,serverid,version,versionserverid) values(?,?,?,?,?,?,?,?)");
                        ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("ItemID"));
                        ps.setString(2, ITEM_TYPE_PREFIX+ITEM_TYPE+ITEM_TYPE_REFLAB);
                        String sLab=lab.name;
                        if (lab.address1.trim().length()>0) sLab+="<br/>"+lab.address1;
                        if (lab.address2.trim().length()>0) sLab+="<br/>"+lab.address2;
                        if (lab.address3.trim().length()>0) sLab+="<br/>"+lab.address3;
                        if (lab.RIZIV.trim().length()>0) sLab+="<br/>"+lab.RIZIV;
                        ps.setString(3, sLab);
                        ps.setDate(4, new java.sql.Date(transaction.requestdate.getTime()));
                        ps.setInt(5, transactionId);
                        ps.setInt(6, serverId);
                        ps.setInt(7, version+1);
                        ps.setInt(8, versionServerId);
                        ps.execute();
                        ps.close();
                        //We also want to know keep track of the format
                        ps = occupConnection.prepareStatement("insert into Items(itemId,type,"+valueColumn+","+dateColumn+",transactionId,serverid,version,versionserverid) values(?,?,?,?,?,?,?,?)");
                        ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("ItemID"));
                        ps.setString(2, ITEM_TYPE_PREFIX+ITEM_TYPE+ITEM_TYPE_FORMAT);
                        ps.setString(3, ITEM_TYPE);
                        ps.setDate(4, new java.sql.Date(transaction.requestdate.getTime()));
                        ps.setInt(5, transactionId);
                        ps.setInt(6, serverId);
                        ps.setInt(7, version+1);
                        ps.setInt(8, versionServerId);
                        ps.execute();
                        ps.close();

                        Item item;
                        String sVal;
                        for (int n=0;n<transaction.items.size();n++){
                            item = (Item)transaction.items.get(n);
                            ps = occupConnection.prepareStatement("insert into Items(itemId,type,"+valueColumn+","+dateColumn+",transactionId,serverid,version,versionserverid,priority) values(?,?,?,?,?,?,?,?,?)");
                            ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("ItemID"));
                            ps.setString(2, ITEM_TYPE_PREFIX+ITEM_TYPE+item.id);

                            if (item.type.equals("C")||item.type.equals("T")){
                                sVal=item.type+"|"+item.comment;
                            }
                            else {
                                sVal=item.type+"|"+item.modifier+"|"+item.result+"|"+item.unit+"|"+item.normal+"|"+item.time+"|"+item.comment;
                            }
                            if (sVal.length()>255){
                                sVal = sVal.substring(0,255);
                            }
                            ps.setString(3,sVal);
                            ps.setDate(4, new java.sql.Date(transaction.requestdate.getTime()));
                            ps.setInt(5, transactionId);
                            ps.setInt(6, serverId);
                            ps.setInt(7, version+1);
                            ps.setInt(8, versionServerId);
                            ps.setInt(9, n);
                            ps.execute();
                            ps.close();
                            //We also have to check the existence of the labels
                            //First check the id
                            String sSupportedLanguages = ScreenHelper.getConfigString("supportedLanguages","en,fr");
                            StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages,",");
                            String sLang;
                            while(tokenizer.hasMoreTokens()){
                                sLang = tokenizer.nextToken();
                                if (hLabels.get(ITEM_TYPE_PREFIX+ITEM_TYPE+item.id)==null && item.name.get(sLang.toUpperCase())!=null){
                                    ps = occupConnection.prepareStatement("insert into OC_LABELS (OC_LABEL_TYPE,OC_LABEL_ID,OC_LABEL_LANGUAGE,OC_LABEL_VALUE,OC_LABEL_SHOWLINK,OC_LABEL_UPDATETIME) values(?,?,?,?,1,?)");
                                    ps.setString(1,fileType);
                                    ps.setString(2,ITEM_TYPE_PREFIX+ITEM_TYPE+item.id);
                                    ps.setString(3,sLang);
                                    ps.setString(4,(String)item.name.get(sLang.toUpperCase()));
                                    ps.setTimestamp(5,new Timestamp(new java.util.Date().getTime()));
                                    ps.execute();
                                    ps.close();
                                    hLabels.put(ITEM_TYPE_PREFIX+ITEM_TYPE+item.id,"");
                                }
                                //Then check the unit
                                if (hLabels.get(ITEM_TYPE_PREFIX+ITEM_TYPE+UNIT_TYPE+item.unit)==null && item.unitname.get(sLang.toUpperCase())!=null){
                                    ps = occupConnection.prepareStatement("insert into OC_LABELS (OC_LABEL_TYPE,OC_LABEL_ID,OC_LABEL_LANGUAGE,OC_LABEL_VALUE,OC_LABEL_SHOWLINK,OC_LABEL_UPDATETIME) values(?,?,?,?,1,?)");
                                    ps.setString(1,fileType);
                                    ps.setString(2,ITEM_TYPE_PREFIX+ITEM_TYPE+UNIT_TYPE+item.unit);
                                    ps.setString(3,sLang);
                                    ps.setString(4,(String)item.unitname.get(sLang.toUpperCase()));
                                    ps.setTimestamp(5,new Timestamp(new java.util.Date().getTime()));
                                    ps.execute();
                                    ps.close();
                                    hLabels.put(ITEM_TYPE_PREFIX+ITEM_TYPE+UNIT_TYPE+item.unit,"");
                                }
                            }
                            /*
                            if (hLabels.get(ITEM_TYPE_PREFIX+ITEM_TYPE+item.id)==null && (String)item.name.get("NL")!=null){
                                ps = MedwanQuery.getInstance().getAdminConnection().prepareStatement("insert into Labels(labeltype,labelid,labelnl,labelfr,labelen,doNotShowLink,updatetime) values(?,?,?,?,?,1,?)");
                                ps.setString(1,fileType);
                                ps.setString(2,ITEM_TYPE_PREFIX+ITEM_TYPE+item.id);
                                ps.setString(3,(String)item.name.get("NL"));
                                ps.setString(4,(String)item.name.get("FR"));
                                ps.setString(5,(String)item.name.get("EN"));
                                ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime()));
                                ps.execute();
                                ps.close();
                                hLabels.put(ITEM_TYPE_PREFIX+ITEM_TYPE+item.id,"");
                            }
                            //Then check the unit
                            if (hLabels.get(ITEM_TYPE_PREFIX+ITEM_TYPE+UNIT_TYPE+item.unit)==null && (String)item.unitname.get("NL")!=null){
                                ps = MedwanQuery.getInstance().getAdminConnection().prepareStatement("insert into Labels(labeltype,labelid,labelnl,labelfr,labelen,doNotShowLink,updatetime) values(?,?,?,?,?,1,?)");
                                ps.setString(1,fileType);
                                ps.setString(2,ITEM_TYPE_PREFIX+ITEM_TYPE+UNIT_TYPE+item.unit);
                                ps.setString(3,(String)item.unitname.get("NL"));
                                ps.setString(4,(String)item.unitname.get("FR"));
                                ps.setString(5,(String)item.unitname.get("EN"));
                                ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime()));
                                ps.execute();
                                ps.close();
                                hLabels.put(ITEM_TYPE_PREFIX+ITEM_TYPE+UNIT_TYPE+item.unit,"");
                            }
                            */
                        }
                    }
                }
                catch (Exception e){
                    e.printStackTrace();
                }
                try {
					occupConnection.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
            return result;
        }
    }

    public class Lab{
        public String id="";
        public String name="";
        public String address1="";
        public String address2="";
        public String address3="";
        public String telephone="";
        public String fax="";
        public String RIZIV="";
    }

    public class User{
        public int userid=-1;
        public String RIZIV="";
        public String lastname="";
        public String firstname="";
        public int update = NO;
        public String email="";
        public String language="";

        public void update() {
            if (this.update==YES && this.userid!=-1){
                Connection occupConnection = MedwanQuery.getInstance().getAdminConnection();
                //Find previous results
                try {
                    String sQuery = " INSERT INTO AdminExtends (personid,extendid,extendtype,labelid,extendvalue,updatetime)" +
                                    " VALUES(?,?,?,?,?,?)";
                    //String sQuery="insert into AlternateID(personid,alternateid) select personid,'"+this.RIZIV+"' from Users where userid=?";
                    PreparedStatement ps = occupConnection.prepareStatement(sQuery);
                    ps.setInt(1,this.userid);
                    ps.setNull(2,java.sql.Types.INTEGER);
                    ps.setString(3,"RIZIV");
                    ps.setString(4,"alternateid");
                    ps.setString(5,this.RIZIV);
                    ps.setTimestamp(6, ScreenHelper.getSQLTime());
                    if(Debug.enabled) Debug.println(sQuery);
                    ps.execute();
                    ps.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
                try {
					occupConnection.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
        }
    }

    public class Patient{
        public int personid=-1;
        public String id="";
        public String natreg="";
        public String lastname="";
        public String firstname="";
        public Date dateofbirth=null;
        public String gender="";
        public String address="";
        public String zipcode="";
        public String city="";
        public int update = NO;
        public Vector alternatePatients=new Vector();
    }

    public class Transaction{
        public Date requestdate=null;
        public String refnum="";
        public int protocolcode;
        public Vector items=new Vector();
        public String type="";
    }

    public class Item{
        public String id="";
        public String type="";
        public String modifier="";
        public String result="";
        public String unit="";
        public String normal="";
        public String comment="";
        public String time;
        public Hashtable name=new Hashtable();
        public Hashtable unitname=new Hashtable();
    }

    public MessageReader(){

    }

    public MessageReader(String fileName,String sFileType) throws java.io.IOException,java.sql.SQLException {
        PreparedStatement ps;
        ResultSet rs;

        this.fileName=fileName;
        this.fileType=sFileType;
        file = null;
        lab = new Lab();
        user = new User();
        documents = new Vector();
        String sQuery="select * from OC_LABELS where OC_LABEL_TYPE like '"+fileType+"%'";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        ps = oc_conn.prepareStatement(sQuery);

        //Statement st = MedwanQuery.getInstance().getAdminStatement();
        if(Debug.enabled) Debug.println(sQuery);
        //ResultSet rs = st.executeQuery(sQuery);
        rs = ps.executeQuery();
        while (rs.next()){
            if(Debug.enabled) Debug.println(rs.getString("OC_LABEL_ID"));
            hLabels.put(rs.getString("OC_LABEL_ID"),"1");
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }

    protected String readLine() throws java.io.IOException{
        lastline=file.readLine();
        return lastline;
    }

    public String readField(int chars){
        if (chars>lastline.length()){
            chars = lastline.length();
        }
        String field = lastline.substring(0,chars);
        lastline = lastline.substring(chars);
        return field.trim();
    }

    public String readField(String separator){
        int pos = lastline.indexOf(separator);
        String field;
        if (pos>-1){
            field = lastline.substring(0,pos);
            lastline = lastline.substring(pos+1);
        }
        else {
            field = lastline;
            lastline = "";
        }
        return field.trim();
    }

    protected String readField(){
        String field = lastline;
        lastline = "";
        return field.trim();
    }

    public Vector getDocuments(){
        return documents;
    }

    abstract int process() throws java.io.IOException,java.text.ParseException;

    public int identify(){
        int unidentifiedPersons=0;
        try{
            Connection con = MedwanQuery.getInstance().getAdminConnection();
            Patient patient;
            PreparedStatement st;
            ResultSet rs;
            Patient alternatePatient;

            for (int n=0;n<documents.size();n++){
                patient = ((Document)documents.get(n)).patient;
                if (patient.personid==-1){
                    String searchName=cleanString(patient.lastname.toUpperCase())+","+cleanString(patient.firstname.toUpperCase());
                    if (searchName.length()>2){
                        st = con.prepareStatement("select personid,lastname,firstname,dateofbirth,gender from Admin where searchname like ?+'%' and dateofbirth=? and gender like ?+'%'");
                        st.setString(1,searchName);
                        st.setDate(2,new java.sql.Date(patient.dateofbirth.getTime()));
                        st.setString(3,patient.gender);
                        rs = st.executeQuery();
                        if (rs.next()){
                            if (rs.isLast()){
                                patient.personid = rs.getInt("personid");
                            }
                            else {
                                alternatePatient = new Patient();
                                alternatePatient.personid=rs.getInt("personid");
                                alternatePatient.lastname=rs.getString("lastname");
                                alternatePatient.firstname=rs.getString("firstname");
                                alternatePatient.dateofbirth=rs.getDate("dateofbirth");
                                alternatePatient.gender=rs.getString("gender");
                                patient.alternatePatients.add(alternatePatient);
                                while (rs.next()){
                                    alternatePatient = new Patient();
                                    alternatePatient.personid=rs.getInt("personid");
                                    alternatePatient.lastname=rs.getString("lastname");
                                    alternatePatient.firstname=rs.getString("firstname");
                                    alternatePatient.dateofbirth=rs.getDate("dateofbirth");
                                    alternatePatient.gender=rs.getString("gender");
                                    patient.alternatePatients.add(alternatePatient);
                                }
                                unidentifiedPersons++;
                            }
                        }
                        else {
                            rs.close();
                            st.close();
                            st = con.prepareStatement("select personid,lastname,firstname,dateofbirth,gender from Admin where searchname like ?+'%' and dateofbirth=? and gender like ?+'%'");
                            st.setString(1,cleanString(patient.lastname.toUpperCase()));
                            st.setDate(2,new java.sql.Date(patient.dateofbirth.getTime()));
                            st.setString(3,patient.gender);
                            rs = st.executeQuery();
                            if (rs.next()){
                                if (rs.isLast()){
                                    patient.personid = rs.getInt("personid");
                                }
                                else {
                                    alternatePatient = new Patient();
                                    alternatePatient.personid=rs.getInt("personid");
                                    alternatePatient.lastname=rs.getString("lastname");
                                    alternatePatient.firstname=rs.getString("firstname");
                                    alternatePatient.dateofbirth=rs.getDate("dateofbirth");
                                    alternatePatient.gender=rs.getString("gender");
                                    patient.alternatePatients.add(alternatePatient);
                                    while (rs.next()){
                                        alternatePatient = new Patient();
                                        alternatePatient.personid=rs.getInt("personid");
                                        alternatePatient.lastname=rs.getString("lastname");
                                        alternatePatient.firstname=rs.getString("firstname");
                                        alternatePatient.dateofbirth=rs.getDate("dateofbirth");
                                        alternatePatient.gender=rs.getString("gender");
                                        patient.alternatePatients.add(alternatePatient);
                                    }
                                    unidentifiedPersons++;
                                }
                            }
                            else {
                                rs.close();
                                st.close();
                                st = con.prepareStatement("select personid,lastname,firstname,dateofbirth,gender from Admin where searchname like ?+'%'");
                                st.setString(1,cleanString(patient.lastname.toUpperCase())+","+cleanString(patient.firstname.toUpperCase()));
                                rs = st.executeQuery();
                                while (rs.next()){
                                    alternatePatient = new Patient();
                                    alternatePatient.personid=rs.getInt("personid");
                                    alternatePatient.lastname=rs.getString("lastname");
                                    alternatePatient.firstname=rs.getString("firstname");
                                    alternatePatient.dateofbirth=rs.getDate("dateofbirth");
                                    alternatePatient.gender=rs.getString("gender");
                                    patient.alternatePatients.add(alternatePatient);
                                }
                                unidentifiedPersons++;
                            }
                        }
                        if (rs!=null) rs.close();
                        st.close();
                    }
                    else {
                        unidentifiedPersons++;
                    }
                }
            }
            con.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
        return unidentifiedPersons;
    }

    public String cleanString(String sIn){
        String sOut="";
        char[] bIn=sIn.toCharArray();
        for(int n=0;n<bIn.length;n++){
            if ((bIn[n]>='A' && bIn[n]<='Z') || (bIn[n]>='a' && bIn[n]<='z')){
                sOut+=bIn[n];
            }
        }
        return sOut;
    }
}
