package be.mxs.common.util.system;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;

import java.io.*;
import org.dom4j.Element;
import org.dom4j.DocumentHelper;
import org.dom4j.io.XMLWriter;

/**
 * Created by IntelliJ IDEA.
 * User: Administrator
 * Date: 6-feb-2004
 * Time: 9:51:26
 * To change this template use Options | File Templates.
 */
public class Document {
    public static String toXML(Integer personId,TransactionVO transactionVO){
        StringBuffer sXML=new StringBuffer();
        sXML.append("<Document personId='"+personId+"'>");
        sXML.append(transactionVO.toXML());
        sXML.append("</Document>");
        return sXML.toString();
    }

    public static void exportTransaction(Integer personId,TransactionVO transactionVO){
        try {
            org.dom4j.Document document = DocumentHelper.createDocument();
            Element root = document.addElement("Document")
                .addAttribute("personId",personId.toString());
            transactionVO.createXML(root);
            FileWriter fileWriter = new FileWriter((MedwanQuery.getInstance().getConfigString("exportDirectory")+"/"+transactionVO.getTransactionId()+"."+transactionVO.getServerId()+"."+transactionVO.getVersion()+".xml").replaceAll("//","/"));
            XMLWriter xmlWriter = new XMLWriter(fileWriter);
            xmlWriter.setMaximumAllowedCharacter(127);
            xmlWriter.write(document);
            xmlWriter.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }
}
