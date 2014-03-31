package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFPrenatalConsultation extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // type.de.visite
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_TYPE_VISITE");
                if(itemValue.length() > 0){
                	itemValue = getTran("cs.cpn.type.visite",itemValue);
                    addItemRow(table,getTran("cs.cpn","type.de.visite"),itemValue);
                }

                // grossesse.risque
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE");
                if(itemValue.length() > 0){
                	itemValue = getTran("web",itemValue);
                    addItemRow(table,getTran("cs.cpn","grossesse.risque"),itemValue);
                }

				// tpi
				itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_TPI");
				if(itemValue.length() > 0){
				    addItemRow(table,getTran("cs.cpn","type.de.visite"),itemValue);
				}

				// vat
				itemValue = getItemValue(IConstants_PREFIX+"TEM_TYPE_CS_CPN_VAT");
				if(itemValue.length() > 0){
				    addItemRow(table,getTran("cs.cpn","vat"),itemValue);
				}
				
				// fer.acide.folique
				itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_FER_ACIDE_FOLIQUE");
                if(itemValue.length() > 0){
                	itemValue = getTran("web",itemValue);
				    addItemRow(table,getTran("cs.cpn","fer.acide.folique"),itemValue);
				}
				
				// moustiquaire.impregnee
				itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_MOUSTIQUAIRE_IMPREGNEE");
                if(itemValue.length() > 0){
                	itemValue = getTran("web",itemValue);
				    addItemRow(table,getTran("cs.cpn","moustiquaire.impregnee"),itemValue);
				}

				// comment
				itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_COMMENTAIRE_0");
				if(itemValue.length() > 0){
					itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_COMMENTAIRE_1");
					if(itemValue.length() > 0){
						itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_COMMENTAIRE_2");
						if(itemValue.length() > 0){
							itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_COMMENTAIRE_3");
							if(itemValue.length() > 0){
								itemValue+= getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_CPN_COMMENTAIRE_4");								
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
