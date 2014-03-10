package be.mxs.common.util.pdf.general.oc.examinations;

import java.sql.Timestamp;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.Diagnosis;
import be.openclinic.medical.ReasonForEncounter;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFColonoscopyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                //*********************************************************************************
                //*** PART 1 - REGULAR-ITEMS ******************************************************
                //*********************************************************************************
                
                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                }

                // premedication
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_PREMEDICATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","premedication"),itemValue);
                }

                // endoscopy_type
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_ENDOSCOPY_TYPE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endoscopy_type"),itemValue);
                }

                // examination_description
                itemValue = getItemValue(IConstants_PREFIX+"v");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","examination_description"),itemValue);
                }

                //*** investigations_done (BIOSCOPY) ***
                String investigations = "";

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_BIOSCOPY");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy");
                }

                /*
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY2");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy2");
                }
                */

                if(investigations.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","investigations_done"),investigations);
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
                                
                
                //*********************************************************************************
                //*** PART 2 - CODE-ITEMS *********************************************************
                //*********************************************************************************
                contentTable = new PdfPTable(1);
                
                table = new PdfPTable(2);
                table.setWidthPercentage(100);
                
            	String sActiveEncounterUID = "";
                String sEncounterUID = transactionVO.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                if(sEncounterUID.length() > 0){
                	sActiveEncounterUID = sEncounterUID;
                }
                else{
                    Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(transactionVO.getUpdateTime().getTime()),this.patient.personid);
                    if(activeEnc!=null){
                    	sActiveEncounterUID = activeEnc.getUid();
                    }
                }
                
                //***** 1 - reasons for encounter *****************************
                if(sActiveEncounterUID.length() > 0){
                    Vector rfeVector = ReasonForEncounter.getReasonsForEncounterByEncounterUid(sActiveEncounterUID);
                    
                    if(rfeVector.size() > 0){	                    
	                    PdfPTable rfeTable = new PdfPTable(20);
	                    rfeTable.setWidthPercentage(100);

	                    // title
	                    String sTitle = getTran("openclinic.chuk","rfe")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	                    cell = createTitleCell(sTitle,20);
	                    cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                    rfeTable.addCell(cell);
	                    
	                    ReasonForEncounter rfe;
	                    for(int i=0; i<rfeVector.size(); i++){
	                    	rfe = (ReasonForEncounter)rfeVector.get(i);
	                    	
                            // one encounter
		                    rfeTable.addCell(createValueCell(rfe.getCodeType().toUpperCase(),2));
		                    rfeTable.addCell(createValueCell(rfe.getCode(),2));
		                    rfeTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(rfe.getCodeType()+"code"+rfe.getCode(),sPrintLanguage),16));
	                    }
	                    
	                    // add to main table
	                    cell = createBorderlessCell(2);
	                    cell.addElement(rfeTable);
	                    table.addCell(cell);
                    }
                }
                  
                //***** 2 - ICPC / ICD10 **************************************
                PdfPTable icpcTable = new PdfPTable(20);
                icpcTable.setWidthPercentage(100);
                
                String sTitle = getTran("openclinic.chuk","diagnostic.document")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
                cell = createTitleCell(sTitle,20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                icpcTable.addCell(cell);
                                		
		        String sReferenceUID = transactionVO.getServerId()+"."+transactionVO.getTransactionId();
		        Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID,"Transaction");
		        String sCode, sGravity, sCertainty, sPOA, sNC, sServiceUid, sFlags;

    	        Iterator items = transactionVO.getItems().iterator();
		        Hashtable hDiagnosisInfo;
		        ItemVO item;
		        
		        while(items.hasNext()){
		            item = (ItemVO)items.next();
		             
                    //***** a : ICPC *****	             
		            if(item.getType().indexOf("ICPCCode")==0){
		                sCode = item.getType().substring("ICPCCode".length(),item.getType().length());

		                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
		                if(hDiagnosisInfo!=null){
	                        sGravity    = (String)hDiagnosisInfo.get("Gravity");
		                    sCertainty  = (String)hDiagnosisInfo.get("Certainty");
		                    sPOA        = (String)hDiagnosisInfo.get("POA");
		                    sNC         = (String)hDiagnosisInfo.get("NC");
		                    sServiceUid = (String)hDiagnosisInfo.get("ServiceUid");
		                    sFlags      = (String)hDiagnosisInfo.get("Flags");
		                }
		                else{
		                    sGravity = "";
		                    sCertainty = "";
		                    sPOA = "";
		                    sNC = "";
		                    sServiceUid = "";
		                    sFlags = "";
		                }

		                // one ICPC
		                icpcTable.addCell(createValueCell("ICPC",2));
		                icpcTable.addCell(createValueCell(item.getType().replaceAll("ICPCCode",""),2));
		                icpcTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage)+" "+item.getValue().trim(),11));
		                icpcTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));
		     	    }		      
		            //***** b : icd10 *****
		            else if(item.getType().indexOf("ICD10Code")==0){
		                sCode = item.getType().substring("ICD10Code".length(),item.getType().length());

		                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
		                if(hDiagnosisInfo!=null){
		                    sGravity    = (String)hDiagnosisInfo.get("Gravity");
		                    sCertainty  = (String)hDiagnosisInfo.get("Certainty");
		                    sPOA        = (String)hDiagnosisInfo.get("POA");
		                    sNC         = (String)hDiagnosisInfo.get("NC");
		                    sServiceUid = (String)hDiagnosisInfo.get("ServiceUid");
		                    sFlags      = (String)hDiagnosisInfo.get("Flags");
		                } 
		                else{
		                    sGravity = "";
		                    sCertainty = "";
		                    sPOA = "";
		                    sNC = "";
		                    sServiceUid = "";
		                    sFlags = "";
		                }

		                // one ICD10
		                icpcTable.addCell(createValueCell("ICD10",2));
		                icpcTable.addCell(createValueCell(item.getType().replaceAll("ICD10Code",""),2));
		                icpcTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage)+" "+item.getValue().trim(),11));
		                icpcTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));		               
		            }
		        }
	            
                // add to main table
 	            cell = createBorderlessCell(2);
	            cell.addElement(icpcTable);
                table.addCell(cell);
		        
		        //***** 3 - diagnoses ***************************************** 
                PdfPTable diagTable = new PdfPTable(20);
                diagTable.setWidthPercentage(100);
                
		        sTitle = getTran("openclinic.chuk","contact.diagnoses")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
                cell = createTitleCell(sTitle,20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                diagTable.addCell(cell);
          
		        if(sActiveEncounterUID.length() > 0){			
			         sReferenceUID = transactionVO.getServerId()+"."+transactionVO.getTransactionId();
			         Vector diagnoses = Diagnosis.selectDiagnoses("","",sActiveEncounterUID,"","","","","","","","","","");

			         Diagnosis diag;
			         for(int n=0; n<diagnoses.size(); n++){
			        	 diag = (Diagnosis)diagnoses.get(n);
			        	 
	                     sGravity   = diag.getGravity()+"";
	                     sCertainty = diag.getCertainty()+"";
	                     sPOA       = diag.getPOA();
	                     sNC        = diag.getNC();
	                     sFlags     = diag.getFlags();
	                     
		     		     if(diag.getCodeType().equalsIgnoreCase("icpc")){
			     			 // one ICPC
		                     diagTable.addCell(createValueCell("ICPC",2));
				             diagTable.addCell(createValueCell(diag.getCode(),2));
				             diagTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran("icpccode"+diag.getCode(),sPrintLanguage)+" "+diag.getLateralisation(),11));
				             diagTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));
			             }
			             else if(diag.getCodeType().equalsIgnoreCase("icd10")){
			            	 // one ICD10
			            	 diagTable.addCell(createValueCell("ICD10",2));
				             diagTable.addCell(createValueCell(diag.getCode(),2));
				             diagTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sPrintLanguage)+" "+diag.getLateralisation(),11));
				             diagTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));			             	 				     		 
			             }
			        }
		            
		            // add to main table
	 	            cell = createBorderlessCell(2);
		            cell.addElement(diagTable);
	                table.addCell(cell); 
		        }       
                    
                // add table
                if(table.size() > 0){
	 	            cell = createBorderlessCell(1);
		            cell.addElement(table);
		            tranTable.addCell(cell); 
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
}

