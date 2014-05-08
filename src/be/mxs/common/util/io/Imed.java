package be.mxs.common.util.io;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.dom4j.tree.DefaultDocument;
import org.dom4j.tree.DefaultElement;

import be.mxs.common.util.system.ScreenHelper;

import java.text.SimpleDateFormat;
import java.io.*;
import java.util.Iterator;
import net.admin.AdminPerson;
import net.admin.User;


/**
 * User: frank
 * Date: 1-dec-2005
 */
public class Imed {
    public static class Spirometry{
        public boolean initialized;
        public java.util.Date date=new java.util.Date();
        public String fev1="";
        public String fev1pct="";
        public String fvc="";
        public String fvcpct="";
        public String pef="";
        public String pefpct="";
        public String vc="";
        public String vcpct="";
        public String remark="";
    }

    public static void clearOut(String sDir){
        File dir = new File(sDir);
        if (dir.isDirectory()){
            File[] files = dir.listFiles();
            for (int n=0;n<files.length;n++){
                files[n].delete();
            }
        }
    }

    public static Spirometry readSpiro(String sDir,AdminPerson activePatient){
        Spirometry spirometry=new Spirometry();
        SAXReader reader = new SAXReader(false);
        reader.setValidation(false);
        reader.setIncludeExternalDTDDeclarations(false);
        reader.setIncludeInternalDTDDeclarations(false);
        try {
            File dir = new File(sDir);
            if (dir.isDirectory()){
                File[] files = dir.listFiles();
                Element root, doc, patient, id, transaction, item;
                Iterator ids, items;

                for (int n=0;n<files.length;n++){
                    File sFile = files[n];
                    BufferedReader r = new BufferedReader(new FileReader(sFile));
                    String s = r.readLine(),sOut="";
                    while (s!=null){
                        if (s.indexOf("DOCTYPE Message SYSTEM")==-1){
                            sOut+=s;
                        }
                        s=r.readLine();
                    }
                    r.close();
                    sFile.delete();
                    BufferedWriter writer=new BufferedWriter(new FileWriter(sFile));
                    writer.write(sOut);
                    writer.close();
                    Document document = reader.read(sFile);
                    root=document.getRootElement();
                    doc = root.element("Document");
                    patient = doc.element("Patient");

                    ids = patient.elementIterator("ID");
                    while (ids.hasNext()){
                        id = (Element)ids.next();
                        if (id.attributeValue("IDSystem").equalsIgnoreCase("OpenWork") && id.getText().equalsIgnoreCase(activePatient.personid)){
                            spirometry.initialized=true;
                            //OK, the data we find in the XML file comes from our active patient
                            transaction = doc.element("Transaction");
                            //First set the datetime
                            spirometry.date = ScreenHelper.fullDateFormatSS.parse(transaction.element("DateTime").element("DateTimeBegin").getText());

                            items = transaction.elementIterator("Item");
                            while (items.hasNext()){
                                item = (Element)items.next();
                                if (item.element("ItemType").element("ID").attributeValue("IDSystem").equalsIgnoreCase("Imed") && item.element("ItemType").element("ID").getText().equalsIgnoreCase("1.9")){
                                    spirometry.fvc = item.element("ItemContent").getText().replaceAll(",",".");
                                    spirometry.fvcpct = new Integer(new Float(new Float(spirometry.fvc).floatValue()*100/new Float(item.element("ItemContent").attributeValue("MinRef").replaceAll(",",".")).floatValue()).intValue()).toString();
                                }
                                else if (item.element("ItemType").element("ID").attributeValue("IDSystem").equalsIgnoreCase("Imed") && item.element("ItemType").element("ID").getText().equalsIgnoreCase("1.8")){
                                    spirometry.fev1 = item.element("ItemContent").getText().replaceAll(",",".");
                                    spirometry.fev1pct = new Integer(new Float(new Float(spirometry.fev1).floatValue()*100/new Float(item.element("ItemContent").attributeValue("MinRef").replaceAll(",",".")).floatValue()).intValue()).toString();
                                }
                                else if (item.element("ItemType").element("ID").attributeValue("IDSystem").equalsIgnoreCase("Imed") && item.element("ItemType").element("ID").getText().equalsIgnoreCase("1.26")){
                                    spirometry.pef = item.element("ItemContent").getText().replaceAll(",",".");
                                    spirometry.pefpct = new Integer(new Float(new Float(spirometry.pef).floatValue()*100/new Float(item.element("ItemContent").attributeValue("MinRef").replaceAll(",",".")).floatValue()).intValue()).toString();
                                }
                                else if (item.element("ItemType").element("ID").attributeValue("IDSystem").equalsIgnoreCase("Imed") && item.element("ItemType").element("ID").getText().equalsIgnoreCase("1.35")){
                                    spirometry.vc = item.element("ItemContent").getText().replaceAll(",",".");
                                    spirometry.vcpct = new Integer(new Float(new Float(spirometry.vc).floatValue()*100/new Float(item.element("ItemContent").attributeValue("MinRef").replaceAll(",",".")).floatValue()).intValue()).toString();
                                }
                            }
                        }
                    }
                    sFile.delete();
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return spirometry;
    }

    public static void writeIdent(String sFile,AdminPerson activePatient,User activeUser){
        Document document = new DefaultDocument();
        Element root = new DefaultElement("Message");
        root.addAttribute("version","1.0");
        //Add Message ID
        Element element = root.addElement("ID");
        element.addAttribute("Country","BE");
        element.addAttribute("IDSystem","Imed");
        element.setText("IDENT1");
        //Add Message Datetime
        element = root.addElement("DateTime");
        element = element.addElement("DateTimeBegin");
        element.setText(ScreenHelper.fullDateFormatSS.format(new java.util.Date()));
        //Add Message Sender
        Element sender = root.addElement("Sender");
        element = sender.addElement("ID");
        element.addAttribute("Country","BE");
        element.addAttribute("IDSystem","OpenWork");
        element.setText(activeUser.userid);
        Element name = sender.addElement("Name");
        element = name.addElement("FirstName");
        element.setText(activeUser.person.firstname);
        element = name.addElement("LastName");
        element.setText(activeUser.person.lastname);
        //Add Message Addressee
        element = root.addElement("Addressee");
        element = element.addElement("ID");
        element.addAttribute("Country","BE");
        element.addAttribute("IDSystem","Winspiro");
        element.setText("Application");
        //Add Document
        Element doc = root.addElement("Document");
        element = doc.addElement("ID");
        element.addAttribute("Country","BE");
        element.addAttribute("IDSystem","Imed");
        element.setText("IDENT1");
        Element patient = doc.addElement("Patient");
        element = patient.addElement("ID");
        element.addAttribute("Country","BE");
        element.addAttribute("IDSystem","OpenWork");
        element.setText(activePatient.personid);
        name = patient.addElement("Name");
        element = name.addElement("FirstName");
        element.setText(activePatient.firstname);
        element = name.addElement("LastName");
        element.setText(activePatient.lastname);
        element = patient.addElement("DateOfBirth");
        element.setText(activePatient.dateOfBirth);
        element = patient.addElement("Sex");
        element.setText(activePatient.gender.toUpperCase());
        Element address = patient.addElement("Address");
        element = address.addElement("Street");
        element.setText(activePatient.getActivePrivate().address);
        element = address.addElement("Zipcode");
        element.setText(activePatient.getActivePrivate().zipcode);
        element = address.addElement("City");
        element.setText(activePatient.getActivePrivate().city);
        element = patient.addElement("Telephone");
        element.setText(activePatient.getActivePrivate().telephone);
        element = patient.addElement("Fax");
        element.setText(activePatient.getActivePrivate().fax);
        element = patient.addElement("Email");
        element.setText(activePatient.getActivePrivate().email);


        document.setRootElement(root);
        try {
            BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(sFile));
            bufferedWriter.write(document.asXML());
            bufferedWriter.flush();
            bufferedWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
