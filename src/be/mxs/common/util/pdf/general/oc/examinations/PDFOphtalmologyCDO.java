package be.mxs.common.util.pdf.general.oc.examinations;

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

import be.mxs.common.util.db.MedwanQuery;
import net.admin.Label;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;


public class PDFOphtalmologyCDO extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(100); // cols
                table.setWidthPercentage(100);
               
                ///////////////////////////////////////////////////////////////////////////////////////////////////////
                /// PART 1 ////////////////////////////////////////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////////////////////////////////////////////////
                
                //*** 0. Medic ***********************************************
                String sMedic = getTran("cdo.physician",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_PHYSICIAN"));
                if(sMedic.length() > 0){
                    table.addCell(createItemNameCell(getTran("web","cdo.physician"),20));
                    table.addCell(createValueCell(sMedic,80));
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
                
                //*** ROW 2 : Localisation ************************************               
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_2");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_2_COMMENT").toUpperCase();
                }
                else{
                	itemValue = getTran("cdo.2",itemValue).toUpperCase();
                }

                if(itemValue.length() > 0){
                    table.addCell(createItemNameCell("2. "+getTran("web","localisation"),20));
                    table.addCell(createValueCell(itemValue,80));
                }

                //*** ROW 3 : 3 + 4 + 5 ***************************************
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3").length() > 0 ||
              	   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4").length() > 0 ||
                   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5").length() > 0){

	                //*** 3. Severity ***
	                table.addCell(createItemNameCell("3. "+getTran("web","severity"),20));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.3",itemValue).toUpperCase();
	                }
	
	                table.addCell(createValueCell(itemValue,16));
                
	                //*** 4. Duration ***
	                table.addCell(createItemNameCell("4. "+getTran("web","cdo.duration"),16));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.4",itemValue).toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,16));
                
	                //*** 5. Rythm ***
	                table.addCell(createItemNameCell("5. "+getTran("web","cdo.rythm"),16));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.5",itemValue).toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,16));
                }
                
                // ROW 4 : 6 **************************************************
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_6").length() > 0){                	
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
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7").length() > 0 ||
                   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8").length() > 0){
                	//*** 7. Médicaments ***
	                table.addCell(createItemNameCell("7. "+getTran("web","cdo.meds"),20));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.7",itemValue).toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,32));
	
	                //*** 8. Rythm ***
	                table.addCell(createItemNameCell("8. "+getTran("web","cdo.allergy"),16));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.8",itemValue).toUpperCase();
	                }

                    table.addCell(createValueCell(itemValue,32));
	            }
	            
                //*** ROW 6 : 9 + 10 ******************************************
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9").length() > 0 ||
                   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10").length() > 0){
                     	
	                //*** 9. Antécédents familiaux ***
	                table.addCell(createItemNameCell("9. "+getTran("web","cdo.history.family"),20));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.9",itemValue).toUpperCase();
	                }
	                
	                table.addCell(createValueCell(itemValue,32));

	                //*** 10. Antécédents chirurgicaux ***
	                table.addCell(createItemNameCell("10. "+getTran("web","cdo.history.surgery"),16));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10");
	                if(itemValue.equalsIgnoreCase("0")){
	                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10_COMMENT").toUpperCase();
	                }
	                else{
	                	itemValue = getTran("cdo.10",itemValue).toUpperCase();
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
                
                
                ///////////////////////////////////////////////////////////////////////////////////////////////////////
                /// PART 2 ////////////////////////////////////////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////////////////////////////////////////////////
                contentTable = new PdfPTable(1);
                table = new PdfPTable(100);
                table.setWidthPercentage(100);
                
                //*** ROW 8 : 13 + 14 + 15 ************************************
                PdfPTable avtpTable = new PdfPTable(21); // 3*7 cols
                avtpTable.setWidthPercentage(100);
                  
        		//*** 13 : AV ******
                cell = createItemNameCell("13.",1);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                avtpTable.addCell(cell);
                avtpTable.addCell(createLargeFontCell(getTran("web.occup","av").toUpperCase(),2));
                    			
    			// H-selection
    			String sValue = "H: ";
                itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_13_H");
    		    itemValue = getTran("cdo.13",itemValue);
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue+", ";
    		    }
    		    
    		    // H-comment
    		    itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_13_H_COMMENT");
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue;
    		    }
   			
    			// L-selection
    			sValue+= "\r\nL: ";
        		itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_13_L");
    		    itemValue = getTran("cdo.13",itemValue);
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue+", ";
    		    }
    		    
    		    // L-comment
    		    itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_13_L_COMMENT");
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue;
    		    }
    		    
    		    cell = createValueCell(sValue,6);
    		    cell.setHorizontalAlignment(PdfPCell.ALIGN_TOP);
                avtpTable.addCell(cell);
    		                                    
        		//*** 14 : T ******
                cell = createItemNameCell("14.",1);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                avtpTable.addCell(cell);
                avtpTable.addCell(createLargeFontCell(getTran("web.occup","t").toUpperCase(),2));

      			// H-selection
                sValue = "H: ";
        		itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_14_H");
    		    itemValue = getTran("cdo.14",itemValue);
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue;
    		    }
   			
    			// L-selection
    			sValue+= "\r\nL: ";
        		itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_14_L");
    		    itemValue = getTran("cdo.14",itemValue);
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue;
    		    }
    		    
    		    cell = createValueCell(sValue,3);
    		    cell.setHorizontalAlignment(PdfPCell.ALIGN_TOP);
                avtpTable.addCell(cell);

        		//*** 15 : P ******
                cell = createItemNameCell("15.",1);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                avtpTable.addCell(cell);
                avtpTable.addCell(createLargeFontCell(getTran("web.occup","p").toUpperCase(),2));

      			// H-selection
                sValue = "H: ";
        		itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_15_H");
    		    itemValue = getTran("cdo.15",itemValue);
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue;
    		    }
   			
    			// L-selection
    			sValue+= "\r\nL: ";
        		itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_15_L");
    		    itemValue = getTran("cdo.15",itemValue);
    		    if(itemValue.length() > 0){
    		    	sValue+= itemValue;
    		    }
    		    
    		    cell = createValueCell(sValue,3);
    		    cell.setHorizontalAlignment(PdfPCell.ALIGN_TOP);
                avtpTable.addCell(cell);
    		    
        		if(avtpTable.size() > 0){
        			cell = new PdfPCell(avtpTable);
        			cell.setColspan(60);
        			table.addCell(cell);
        		}
        	    		
                //*** 16 : correction.worn ***************************	
                cell = createItemNameCell("16. "+getTran("web","cdo.correction.worn"),20);
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
        				
        		if(wornTable.size() > 0){
        			cell = new PdfPCell(wornTable);
        			cell.setColspan(20);
        			table.addCell(cell);
        		}   	        		
        		
                //*** ROW 9 : 20 ~ 39 *****************************************
        		String s20To39 = "";
        		
        		Vector labels20To39 = new Vector();
        		labels20To39.add(getTran("web","cdo.eyelid"));
        		labels20To39.add(getTran("web","cdo.lacrymaldrain"));
        		labels20To39.add(getTran("web","cdo.orbit"));
        		labels20To39.add(getTran("web","cdo.drye.eye"));
        		labels20To39.add(getTran("web","cdo.conjunctivitis"));
        		labels20To39.add(getTran("web","cdo.cornea"));
        		labels20To39.add(getTran("web","cdo.sclera"));
        		labels20To39.add(getTran("web","cdo.cristalline"));
        		labels20To39.add(getTran("web","cdo.glaucoma"));
        		labels20To39.add(getTran("web","cdo.uveitis"));
        		labels20To39.add(getTran("web","cdo.tumor"));
        		labels20To39.add(getTran("web","cdo.vascular"));
        		labels20To39.add(getTran("web","cdo.macular"));
        		labels20To39.add(getTran("web","cdo.dystrophia"));
        		labels20To39.add(getTran("web","cdo.release"));
        		labels20To39.add(getTran("web","cdo.strabismus"));
        		labels20To39.add(getTran("web","cdo.neuro.ophtalmology"));
        		labels20To39.add(getTran("web","cdo.toxicity"));
        		labels20To39.add(getTran("web","cdo.traumatism"));
        		labels20To39.add(getTran("web","cdo.refraction.error"));
        		
        		int idx = 0;
        		for(int i=20; i<=39; i++){
	        		itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_20");
	        		if(itemValue.equalsIgnoreCase("medwan.common.true")){
	        			s20To39+= labels20To39.get(idx)+", ";
	        		}
	        		idx++;
        		}
        		
        		if(s20To39.length() > 0){
	        		if(s20To39.endsWith(", ")){
	        			s20To39 = s20To39.substring(0,s20To39.length()-2);
	        		}
	        		
	        		table.addCell(createValueCell(s20To39,60));
        		}	
        		
				//*** 17 - refraction measured ***        		
                cell = createItemNameCell("17. "+getTran("web","cdo.refraction.measured"),20);
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
        				
        		if(measuredTable.size() > 0){
        			cell = new PdfPCell(measuredTable);
        			cell.setColspan(20);
        			table.addCell(cell);
        		}
        						    			
                //*** 18 - visual field ***************************************
        		table.addCell(createItemNameCell("18. "+getTran("web","cdo.visual.field"),20));
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
				
				section18Table.addCell(emptyCell(17));

        		if(section18Table.size() > 0){
        			cell = new PdfPCell(section18Table);
        			cell.setColspan(80);
                    cell.setBorderColor(innerBorderColor);
        			table.addCell(cell);
        		}
        		
				//*** 19 - P **************************************************
        		cell = createItemNameCell("19.",4);
        		cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                table.addCell(cell);
                table.addCell(createLargeFontCell(getTran("web.occup","p").toUpperCase(),16));
                
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

        		if(section19Table.size() > 0){
        			cell = new PdfPCell(section19Table);
        			cell.setColspan(80);
        			table.addCell(cell);
        		}
        		
				//*** 20 - fundus *********************************************
        		PdfPTable section20Table = new PdfPTable(16);
        		
        		// header
        		section20Table.addCell(createSubtitleCell(getTran("web","cdo.fundus"),4));
        		section20Table.addCell(createSubtitleCell(getTran("web","cdo.CD"),4));
                cell = createSubtitleCell(getTran("web","cdo.CD"),4);
        		cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        		section20Table.addCell(cell);
        		section20Table.addCell(createSubtitleCell(getTran("web","cdo.gonioscopy"),4));
        		
        		// 3 checkboxes       
        		PdfPTable cbTable = new PdfPTable(10);
        		
        		cell = checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_DIRECT").equalsIgnoreCase("medwan.common.true"),4,getTran("web","cdo.direct"));
        		cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        		cbTable.addCell(cell);
        		
                cell = checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_20D").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.20D"));
        		cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        		cbTable.addCell(cell);

        		cell = checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_90D").equalsIgnoreCase("medwan.common.true"),3,getTran("web","cdo.90D"));
        		cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        		cbTable.addCell(cell);
        		
      			cell = new PdfPCell(cbTable);
       			cell.setColspan(4);
       			section20Table.addCell(cell);
        		
        		section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PCT1"),4));
        		cell = createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PCT2"),4);
        		cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        		section20Table.addCell(cell);
        		section20Table.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY"),4));

        		if(section20Table.size() > 0){
        			cell = new PdfPCell(section20Table);
        			cell.setColspan(100);
        			table.addCell(cell);
        		}
        		
        		//*** 21 - papil **********************************************
        		PdfPTable section21Table = new PdfPTable(16);
        		
        		// 5 checkboxes
        		PdfPTable fiveCBsTable = new PdfPTable(1);
        		fiveCBsTable.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PAPIL").equalsIgnoreCase("medwan.common.true"),1,getTran("web","cdo.papil")));
        		fiveCBsTable.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_NFL").equalsIgnoreCase("medwan.common.true"),1,getTran("web","cdo.NFL")));
        		fiveCBsTable.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_MACULA").equalsIgnoreCase("medwan.common.true"),1,getTran("web","cdo.macula")));
        		fiveCBsTable.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_VESSELS").equalsIgnoreCase("medwan.common.true"),1,getTran("web","cdo.vessels")));
        		fiveCBsTable.addCell(checkBoxCellWithLabel(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CDO_FUNDUS_PERIPHERY").equalsIgnoreCase("medwan.common.true"),1,getTran("web","cdo.periphery")));

      			cell = createContentCell(fiveCBsTable);
      			cell.setColspan(4);
      			cell.setBorderColor(innerBorderColor);
      			section21Table.addCell(cell);
        		
                // double ophtalmo image        	    		
                image = Miscelaneous.getImage("ophtalmo_1.png","");
                image.scaleToFit(190,86);
                
                cell = new PdfPCell(image);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setColspan(12);
                cell.setPadding(1);
                section21Table.addCell(cell);

        		if(section21Table.size() > 0){
        			cell = new PdfPCell(section21Table);
        			cell.setColspan(100);
                    cell.setBorderColor(innerBorderColor);
        			table.addCell(cell);
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
                
        	    //*** 40 - cdo complementary exams ***
                table.addCell(createItemNameCell(getTran("web","cdo.complementary.exams"),20)); 
                table.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_40"),30));
                 
    	        //*** 41 - results ***
                table.addCell(createItemNameCell(getTran("web","cdo.results"),20));
                table.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_41"),30));

                // titles for 42 and 43
                table.addCell(createItemNameCell(getTran("web","cdo.todays.diagnosis"),50));
                table.addCell(createItemNameCell(getTran("web","cdo.todays.intake"),50));
                
        		//*** 42 - general diagnosis ***
                PdfPTable diagTable = new PdfPTable(5);
                diagTable.addCell(createSubtitleCell(getTran("web","cdo.general.diagnosis"),1));
                String sDiag = "";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_GENERAL_1");
                sDiag+= getTran("cdo.general.diagnosis",itemValue)+"\r\n";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_GENERAL_2");
                sDiag+= getTran("cdo.general.diagnosis",itemValue)+"\r\n";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_GENERAL_3");
                sDiag+= getTran("cdo.general.diagnosis",itemValue)+"\r\n";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_GENERAL");
                sDiag+= itemValue.replaceAll("<br>","\r\n");
                
                diagTable.addCell(createValueCell(sDiag,4));
			    
        		//*** 43 - specific diagnosis ***
                diagTable.addCell(createSubtitleCell(getTran("web","cdo.specific.diagnosis"),1));
                sDiag = "";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_SPECIFIC_1");
                sDiag+= getTran("cdo.general.diagnosis",itemValue)+"\r\n";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_SPECIFIC_2");
                sDiag+= getTran("cdo.general.diagnosis",itemValue)+"\r\n";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_SPECIFIC_3");
                sDiag+= getTran("cdo.general.diagnosis",itemValue)+"\r\n";
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_42_SPECIFIC");
                sDiag+= itemValue.replaceAll("<br>","\r\n");
                
                diagTable.addCell(createValueCell(sDiag,4));
                
                cell = new PdfPCell(diagTable);
                cell.setColspan(50);
                table.addCell(cell);

                //*** 6 * 3 ****
                PdfPTable workloadTable = new PdfPTable(5);
                
                // header
                workloadTable.addCell(createSubtitleCell(getTran("web","cdo.name"),3));                
                workloadTable.addCell(createSubtitleCell(getTran("web","cdo.treatment.rythm"),1));                
                workloadTable.addCell(createSubtitleCell(getTran("web","cdo.treatment.duration"),1));

                // rows 1 to 6
                for(int i=1; i<=6; i++){
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_"+i+"_3");
	                workloadTable.addCell(createValueCell(itemValue,3));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_"+i+"_4");
	                workloadTable.addCell(createValueCell(itemValue,1));
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_43_"+i+"_5");
	                workloadTable.addCell(createValueCell(itemValue,1));
                }   
                
                cell = new PdfPCell(workloadTable);
                cell.setColspan(50);
                table.addCell(cell);             
                
                // add table
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
                    addTransactionToDoc();
                }
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
