package be.mxs.common.util.cardio;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.DocumentException;
import org.dom4j.io.SAXReader;

import java.net.URL;
import java.net.MalformedURLException;
import java.util.Iterator;

import be.mxs.common.util.db.MedwanQuery;

public class CardiovascularRiskBelgium {
    private int riskLevel;
    private Element riskClass;
    private int riskPosition;

    public CardiovascularRiskBelgium(String gender,int age,boolean smoker,double syst,double chol){
        calculateRiskLevel(gender,age,smoker,syst,chol);
    }

    public int getRiskLevel() {
        return riskLevel;
    }

    public Element getRiskClass() {
        return riskClass;
    }

    public int getRiskPosition() {
        return riskPosition;
    }

    private void calculateRiskLevel(String gender,int age,boolean smoker,double syst,double chol){
        //Eerst openen we het cardiovasculair risico-document
        try {
            SAXReader reader = new SAXReader(false);
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"cardiorisk_b.xml";
            Document document;
            document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            if (age>=68){
                age=68;
            }
            else if (age>=63){
                age=63;
            }
            else if (age>=58){
                age=58;
            }
            else if (age>=53){
                age=53;
            }
            else if (age>=45){
                age=45;
            }
            else{
                age=0;
            }
            String classGender="men";
            if (gender.equalsIgnoreCase("F")){
                classGender="women";
            }
            Element riskClass=null;
            Iterator riskClasses=root.elementIterator(classGender);
            while (riskClasses.hasNext()){
                riskClass = (Element)riskClasses.next();
                if (riskClass.attributeValue("smoker").equalsIgnoreCase("yes")==smoker){
                    if (Integer.parseInt(riskClass.attributeValue("age"))==age){
                        this.riskClass=riskClass;
                        break;
                    }
                }
            }
            if (riskClass!=null){
                Iterator riskLevels=riskClass.elementIterator("risk");
                int counter=0;
                Element riskLevel;
                while (riskLevels.hasNext()){
                    counter++;
                    riskLevel = (Element)riskLevels.next();
                    if (Integer.parseInt(riskLevel.attributeValue("chol"))<=chol && Integer.parseInt(riskLevel.attributeValue("syst"))<=syst){
                        this.riskLevel=Integer.parseInt(riskLevel.attributeValue("value"));
                        this.riskPosition=counter;
                    }
                }
            }
        } catch (DocumentException e) {
            e.printStackTrace();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
    }
}
