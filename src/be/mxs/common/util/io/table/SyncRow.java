package be.mxs.common.util.io.table;

import org.dom4j.Element;
import java.util.Vector;
import java.util.Iterator;

public class SyncRow {
    private Vector vData;

    public Vector getData() {
        return vData;
    }

    public void setData(Vector vData) {
        this.vData = vData;
    }

    public SyncRow(){
        this.vData = new Vector();
    }

    public void parse (Element row) {
        if (row !=null){
            Element element;
            Iterator elements = row.elementIterator("RowData");
            while (elements.hasNext()){
                element = (Element)elements.next();
                this.vData.add(element.getStringValue());
            }
        }
        /*if (n.hasChildNodes()) {
            String sData;
            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().equalsIgnoreCase("data")) {
                    sData = Helper.getValue(child);
                    this.vData.add(sData);
                }
            }
        }*/
    }

/*    public String toXML(int iIndent){
        String sReturn = Helper.beginTag("Row",iIndent)+">\r\n";

        iIndent ++;

        for (int i=0; i<this.vData.size();i++) {
            sReturn += Helper.beginTag("Data",iIndent)+">"+((String)(this.vData.elementAt(i)))+"</Data>\r\n";
        }

        iIndent--;
        return sReturn+Helper.endTag("Row",iIndent);
    }*/
    public void toXML(Element parent) {
        Element row = parent.addElement("Row");

        for (int i=0; i<this.vData.size();i++) {
            row.addElement("RowData")
                .addText(convertCharToHTMLCode((String)(this.vData.elementAt(i))));
        }
    }

    static public String convertCharToHTMLCode(String text){
        StringBuffer xmlText = new StringBuffer();
        char[] chars = text.toCharArray();
        for (int n=0;n<chars.length;n++){
            if (chars[n]>128){
                xmlText.append("&#"+(int)chars[n]+";");
            } else {
                xmlText.append(chars[n]);
            }
        }
        return xmlText.toString();
    }
}
