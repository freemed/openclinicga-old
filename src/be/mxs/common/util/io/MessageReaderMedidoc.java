package be.mxs.common.util.io;

import be.mxs.common.util.db.MedwanQuery;
import java.text.SimpleDateFormat;
import java.util.Hashtable;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.io.BufferedReader;
import java.io.FileReader;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 21-okt-2004
 * Time: 14:36:27
 * To change this template use Options | File Templates.
 */
public class MessageReaderMedidoc extends MessageReader{

    private Hashtable names = new Hashtable();
    private Hashtable units = new Hashtable();

    public MessageReaderMedidoc(String fileName,String fileType) throws java.io.IOException,java.sql.SQLException {
        new MessageReaderMedidoc(fileName);
        this.fileType=fileType;
    }

    public MessageReaderMedidoc(String fileName) throws java.io.IOException,java.sql.SQLException {
        super(fileName,TRANSACTION_TYPE_LAB);
        this.ITEM_TYPE="MEDIDOC_";
    }
    public MessageReaderMedidoc() throws java.io.IOException,java.sql.SQLException {
        super();
    }

    public int process() throws java.io.IOException,java.text.ParseException{
        Connection connection = MedwanQuery.getInstance().getOpenclinicConnection();
        //Load names
        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery("select * from MedidocKeywords");
            Hashtable nameList;
            while (rs.next()){
                nameList=new Hashtable();
                nameList.put("NL",rs.getString("m_namenl"));
                nameList.put("FR",rs.getString("m_namefr"));
                nameList.put("EN",rs.getString("m_nameen"));
                names.put(rs.getString("m_key"),nameList);
            }
            rs.close();
            //Load units
            rs = st.executeQuery("select * from MedidocUnits");
            while (rs.next()){
                nameList=new Hashtable();
                nameList.put("NL",rs.getString("m_namenl"));
                nameList.put("FR",rs.getString("m_namefr"));
                nameList.put("EN",rs.getString("m_nameen"));
                units.put(rs.getString("m_key"),nameList);
            }
            rs.close();
            st.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
        String sTmp;
        //Read laboratory data
        file=new BufferedReader(new FileReader(this.fileName));
        lab.id = readLine();
        lab.name = readLine();
        lab.address1 = readLine();
        lab.address2 = readLine();
        lab.telephone = readLine();
        lab.RIZIV = readLine();
        //Read disk data
        sTmp=readLine();
        try{
            fileDate=new SimpleDateFormat("yyyyMMdd").parse(sTmp);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        //Read addressed user data
        user.RIZIV = readLine();
        readLine();
        user.lastname = readField(24);
        user.firstname = readField(14);

        Document document;
        Item item;
        //Loop request blocks
        while (readLine().startsWith("#A")){
            document = new Document();
            documents.add(document);
            readField(2);
            //Read patient data
            document.patient.id = readField();
            readLine();
            document.patient.lastname = readField(24);
            document.patient.firstname = readField(16);
            try{
                document.patient.dateofbirth = new SimpleDateFormat("yyyyMMdd").parse(readLine());
            }
            catch (Exception e){
                document.patient.dateofbirth = new SimpleDateFormat("ddMMyyyy").parse("01011901");
            }
            document.patient.gender=readLine();
            if (document.patient.gender.equalsIgnoreCase("x")){
                document.patient.gender=FEMALE;
            }
            else if (document.patient.gender.equalsIgnoreCase("y")){
                document.patient.gender=MALE;
            }
            else {
                document.patient.gender=UNKNOWN;
            }
            //Read transaction data
            try{
                document.transaction.requestdate = new SimpleDateFormat("yyyyMMdd").parse(readLine());
            }
            catch (Exception e){
                e.printStackTrace();
            }
            document.transaction.refnum = readLine();
            sTmp = readLine();
            if (sTmp.equalsIgnoreCase("p")){
                document.transaction.protocolcode=PARTIAL;
            }
            else if (sTmp.equalsIgnoreCase("c")){
                document.transaction.protocolcode=COMPLETE;
            }
            else if (sTmp.equalsIgnoreCase("s")){
                document.transaction.protocolcode=ADDITIONAL;
            }
            else if (sTmp.equalsIgnoreCase("l")){
                document.transaction.protocolcode=ADDITIONAL;
            }
            if (!readLine().startsWith("#R")){
                document.patient.address=lastline.trim();
                if (!readLine().startsWith("#R")){
                    document.patient.zipcode=lastline.trim();
                    if (!readLine().startsWith("#R")){
                        document.patient.city=lastline.trim();
                        readLine();
                    }
                }
            }
            //Loop result blocks
            while (lastline.startsWith("#R")){
                item = new Item();
                document.transaction.items.add(item);
                if (lastline.startsWith("#Ra")||lastline.startsWith("#Rd")||lastline.startsWith("#Rh")||lastline.startsWith("#Rm")||lastline.startsWith("#Rs") ){
                    //numerical result block
                    if (lastline.startsWith("#Ra")){
                        item.type=TYPE_NUMERIC;
                    }else if (lastline.startsWith("#Rd")){
                        item.type=TYPE_DAYS;
                    }else if (lastline.startsWith("#Rh")){
                        item.type=TYPE_HOURS;
                    }else if (lastline.startsWith("#Rm")){
                        item.type=TYPE_MINUTES;
                    }else if (lastline.startsWith("#Rs")){
                        item.type=TYPE_SECONDS;
                    }
                    readLine();
                    item.id= readField("/");
                    item.name=(Hashtable)names.get(item.id);
                    if (item.name==null){
                        item.name=new Hashtable();
                        item.name.put("NL",item.id);
                        item.name.put("FR",item.id);
                        item.name.put("EN",item.id);
                    }
                    item.time=readField();
                    readLine();
                    item.modifier=readField(1);
                    if (item.modifier.equals("=")){
                        item.modifier=EQUALS;
                    }
                    item.result=readField();
                    item.unit=readLine();
                    item.unitname=(Hashtable)units.get(item.unit);
                    if (item.unitname==null){
                        item.unitname=new Hashtable();
                        item.unitname.put("NL",item.unit);
                        item.unitname.put("FR",item.unit);
                        item.unitname.put("EN",item.unit);
                    }
                    item.normal=readLine();
                    if (item.normal.toLowerCase().startsWith("ll") || item.normal.startsWith("1")){
                        item.normal=LL;
                    }
                    else if (item.normal.toLowerCase().startsWith("hh") || item.normal.startsWith("5")){
                        item.normal=HH;
                    }
                    else if (item.normal.toLowerCase().startsWith("l") || item.normal.startsWith("2")){
                        item.normal=L;
                    }
                    else if (item.normal.toLowerCase().startsWith("h") || item.normal.startsWith("4")){
                        item.normal=H;
                    }
                    else if (item.normal.toLowerCase().startsWith("n") || item.normal.startsWith("=") || item.normal.startsWith("3") || item.normal.length()==0){
                        item.normal=N;
                    }
                    else {
                        item.normal=N;
                    }
                    while (!readLine().startsWith("#R/")){
                        item.comment+=lastline+"\n";
                    }
                }
                else if (lastline.startsWith("#Rb")){
                    //comment result block
                    item.type=TYPE_COMMENT;
                    item.id=readLine();
                    item.name=(Hashtable)names.get(item.id);
                    if (item.name==null){
                        item.name=new Hashtable();
                        item.name.put("NL",item.id);
                        item.name.put("FR",item.id);
                        item.name.put("EN",item.id);
                    }
                    while (!readLine().startsWith("#R/")){
                        item.comment+=lastline+"\n";
                    }
                }
                else if (lastline.startsWith("#Rc")){
                    //title result block
                    item.type=TYPE_TITLE;
                    item.id=readLine();
                    item.name=(Hashtable)names.get(item.id);
                    if (item.name==null){
                        item.name=new Hashtable();
                        item.name.put("NL",item.id);
                        item.name.put("FR",item.id);
                        item.name.put("EN",item.id);
                    }
                    while (!readLine().startsWith("#R/")){
                        item.comment+=lastline+"\n";
                    }
                }
                readLine();
            }
            while (!lastline.equals("#A/")){
                readLine();
            }
        }
        names.clear();
        units.clear();
        file.close();
        file=null;
        try {
			connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return documents.size();
    }
}