package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;
import org.w3c.dom.NamedNodeMap;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 22-mrt-2005
 * Time: 9:58:32
 * To change this template use Options | File Templates.
 */
public class Helper {

    static public String getAttribute(Node n, String sAttribute)  {
        if (n.hasChildNodes())	{
            NamedNodeMap atts = n.getAttributes();
            Node att;
            for (int i = 0; i < atts.getLength(); i++) {
                att = atts.item(i);
                if (att.getNodeName().toLowerCase().equals(sAttribute.toLowerCase())) {
                    return att.getNodeValue();
                }
            }
  	    }
        return "";
    }

    static public String getValue(Node n)  {
        if (n.hasChildNodes()) {
            Node child = n.getFirstChild();
            if (child.getNodeType() == Node.TEXT_NODE) {
                return child.getNodeValue();
            }
        }
        return "";
    }

    static public String repeat(String sRepeat, int nCount){
        String sResult = "";
        for (int n=0;n<nCount;n++){
    	    sResult += sRepeat;
        }
        return sResult;
    }

    static public String beginTag(String sTagName, int iIndent){
        sTagName = sTagName.substring(sTagName.lastIndexOf(".")+1);
        return repeat(" ",iIndent)+"<"+sTagName;
    }

    static public String endTag(String sTagName, int iIndent){
        sTagName = sTagName.substring(sTagName.lastIndexOf(".")+1);
        return repeat(" ",iIndent)+"</"+sTagName+">\r\n";
    }

    static public String writeTagAttribute(String sAttributeName, String sAttributeValue){
        if ((sAttributeValue!=null)&&(sAttributeValue.length()>0)){
  	        return " "+sAttributeName+"=\""+sAttributeValue+"\"";
        }
        return "";
    }

}
