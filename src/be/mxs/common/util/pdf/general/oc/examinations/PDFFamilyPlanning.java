package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFFamilyPlanning extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
         
                //*** UTILISATRICE ***
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_TYPE_UTILISATRICE");
                if(itemValue.length() > 0){
                	itemValue = getTran("cs.planification",itemValue);
                    addItemRow(table,getTran("cs.planification","type.utilisatrice"),itemValue);
                }
                                
                //*** METHOD ***
                String sMethod = "";

                // pilule 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_PILULE");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","pilule")+", ";
                }

                // depo.provera 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_DEPO_PROVERA");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","depo.provera")+", ";
                }  

                // implant 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_IMPLANT");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","implant")+", ";
                }  
                
                // diu 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_DIU");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","diu")+", ";
                }

                // mjf 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_MJF");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","mjf")+", ";
                }
            	
                // barrieres 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_BARRIERES");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","barrieres")+", ";
                }

                // auto.observation 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_AUTO_OBSERVATION");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","auto.observation")+", ";
                }

                // ligature 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_LIGATURE");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","ligature")+", ";
                }
            	
                // vasectomie 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_VASECTOMIE");
                if(itemValue.length() > 0){
                	sMethod+= getTran("cs.planification","vasectomie")+", ";
                }
                
                if(sMethod.length() > 0){
                	if(sMethod.endsWith(", ")){
                	    sMethod = sMethod.substring(0,sMethod.length()-2);
                	}
                	
                    addItemRow(table,getTran("cs.planification","methode"),sMethod);
                }
            	
                // nouveau.cas
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_NOUVEAU_CAS");
                if(itemValue.length() > 0){
                	itemValue = getTran("web",itemValue);
                    addItemRow(table,getTran("cs.pvv","nouveau.cas"),itemValue);
                }
            	          
                // comment 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_COMMENTAIRE_0");
                if(itemValue.length() > 0){
                	itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_COMMENTAIRE_1");
	                if(itemValue.length() > 0){
	                	itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_COMMENTAIRE_2");
		                if(itemValue.length() > 0){
		                	itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_COMMENTAIRE_3");
			                if(itemValue.length() > 0){
			                	itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PLANNING_FAMILIAL_COMMENTAIRE_4");
			                }
		                }
	                }
	                
	                if(itemValue.length() > 0){
	                    addItemRow(table,getTran("web","comment"),itemValue);
	                }
                }
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc(); 
                }

                //addDiagnosisEncoding();
                //addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
}
