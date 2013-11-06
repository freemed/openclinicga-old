package be.openclinic.finance;

import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

import com.itextpdf.text.pdf.PdfPTable;

public class CsvInvoiceRamaExtra {
    static DecimalFormat priceFormatInsurar = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatInsurar","#,##0.00"));

	public static String getOutput(javax.servlet.http.HttpServletRequest request){
		double pageTotalAmount=0,pageTotalAmount85=0,pageTotalAmount100=0;
		String invoiceuid=request.getParameter("invoiceuid");
        int coverage=85;
		ExtraInsurarInvoice invoice = ExtraInsurarInvoice.get(invoiceuid);
		if(invoice!=null){
			Insurar insurar=invoice.getInsurar();
	        if(insurar!=null && insurar.getInsuraceCategories()!=null && insurar.getInsuraceCategories().size()>0){
	        	try{
	        		coverage=100-Integer.parseInt(((InsuranceCategory)insurar.getInsuraceCategories().elementAt(0)).getPatientShare());
	        	}
	        	catch(Exception e){
	        		e.printStackTrace();
	        	}
	        }
		}
		String sOutput="#;DATE;VOUCHER_ID;INVOICE_ID;BENEFICIARY_NR;BENEFICIARY_AGE;BENEFICIARY_SEX;BENEFICIARY_NAME;AFFILIATE_NAME;AFFILIATE_AFFECT;CONS;LAB;IMA;HOS;ACT;MAT;OTH;MED;TOT 100%;TOT x%\r\n";
		if(invoiceuid!=null){
	        Vector debets = ExtraInsurarInvoice.getDebetsForInvoiceSortByDate(invoiceuid);
	        if(debets.size() > 0){
	            // print debets
	            Debet debet;
	            String sPatientName="", sPrevPatientName = "",sPreviousInvoiceUID="",beneficiarynr="",beneficiaryage="",beneficiarysex="",affiliatecompany="";
	            Date date=null,prevdate=null;
	            boolean displayPatientName=false,displayDate=false;
	            SortedMap categories = new TreeMap(), totalcategories = new TreeMap();
	            double total100pct=0,total85pct=0,generaltotal100pct=0,generaltotal85pct=0,daytotal100pct=0,daytotal85pct=0;
	            String invoiceid="",adherent="",recordnumber="",insurarreference="";
	            int linecounter=1;
	            for(int i=0; i<debets.size(); i++){
	                debet = (Debet)debets.get(i);
	                try {
						date = new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()));
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						date=debet.getDate();
						e.printStackTrace();
					}
	                displayDate = !date.equals(prevdate);
	                sPatientName = debet.getPatientName()+";"+debet.getEncounter().getPatientUID();
	                displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName) || (debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0 && invoiceid.length()>0);
	                if(i>0 && (displayDate || displayPatientName)){
	                    sOutput+=printDebet2(categories,displayDate,prevdate!=null?prevdate:date,invoiceid,adherent,sPrevPatientName.split(";")[0],total100pct,total85pct,recordnumber,linecounter++,insurarreference,beneficiarynr,beneficiaryage,beneficiarysex,affiliatecompany);
	                	categories = new TreeMap();
	                	total100pct=0;
	                	total85pct=0;
	                	if(displayDate){
	                		daytotal100pct=0;
	                		daytotal85pct=0;
	                	}
	                	invoiceid="";
	                	adherent="";
	                	recordnumber="";
	                	insurarreference="";
	                	beneficiarynr="";
	                	beneficiaryage="";
	                	beneficiarysex="";
	                	affiliatecompany="";
	                }
	                if(debet.getEncounter()!=null && debet.getEncounter().getPatient()!=null){
	                	beneficiarysex=debet.getEncounter().getPatient().gender;
	                	if(debet.getEncounter().getPatient().dateOfBirth!=null){
	                		beneficiaryage=debet.getEncounter().getPatient().dateOfBirth;
	                	}
	                }
	                if(debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0){
	                	if(invoiceid.length()>0){
	                		invoiceid+="\n";
	                	}
	                	invoiceid+=debet.getPatientInvoiceUid().split("\\.")[1];
	                	if(insurarreference.equalsIgnoreCase("")){
		                	PatientInvoice patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
		                	if(patientInvoice!=null){
		                		insurarreference=patientInvoice.getInsurarreference();
		                	}
	                	}
	                }
	                if(debet.getInsuranceUid()!=null){
	                	Insurance insurance = Insurance.get(debet.getInsuranceUid());
	                	debet.setInsurance(insurance);
	                	beneficiarynr=insurance.getInsuranceNr();
	                	affiliatecompany=insurance.getMemberEmployer();
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getMember()!=null && adherent.indexOf(debet.getInsurance().getMember().toUpperCase())<0){
	                	if(adherent.length()>0){
	                		adherent+="\n";
	                	}
	                	adherent+=debet.getInsurance().getMember().toUpperCase();
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getInsuranceNr()!=null && recordnumber.indexOf(debet.getInsurance().getInsuranceNr())<0){
	                	if(recordnumber.length()>0){
	                		recordnumber+="\n";
	                	}
	                	recordnumber+=debet.getInsurance().getInsuranceNr();
	                }
	                Prestation prestation = debet.getPrestation();
	                double rAmount = debet.getAmount();
	                double rInsurarAmount = debet.getInsurarAmount();
	                double rExtraInsurarAmount = debet.getExtraInsurarAmount();
	                int rTotal=(int)(rAmount+rInsurarAmount+rExtraInsurarAmount);
	                if(prestation!=null && prestation.getReferenceObject()!=null && prestation.getReferenceObject().getObjectType()!=null && prestation.getReferenceObject().getObjectType().length()>0){
	                	String sCat=prestation.getReferenceObject().getObjectType();
	                    if(categories.get(sCat)==null){
	                        categories.put(sCat,"+"+rTotal);
	                    }
	                    else {
	                        categories.put(sCat,categories.get(sCat)+"+"+rTotal);
	                    }
	                    if(totalcategories.get(sCat)==null){
	                        totalcategories.put(sCat,"+"+rTotal);
	                    }
	                    else {
	                        totalcategories.put(sCat,totalcategories.get(sCat)+"+"+rTotal);
	                    }
	                }
	                else {
	                    if(categories.get("OTHER")==null){
	                        categories.put("OTHER","+"+rTotal);
	                    }
	                    else {
	                        categories.put("OTHER",categories.get("OTHER")+"+"+rTotal);
	                    }
	                    if(totalcategories.get("OTHER")==null){
	                        totalcategories.put("OTHER","+"+rTotal);
	                    }
	                    else {
	                        totalcategories.put("OTHER",totalcategories.get("OTHER")+"+"+rTotal);
	                    }
	                }                
	                total100pct+=rTotal;
	                total85pct+=rExtraInsurarAmount;
	                prevdate = date;
	                sPrevPatientName = sPatientName;
	            }
                sOutput+=printDebet2(categories,displayDate,prevdate!=null?prevdate:date,invoiceid,adherent,sPrevPatientName.split(";")[0],total100pct,total85pct,recordnumber,linecounter++,insurarreference,beneficiarynr,beneficiaryage,beneficiarysex,affiliatecompany);

	        }
		}
		return sOutput;
	}
	
    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private static String printDebet2(SortedMap categories, boolean displayDate, Date date, String invoiceid,String adherent,String beneficiary,double total100pct,double total85pct,String recordnumber,int linecounter,String insurarreference,String beneficiarynr,String beneficiaryage,String beneficiarysex,String affiliatecompany){
    	String sOutput="";
        sOutput+=linecounter+";";
        sOutput+=new SimpleDateFormat("dd/MM/yyyy").format(date)+";";
        sOutput+=insurarreference+";";
        sOutput+=invoiceid+";";
        sOutput+=beneficiarynr+";";
        sOutput+=beneficiaryage+";";
        sOutput+=beneficiarysex+";";
        sOutput+=beneficiary+";";
        sOutput+=adherent+";";
        sOutput+=affiliatecompany+";";
        String amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C"));
        sOutput+=amount==null?"0;":amount+";";
        String otherprice="+0";
        String allcats=	"*"+MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M")+"*";
        Iterator iterator = categories.keySet().iterator();
        while (iterator.hasNext()){
        	String cat = (String)iterator.next();
        	if(allcats.indexOf("*"+cat+"*")<0 && ((String)categories.get(cat)).length()>0){
        		otherprice+="+"+(String)categories.get(cat);
        	}
        }
        sOutput+=otherprice+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M"));
        sOutput+=amount==null?"0;":amount+";";
        sOutput+=priceFormatInsurar.format(total100pct)+";";
        sOutput+=priceFormatInsurar.format(total85pct)+"\r\n";
        return sOutput;
    }

}
