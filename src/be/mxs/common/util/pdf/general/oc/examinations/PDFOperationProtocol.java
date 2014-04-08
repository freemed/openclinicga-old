package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFOperationProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

            	// START HOUR 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_START");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","starthour"),itemValue);
                }
            	
            	// END HOUR
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_END");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endhour"),itemValue);
                }
            	
            	// DURATION           	
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_DURATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","duration"),itemValue);
                }

            	// INTERVENTION
            	itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","intervention"),itemValue);
                }

            	//*** GROUP COMPOSITION *************************************************                
                String sSurgeons     = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS"),   	
                       sAnesthesists = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS"),
            	       sNurses       = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_NURSES");
                
                if(sSurgeons.length() > 0 || sAnesthesists.length() > 0 || sNurses.length() > 0){
                    // add table
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                        tranTable.addCell(new PdfPCell(contentTable));
                        addTransactionToDoc();
                    }
                    
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);
                    
                    table.addCell(createSubtitleCell(getTran("openclinic.chuk","group.composition"),5));
                    
                	// SURGEONS            	
                    if(sSurgeons.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","surgeons"),sSurgeons);
                    }
                	
                	// ANESTHESISTS         
                    if(sAnesthesists.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","anasthesists"),sAnesthesists);
                    }
                	
                	// NURSES
                    if(sNurses.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","nurses"),sNurses);
                    }

                    // add table
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                        tranTable.addCell(createContentCell(contentTable));
                        addTransactionToDoc();

                        contentTable = new PdfPTable(1);
                        table = new PdfPTable(5);
                    }
                }
                
            	// INSTALLATION            	
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","patient.installation"),itemValue);
                }
            	
            	// APROVAL            	
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_APROVAL");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","aproval"),itemValue);
                }
            	    
            	// OBSERVATIONS            	
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","observations"),itemValue);
                }
            	
            	// SURGICAL ACT 1
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT1");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","surgical.act")+" 1",getTran("surgicalacts",itemValue));
                }
            	
            	// SURGICAL ACT 2
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT2");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","surgical.act")+" 2",getTran("surgicalacts",itemValue));
                }
            	
            	// SURGICAL ACT 3
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT3");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","surgical.act")+" 3",getTran("surgicalacts",itemValue));
                }
            	     
            	// CLOSURE            	
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","closure"),itemValue);
                }
            	
            	// CARE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_CARE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","care.post.op"),itemValue);
                }
            	
            	// REMARKS
            	itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue.replaceAll("<br>","\r\n"));
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }

                // diagnoses
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
    

}