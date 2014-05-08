package be.mxs.common.util.io.table;

import org.dom4j.Element;
import java.util.Vector;
import java.util.Iterator;
import java.sql.*;
import java.text.SimpleDateFormat;
import be.mxs.common.util.io.table.SyncColumn;
import be.mxs.common.util.io.table.SyncRow;
import be.mxs.common.util.system.ScreenHelper;

public class SyncTable {
    private String sTableName;
    private String sTableDatabase;
    private Vector vColumns;
    private Vector vRows;

    public String getName() {
        return sTableName;
    }

    public void setName(String sTableName) {
        this.sTableName = sTableName;
    }

    public String getDatabase() {
        return sTableDatabase;
    }

    public void setDatabase(String sTableDatabase) {
        this.sTableDatabase = sTableDatabase;
    }

    public Vector getColumns() {
        return vColumns;
    }

    public void setColumns(Vector vColumns) {
        this.vColumns = vColumns;
    }

    public Vector getRows() {
        return vRows;
    }

    public void setRows(Vector vRows) {
        this.vRows = vRows;
    }

    public SyncTable (){
        this.sTableName = "";
        this.sTableDatabase = "";
        this.vColumns = new Vector();
        this.vRows = new Vector();
    }

    public void parse (Element table) {
        if (table != null){
            this.sTableName = table.attributeValue("name");
            this.sTableDatabase = table.attributeValue("database");
            SyncColumn syncColumn;
            Element element;
            Iterator elements = table.elementIterator("Column");
            while (elements.hasNext()){
                element = (Element)elements.next();
                syncColumn = new SyncColumn();
                syncColumn.parse(element);
                this.vColumns.add(syncColumn);
            }

            SyncRow syncRow;
            elements = table.elementIterator("Row");
            while (elements.hasNext()){
                element = (Element)elements.next();
                syncRow = new SyncRow();
                syncRow.parse(element);
                this.vRows.add(syncRow);
            }
        }
        /*this.sTableName = Helper.getAttribute(n,"name");
        this.sTableDatabase = Helper.getAttribute(n,"database");

        if (n.hasChildNodes()) {
            SyncColumn column;
            SyncRow row;
            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().equalsIgnoreCase("column")) {
                    column = new SyncColumn();
                    column.parse(child);
                    this.vColumns.add(column);
                }
                else if (child.getNodeName().equalsIgnoreCase("row")) {
                    row = new SyncRow();
                    row.parse(child);
                    this.vRows.add(row);
                }
            }
        }*/
    }

    /*public String toXML(int iIndent){
        String sReturn = Helper.beginTag("Table",iIndent)
            +Helper.writeTagAttribute("name",this.sTableName)
            +Helper.writeTagAttribute("database",this.sTableDatabase)
            +">\r\n";

        iIndent ++;

        for (int i=0; i<this.vColumns.size();i++) {
            sReturn +=((SyncColumn)(this.vColumns.elementAt(i))).toXML(iIndent);
        }

        for (int i=0; i<this.vRows.size();i++) {
            sReturn +=((SyncRow)(this.vRows.elementAt(i))).toXML(iIndent);
        }
        iIndent--;
        return sReturn+Helper.endTag("Table",iIndent);
    }*/

    public void toXML(Element parent){
        Element table = parent.addElement("Table")
                    .addAttribute("name", this.sTableName)
                    .addAttribute("database", this.sTableDatabase);
        for (int i=0; i<this.vColumns.size();i++) {
            ((SyncColumn)(this.vColumns.elementAt(i))).toXML(table);
        }

        for (int i=0; i<this.vRows.size();i++) {
            ((SyncRow)(this.vRows.elementAt(i))).toXML(table);
        }
    }

     public boolean save(){
        boolean bSaved = true;
        try{
            if (ScreenHelper.checkString(this.sTableDatabase).length()>0){
                Connection connection = null;
                PreparedStatement ps = null;
                String sInsertColumns = "", sInsertValues = "", sTestWhere = "", sUpdateSet = "", sIds = "", sData;
                SyncColumn column;
                SyncRow row;
                boolean bUpdate = false;
                int i,y;
                ResultSet rs;

                for (i=0; i<this.vColumns.size();i++) {
                    column = (SyncColumn)(this.vColumns.elementAt(i));
                    sInsertColumns += column.getName()+",";
                    sInsertValues += "?,";
                    sUpdateSet += " "+column.getName()+" = ?,";
                    if (ScreenHelper.checkString(column.getId()).equals("1")){
                        sTestWhere += " "+column.getName()+" = ? AND ";
                        sIds += i+",";
                    }
                }
                String[] aIds = sIds.split(",");
                sTestWhere = sTestWhere.substring(0,sTestWhere.length()-4);
                sUpdateSet = sUpdateSet.substring(0,sUpdateSet.length()-1);
                sInsertColumns = sInsertColumns.substring(0,sInsertColumns.length()-1);
                sInsertValues = sInsertValues.substring(0,sInsertValues.length()-1);

                for (i=0; i<this.vRows.size();i++) {
                    row = (SyncRow)(this.vRows.elementAt(i));

                    if (sTestWhere.length()>0){
                        bUpdate = false;
                        ps = connection.prepareStatement("SELECT 1 FROM "+this.sTableName+" WHERE "+sTestWhere);
                        for (y=0;y<=aIds.length-1;y++){
                            sData = (String)row.getData().elementAt(Integer.parseInt(aIds[y]));
                            column = (SyncColumn)this.vColumns.elementAt(Integer.parseInt(aIds[y]));
                            setPs(ps,column,sData,y+1);
                        }

                        rs = ps.executeQuery();

                        if (rs.next()){
                            bUpdate = true;
                        }
                        rs.close();
                        ps.close();
                    }

                    if (bUpdate){
                        ps = connection.prepareStatement("UPDATE "+this.sTableName+" SET "+sUpdateSet+" WHERE "+sTestWhere);

                        for (y=0;y<row.getData().size();y++){
                            sData = (String)row.getData().elementAt(y);
                            column = (SyncColumn)this.vColumns.elementAt(y);
                            setPs(ps,column,sData,y+1);
                        }

                        for (y=0;y<=aIds.length-1;y++){
                            sData = (String)row.getData().elementAt(Integer.parseInt(aIds[y]));
                            column = (SyncColumn)this.vColumns.elementAt(Integer.parseInt(aIds[y]));
                            setPs(ps,column,sData,row.getData().size()+y+1);
                        }
                        ps.executeUpdate();
                        ps.close();
                    }
                    else {
                        ps = connection.prepareStatement("INSERT INTO "+this.sTableName+"("+sInsertColumns+") VALUES ("+sInsertValues+")");
                        for (y=0;y<row.getData().size();y++){
                            sData = (String)row.getData().elementAt(y);
                            column = (SyncColumn)this.vColumns.elementAt(y);
                            setPs(ps,column,sData,y+1);
                        }

                        ps.executeUpdate();
                        ps.close();
                    }
                }

                if (ps!=null){
                    ps.close();
                }
            }
        }
        catch (Exception e){
            e.printStackTrace();
            bSaved = false;
        }
        return bSaved;
    }

    private void setPs(PreparedStatement ps, SyncColumn column, String sData, int iIndex){
        try{
            if (column.getType().equals("char")){
                ps.setString(iIndex,sData);
            }
            else if (column.getType().equals("datetime")){
                try{
                    if ((sData == null)||(sData.trim().length()==0)) {
                        ps.setNull(iIndex, Types.TIMESTAMP);
                    }
                    else{
                        ps.setTimestamp(iIndex, new Timestamp(ScreenHelper.fullDateFormat.parse(sData).getTime()));
                    }
                }
                catch(Exception e){
                    e.printStackTrace();
                    ps.setNull(iIndex, Types.TIMESTAMP);
                }
            }
            else if (column.getType().equals("float")){
                try{
                    float f = Float.parseFloat(sData.replaceAll(",","."));
                    ps.setFloat(iIndex,f);
                }
                catch(Exception e){
                    e.printStackTrace();
                    ps.setNull(iIndex, Types.FLOAT);
                }
            }
            else if (column.getType().equals("int")){
                try{
                    ps.setInt(iIndex,Integer.parseInt(sData));
                }
                catch(Exception e){
                    e.printStackTrace();
                    ps.setNull(iIndex, Types.INTEGER);
                }
            }
            else if (column.getType().equals("varchar")){
                ps.setString(iIndex,sData);
            }
            else if (column.getType().equals("bit")){
                ps.setBoolean(iIndex,sData.equals("1"));
            }
            else if (column.getType().equals("bytes")){
                /*if (sData.length()>0){
                    ps.setBytes(iIndex,sData.getBytes());
                }
                else {
                    ps.setNull(iIndex,Types.LONGVARBINARY);
                }*/
                if (sData.length()>0){
                    int i = 0;
                    int digits = 0;
                    String substring = null;
                    byte[] byteArray = new byte[sData.length()/3];

                    while(i < sData.length()){
                        substring = ScreenHelper.checkString(sData.substring(i,i+3));
                        if(substring.length()==0) break;
                        digits = Integer.parseInt(substring)-128;
                        byteArray[i/3] = new Integer(digits).byteValue();
                        i+=3;
                    }
                    ps.setBytes(iIndex,byteArray);
                }
                else {
                    ps.setNull(iIndex,Types.LONGVARBINARY);
                }
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }
}
