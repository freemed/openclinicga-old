package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.LabAnalysis;
import be.openclinic.medical.RequestedLabAnalysis;

import com.itextpdf.text.*;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.pdf.*;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.*;
import java.awt.*;

import org.hnrw.report.Report_Diagnosis;
import org.hnrw.report.Report_Identification;
import org.hnrw.report.Report_RFE;
import org.hnrw.report.Report_Transaction;
import org.dom4j.io.SAXReader;
import org.dom4j.*;
import org.dom4j.Element;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFMonthlyReportGeneratorDH extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;

    public void addHeader(){
    }
    public void addContent(){
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFMonthlyReportGeneratorDH(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Date begin, Date end) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            doc.setPageSize(PageSize.A4.rotate());
            doc.open();

            // add content to document
            printIdentification(end);
            doc.newPage();
            printConsultationData(begin,end);
            doc.newPage();
            printSexualViolenceData(begin,end);
            doc.newPage();
            printAdmissionData(begin,end);
            doc.newPage();
            Report_Transaction report_transaction = new Report_Transaction(begin,end);
            printPVVData(begin,end,report_transaction);
            doc.newPage();
            printMaternityData(begin,end);
            doc.newPage();
            printFamilyPlanning(begin,end);
            doc.newPage();
            printOperatingTheatre(begin,end);
            doc.newPage();
            printAnesthaesia(begin,end);
            printFunctionalRehabilitation(begin,end);
            doc.newPage();
            printDiagnostics(begin,end);
		}
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			try{
				if(doc!=null) {
					if(baosPDF.size() < 1){
						doc.add(new Paragraph("The document has no pages"));
					}
					doc.close();
				}
	            if(docWriter!=null) docWriter.close();
			}
			catch(Exception e2){};
		}

		return baosPDF;
	}

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
    }

    protected void printDiagnostics(Date begin,Date end){
    	try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.lab.title",user.person.language),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));
            table.addCell(createBorderlessCell("",5,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.results",user.person.language),8,2));
            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.total",user.person.language),8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.exams",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.positive",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.negative",user.person.language),8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            //Nu voegen we alle te onderzoeken analyses toe
            //Eerst alle onderzoeken van de betreffende periode opzoeken
            Vector results=RequestedLabAnalysis.find("", "", "", "", "", "", "", "", "", "", "", "", ScreenHelper.stdDateFormat.format(begin), ScreenHelper.stdDateFormat.format(end), "", "", false, "");
            //Ook een lijst maken van alle bestaande analyses
            Hashtable allAnalyses=LabAnalysis.getAllLabanalyses();
        	Hashtable allTreatedRequests=new Hashtable();
            SAXReader saxReader = new SAXReader(false);
            org.dom4j.Document document = saxReader.read(MedwanQuery.getInstance().getConfigString("templateSource")+"/monthlyreport.lab.DH.xml");
            Element root = document.getRootElement();
            Iterator labgroups = root.elementIterator("labgroup");
            String language="fr";
            if(user.person.language.toLowerCase().startsWith("e")){
                language="en";
            }
            else if(user.person.language.toLowerCase().startsWith("n")){
                language="nl";
            }
            int counter=0,at=0;;
            while(labgroups.hasNext()){
            	Element labgroup = (Element)labgroups.next();
            	boolean initialized=false;
            	String[] loinccodestoinclude,samplecodestoinclude,positives,positiveresults,labgroupstoinclude,loinccodestoexclude,lgs;
            	String analysisloinccodes,modifier,columns,pos,loinc,samp,labgr,lg;
            	LabAnalysis la;
            	Iterator analyses = labgroup.elementIterator("lab");
            	while(analyses.hasNext()){
            		Element analysis=(Element)analyses.next();
            		int positive=0,negative=0;
                	Hashtable treatedRequests=new Hashtable();
            		for(int n=0;n<results.size();n++){
            			RequestedLabAnalysis result = (RequestedLabAnalysis)results.elementAt(n);
            			boolean done=false;
						boolean isPositive=false;
						boolean matchingExam=false;
            			Iterator includes = analysis.elementIterator("include");
            			while(includes.hasNext() && !done){
            				Element include=(Element)includes.next();
            				if(include.attributeValue("loinc")!=null && include.attributeValue("loinc").length()>0){
            					loinc=ScreenHelper.checkString(include.attributeValue("loinc"));
            					loinccodestoinclude=loinc.split(";");
            					for(int i=0;i<loinccodestoinclude.length && !done;i++){
	            					la=(LabAnalysis)allAnalyses.get(result.getAnalysisCode());
	            					if(la!=null && la.getMedidoccode().contains(loinccodestoinclude[i])){
	                        			if(treatedRequests.get(result.getServerId()+"."+result.getTransactionId())==null){
		                    				matchingExam=true;
	                        				treatedRequests.put(result.getServerId()+"."+result.getTransactionId(),"1");
	                        				allTreatedRequests.put(result.getServerId()+"."+result.getTransactionId(),"1");
		            						//This is a labexam for which we have to check the results
		            						pos=ScreenHelper.checkString(include.attributeValue("positive"));
		            						positives=pos.split("$");
		            						for(int p=0;p<positives.length && !done;p++){
		            							if(positives[p].split(":").length>1){
			            							modifier=positives[p].split(":")[0];
			            							positiveresults=positives[p].split(":")[1].split(";");
			            							if(modifier.equalsIgnoreCase("not-equals")){
			            								if(result.getResultValue().trim().length()>0){
				            								isPositive=true;
				            								for(int q=0;q<positiveresults.length && !done;q++){
					            								if(result.getResultValue().equalsIgnoreCase(positiveresults[q])){
					            									isPositive=false;
					            									done=true;
					            								}
					            							}
			            								}
			            								else {
			            									isPositive=false;
			            								}
			            							}
			            							else if(modifier.equalsIgnoreCase("not-contains")){
			            								if(result.getResultValue().trim().length()>0){
				            								isPositive=true;
				            								for(int q=0;q<positiveresults.length && !done;q++){
					            								if(result.getResultValue().toLowerCase().indexOf(positiveresults[q].toLowerCase())>-1){
					            									isPositive=false;
					            									done=true;
					            								}
					            							}
			            								}
			            								else {
			            									isPositive=false;
			            								}
			            							}
			            							else if(modifier.equalsIgnoreCase("contains")){
			            								if(result.getResultValue().trim().length()>0){
				            								isPositive=false;
				            								for(int q=0;q<positiveresults.length && !done;q++){
					            								if(result.getResultValue().toLowerCase().indexOf(positiveresults[q].toLowerCase())>-1){
					            									isPositive=true;
					            								}
					            							}
			            								}
			            								else {
			            									isPositive=false;
			            								}
			            								if(!isPositive){
			            									done=true;
			            								}
			            							}
		            							}
		            						}
	                        			}
	            					}
            					}
            				}
            				else if(include.attributeValue("sample")!=null && include.attributeValue("sample").length()>0){
            					samp=ScreenHelper.checkString(include.attributeValue("sample"));
            					samplecodestoinclude=samp.split(";");
            					for(int i=0;i<samplecodestoinclude.length && !done;i++){
	            					la=(LabAnalysis)allAnalyses.get(result.getAnalysisCode());
	            					if(la!=null && la.getMonster().contains(samplecodestoinclude[i])){
	                        			if(treatedRequests.get(result.getServerId()+"."+result.getTransactionId())==null){
		                    				matchingExam=true;
	                        				treatedRequests.put(result.getServerId()+"."+result.getTransactionId(),"1");
	                        				allTreatedRequests.put(result.getServerId()+"."+result.getTransactionId(),"1");
		            						//This is a labexam for which we have to check the results
		            						pos=ScreenHelper.checkString(include.attributeValue("positive"));
		            						positives=pos.split("\\$");
		            						for(int p=0;p<positives.length && !done;p++){
		            							if(positives[p].split(":").length>1){
			            							modifier=positives[p].split(":")[0];
			            							positiveresults=positives[p].split(":")[1].split(";");
			            							if(modifier.equalsIgnoreCase("not-equals")){
			            								isPositive=true;
			            								for(int q=0;q<positiveresults.length && !done;q++){
				            								if(result.getResultValue().equalsIgnoreCase(positiveresults[q])){
				            									isPositive=false;
				            									done=true;
				            								}
				            							}
			            							}
			            							else if(modifier.equalsIgnoreCase("not-contains")){
			            								isPositive=true;
			            								for(int q=0;q<positiveresults.length && !done;q++){
				            								if(result.getResultValue().toLowerCase().indexOf(positiveresults[q].toLowerCase())>-1){
				            									isPositive=false;
				            									done=true;
				            								}
				            							}
			            							}
			            							else if(modifier.equalsIgnoreCase("contains")){
			            								isPositive=false;
			            								for(int q=0;q<positiveresults.length && !done;q++){
				            								if(result.getResultValue().toLowerCase().indexOf(positiveresults[q].toLowerCase())>-1){
				            									isPositive=true;
				            								}
				            							}
			            								if(!isPositive){
			            									done=true;
			            								}
			            							}
		            							}
		            						}
	                        			}
	            					}
            					}
            				}
            				else if(include.attributeValue("labgroup")!=null && include.attributeValue("labgroup").length()>0){
            					labgr=ScreenHelper.checkString(include.attributeValue("labgroup"));
            					//De mapping tussen een labgroup in de XML-file en de labgroups in de db wordt gemaakt via oc_config
            					//parameters waarvan de naam begint met 'labgroup_', vb 'labgroup_biochemistry=usualchemistry;biochemy'
            					//Zonder deze mapping wordt een 1 op 1 relatie verondersteld tussen de XML-file en de db
            					lgs=MedwanQuery.getInstance().getConfigString("labgroup_"+labgr.split(":")[0],labgr.split(":")[0]).split(";");
            					for(int o=0;o<lgs.length;o++){
            						lg=lgs[o];
	            					la=(LabAnalysis)allAnalyses.get(result.getAnalysisCode());
	            					if(la!=null && la.getLabgroup().contains(lg)){
	            						boolean excluded=false;
	            						if(labgr.split(":").length>1){
	            							loinccodestoexclude=labgr.split(":")[1].split(";");
	            							for(int r=0;r<loinccodestoexclude.length;r++){
	            								if(la.getMedidoccode().contains(loinccodestoexclude[r])){
	            									excluded=true;
	            									break;
	            								}
	            							}
	            						}
	            						if(!excluded && treatedRequests.get(result.getServerId()+"."+result.getTransactionId())==null){
		                    				matchingExam=true;
	                        				treatedRequests.put(result.getServerId()+"."+result.getTransactionId(),"1");
	                        				allTreatedRequests.put(result.getServerId()+"."+result.getTransactionId(),"1");
		            						//This is a labexam for which we have to check the results
		            						pos=ScreenHelper.checkString(include.attributeValue("positive"));
		            						positives=pos.split("\\$");
		            						for(int p=0;p<positives.length && !done;p++){
		            							if(positives[p].split(":").length>1){
			            							modifier=positives[p].split(":")[0];
			            							positiveresults=positives[p].split(":")[1].split(";");
			            							if(modifier.equalsIgnoreCase("not-equals")){
			            								isPositive=true;
			            								for(int q=0;q<positiveresults.length && !done;q++){
				            								if(result.getResultValue().equalsIgnoreCase(positiveresults[q])){
				            									isPositive=false;
				            									done=true;
				            								}
				            							}
			            							}
			            							else if(modifier.equalsIgnoreCase("not-contains")){
			            								isPositive=true;
			            								for(int q=0;q<positiveresults.length && !done;q++){
				            								if(result.getResultValue().toLowerCase().indexOf(positiveresults[q].toLowerCase())>-1){
				            									isPositive=false;
				            									done=true;
				            								}
				            							}
			            							}
			            							else if(modifier.equalsIgnoreCase("contains")){
			            								isPositive=false;
			            								for(int q=0;q<positiveresults.length && !done;q++){
				            								if(result.getResultValue().toLowerCase().indexOf(positiveresults[q].toLowerCase())>-1){
				            									isPositive=true;
				            								}
				            							}
			            								if(!isPositive){
			            									done=true;
			            								}
			            							}
		            							}
		            						}
	                        			}
	            					}
            					}
            				}
            			}
						if(matchingExam){
	            			if(isPositive){
								positive++;
							}
							else {
								negative++;
							}
						}
            		}
            		if(!initialized){
                        cell=createBorderCell(ScreenHelper.checkString(labgroup.attributeValue(language)),8,1);
                        cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
                        table.addCell(cell);
            		}
            		else{
                        cell=createBorderCell("",8,1);
                        cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
                        table.addCell(cell);
            		}
                    table.addCell(createBorderCell(analysis.attributeValue(language),8,3));
                    columns=ScreenHelper.checkString(analysis.attributeValue("columns"));
                    if(columns.indexOf("positive")>-1){
                    	table.addCell(createBorderCell(positive+"",8,1));
                    }
                    else {
                    	cell=createBorderCell("",8,1);
                    	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    	table.addCell(cell);
                    }
                    if(columns.indexOf("negative")>-1){
                    	table.addCell(createBorderCell(negative+"",8,1));
                    }
                    else {
                    	cell=createBorderCell("",8,1);
                    	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    	table.addCell(cell);
                    }
                    if(columns.indexOf("total")>-1){
                    	table.addCell(createBorderCell((positive+negative)+"",8,1));
                		at+=positive+negative;
                    }
                    else {
                    	cell=createBorderCell("",8,1);
                    	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    	table.addCell(cell);
                    }
            		initialized=true;
            	}
            }
            //Now we add all other exams
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.other.exams",user.person.language),8,4));
        	cell=createBorderCell("",8,1);
        	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        	table.addCell(cell);
        	cell=createBorderCell("",8,1);
        	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        	table.addCell(cell);
        	table.addCell(createBorderCell((results.size()-at)+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.total",user.person.language),8,4));
        	cell=createBorderCell("",8,1);
        	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        	table.addCell(cell);
        	cell=createBorderCell("",8,1);
        	cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        	table.addCell(cell);
        	table.addCell(createBorderCell(results.size()+"",8,1));
            doc.add(table);
            
            //Now add medical imaging
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.imaging.title",user.person.language),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.type",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.number",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.xrays",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.lungs",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.bones",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.abdomen",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.abdomen.contrast",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.other.xrays",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.gastroscopy",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.echography",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","diagnostics.ecg",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));
            doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }

    protected void printFunctionalRehabilitation(Date begin,Date end){
    	try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","rehab.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderlessCell("",5,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","rehab.outpatient",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","rehab.inpatient",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","rehab.total",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","rehab.newcases",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","rehab.sessions",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    
    protected void printAnesthaesia(Date begin,Date end){
    	try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.types",user.person.language),5,2,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.total",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.general",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.with.gas",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.with.ketamine",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.rachi",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.locale",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.other",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","anesthaesia.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,4));
            
            doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    
    protected void printOperatingTheatre(Date begin,Date end){
    	try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","ot.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.departments",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.procedure.type",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.emergency",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.planned",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.post.intervention.infection",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total",user.person.language),8,1));
    		
            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.general.surgery",user.person.language),8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.appendectomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.hernia",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.laparatomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.thyroidectomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.cataract",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.adenectomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.trachoma",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.glaucoma",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.other",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.gynaecology",user.person.language),8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.ceasarian",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.hysterectomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.laparotomy.geu",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.laparotomy.other",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.myomectomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.curettage",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.orthopaedics",user.person.language),8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.amputations",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.osteosynthesis",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.other",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total.procedures",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",8,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total.procedures.major",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",8,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ot.total.procedures.minor",user.person.language),8,3));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",8,2));
            
            doc.add(table);

    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    
    protected void printFamilyPlanning(Date begin,Date end){
    	try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderlessCell("",5,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.district",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.out.of.district",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.total",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,3));
    		
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.new",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.old",user.person.language),8,1));
            cell=createBorderCell("",8,1);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(cell);
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,3));

            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.used.methods",user.person.language),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderlessCell("",5,1));
            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.age",user.person.language),8,5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.total",user.person.language),8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.methods",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.15to24",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.25to34",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.35to44",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.45to49",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.morethan50",user.person.language),8,1));
            cell=createBorderCell("",8,1);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.diu",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.vasectomy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.ligature",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.implant",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.injection",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.pill",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.preservative",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.mjf",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    	
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","familyplanning.total",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            
            doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    
    protected void printMaternityData(Date begin,Date end){
    	try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","maternity.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","maternity.deliveries",user.person.language),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderlessCell("",5,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.referred.HC.labour",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.referred.HC.CPN",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.referred.HC.illness",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.numberof.HIV",user.person.language),8,1));
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.eutocic",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.dystocic",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.dystocic.caesarian",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.dystocic.ventouse",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.dystocic.forceps",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.dystocic.craniotomia",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.total.deliveries",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.deceased.mothers",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
    		
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.observations.72h",user.person.language),8,4));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
    		
            table.addCell(createBorderlessCell("",5,7));

            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.according.to.origin",user.person.language),8,2,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.district",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.out.of.district",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.total",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.number.DH",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.according.to.pmtct",user.person.language),8,2,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.district",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.out.of.district",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.total",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.number.women.ARV",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.number.children.ARV",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            
            table.addCell(createBorderlessCell("",5,7));
            doc.add(table);
            
            table = new PdfPTable(4);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.causes.title",user.person.language),10,4,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,4));

            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.causes",user.person.language),8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            table.addCell(cell);
            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.number.of.cases",user.person.language),8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.child.future",user.person.language),8,2));

            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.child.alive",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.child.dead",user.person.language),8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.dystocic",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.foetal.distress",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.preeclampsy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.eclampsy",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.bad.position",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.iterative",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.caesarian.other.causes",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            doc.add(table);
            
            table = new PdfPTable(4);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,4));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.title",user.person.language),10,4,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,4));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.quantity",user.person.language),8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.placenta.retention",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.hemorrhage",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.uterine.rupture",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.anemia",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.fever",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.infections",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.perineal.tear",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.cervix.tear",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.rectovaginal.fistel",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.complications.death",user.person.language),8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            doc.add(table);
            
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.title",user.person.language),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));

            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.total",user.person.language),8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            table.addCell(cell);
            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.live",user.person.language),8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            table.addCell(cell);
            cell=createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.death",user.person.language),8,3);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            table.addCell(cell);

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBorderCell("",8,1);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.perinatal.mortality",user.person.language),8,2));

            cell=createBorderCell("",8,2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.lessthan2.5kg",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.morethan2.5kg",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.inutero",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.mortality.at.birth",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.births.mortality.neonatal",user.person.language),8,1));

            table.addCell(createBorderCell(" ",8,2));
            table.addCell(createBorderCell(" ",8,1));
            table.addCell(createBorderCell(" ",8,1));
            table.addCell(createBorderCell(" ",8,1));
            table.addCell(createBorderCell(" ",8,1));
            table.addCell(createBorderCell(" ",8,1));
            doc.add(table);
            
            table = new PdfPTable(5);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,5));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.mothers.title",user.person.language),10,5,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,5));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.children",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.pcr.6months",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.of.whom.hivpositive",user.person.language),8,1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.child.tested.9months",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.of.whom.hivpositive",user.person.language),8,1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.child.tested.18months",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            cell=createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.of.whom.hivpositive",user.person.language),8,1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.mothermilk.only",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.artificial.food",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","maternity.hiv.weaned.6months",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,2));
            doc.add(table);

    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    protected void printDeliveryData(Date begin,Date end, Report_Transaction report_transaction){
        try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","delivery.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));
            table.addCell(createBorderlessCell("",5,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.dyst",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.hivpos",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.referral",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.dead",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.healthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_TYPE,dystocy;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH,+;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithOutcomeNoLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs","reference")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithOutcomeNoLocation("F","be.mxs.common.model.vo.healthrecord.ICon" +
                    "stants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs","dead")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.outofhealthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","hors.cs")+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH,+;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,hors.cs")+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","delivery.geographic",user.person.language),8,3,Font.BOLD);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.healthcenter",user.person.language),8,3));
            int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT");
            int total=n;
            int a=n;
            table.addCell(createBorderCell(n+"",8,1));
            n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT");
            total+=n;
            table.addCell(createBorderCell(n+"",8,1));
            n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT");
            total+=n;
            table.addCell(createBorderCell(n+"",8,1));
            table.addCell(createBorderCell(total+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.coverage",user.person.language),8,6));
            Report_Identification report_identification = new Report_Identification(end);
            try{
                double expectedPregnant = Double.parseDouble(report_identification.getItem("OC_HC_POPULATION_PREG"));
                long d = end.getTime()-begin.getTime();
                d=d/(1000*3600*24);
                table.addCell(createBorderCell(a*100/(expectedPregnant*d/365)+"",8,1));
            }
            catch(Exception e2){
                e2.printStackTrace();
                table.addCell(createBorderCell("",8,1));
            }
            doc.add(table);
            table = new PdfPTable(8);
            table.addCell(createBorderlessCell("",5,8));
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","delivery.births",user.person.language),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(createBorderlessCell("",2));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.dead",user.person.language),8,3));
            table.addCell(createBorderlessCell("",2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.lt2.5",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.reference",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.atbirth",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.inutero",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.healthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countSmallerWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_POIDS",2.5)+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_REFERENCE_HD,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs")+"",8,1));
            int mortnenaiss=0,mortneinutero=0;
            mortnenaiss=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,birth;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs");
            mortneinutero=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,inutero;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs");
            table.addCell(createBorderCell((mortneinutero+mortnenaiss)+"",8,1));
            table.addCell(createBorderCell(mortnenaiss+"",8,1));
            table.addCell(createBorderCell(mortneinutero+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.outofhealthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","hors.cs")+"",8,1));
            table.addCell(createGreyCell("",1));
            table.addCell(createGreyCell("",1));
            mortnenaiss=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,birth;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,hors.cs");
            mortneinutero=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,inutero;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,hors.cs");
            table.addCell(createBorderCell((mortneinutero+mortnenaiss)+"",8,1));
            table.addCell(createGreyCell("",1));
            table.addCell(createGreyCell("",1));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printPrenatalData(Date begin,Date end, Report_Transaction report_transaction){
        try {
            table = new PdfPTable(10);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","prenatal.title",user.person.language),14,10,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,10));
            table.addCell(createBorderCell("",8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,1));
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","prenatal.comment1",user.person.language),8,2));
            int a=addPrenatalRow(begin,end,report_transaction,"cpn.newinscriptions","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","nouvelle.inscription");
            Report_Identification report_identification = new Report_Identification(end);
            try{
                double expectedPregnant = Double.parseDouble(report_identification.getItem("OC_HC_POPULATION_PREG"));
                long d = end.getTime()-begin.getTime();
                d=d/(1000*3600*24);
                table.addCell(createBorderCell(a*100/(expectedPregnant*d/365)+"",8,2));
            }
            catch(Exception e2){
                table.addCell(createBorderCell("",8,2));
            }
            addPrenatalRow(begin,end,report_transaction,"cpn.1.trimestre","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","premier.trimestre");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.2.trimestre","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","deuxieme.trimestre");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.7.8.mois","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","7.8.mois");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.9.mois","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","9.mois");
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","prenatal.comment2",user.person.language),8,2));
            //todo
            int b=addPrenatalRow(begin,end,report_transaction,"cpn.4visits","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","4.visits");
            table.addCell(createBorderCell(b+"",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.othervisits","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","autre");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.grossesse.risque.depistee","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE","true");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.grossesse.rsique.referee","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE","true","reference");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.total","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.I","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI","I");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.II","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI","II");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.III","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI","III");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.total","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.1","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","1");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.2","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","2");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.3","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","3");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.4","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","4");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.5","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","5");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.fer","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_FER_ACIDE_FOLIQUE","true");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.moustiquaire","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_MOUSTIQUAIRE_IMPREGNEE","true");
            table.addCell(createBorderlessCell("",8,2));
            doc.add(table);

            //PMTCT
            table = new PdfPTable(8);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.title",user.person.language),14,10,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(createBorderCell("",8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,1));
            addPMTCTRow(begin,end,report_transaction,"pmtct.counseling","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COUNSELLING","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct.vih.tested","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct.rpr.tested","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct..received.results","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RECUPERATION_RESULTATS","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct.with.partner","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE","true");
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.total.tested",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH","true")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.vihpos",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH,+")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.partner.tested",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE","true")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.vihpos",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH,+")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.rpr.tested",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR","true")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.rprpos",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RPR,+")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.eligible.tritherapy",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_ARV","true")+"",8,1));
            table.addCell(createBorderlessCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.eligible.prophylaxie",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_PROPHYLAXIE","true")+"",8,1));
            table.addCell(createBorderlessCell("",8,3));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private int addPrenatalRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    private int addPrenatalRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype,String itemvalue){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    private int addPMTCTRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype,String itemvalue){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT",itemtype,itemvalue);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    private int addPrenatalRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype,String itemvalue,String outcome){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.countWithOutcome("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue,outcome);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.countWithOutcome("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue,outcome);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.countWithOutcome("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue,outcome);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    protected void printPVVData(Date begin,Date end, Report_Transaction report_transaction){
        try {
            table = new PdfPTable(24);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.HD",user.person.language),14,24,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,24));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.depistage",user.person.language),8,24,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,24));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","pvv.categories",user.person.language),8,10));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt35y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.35to50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,10));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.individual",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECU_INDIVIDUELLEMENT","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.counseled",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_CONSEILLE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.tested",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TESTE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.couples.tested",user.person.language),8,10));
            addPVVRowTotalsOnly(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PARTENAIRE_TESTE,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TESTE,true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.retrievedresults",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECUPERATION_RESULTATS","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.testedvihpos",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH","+");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.testedvihposwithresult",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH,+;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECUPERATION_RESULTATS,true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.partners.tested",user.person.language),8,10));
            addPVVRowTotalsOnly(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PARTENAIRE_TESTE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.couples.serodiscordance",user.person.language),8,10));
            addPVVRowTotalsOnly(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SERODISCORDANCE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.followup",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SUIVI_VIH,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH,+");
            doc.add(table);

            //Suivi
            table = new PdfPTable(12);
            table.setWidthPercentage(pageWidth/2);
            table.setHorizontalAlignment(PdfPTable.ALIGN_LEFT);
            table.addCell(createBorderlessCell("",5,12));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.followup",user.person.language),8,12,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,12));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","pvv.followup",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt15y",user.person.language),8,6));
            addPVVFollowUpRow(report_transaction,0,5474);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt25y",user.person.language),8,6));
            addPVVFollowUpRow(report_transaction,5475,9124);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.adults",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt35y",user.person.language),8,3));
            addPVVFollowUpRow(report_transaction,9125,12774);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt50y",user.person.language),8,3));
            addPVVFollowUpRow(report_transaction,12775,18249);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.mt50y",user.person.language),8,3));
            addPVVFollowUpRow(report_transaction,18250,36500);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,6));
            addPVVFollowUpRow(report_transaction,0,36500);
            doc.add(table);

            //Prise en charge
            table = new PdfPTable(36);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,36));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.care",user.person.language),8,36,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,36));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","pvv.patient.categories",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.underarv",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.iotreatment",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.isttreatment",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.bactrim",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.tbc",user.person.language),8,6));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt15y",user.person.language),8,6));
            addPVVCareRow(report_transaction,0,5474);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt25y",user.person.language),8,6));
            addPVVCareRow(report_transaction,5475,9124);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.adults",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt35y",user.person.language),8,3));
            addPVVCareRow(report_transaction,9125,12774);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt50y",user.person.language),8,3));
            addPVVCareRow(report_transaction,12775,18249);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.mt50y",user.person.language),8,3));
            addPVVCareRow(report_transaction,18250,36500);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,6));
            addPVVCareRow(report_transaction,0,36500);
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void addPVVCareRow(Report_Transaction report_transaction,int minage,int maxage){
        int mtot=0,ftot=0,n=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
    }

    private void addPVVFollowUpRow(Report_Transaction report_transaction,int minage,int maxage){
        int mtot=0,ftot=0,n=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
    }

    private void addPVVRow(Report_Transaction report_transaction,String transactionType,String itemType,String itemValue){
        table.addCell(createBorderCell(report_transaction.count(0,1824,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,1824,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,itemType,itemValue)+"",8,1));
    }

    private void addPVVRow(Report_Transaction report_transaction,String transactionType,String item){
        table.addCell(createBorderCell(report_transaction.count(0,1824,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,1824,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,item)+"",8,1));
    }

    private void addPVVRowTotalsOnly(Report_Transaction report_transaction,String transactionType,String itemType,String itemValue){
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,itemType,itemValue)+"",8,1));
    }

    private void addPVVRowTotalsOnly(Report_Transaction report_transaction,String transactionType,String item){
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,item)+"",8,1));
    }

    protected void printConsultationData(Date begin, Date end){
        try {
            table = new PdfPTable(24);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","consultation.title",user.person.language),14,24,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,24));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","consultation.reasons",user.person.language),8,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt30d",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt12m",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,8));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            Report_RFE report_rfe = new Report_RFE(begin,end,"visit");
            SAXReader saxReader = new SAXReader(false);
            org.dom4j.Document document = saxReader.read(MedwanQuery.getInstance().getConfigString("templateSource")+"/monthlyreport.consultations.DH.xml");
            Element root = document.getRootElement();
            Element consultations = root.element("consultations");
            Iterator rfes = consultations.elementIterator("rfe");
            String language="fr";
            if(user.person.language.toLowerCase().startsWith("e")){
                language="en";
            }
            else if(user.person.language.toLowerCase().startsWith("n")){
                language="nl";
            }
            int counter=0;
            while(rfes.hasNext()){
                //First print disease label
                Element rfe = (Element)rfes.next();
                table.addCell(createBorderCell(rfe.attributeValue(language),8,8));
                String codes = rfe.attributeValue("codes");
                String flags = rfe.attributeValue("flags");
                Iterator cases = rfe.elementIterator("case");
                counter=0;
                while(cases.hasNext()){
                    counter++;
                    Element c = (Element)cases.next();
                    if(c.attributeCount()==0){
                        table.addCell(createGreyCell("",1));
                    }
                    else {
                        int minage = Integer.parseInt(c.attributeValue("minage"));
                        int maxage = Integer.parseInt(c.attributeValue("maxage"));
                        String gender = c.attributeValue("gender");
                        int count = report_rfe.count(codes,gender,minage,maxage,flags);
                        if(count==0){
                            cell=createBorderCell(count+"",8,1,BaseColor.LIGHT_GRAY);
                        }
                        else {
                            cell=createBorderCellBold(count+"",8,1);
                        }
                        table.addCell(cell);
                    }
                }
                if(counter<16){
                    table.addCell(emptyCell(16-counter));
                }
            }
            //nu nog de 'andere' ziekten uitlijsten
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.reasons",user.person.language),8,8));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            Element otherrfe = consultations.element("otherrfe");
            //Nu alle overblijvende RFE's opvragen
            Hashtable uncounted = report_rfe.getUncountedRFEs();
            Iterator i = uncounted.values().iterator();
            while(i.hasNext()){
                Report_RFE.RFE uncountedRfe = (Report_RFE.RFE)i.next();
                if(uncountedRfe.isNewcase()){
                    table.addCell(createBorderCell(MedwanQuery.getInstance().getCodeTran(uncountedRfe.getCodeType()+"code"+uncountedRfe.getCode(),language),8,8));
                    Iterator cases = otherrfe.elementIterator("case");
                    counter=0;
                    while(cases.hasNext()){
                        counter++;
                        Element c = (Element)cases.next();
                        if(c.attributeCount()==0){
                            table.addCell(createGreyCell("",1));
                        }
                        else {
                            int minage = Integer.parseInt(c.attributeValue("minage"));
                            int maxage = Integer.parseInt(c.attributeValue("maxage"));
                            String gender = c.attributeValue("gender");
                            int count = report_rfe.count(uncountedRfe.getCodeType()+":"+uncountedRfe.getCode(),gender,minage,maxage,"N");
                            if(count==0){
                                cell=createBorderCell(count+"",8,1,BaseColor.LIGHT_GRAY);
                            }
                            else {
                                cell=createBorderCellBold(count+"",8,1);
                            }
                            table.addCell(cell);
                        }
                    }
                }
            }
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,8));
            Iterator cases = otherrfe.elementIterator("case");
            counter=0;
            while(cases.hasNext()){
                counter++;
                Element c = (Element)cases.next();
                if(c.attributeCount()==0){
                    table.addCell(createGreyCell("",1));
                }
                else {
                    int minage = Integer.parseInt(c.attributeValue("minage"));
                    int maxage = Integer.parseInt(c.attributeValue("maxage"));
                    String gender = c.attributeValue("gender");
                    int count = report_rfe.count("ICPC:A-Z9999;ICD10:A-Z99.9",gender,minage,maxage,"N");
                    if(count==0){
                        cell=createBorderCell(count+"",8,1,BaseColor.GRAY);
                    }
                    else {
                        cell=createBorderCellBold(count+"",8,1);
                    }
                    table.addCell(cell);
                }
            }
            if(counter<16){
                table.addCell(emptyCell(16-counter));
            }
            doc.add(table);
            doc.newPage();
            
            table = new PdfPTable(16);
            table.setWidthPercentage(pageWidth);
            cell=createLabel("\n"+MedwanQuery.getInstance().getLabel("report.monthly","consultation.synthetictable",user.person.language)+"\n",8,16,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.consultations",user.person.language),2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.district",user.person.language),8,4));
            cell = new PdfPCell(new Paragraph(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell = new PdfPCell(new Paragraph(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.newcase.insured",user.person.language),8,4));
            table.addCell(createBorderCell("",8,2));

            table.addCell(emptyCell(2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.referedbyhc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.notreferredbyhc",user.person.language),8,2));
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.tariff.curative.cons",user.person.language),8,4));
            table.addCell(createBorderCell("",8,2));

            cell = new PdfPCell(new Paragraph(MedwanQuery.getInstance().getLabel("report.monthly","consultation.newcases.hd",user.person.language),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            int allnewcases=report_rfe.countNewCases("MF");
            int outofdistrictnewcases=report_rfe.countLocations("3");
            int indistrictreferrednewcases=report_rfe.countLocationDifferentFromOrigins("3", "healthcenter", true, "MF");
            int indistrictnonreferrednewcases=report_rfe.countLocationDifferentFromOriginsDifferentFrom("3", "healthcenter", true, "MF");
            cell = new PdfPCell(new Paragraph(indistrictreferrednewcases+"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell = new PdfPCell(new Paragraph(indistrictnonreferrednewcases+"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell = new PdfPCell(new Paragraph(outofdistrictnewcases+"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell = new PdfPCell(new Paragraph(allnewcases+"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.tariff.forfait.NC.and.acts",user.person.language),8,4));
            table.addCell(createBorderCell("",8,2));
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=emptyCell(2);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.tariff.average.drugs.NC",user.person.language),8,4));
            table.addCell(createBorderCell("",8,2));
            
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.oldcases",user.person.language),8,2));
            table.addCell(createGreyCell("",6));
            int alloldcases=report_rfe.countOldCases();
            table.addCell(createBorderCell(alloldcases+"",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total.NC.for.free",user.person.language),8,4));
            table.addCell(createBorderCell("",8,2));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.totalcases",user.person.language),8,2));
            table.addCell(createGreyCell("",6));
            table.addCell(createBorderCell(alloldcases+allnewcases+"",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total.NC.for.free.indigents",user.person.language),8,4));
            table.addCell(createBorderCell("",8,2));
            doc.add(table);
            
            //Références issues des FOSA de premier échelon
            table = new PdfPTable(17);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",8,17));
            table.addCell(createBorderlessCell("",8,17));
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.references.from.fosa",user.person.language),8,17));
            table.addCell(createBorderlessCell("",8,17));
            //line 1
            table.addCell(emptyCell(2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total.number",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.on.request",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.justified",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.late",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.with.admission",user.person.language),8,3));
            //line 2
            table.addCell(emptyCell(2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.mutuelle",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.not.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.mutuelle",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.not.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.mutuelle",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.not.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.mutuelle",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.not.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.mutuelle",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.insured",user.person.language),6,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.not.insured",user.person.language),6,1));
            //Line 3
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.cpn",user.person.language),8,2));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            //Line 4
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.delivery",user.person.language),8,2));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            //Line 5
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.diagnostic",user.person.language),8,2));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            //Line 6
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.pec",user.person.language),8,2));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            //Line 7
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.specialises.exam",user.person.language),8,2));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            table.addCell(createBorderCell("",6,1));
            //Line 8
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.legal.documents",user.person.language),8,2));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            table.addCell(createGreyCell("", 1));
            //Line 9
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other",user.person.language),8,2));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            //Line 10
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total.referred.cases",user.person.language),8,2));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            table.addCell(createBorderCell("",6,3));
            //Line 11
            table.addCell(createBorderlessCell("",8,17));
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.contra.references",user.person.language),8,8));
            table.addCell(createBorderCell("",6,2));
            table.addCell(emptyCell(7));
            doc.add(table);
            
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printSexualViolenceData(Date begin, Date end){
        try {
	        table = new PdfPTable(20);
	        table.setWidthPercentage(pageWidth);
	        cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.title",user.person.language),14,20,Font.BOLD);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        table.addCell(createBorderlessCell("",8,20));
	        table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.effective.cases",user.person.language),8,20));
	
	        table.addCell(emptyCell(9));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.age.and.gender",user.person.language),8,11));
	        
	        table.addCell(emptyCell(9));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.lessthan5",user.person.language),8,3));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.5to18",user.person.language),8,3));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.morethan18",user.person.language),8,3));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.total",user.person.language),8,2));
	        
	        table.addCell(emptyCell(9));
	        table.addCell(createBorderCell("M",8,1));
	        table.addCell(createBorderCell("F",8,1));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.total",user.person.language),8,1));
	        table.addCell(createBorderCell("M",8,1));
	        table.addCell(createBorderCell("F",8,1));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.total",user.person.language),8,1));
	        table.addCell(createBorderCell("M",8,1));
	        table.addCell(createBorderCell("F",8,1));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.total",user.person.language),8,1));
	        table.addCell(createBorderCell("M",8,1));
	        table.addCell(createBorderCell("F",8,1));
	        
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.received.suspected",user.person.language),8,9));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.received.signs",user.person.language),8,9));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        table.addCell(createBorderCell("",8,1));
	        
	        table.addCell(createBorderlessCell("",8,20));
	        table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.evocative.signs",user.person.language),8,20));
	        table.addCell(createBorderlessCell("",8,20));
	
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.age",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.gender",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.hivplus",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.hiv-",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.tear",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.istplus",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.ist-",user.person.language),8,2));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.other.lesions",user.person.language),8,4));
	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.total",user.person.language),8,2));

	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.lessthan5",user.person.language),8,2));
	        table.addCell(createBorderCell("M",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("F",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.5to18",user.person.language),8,2));
	        table.addCell(createBorderCell("M",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("F",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.morethan18",user.person.language),8,2));
	        table.addCell(createBorderCell("M",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("F",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sexual.violence.total",user.person.language),8,2));
	        table.addCell(createBorderCell("M",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("F",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,2));
	        table.addCell(createBorderCell("",8,4));
	        table.addCell(createBorderCell("",8,2));

	        doc.add(table);
        }
        catch(Exception e){
        	e.printStackTrace();
        }
    }
    
    protected void printAdmissionData(Date begin, Date end){
        try {
            Report_Identification report_identification = new Report_Identification(end);
            table = new PdfPTable(10);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","admission.title.HD",user.person.language),14,10,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,10));

            table.addCell(createLabel(MedwanQuery.getInstance().getLabel("report.monthly","admissions",user.person.language),8,2,Font.NORMAL));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","internal.medicine",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pediatrics",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","surgery",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","obstetrics",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","nutrition",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","usi",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","specialisations",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","total",user.person.language),8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.number.of.beds",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.present.begin",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.entered",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.zone.entered.referred.by.HC",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.zone.entered.nonreferred.by.HC",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.out.of.zone",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.authorized",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.escaped",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.died",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.referrals",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.contrareferrals",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","present.end",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.total.length.of.stay",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.average.length.of.stay",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.potential",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.effective",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.occupancy",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderlessCell("",5,10));
            table.addCell(createLabel(MedwanQuery.getInstance().getLabel("report.monthly","admission.insurance",user.person.language),8,10,Font.NORMAL));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.nopay",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.nopay.indigents",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","departures.nopay.other",user.person.language),8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));

            table.addCell(createBorderlessCell("",5,10));
            table.addCell(createLabel(MedwanQuery.getInstance().getLabel("report.monthly","admission.proportion.referrals",user.person.language),8,2,Font.NORMAL));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",8,7));
            table.addCell(createBorderlessCell("",5,10));
            doc.add(table);
            
            table = new PdfPTable(42);
            table.setWidthPercentage(pageWidth);

            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","admission.newcases",user.person.language),8,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt30d",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt12m",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt50y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.pregnantwomen",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,4));
            
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.atdischarge",user.person.language),8,8));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,1));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            
            table.addCell(createBorderCell("",8,8));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            
            Report_Diagnosis report_diagnosis = new Report_Diagnosis(begin,end,"admission");
            SAXReader saxReader = new SAXReader(false);
            org.dom4j.Document document = saxReader.read(MedwanQuery.getInstance().getConfigString("templateSource")+"/monthlyreport.admissions.DH.xml");
            Element root = document.getRootElement();
            Element consultations = root.element("admissions");
            Iterator diagnoses = consultations.elementIterator("diagnosis");
            String language="fr";
            if(user.person.language.toLowerCase().startsWith("e")){
                language="en";
            }
            else if(user.person.language.toLowerCase().startsWith("n")){
                language="nl";
            }
            int counter=0;
            while(diagnoses.hasNext()){
                //First print disease label
                Element diagnosis = (Element)diagnoses.next();
                table.addCell(createBorderCell(diagnosis.attributeValue(language),8,8));
                String codes = diagnosis.attributeValue("codes");
                String flags = diagnosis.attributeValue("flags");
                Iterator cases = diagnosis.elementIterator("case");
                counter=10;
                while(cases.hasNext()){
                    Element c = (Element)cases.next();
                    if(c.attributeCount()==0){
                        table.addCell(createGreyCell("",1));
                        counter++;
                    }
                    else {
                        int minage = Integer.parseInt(c.attributeValue("minage"));
                        int maxage = Integer.parseInt(c.attributeValue("maxage"));
                        String gender = c.attributeValue("gender");
                        int count;
                        if("yes".equalsIgnoreCase(c.attributeValue("days"))){
                            count = report_diagnosis.countDuration(codes,gender,minage,maxage,flags+("yes".equalsIgnoreCase(c.attributeValue("pregnant"))?"E":""));
                        }
                        else {
                            count = report_diagnosis.count(codes,gender,minage,maxage,flags+("yes".equalsIgnoreCase(c.attributeValue("pregnant"))?"E":""));
                        }
                        if(count==0){
                            cell=createBorderCell(count+"",6,(ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1),BaseColor.LIGHT_GRAY);
                        }
                        else {
                            cell=createBorderCellBold(count+"",6,(ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1));
                        }
                        table.addCell(cell);
                        counter+=(ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1);
                    }
                }
                if(counter<42){
                    table.addCell(emptyCell(42-counter));
                }
            }
            //nu nog de 'andere' ziekten uitlijsten
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.diagnoses",user.person.language),8,8));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            Element otherdiagnoses = consultations.element("otherdiagnosis");
            //Nu alle overblijvende Diagnoses opvragen
            Hashtable uncounted = report_diagnosis.getUncountedDiagnoses();
            Iterator i = uncounted.values().iterator();
            while(i.hasNext()){
                Report_Diagnosis.Diagnosis uncountedDiagnosis = (Report_Diagnosis.Diagnosis)i.next();
                if(uncountedDiagnosis.isNewcase()){
                    table.addCell(createBorderCell(MedwanQuery.getInstance().getCodeTran(uncountedDiagnosis.getCodeType()+"code"+uncountedDiagnosis.getCode(),language),8,8));
                    Iterator cases = otherdiagnoses.elementIterator("case");
                    counter=10;
                    while(cases.hasNext()){
                        Element c = (Element)cases.next();
                        counter+=ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1;
                        if(c.attributeCount()==0){
                            table.addCell(createGreyCell("",1));
                        }
                        else {
                            int minage = Integer.parseInt(c.attributeValue("minage"));
                            int maxage = Integer.parseInt(c.attributeValue("maxage"));
                            String gender = c.attributeValue("gender");
                            int count;
                            if("yes".equalsIgnoreCase(c.attributeValue("days"))){
                                count = report_diagnosis.countDuration(uncountedDiagnosis.getCodeType()+":"+uncountedDiagnosis.getCode(),gender,minage,maxage,"N");
                            }
                            else {
                                count = report_diagnosis.count(uncountedDiagnosis.getCodeType()+":"+uncountedDiagnosis.getCode(),gender,minage,maxage,"N");
                            }
                            if(count==0){
                                cell=createBorderCell(count+"",6,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1,BaseColor.LIGHT_GRAY);
                            }
                            else {
                                cell=createBorderCellBold(count+"",6,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1);
                            }
                            table.addCell(cell);
                        }
                    }
                }
            }
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.total",user.person.language),8,8));
            Iterator cases = otherdiagnoses.elementIterator("case");
            counter=10;
            while(cases.hasNext()){
                Element c = (Element)cases.next();
                counter+=ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1;
                if(c.attributeCount()==0){
                    table.addCell(createGreyCell("",1));
                }
                else {
                    int minage = Integer.parseInt(c.attributeValue("minage"));
                    int maxage = Integer.parseInt(c.attributeValue("maxage"));
                    String gender = c.attributeValue("gender");
                    int count;
                    if("yes".equalsIgnoreCase(c.attributeValue("days"))){
                        count = report_diagnosis.countDuration("ICPC:A-Z9999;ICD10:A-Z99.9",gender,minage,maxage,"N");
                    }
                    else {
                        count = report_diagnosis.count("ICPC:A-Z9999;ICD10:A-Z99.9",gender,minage,maxage,"N");
                    }
                    if(count==0){
                        cell=createBorderCell(count+"",6,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1,BaseColor.GRAY);
                    }
                    else {
                        cell=createBorderCellBold(count+"",6,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1);
                    }
                    table.addCell(cell);
                }
            }
            if(counter<42){
                table.addCell(emptyCell(42-counter));
            }
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printIdentification(Date end){
        try {
            Report_Identification report_identification = new Report_Identification(end);
            table = new PdfPTable(16);
            table.setWidthPercentage(pageWidth);
            table.addCell(createLabel(MedwanQuery.getInstance().getLabel("report.monthly","district_hospital.title",user.person.language),14,16,Font.BOLD));
            table.addCell(createBorderlessCell("",5,16));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","identification.title",user.person.language),14,16,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,16));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","year",user.person.language),8,2));
            table.addCell(createBorderCell(new SimpleDateFormat("yyyy").format(end),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","month",user.person.language),8,2));
            table.addCell(createBorderCell(new SimpleDateFormat("MM").format(end),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","province",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_PROVINCE"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sector",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_SECTEUR"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","district",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_DISTRICT"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","cell",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_CELL"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","fosa",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_FOSA"),8,6));
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(emptyCell(16));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","identification.remarks",user.person.language),8,16,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","epidemiology",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_EPIDEMIOLOGIE"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","drugs",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_DRUGS"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","vaccinations",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_VACCINATIONS"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","equipment",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_EQUIPMENT"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","building",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_BUILDING"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","transport",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_TRANSPORT"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","personnel",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_PERSONNEL"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","other",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_OTHER"),8,12));
            table.addCell(emptyCell(16));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","contactname",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_CONTACTNAME"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datesent",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","qualification",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datereceived",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datecreated",user.person.language),8,2));
            table.addCell(createBorderCell(ScreenHelper.stdDateFormat.format(new Date()),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","signature",user.person.language),8,2));
            table.addCell(createBorderCell("\n\n\n\n\n",8,6));
            table.addCell(emptyCell(8));
            doc.add(table);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datecreated",user.person.language),8,2));

            table = new PdfPTable(12);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","title.population",user.person.language),8,12,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.total.zone",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.total.insured",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt30d",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt12m",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt50y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.pregnant",user.person.language),8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_TOTAL"),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_MUT")+"%",8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT1M")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT1Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT5Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT25Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT25Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT50Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_MT50Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_PREG")+"/"+MedwanQuery.getInstance().getLabel("web","year",user.person.language),8,1));
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","population.source",user.person.language),12));
            table.addCell(emptyCell(12));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- PRINT VECTOR ----------------------------------------------------------------------------
    protected String printVector(Vector vector){
        StringBuffer buf = new StringBuffer();
        for(int i=0; i<vector.size(); i++){
            buf.append(vector.get(i)).append(", ");
        }

        // remove last comma
        if(buf.length() > 0) buf.deleteCharAt(buf.length()-2);

        return buf.toString();
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int height, int colspan, int fontsize){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderCell(String value, int fontsize, int colspan, BaseColor color){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.NORMAL,color)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderCell(String value, int fontsize, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderCellBold(String value, int fontsize, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}