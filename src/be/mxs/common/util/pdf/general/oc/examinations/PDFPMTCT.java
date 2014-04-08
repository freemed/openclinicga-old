package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFPMTCT extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                                
                //*** ACTIONS ***                
                String sActions = "";
                
                // counselling
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_COUNSELLING");
                if(itemValue.equalsIgnoreCase("true")){  
                    sActions+= getTran("cs.pmtct","counselling");
                	
                    // avec.partenaire ?
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE");
                    if(itemValue.length() > 0){
                    	sActions+= " ("+getTran("cs.pmtct","avec.partenaire").toLowerCase()+")";
                    }
                    
                    sActions+= ", ";
                }
                
                // teste.rpr
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_TESTE_RPR");
                if(itemValue.equalsIgnoreCase("true")){   
                	sActions+= getTran("cs.pmtct","teste.rpr")+", ";
                }
                                
                // teste.vih
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_TESTE_VIH");
                if(itemValue.length() > 0){
                	sActions+= getTran("cs.pmtct","teste.vih")+", ";
                }
                
                // recuperation.resultats
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_RECUPERATION_RESULTATS");
                if(itemValue.equalsIgnoreCase("true")){    
                	sActions+= getTran("cs.pmtct","recuperation.resultats")+", ";
                }
                
                if(sActions.length() > 0){
                	if(sActions.endsWith(", ")){
                		sActions = sActions.substring(0,sActions.lastIndexOf(", "));
                	}

                    addItemRow(table,getTran("cs.pvv","actions"),sActions);
                }

                //*** VIH ***
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_VIH");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("cs.pmtct","vih"),itemValue);
                }
                
	                // eligible.arv
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_ELIGIBLE_ARV");
	                if(itemValue.length() > 0){
	                	itemValue = getTran("web",itemValue);
	                    addItemRow(table,"    "+getTran("cs.pmtct","eligible.arv"),itemValue);
	                }
	                
	                // eligible.prophylaxie
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_ELIGIBLE_PROPHYLAXIE");
	                if(itemValue.length() > 0){
	                	itemValue = getTran("web",itemValue);
	                    addItemRow(table,"    "+getTran("cs.pmtct","eligible.prophylaxie"),itemValue);
	                }
	                
                // rpr
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_RPR");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("cs.pmtct","rpr"),itemValue);
                }
                
				// comment
				itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_COMMENTAIRE_0");
				if(itemValue.length() > 0){
					itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_COMMENTAIRE_1");
					if(itemValue.length() > 0){
						itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_COMMENTAIRE_2");
						if(itemValue.length() > 0){
							itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_COMMENTAIRE_3");
							if(itemValue.length() > 0){
								itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_PMTCT_COMMENTAIRE_4");								
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
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
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



