package be.mxs.common.util.pdf.general.oc.examinations;

import java.awt.Color;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.lowagie.text.Cell;

import be.mxs.common.util.db.MedwanQuery;
import net.admin.Label;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;


public class PDFOphtalmologyIOTA extends PDFGeneralBasic {
	
    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(100); // cols
                table.setWidthPercentage(100);
               
                ///////////////////////////////////////////////////////////////////////////////////////////////////////
                /// PART 1 ////////////////////////////////////////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////////////////////////////////////////////////
                
                //*** 0. Medic / Referral *************************************
                String sMedic = getTran("cdo.physician",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_PHYSICIAN"));
                if(sMedic.length() > 0){
                    table.addCell(createItemNameCell(getTran("web","cdo.physician"),20));
                    table.addCell(createValueCell(sMedic,80));
                }
                
                String sReferral = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_REFERENCE");            		    
                if(sReferral.length() > 0){
                    table.addCell(createItemNameCell(getTran("web","reference"),20));
                    table.addCell(createValueCell(getTran("web.occup",sReferral),80));
                }
            
                //*** ROW 1 : Complaints **************************************                
                String sComplaints = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_1");
                if(sComplaints.length() > 0){
                	sComplaints = sComplaints.replaceAll("\\*\\*",",").replaceAll("\\*","");
                    
                    // list complaints
                    String[] complaints = sComplaints.split(",");
                    sComplaints = ""; // reset
                    for(int n=0; n<complaints.length; n++){
                    	if(sComplaints.length() > 0){
                    		sComplaints+= ", ";
                    	}
                    	sComplaints+= getTran("cdo.1",complaints[n]).toUpperCase();
                    }

	                if(sComplaints.endsWith(", ")){
	                	sComplaints = sComplaints.substring(0,sComplaints.length()-2);
	                }
                }
                
                // comment
                String sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_1_COMMENT"); 
                
                if(sComplaints.length() > 0 || sComment.length() > 0){
                    table.addCell(createItemNameCell("1. "+getTran("web","actual.complaints"),20));
                    itemValue = "";
                    
                    if(sComplaints.length() > 0) itemValue+= sComplaints;
                    if(sComment.length() > 0) itemValue+= "\r\n\r\n"+sComment;

                    table.addCell(createValueCell(itemValue,80));
                }
                
                //*** ROW 2 : Location ****************************************               
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_2");
                if(itemValue.length() > 0 && !itemValue.equals("0")){
                    table.addCell(createItemNameCell("2. "+getTran("web","localisation"),20));
                    table.addCell(createValueCell(getTran("cdo.2",itemValue.toUpperCase()),80));
                }                             
    		    
	            //*** ROW 3 : 3 + 4 + 5 ***************************************
	            if((getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3").equals("0")) ||
	          	   (getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4").equals("0")) ||
	               (getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5").equals("0"))){
	
	                //*** 3. Severity ***
	                table.addCell(createItemNameCell("3. "+getTran("web","severity"),20));
	                
	                itemValue = getTran("cdo.3",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }
	
	                table.addCell(createValueCell(itemValue,16));
	            
	                //*** 4. Duration ***
	                table.addCell(createItemNameCell("4. "+getTran("web","cdo.duration"),16));
	                
	                itemValue = getTran("cdo.4",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,16));
	            
	                //*** 5. Rythm ***
	                table.addCell(createItemNameCell("5. "+getTran("web","cdo.rythm"),16));
	                
	                itemValue = getTran("cdo.5",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,16));
	            }
            
                // ROW 4 : 6 **************************************************
	            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_6");
                if(itemValue.length() > 0 && !itemValue.equals("0")){                	
	                //*** 6. Antécédents médicaux ***
	                table.addCell(createItemNameCell("6. "+getTran("web","cdo.history"),20));
	                itemValue = "";
	             
	                String sHistory = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_6");		        	
		        	Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sPrintLanguage.toLowerCase());
		        	if(labelTypes!=null){
		                Hashtable labelIds = (Hashtable)labelTypes.get("cdo.6");
		                if(labelIds!=null){
		                	// translate
		                    Enumeration idsEnum = labelIds.elements();
		                    Hashtable hSelected = new Hashtable();
		                    Label label;
		                    while(idsEnum.hasMoreElements()){
		                        label = (Label)idsEnum.nextElement();
		                        hSelected.put(label.value.toUpperCase(),label.id);
		                    }
		                    
		                    // sort
		                    Vector keys = new Vector(hSelected.keySet());
		                    Collections.sort(keys);

		                    // list
		                    Iterator it = keys.iterator();
		                    String sLabelValue, sLabelID;
	                   	    int counter = 0;
		                    while(it.hasNext()){
		                        sLabelValue = (String)it.next();
	                       		itemValue+= sLabelValue+", ";
		                        counter++;
		                    }
		                }
		                if(itemValue.endsWith(", ")){
		                	itemValue = itemValue.substring(0,itemValue.length()-2);
		                }
		        	}
		        	
		        	// comment
                    sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_6_COMMENT").toUpperCase();
                    if(sComment.length() > 0 && itemValue.length() > 0){
                    	itemValue+= "\r\n\r\n"+sComment;
                    }
	                
	                table.addCell(createValueCell(itemValue,80));	                
	            }

                // ROW 5 : 7 + 8 **********************************************
                if((getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7").equals("0")) ||
                   (getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8").equals("0"))){
                	//*** 7. Médicaments ***
	                table.addCell(createItemNameCell("7. "+getTran("web","cdo.meds"),20));
	                
	                itemValue = getTran("cdo.7",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,32));
	
	                //*** 8. Rythm ***
	                table.addCell(createItemNameCell("8. "+getTran("web","cdo.allergy"),16));
	                
	                itemValue = getTran("cdo.8",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }

                    table.addCell(createValueCell(itemValue,32));
	            }
                
                //*** ROW 6 : 9 + 10 ******************************************
                if((getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9").equals("0")) ||
                   (getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10").length() > 0 && !getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10").equals("0"))){
                     	
	                //*** 9. Antécédents familiaux ***
	                table.addCell(createItemNameCell("9. "+getTran("web","cdo.history.family"),20));
	                
	                itemValue = getTran("cdo.9",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,32));

	                //*** 10. Antécédents chirurgicaux ***
	                table.addCell(createItemNameCell("10. "+getTran("web","cdo.history.surgery"),16));
	                
	                itemValue = getTran("cdo.10",getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10")).toUpperCase();
	                sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10_COMMENT");
	                if(sComment.length() > 0){
	                    itemValue+= ",\n"+sComment.toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,32));
                }

	            //*** ROW 7 : 11 + 12 *****************************************
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_11").length() > 0 ||
                   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_12").length() > 0){
                     		                
	                //*** 11. Antécédents médicaux oculaires ***
	                table.addCell(createItemNameCell("11. "+getTran("web","cdo.history.eye"),20));
	                table.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_11"),32));
	
	                //*** 12. Prise en charge ***
	                table.addCell(createItemNameCell("12. "+getTran("web","cdo.intake"),16)); 
	                table.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_12"),32));
                }              
                
                // add table
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
                    addTransactionToDoc();
                }
            }
            
            ///////////////////////////////////////////////////////////////////////////////////////////////////////
            /// PART 2 ////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////////////////////////////////////////////////
            contentTable = new PdfPTable(1);
            table = new PdfPTable(100);
            table.setWidthPercentage(100);
                
	    	//*** ROW 8 : 13 - history eye ************************************
    		PdfPTable histTable = new PdfPTable(3);
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLSC_RE").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLSC_LE").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.avlsc"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.RE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLSC_RE"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.LE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLSC_LE"),1));
    		}
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_TS_RE").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_TS_LE").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.ts"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.RE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_TS_RE"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.LE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_TS_LE"),1));
    		}
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLAC_RE").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLAC_LE").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.avlac"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.RE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLAC_RE"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.LE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_AVLAC_LE"),1));
    		}
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_RE_AS").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_RE_ANNEXES").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.laf.re"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.anterior.segment")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_RE_AS")+"\n"+
	    				                          getTran("web","cdo.annexes")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_RE_ANNEXES"),2));
    		}
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_LE_AS").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_LE_ANNEXES").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.laf.le"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.anterior.segment")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_LE_AS")+"\n"+
	    				                          getTran("web","cdo.annexes")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_LAF_LE_ANNEXES"),2));
    		}
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_RE").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_LE").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.gonioscopy.exam"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.RE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_RE"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.LE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_LE"),1));
    		}
    		
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_PIO_RE").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_PIO_LE").length() > 0){
	    		histTable.addCell(createItemNameCell(getTran("web","cdo.pio"),1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.RE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_PIO_RE")+" mmHg",1));
	    		histTable.addCell(createValueCell(getTran("web","cdo.LE")+" : "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_PIO_LE")+" mmHg",1));
    		}
    		
    		if(histTable.size() > 0){
    			cell = new PdfPCell(histTable);
    			cell.setColspan(100);
    			table.addCell(cell);
    		}   	    
    		
			//*** 14 - fundus *********************************************
      		PdfPTable section20Table = new PdfPTable(3);
      		
      		// header
      		section20Table.addCell(createSubtitleCell(getTran("web","cdo.fundus"),1));
      		section20Table.addCell(createSubtitleCell(getTran("web","cdo.RE"),1));
      		section20Table.addCell(createSubtitleCell(getTran("web","cdo.LE"),1));
      		
      		// RE : 3 checkboxes    
      		PdfPTable cbTableR = new PdfPTable(9);         
      		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_DIRECT_RE").length() > 0 ||
     		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_20D_RE").length() > 0 ||
     		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_90D_RE").length() > 0){		
	      		cbTableR.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_DIRECT_RE").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.direct")));
	      		cbTableR.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_20D_RE").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.20D")));
	      		cbTableR.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_90D_RE").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.90D")));
      		}
      		
      		// LE : 3 checkboxes  
      		PdfPTable cbTableL = new PdfPTable(9);  
      		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_DIRECT_LE").length() > 0 ||
          	   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_20D_LE").length() > 0 ||
          	   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_90D_LE").length() > 0){    		
	      		cbTableL.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_DIRECT_LE").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.direct")));
	      		cbTableL.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_20D_LE").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.20D")));
	      		cbTableL.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_90D_LE").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.90D")));
      		}
      		
      		if(cbTableR.size() > 0 || cbTableL.size() > 0){
	            section20Table.addCell(emptyCell(1));
	            
	            cell = new PdfPCell(cbTableR);
	            cell.setPadding(3);
	            cell.setBorderColor(innerBorderColor);
	            section20Table.addCell(cell);
	            
	            cell = new PdfPCell(cbTableL);
	            cell.setPadding(3);
	            cell.setBorderColor(innerBorderColor);
	            section20Table.addCell(cell);
      		}
      		
            if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_CD_RE").length() > 0 ||
               getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_CD_LE").length() > 0){
	          	section20Table.addCell(createItemNameCell("   "+getTran("web","cdo.cd"),1));
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_CD_RE"),1));        
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_CD_LE"),1));        
            }

            if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PAPIL_RE").length() > 0 ||
               getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PAPIL_LE").length() > 0){
	          	section20Table.addCell(createItemNameCell("   "+getTran("web","cdo.papil"),1));
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PAPIL_RE"),1));        
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PAPIL_LE"),1));        
            }
            
            if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_NFL_RE").length() > 0 ||
               getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_NFL_LE").length() > 0){
	          	section20Table.addCell(createItemNameCell("   "+getTran("web","cdo.NFL"),1));
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_NFL_RE"),1));        
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_NFL_LE"),1));        
            }
            
            if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_MACULA_RE").length() > 0 ||
               getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_MACULA_LE").length() > 0){
	          	section20Table.addCell(createItemNameCell("   "+getTran("web","cdo.macula"),1));
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_MACULA_RE"),1));        
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_MACULA_LE"),1));        
            }
            
            if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_VESSELS_RE").length() > 0 ||
               getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_VESSELS_LE").length() > 0){
	          	section20Table.addCell(createItemNameCell("   "+getTran("web","cdo.vessels"),1));
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_VESSELS_RE"),1));        
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_VESSELS_LE"),1));        
            }
            
            if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PERIPHERY_RE").length() > 0 ||
               getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PERIPHERY_LE").length() > 0){
	          	section20Table.addCell(createItemNameCell("   "+getTran("web","cdo.periphery"),1));
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PERIPHERY_RE"),1));        
	          	section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PERIPHERY_LE"),1));        
            }
            
          	if(section20Table.size() > 1){
          		cell = new PdfPCell(section20Table);
          		cell.setColspan(100);
          		table.addCell(cell);
          	}
    		        
            // add table
            if(table.size() > 0){
                tranTable.addCell(new PdfPCell(table));
                addTransactionToDoc();
                
                contentTable = new PdfPTable(1);
                table = new PdfPTable(100);
                table.setWidthPercentage(100);
            } 
    		
            //*** 16 : correction.worn ****************************************	
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_RIGHT_1").length() > 0 ||
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_RIGHT_2").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_RIGHT_3").length() > 0 || 
		       getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_LEFT_1").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_LEFT_2").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_LEFT_3").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_ADD_L").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_ADD_R").length() > 0){
	            cell = createItemNameCell(getTran("web","cdo.correction.worn"),20);
	            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	            table.addCell(cell);
	            
	    		PdfPTable wornTable = new PdfPTable(5);
	    	    		
	    		wornTable.addCell(createSubtitleCell(getTran("web","cdo.RE"),2));
	    		wornTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_RIGHT_1")+" = "+
	    				                          getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_RIGHT_2")+" / "+
	    				                          getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_RIGHT_3")+"°",
	    				                          3));
	
	    		wornTable.addCell(createSubtitleCell(getTran("web","cdo.LE"),2));
	    		wornTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_LEFT_1")+" = "+
	    				                          getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_LEFT_2")+" / "+
	    				                          getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_LEFT_3")+"°",
	    				                          3));
	    	    			
	    		wornTable.addCell(createValueCell(getTran("web","cdo.addplus.L")+": "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_ADD_L"),2));        
	    		wornTable.addCell(createValueCell(getTran("web","cdo.addplus.R")+": "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_16_ADD_R"),3));
	    				
	    		if(wornTable.size() > 1){
	    			cell = new PdfPCell(wornTable);
	    			cell.setColspan(30);
	    			table.addCell(cell);
	    		}  
    		} 	     
    		
			//*** 17 - refraction measured ************************************
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_RIGHT_1").length() > 0 ||
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_RIGHT_2").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_RIGHT_3").length() > 0 || 
		       getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_LEFT_1").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_LEFT_2").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_LEFT_3").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_ADD_L").length() > 0 || 
			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_ADD_R").length() > 0){
	            cell = createItemNameCell(getTran("web","cdo.refraction.measured"),20);
	            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	            table.addCell(cell);
	            
	    		PdfPTable measuredTable = new PdfPTable(5);
	    	    		
	    		measuredTable.addCell(createSubtitleCell(getTran("web","cdo.RE"),2));
	    		measuredTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_RIGHT_1")+" = "+
	    				                              getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_RIGHT_2")+" / "+
	    				                              getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_RIGHT_3")+"°",
	    				                              3));
	
	    		measuredTable.addCell(createSubtitleCell(getTran("web","cdo.LE"),2));
	    		measuredTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_LEFT_1")+" = "+
	    				                              getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_LEFT_2")+" / "+
	    				                              getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_LEFT_3")+"°",
	    				                              3));
	    	    			 
	    		measuredTable.addCell(createValueCell(getTran("web","cdo.addplus.L")+": "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_ADD_L"),2));        
	    		measuredTable.addCell(createValueCell(getTran("web","cdo.addplus.R")+": "+getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_17_ADD_R"),3));
	    				
	    		if(measuredTable.size() > 1){
	    			cell = new PdfPCell(measuredTable);
	    			cell.setColspan(30);
	    			table.addCell(cell);
	    		}
    		}
    		
            //*** 18 - visual field ***************************************
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_U_L").length() > 0 ||
  			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_L_L").length() > 0 ||
    		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_U_R").length() > 0 ||
    		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_L_R").length() > 0){
	    		table.addCell(createItemNameCell(getTran("web","cdo.visual.field"),20));
	    		PdfPTable section18Table = new PdfPTable(28);
	
	            // eyes image        	    		
	            Image image = Miscelaneous.getImage("ophtalmo_3.png","");
	            image.scaleToFit(190,80);
	            image.setAlignment(com.lowagie.text.Image.UNDERLYING);
	                            
	            cell = new PdfPCell(image);
				cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
	            cell.setColspan(1);
	            cell.setPadding(1);
	            section18Table.addCell(cell);
				
				// spacer col (left)
	            PdfPTable twoCheckBoxesTable = new PdfPTable(1);
	            cell = createBorderlessCell(1);
				twoCheckBoxesTable.addCell(cell);
				cell = new PdfPCell(twoCheckBoxesTable);
				cell.setBorder(PdfPCell.NO_BORDER);
				section18Table.addCell(cell);
				
	            // markers(col 1)							
	            twoCheckBoxesTable = new PdfPTable(1);
	            
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_U_L").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
	
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_L_L").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
				
				cell = new PdfPCell(twoCheckBoxesTable);
				cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
				cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
				cell.setBorder(PdfPCell.NO_BORDER);
				cell.setColspan(2);
				section18Table.addCell(cell);
	
	            // markers(col 2)
				twoCheckBoxesTable = new PdfPTable(1);
				
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_U_R").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
	
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_LEFT_L_R").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
				
				cell = new PdfPCell(twoCheckBoxesTable);
				cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
				cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
				cell.setBorder(PdfPCell.NO_BORDER);
				cell.setColspan(2);
				section18Table.addCell(cell);
				
				// spacer col (middle)
				twoCheckBoxesTable = new PdfPTable(1);
				twoCheckBoxesTable.addCell(createBorderlessCell(1));
				cell = new PdfPCell(twoCheckBoxesTable);
				cell.setBorder(PdfPCell.NO_BORDER);
				section18Table.addCell(cell);
	
	            // markers(col 3)
				twoCheckBoxesTable = new PdfPTable(1);
				
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_RIGHT_U_L").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
	
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_RIGHT_L_L").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
				
				cell = new PdfPCell(twoCheckBoxesTable);
				cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
				cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
				cell.setBorder(PdfPCell.NO_BORDER);
				cell.setColspan(2);
				section18Table.addCell(cell);
	
	            // markers(col 4)
				twoCheckBoxesTable = new PdfPTable(1);
				
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_RIGHT_U_R").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
	
				cell = checkBoxCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_18_RIGHT_L_R").equalsIgnoreCase("medwan.common.true"));
				cell.setPadding(10);
				twoCheckBoxesTable.addCell(cell);
				
				cell = new PdfPCell(twoCheckBoxesTable);
				cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
				cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
				cell.setBorder(PdfPCell.NO_BORDER);
				cell.setColspan(2);
				section18Table.addCell(cell);
				
				cell = emptyCell(17);
				cell.setBorder(Cell.NO_BORDER);
				section18Table.addCell(cell);
	
	    		if(section18Table.size() > 1){
	    			cell = new PdfPCell(section18Table);
	    			cell.setColspan(80);
	    			cell.setPadding(3);
	                cell.setBorderColor(innerBorderColor);
	    			table.addCell(cell);
	    		}
    		}
    		
			//*** 19 - PUPILLES ***********************************************
    		if(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_H").length() > 0 ||
   			   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_H").length() > 0 ||
    		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_RAPD").length() > 0 ||
    		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_L").length() > 0 ||
    		   getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_L").length() > 0){
	            table.addCell(createItemNameCell(getTran("web","cdo.visual.pupilles"),20));
	            
	    		PdfPTable section19Table = new PdfPTable(8);
	    		
				// header
	    		section19Table.addCell(createSubtitleCell(getTran("web","cdo.size.in.mm"),4));
	    		section19Table.addCell(createSubtitleCell(getTran("web","cdo.reaction"),3));
	    		section19Table.addCell(createSubtitleCell(getTran("web","cdo.rapd"),1));
	
	    		// row 1 
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_H").equalsIgnoreCase("1"),1,"1"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_H").equalsIgnoreCase("2"),1,"2"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_H").equalsIgnoreCase("3"),1,"3"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_H").equalsIgnoreCase("4"),1,"4"));
	
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_H").equalsIgnoreCase("1"),1,"1"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_H").equalsIgnoreCase("2"),1,"2"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_H").equalsIgnoreCase("3"),1,"3"));
	    		
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_RAPD").equalsIgnoreCase("-"),1,"-"));
	
		        // row 2 
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_L").equalsIgnoreCase("1"),1,"1"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_L").equalsIgnoreCase("2"),1,"2"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_L").equalsIgnoreCase("3"),1,"3"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_S_L").equalsIgnoreCase("4"),1,"4"));
	    		
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_L").equalsIgnoreCase("1"),1,"1"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_L").equalsIgnoreCase("2"),1,"2"));
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_R_L").equalsIgnoreCase("3"),1,"3"));
	    		
	    		section19Table.addCell(radioCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_19_RAPD").equalsIgnoreCase("+"),1,"+"));
	
	    		if(section19Table.size() > 1){
	    			cell = new PdfPCell(section19Table);
	    			cell.setColspan(50);
	    			cell.setBorderColor(innerBorderColor);
	    			cell.setPadding(3);
	    			table.addCell(cell);
	    			
	    			table.addCell(emptyCell(30)); // space on the right
	    		}
            }
        
    	    //*** 40 + 41 : complementary exams + results ***
    		String sExams   = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_40"),
                   sResults = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_41");
    		
    		if(sExams.length() > 0 || sResults.length() > 0){
	            table.addCell(createItemNameCell(getTran("web","cdo.complementary.exams"),20)); 
	            table.addCell(createValueCell(sExams,30));
             
	            table.addCell(createItemNameCell(getTran("web","cdo.results"),20));
	            table.addCell(createValueCell(sResults,30));
    		}
    		
            // add table
            if(table.size() > 0){
                tranTable.addCell(new PdfPCell(table));
                addTransactionToDoc();
            }


            ///////////////////////////////////////////////////////////////////////////////////////////////////////
            /// PART 3 ////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////////////////////////////////////////////////
            contentTable = new PdfPTable(1);
            table = new PdfPTable(100);
            table.setWidthPercentage(100);

            table.addCell(createItemNameCell(getTran("web","cdo.todays.intake"),20));
            
            //*** 6 * 3 ****
            PdfPTable workloadTable = new PdfPTable(5);
            
            // title
            workloadTable.addCell(createSubtitleCell(getTran("web","cdo.treatment"),5));
            
            // header
            workloadTable.addCell(createSubtitleCell(getTran("web","cdo.name"),3));                
            workloadTable.addCell(createSubtitleCell(getTran("web","cdo.treatment.rythm"),1));                
            workloadTable.addCell(createSubtitleCell(getTran("web","cdo.treatment.duration"),1));

            // rows 1 to 6
            String itemValue1, itemValue2, itemValue3;
            for(int i=1; i<=6; i++){
                itemValue1 = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_"+i+"_3");                
                itemValue2 = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_"+i+"_4");                
                itemValue3 = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_"+i+"_5");
                
                if(itemValue1.length() > 0 || itemValue2.length() > 0 || itemValue3.length() > 0){
                    workloadTable.addCell(createValueCell(itemValue1,3));
                    workloadTable.addCell(createValueCell(itemValue2,1));
                    workloadTable.addCell(createValueCell(itemValue3,1));	
                }
            }   
            
            String sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_COMMENT");
            if(sComment.length() > 0){
                workloadTable.addCell(createValueCell(sComment,5));
            }
            
            if(workloadTable.size() > 2){
	            cell = new PdfPCell(workloadTable);
	            cell.setColspan(80);
	            cell.setPadding(3);
	            cell.setBorderColor(innerBorderColor);
	            table.addCell(cell);             
            }
            
            // add table
            if(table.size() > 0){
                tranTable.addCell(new PdfPCell(table));
                addTransactionToDoc();
            }
            
		    addDiagnosisEncoding();
            addTransactionToDoc();
            
            contentTable = new PdfPTable(1);
            table = new PdfPTable(100);
            table.setWidthPercentage(100);
            
            String sDiagnosisComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_SPECIFIC");
            if(sDiagnosisComment.length() > 0){
            	table.addCell(createValueCell(sDiagnosisComment,100));
            }

            // add table
            if(table.size() > 0){
                tranTable.addCell(new PdfPCell(table));
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
    
    //--- CREATE LARGE FONT CELL ------------------------------------------------------------------
    private PdfPCell createLargeFontCell(String msg, int colspan){
        return createLargeFontCell(msg,PdfPCell.ALIGN_LEFT,colspan);	
    }
    
    private PdfPCell createLargeFontCell(String msg, int alignment, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,15,Font.BOLDITALIC))); // difference
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(alignment);
        cell.setBackgroundColor(new BaseColor(240,240,240)); // light gray

        return cell;
    }

    //--- CREATE GREY CELL ------------------------------------------------------------------------
    protected PdfPCell createGreyCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setBackgroundColor(new BaseColor(245,245,245)); // light gray

        return cell;
    }
    
    //--- CREATE ITEMNAME CELL ---------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingTop(1);
        cell.setBackgroundColor(new BaseColor(240,240,240)); // light gray

        return cell;
    }
    
}
