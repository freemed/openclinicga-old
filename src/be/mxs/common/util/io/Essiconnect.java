package be.mxs.common.util.io;

import net.admin.AdminPerson;
import net.admin.User;

import java.io.*;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.Iterator;
import java.util.Date;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.dom4j.tree.DefaultDocument;
import org.dom4j.tree.DefaultElement;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.IConstants;

public class Essiconnect {
    public static class Ergovision{
        public boolean initialized = false;
        public Date date;
        public String visionFarRight;
        public String visionFarLeft;
        public String visionFarBinocular;
        public String visionNearBinocular;
        public String detectAstigmatismRight;
        public String detectAstigmatismLeft;
        public String detectHypermetropiaRight;
        public String detectHypermetropiaLeft;
        public String detectDuochromeRight;
        public String detectDuochromeLeft;
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

    public static void writeIdent(String sFile,AdminPerson activePatient){
        Document document = new DefaultDocument();
        Element root = new DefaultElement("Patient");
        Element element = root.addElement("IDPatient");
        element.setText(activePatient.personid);
        element = root.addElement("Name");
        element.setText(activePatient.lastname);
        element = root.addElement("FirstName");
        element.setText(activePatient.firstname);
        element = root.addElement("DateOfBirth");
        try {
            element.setText(new SimpleDateFormat("yyyyMMdd").format(new SimpleDateFormat("dd/MM/yyyy").parse(activePatient.dateOfBirth)));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        element = root.addElement("Sex");
        element.setText(activePatient.gender.toUpperCase());
        element = root.addElement("Height");
        ItemVO height = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid),IConstants.ITEM_TYPE_BIOMETRY_HEIGHT);
        if (height!=null){
            element.setText(height.getValue());
        }
        element = root.addElement("Weight");
        ItemVO weight = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid),IConstants.ITEM_TYPE_BIOMETRY_WEIGHT);
        if (weight!=null){
            element.setText(weight.getValue());
        }

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

    public static Ergovision readErgovision(String sDir,AdminPerson activePatient){
        Ergovision ergovision=new Ergovision();
        SAXReader reader = new SAXReader(false);
        reader.setValidation(false);
        reader.setIncludeExternalDTDDeclarations(false);
        reader.setIncludeInternalDTDDeclarations(false);
        try {
            File dir = new File(sDir);
            if (dir.isDirectory()){
                File[] files = dir.listFiles();
                Element root, vision, patient, id, transaction, item;
                Iterator ids, items;

                for (int n=0;n<files.length;n++){
                    File sFile = files[n];
                    Debug.println("Reading Ergovision file "+sFile.getName());
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
                    patient = document.getRootElement();
                    //Check if this is the right patient
                    if (patient.elementText("IDPatient").equalsIgnoreCase(activePatient.personid)){
                        ergovision.initialized=true;
                        try{
                            ergovision.date=new SimpleDateFormat("yyyyMMddHHmmss").parse(patient.elementText("ExamDate"));
                        }
                        catch (Exception e1){}
                        vision = patient.element("Vision");
                        ergovision.visionFarRight=vision.elementText("VisionFarRight");
                        ergovision.visionFarLeft=vision.elementText("VisionFarLeft");
                        ergovision.visionFarBinocular=vision.elementText("VisionFarBinocular");
                        ergovision.visionNearBinocular=vision.elementText("VisionNearBinocular");
                        ergovision.detectAstigmatismRight=vision.elementText("DetectAstigmatismRight");
                        ergovision.detectAstigmatismLeft=vision.elementText("DetectAstigmatismLeft");
                        ergovision.detectHypermetropiaRight=vision.elementText("DetectHypermetropiaRight");
                        ergovision.detectHypermetropiaLeft=vision.elementText("DetectHypermetropiaLeft");
                        ergovision.detectDuochromeRight=vision.elementText("DetectDuochromeRight");
                        ergovision.detectDuochromeLeft=vision.elementText("DetectDuochromeLeft");
                    }
                    sFile.delete();
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return ergovision;
    }
}
