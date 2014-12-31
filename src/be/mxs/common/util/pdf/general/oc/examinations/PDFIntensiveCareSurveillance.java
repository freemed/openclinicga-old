package be.mxs.common.util.pdf.general.oc.examinations;

import java.sql.Connection;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.Hashtable;
import java.util.Iterator;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

public class PDFIntensiveCareSurveillance extends PDFGeneralBasic {
	
	/*
	*   Onderstaande logica is als volgt : iedere USI heeft zijn eigen tabel, die worden naast
	*   elkaar geplaatst in een grotere tabel. De rijhoogte wordt expliciet ingesteld omdat
	*   die afhankelijk is van de hoeveelheid gegevens in de grootste cel van die rij.
	*   Waar een browser dit zelf achter de schermen regelt, moet je het hier zelf doen.
	*   Uiteindelijk bekom je een brede, maar ook een lange tabel; deze wordt niet automatisch
	*   geplitst zoals bij een browser; dat moet je ook weer zelf doen, omdat anders de pdf grote lege
	*   stukken kan bevatten aangezien voor grote elementen de eerst volgende grote ruimte wordt ingenomen,
	*   zodat kleinere ruimte erboven onbenut blijven. Daarom dus dat je best zelf grote element opsplitst in "onzichtbare"
	*   tabellen. Dat zijn meerdere tabellen die samen, visueel 1 geheel lijken.
	*/

    /// INNER CLASS : USI DataHolder //////////////////////////////////////////////////////////////
    private class USI_DataHolder implements Comparable {
        private int dataSetNr;
        private String date;
        private String time;
        private String updateuserid;
        private Hashtable data;

        // constructor
        public USI_DataHolder(int iDataSetNr){
            this.dataSetNr = iDataSetNr;
            this.data = new Hashtable();
        }

        //--- COMPARE TO --------------------------------------------------------------------------
        public int compareTo(Object usi_dataholder) throws ClassCastException {
            if(!(usi_dataholder instanceof USI_DataHolder)){
                throw new ClassCastException("USI_DataHolder object expected");
            }
            
            Calendar registered = ((USI_DataHolder)usi_dataholder).getRegisteredOn();
            if(this.getRegisteredOn().before(registered)){
                return 1;
            }
            else if(this.getRegisteredOn().after(registered)){
                return -1;
            }
            
            return 0;
        }

        //--- GET REGISTERED ON -------------------------------------------------------------------
        public Calendar getRegisteredOn(){
            Calendar calNow = Calendar.getInstance();
            
            try{
                String sDate = this.date.replaceAll("-","/")+" "+this.time;
                calNow.setTime(new java.sql.Date(ScreenHelper.fullDateFormat.parse(sDate).getTime()));
            }
            catch(ParseException e){
                e.printStackTrace();
            }
            
            return calNow;
        }

        //--- GET UPDATE USER ---------------------------------------------------------------------
        public String getUpdateUser(){
        	String sUserName = "";
        	
            if(checkString(this.updateuserid).length() > 0){
            	sUserName = ScreenHelper.getFullUserName(this.updateuserid);
            }

            return sUserName;
        }

        //--- VARIA -------------------------------------------------------------------------------
        public int getDataSetNr(){
            return this.dataSetNr;
        }
        
        public void setDate(String sDate){
            this.date = sDate;
        }

        public String getDate(){
            return this.date;
        }

        public String getTime(){
            return this.time;
        }

        public void setTime(String sTime){
            this.time = sTime;
        }

        public void setDataSetNr(int iDataSetNr){
            this.dataSetNr = iDataSetNr;
        }

        public void setUpdateUserId(String updateuserid){
            this.updateuserid = updateuserid;
        }

        public void addItem(String sKey,Object oValue){
            this.data.put(sKey,oValue);
        }

        public Object getItem(String sKey){
            return this.data.get(sKey);
        }
        
    }

    //--- GET USI DATAHOLDER FROM LIST ------------------------------------------------------------
    public USI_DataHolder getUSI_DataHolderFromList(int iDataSetNr, ArrayList data){
        USI_DataHolder tmpData;

        Iterator dataIter = data.iterator();
        while(dataIter.hasNext()){
            tmpData = (USI_DataHolder)dataIter.next();
            
            if(tmpData.getDataSetNr()==iDataSetNr){
                return tmpData;
            }
        }

        return null;
    }

    //--- ADD ITEM TO DATA LIST -------------------------------------------------------------------
    public void addItemToDataList(int iDataSetNr, ArrayList data, String sKey, Object oValue){
        USI_DataHolder tmpData;

        Iterator dataIter = data.iterator();
        while(dataIter.hasNext()){
            tmpData = (USI_DataHolder)dataIter.next();
            
            if(tmpData.getDataSetNr()==iDataSetNr){
                if(sKey.equals("DATE")){
                    tmpData.setDate((String)oValue);
                }
                else if(sKey.equals("TIME")){
                    tmpData.setTime((String)oValue);
                }
                else if(sKey.equals("UPDATEUSERID")){
                    tmpData.setUpdateUserId((String)oValue);
                }
                
                tmpData.addItem(sKey,oValue);
                
                break;
            }
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                Hashtable listing = getListing();            
                ArrayList usiDataHolders = new ArrayList();
                Hashtable showValues = new Hashtable();
                String sKey, sItemType, sItemValue, sInputNr;
                USI_DataHolder tmpDataHolder;
                
                Collection tranItems = transactionVO.getItems();
                Iterator itemIter = tranItems.iterator();
                ItemVO item;
        
                while(itemIter.hasNext()){
                    item = (ItemVO)itemIter.next();
                    sItemType = checkString(item.getType());
                    sItemValue = checkString(item.getValue());

                    if(!(sItemType.lastIndexOf("-")== -1)){
                        sInputNr = sItemType.substring(sItemType.lastIndexOf("-")+1,sItemType.length());

                        sKey = sItemType.substring("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_".length(),sItemType.lastIndexOf("-"));
                        if(sItemValue.length() > 0){
                            tmpDataHolder = getUSI_DataHolderFromList(Integer.parseInt(sInputNr),usiDataHolders);
                            if(tmpDataHolder==null){
                                usiDataHolders.add(new USI_DataHolder(Integer.parseInt(sInputNr)));
                            }
                            
                            addItemToDataList(Integer.parseInt(sInputNr),usiDataHolders,sKey,sItemValue);
                            showValues.put(sKey,Boolean.TRUE);
                        }
                    }
                }

                Collections.sort(usiDataHolders);
                
                // split table containing USIs horizontally in 4 virtual/invisible parts (to optimize paper-usage)
                double step = Math.ceil((double)listing.size()/4.0);

                displayUSIs((int)step*0,(int)step*1,usiDataHolders,showValues,listing);
                displayUSIs((int)step*1,(int)step*2,usiDataHolders,showValues,listing);
                displayUSIs((int)step*2,(int)step*3,usiDataHolders,showValues,listing);
                displayUSIs((int)step*3,(int)step*4,usiDataHolders,showValues,listing);                
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################
    
    //--- DISPLAY USIS ----------------------------------------------------------------------------
    private void displayUSIs(int beginRowIdx, int endRowIdx, ArrayList usiDataHolders, Hashtable showValues, Hashtable listing){    	
        // table containing all USIs
        PdfPTable usisTable = new PdfPTable(usiDataHolders.size()+1);
        usisTable.setWidthPercentage(100);
      
        if(usiDataHolders.size() > 0){
        	int[] maxRowHeights = getMaximumRowHeights(usiDataHolders,showValues,listing);
        	
            //*********************************     
            //*** list itemnames vertically ***
            //*********************************
        	addItemNamesTable(beginRowIdx,endRowIdx,usisTable,showValues,listing,maxRowHeights);

            //*************************************************
            //*** compose table for all USIs (horizontally) ***
            //*************************************************                    
            Iterator usiIter = usiDataHolders.iterator();
            USI_DataHolder usiData;
            PdfPTable usiTable;
            int usiCount = 0;
            
            while(usiIter.hasNext()){
                usiData = (USI_DataHolder)usiIter.next();
                usiCount++;
                
                usiTable = composeUsiTable(beginRowIdx,endRowIdx,usiData,showValues,listing,maxRowHeights);
                usisTable.addCell(createCell(new PdfPCell(usiTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            }
        }

        // add table                
        if(usisTable.size() > 0){
            table.addCell(createCell(new PdfPCell(usisTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(new PdfPCell(contentTable));
            
            addTransactionToDoc();
            
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);
        }
    }
    
    //--- GET MAXIMUM ROWHEIGHTS ------------------------------------------------------------------
    // height in lines of the specified value
    private int[] getMaximumRowHeights(ArrayList usiDataHolders, Hashtable showValues, Hashtable listing){
    	int[] rowHeights = new int[listing.size()];
        
        Iterator usiIter = usiDataHolders.iterator();
        USI_DataHolder usiData;
        PdfPTable usiTable;
        
        while(usiIter.hasNext()){
            usiData = (USI_DataHolder)usiIter.next();
            		
            // get height in lines of one value
            String sKeyValue, sValue;                    
            for(int x=1; x<=listing.size(); x++){                        
                sKeyValue = checkString((String)listing.get(Integer.toString(x))); 
                
                if(showValues.get(sKeyValue)!=null && ((Boolean)showValues.get(sKeyValue)).booleanValue()){ 
                    sValue = checkString((String)usiData.getItem(sKeyValue));
                    if(sValue.startsWith("usi.surveillance.") || sValue.startsWith("medwan.common.")){
                        sValue = getTran("web.occup",sValue);
                    }
                    
                    if(sValue.length() > 0){
                        int lineCount = countLines(sValue);
                        if(lineCount > rowHeights[x-1]){
                        	rowHeights[x-1] = lineCount;
                        }
                    }
                } 
            }
        }
        
        return rowHeights;
    }
    
    //--- COUNT LINES -----------------------------------------------------------------------------
    private int countLines(String sValue){
    	return ScreenHelper.countMatchesInString(sValue,"\n")+1;
    }
    
    //--- ADD ITEM NAMES TABLE --------------------------------------------------------------------
    private void addItemNamesTable(int beginRowIdx, int endRowIdx,
    		                       PdfPTable usisTable, Hashtable showValues, Hashtable listing, int[] maxRowHeights){
        PdfPTable itemNamesTable = new PdfPTable(1);
        
        if(beginRowIdx==0){
            itemNamesTable.addCell(createValueCell(" \n ",1));
        }

        String sKeyValue;
        for(int x=beginRowIdx; x<endRowIdx; x++){                        
            sKeyValue = checkString((String)listing.get(Integer.toString(x)));
            
            if(showValues.get(sKeyValue)!=null && ((Boolean)showValues.get(sKeyValue)).booleanValue()){
            	itemNamesTable.addCell(createSubtitleCell(getTran("openclinic.chuk",sKeyValue.toLowerCase()),1,maxRowHeights[x-1]));
            }
        }
        
        usisTable.addCell(createCell(new PdfPCell(itemNamesTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
    }
    
    //--- COMPOSE USI TABLE -----------------------------------------------------------------------
    private PdfPTable composeUsiTable(int beginRowIdx, int endRowIdx,
    		                          USI_DataHolder usiData, Hashtable showValues, Hashtable listing, int[] maxRowHeights){    	 
        PdfPTable usiTable = new PdfPTable(1);
        usiTable.setWidthPercentage(100);
        
        // header for one USI
        if(beginRowIdx==0){
            usiTable.addCell(createHeaderCell(usiData.getDate()+", "+usiData.getTime()+"\n"+getTran("openclinic.chuk","edited_by")+": "+usiData.getUpdateUser(),1));
        }
    
        // list values of one USI (vertically)
        String sKeyValue, sValue;

        for(int x=beginRowIdx; x<endRowIdx; x++){                   
            sKeyValue = checkString((String)listing.get(Integer.toString(x)));
            
            if(showValues.get(sKeyValue)!=null && ((Boolean)showValues.get(sKeyValue)).booleanValue()){ 
                sValue = checkString((String)usiData.getItem(sKeyValue));
                if(sValue.startsWith("usi.surveillance.") || sValue.startsWith("medwan.common.")){
                    sValue = getTran("web.occup",sValue);
                }   
                if(sValue.length()==0) sValue = " ";

                usiTable.addCell(createValueCell(sValue,1,maxRowHeights[x-1]));
            }
        }
        
        return usiTable;
    }
    
    //--- SET VALUE HEIGHT ------------------------------------------------------------------------
    private String setValueHeight(String sValue, int heightInLines){
    	for(int i=0; i<=heightInLines; i++){
    		sValue+= "\n";
    	}
    	return sValue;
    }
    
    //--- GET LISTING -----------------------------------------------------------------------------
    private Hashtable getListing(){
        Hashtable listing = new Hashtable();

        listing.put("1","");
        listing.put("2","");
        listing.put("3","LACTATE");
        listing.put("4","GLUCOSE");
        listing.put("5","PHYSIOLOGY");
        listing.put("6","SHAEM");
        listing.put("7","TRANSFUSION");
        listing.put("8","BLOOD");
        listing.put("9","TOTAL_IN");
        listing.put("10","POMPE_SYRINGE_TEXT1");
        listing.put("11","POMPE_SYRINGE1");
        listing.put("12","POMPE_SYRINGE_TEXT2");
        listing.put("13","POMPE_SYRINGE2");
        listing.put("14","POMPE_SYRINGE_TEXT3");
        listing.put("15","POMPE_SYRINGE3");
        listing.put("16","REMARKS1");
        listing.put("17","GLYCEMIE");
        listing.put("18","TEMPERATURE");
        listing.put("19","GCS_Y");
        listing.put("20","GCS_V");
        listing.put("21","GCS_M");
        listing.put("22","ISOCORIE");
        listing.put("23","REACTION_LIGHT");
        listing.put("24","RC");
        listing.put("25","TAS");
        listing.put("26","TAD");
        listing.put("27","TAM");
        listing.put("28","PVC");
        listing.put("29","RR");
        listing.put("30","SAT");
        listing.put("31","FIO2");
        listing.put("32","L_MIN");
        listing.put("33","VOIE");
        listing.put("34","NEBULISATION");
        listing.put("35","CPAP");
        listing.put("36","INTUBATION_USI");
        listing.put("37","TUBE");
        listing.put("38","DAYS_INTUBATION");
        listing.put("39","TRACHEOSTOMIE");
        listing.put("40","DAYS_TRACHEOSTOMIE");
        listing.put("41","ASPIRATION");
        listing.put("42","VC");
        listing.put("43","PC");
        listing.put("44","PA");
        listing.put("45","DAYS_VENTILATION");
        listing.put("46","FREQUENCY");
        listing.put("47","TIDAL_VOL");
        listing.put("48","MIN_VOLUME");
        listing.put("49","MAX_PRESSION");
        listing.put("50","DIURESE");
        listing.put("51","DRAIN_TEXT1");
        listing.put("52","DRAIN1");
        listing.put("53","DRAIN_TEXT2");
        listing.put("54","DRAIN2");
        listing.put("55","DRAIN_TEXT3");
        listing.put("56","DRAIN3");
        listing.put("57","DRAIN_TEXT4");
        listing.put("58","DRAIN4");
        listing.put("59","DRAIN_TEXT5");
        listing.put("60","DRAIN5");
        listing.put("61","SNG");
        listing.put("62","TOTAL_OUT");
        listing.put("63","OUT");
        listing.put("64","VOMISSEMENTS");
        listing.put("65","SELLES");
        listing.put("66","REMARKS2");
        listing.put("67","BILAN_IN_OUT");
        listing.put("68","NURSE_NOTES");
        listing.put("69","REMARKS3");
        
        return listing;
    }

    //--- CREATE VALUE CELL ------------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan, int maxHeightInLines){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        
        cell.setFixedHeight(maxHeightInLines==1?12:10*maxHeightInLines); // difference
        return cell;
    }
    
    //--- CREATE SUBTITLE CELL --------------------------------------------------------------------
    protected PdfPCell createSubtitleCell(String value, int colspan, int maxHeightInLines){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setBackgroundColor(BGCOLOR_LIGHT);

        cell.setFixedHeight(maxHeightInLines==1?12:10*maxHeightInLines); // difference

        return cell;
    }
    

}