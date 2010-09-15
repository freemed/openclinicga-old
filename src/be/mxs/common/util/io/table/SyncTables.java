package be.mxs.common.util.io.table;

import org.dom4j.Element;
import org.dom4j.DocumentHelper;
import org.dom4j.Document;
import java.util.Vector;
import java.util.Iterator;

public class SyncTables {
    private String sVersion;
    private Vector vTables;

    public SyncTables(){
        this.sVersion = "";
        this.vTables = new Vector();
    }

    public String getVersion() {
        return sVersion;
    }

    public void setVersion(String sVersion) {
        this.sVersion = sVersion;
    }

    public Vector getTables() {
        return vTables;
    }

    public void setTables(Vector vTables) {
        this.vTables = vTables;
    }

    public void parse (Element tables) {
        if (tables !=null){
            Element table;
            this.sVersion = tables.attributeValue("version");
            SyncTable syncTable;
            Iterator elements = tables.elementIterator("Table");
            while (elements.hasNext()){
                table = (Element)elements.next();
                syncTable = new SyncTable();
                syncTable.parse(table);
                this.vTables.add(syncTable);
            }
        }
        /*this.sVersion = Helper.getAttribute(n,"version");
        if (n.hasChildNodes()) {
            SyncTable table;
            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().equalsIgnoreCase("table")) {
                    table = new SyncTable();
                    table.parse(child);
                    this.vTables.add(table);
                }
            }
        }*/
    }

    /*public String toXML(int iIndent){
        String sReturn = Helper.beginTag("Tables",iIndent)
                +Helper.writeTagAttribute("Version",this.sVersion)+">\r\n";

        iIndent ++;

        for (int i=0; i<this.vTables.size();i++) {
            sReturn +=((SyncTable)(vTables.elementAt(i))).toXML(iIndent);
        }

        iIndent--;
        return sReturn+Helper.endTag("Tables",iIndent);
    }
    */

    public Document toXML(){
        Document document = DocumentHelper.createDocument();
        Element tables = document.addElement("Tables");
        tables.addAttribute("Version",this.sVersion);

        for (int i=0; i<this.vTables.size();i++) {
            ((SyncTable)(vTables.elementAt(i))).toXML(tables);
        }

        return document;
    }

    public boolean save(){
        boolean bSaved = true;
        try{
            for (int i=0; i<this.vTables.size();i++) {
                if (!((SyncTable)(vTables.elementAt(i))).save()){
                    return false;
                }
            }
        }
        catch (Exception e){
            e.printStackTrace();
            bSaved = false;
        }
        return bSaved;
    }
}
