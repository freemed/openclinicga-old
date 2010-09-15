package be.mxs.common.util.pdf.official.chuk.examinations;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.medical.RequestedLabAnalysis;
import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import net.admin.AdminPrivateContact;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Hashtable;
import java.util.Vector;


public class chukPDFOfficialLabRequest extends PDFOfficialBasic {

    // declarations
    private StringBuffer monsters;
    private int pageWidth = 100;


    //--- ADD HEADER ------------------------------------------------------------------------------
    protected void addHeader(){
        try{
            // get required data
            String sUnit = "", sFunction = "", sUnitCode = "";

            AdminPrivateContact apc = ScreenHelper.getActivePrivate(patient);
            String patientAddress = "";
            if (apc!=null){
                patientAddress = apc.address+", "+apc.zipcode+" "+apc.city;
            }

            // put data in tables..
            PdfPTable headerTable = new PdfPTable(4);
            headerTable.setWidthPercentage(pageWidth);

            // ROW 1 - cell 1,2 : left part of title
            cell = createTitle(getTran("web","labresults"),Font.BOLD,10,2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            headerTable.addCell(cell);

            // ROW 1 - cell 3,4 : right part of title
            cell = createTitle(getTran("web","immatnew")+" "+checkString(patient.getID("immatnew")),Font.BOLD,10,2);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            headerTable.addCell(cell);

            table = new PdfPTable(5);

            // ROW 2.1 : werknemer - naam
            table.addCell(createValueCell(getTran("web","patient"),Font.NORMAL,8,1,false));
            table.addCell(createValueCell(getTran("web","name"),Font.NORMAL,8,1,false));
            String patientFullName = patient.lastname+" "+patient.firstname;
            table.addCell(createValueCell(patientFullName,Font.BOLD,8,3,false));

            // ROW 2.2 : werknemer - adres
            table.addCell(emptyCell(1));
            table.addCell(createValueCell(getTran("web","address"),Font.NORMAL,8,1,false));
            table.addCell(createValueCell(patientAddress,Font.NORMAL,8,3,false));

            // ROW 2.3 : onderzochte werknemer - date of birth
            table.addCell(emptyCell(1));
            table.addCell(createValueCell(getTran("web","dateofbirth"),Font.NORMAL,8,1,false));
            table.addCell(createValueCell(patient.dateOfBirth,Font.NORMAL,8,3,false));

            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // ROW 3 : werkgever nr
            table = new PdfPTable(5);
            table.addCell(createValueCell(getTran("web","service"),Font.NORMAL,8,2,false));
            table.addCell(createValueCell(sUnitCode,Font.NORMAL,8,3,false));
            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // ROW 4 : naam en adres werkgever
            table = new PdfPTable(5);
            table.addCell(createValueCell(getTran("web","serviceaddress"),Font.NORMAL,8,2,false));
            table.addCell(createValueCell(sUnit,Font.NORMAL,8,3,false));
            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // ROW 5 : omschrijving functie werkpost of activiteit
            table = new PdfPTable(5);
            table.addCell(createValueCell(getTran("web","function"),Font.NORMAL,8,2,false));
            table.addCell(createValueCell(sFunction,Font.NORMAL,8,3,false));
            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // spacer below page-header
            headerTable.addCell(createBorderlessCell("",10,4));

            // add headertable to document
            doc.add(headerTable);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            contentTable = new PdfPTable(1);
            contentTable.setWidthPercentage(pageWidth);

            monsters = new StringBuffer();

            // CHOSEN LABANALYSES
            PdfPTable chosenLabs = getChosenLabAnalyses();
            if(chosenLabs.size() > 0){
                contentTable.addCell(createCell(new PdfPCell(chosenLabs),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            }

            // TrANSACTION DATA
            table = new PdfPTable(5);
            table.setWidthPercentage(pageWidth);

            // spacer
            table.addCell(createBorderlessCell("",10,5));

            // MONSTERS (calculated)
            if(monsters.length() > 0){
                addItemRow(table,getTran("labrequest.monsters"),monsters.toString());
            }

            // HOUR
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LAB_HOUR");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_LAB_HOUR"),itemValue);
            }

            // COMMENT
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LAB_COMMENT");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_LAB_COMMENT"),itemValue);
            }

            // PROVIDER
            String providerCode = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_SUPPLIER");
            if(providerCode.length() > 0){
                itemValue = providerCode;
                String providerName = getProviderNameFromCode(providerCode);
                if(providerName.length() > 0){
                    itemValue+= " : "+providerName;
                }
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_SUPPLIER"),itemValue);
            }

            // VALUE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALUE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALUE"),itemValue);
            }

            // URGENCE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LAB_URGENCY");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_LAB_URGENCY"),MedwanQuery.getInstance().getLabel("labrequest.urgency",itemValue,sPrintLanguage));
            }

            doc.add(chosenLabs);
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- GET CHOSEN LABANALYSES ------------------------------------------------------------------
    private PdfPTable getChosenLabAnalyses() throws SQLException {
        PreparedStatement ps;
        RequestedLabAnalysis labAnalysis;
        String sTmpCode, sTmpResultValue, sTmpResultUnit, sTmpType = "", sTmpLabel = "",
               sTmpMonster = "", sTmpModifier, sTmpResultUserName = "", sTmpReferences, sTmpResultDate;
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

        PdfPTable chosenAnalyses = new PdfPTable(20);
        chosenAnalyses.setWidthPercentage(pageWidth);

        // get chosen labanalyses from DB
        Hashtable labAnalyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());

        // sort analysis-codes
        Vector codes = new Vector(labAnalyses.keySet());
        Collections.sort(codes);

        // compose query
        String sLowerLabelType = getConfigParam("lowerCompare","l.OC_LABEL_TYPE");
        StringBuffer sSelect = new StringBuffer();
        sSelect.append("SELECT la.labtype,la.monster,l.OC_LABEL_VALUE")
               .append(" FROM LabAnalysis la, OC_LABELS l")
               .append(" WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","la.labID")+" = l.OC_LABEL_ID")
               .append("  AND "+sLowerLabelType+" = 'labanalysis'")
               .append("  AND la.labcode = ? and deletetime is null");

        // run thru saved labanalysis
        for(int i=0; i<codes.size(); i++){
            sTmpCode = (String)codes.get(i);
            labAnalysis = (RequestedLabAnalysis)labAnalyses.get(sTmpCode);

            sTmpModifier = labAnalysis.getResultModifier();
            if(sTmpModifier.length() > 0){
                sTmpModifier = MedwanQuery.getInstance().getLabel("labanalysis.resultmodifier",labAnalysis.getResultModifier(),sPrintLanguage);
                //sTmpComment  = labAnalysis.getComment();

                // get result data
                sTmpResultValue = labAnalysis.getResultValue();
                sTmpResultUnit  = MedwanQuery.getInstance().getLabel("labanalysis.resultunit",labAnalysis.getResultUnit(),sPrintLanguage);
                sTmpReferences  = labAnalysis.getResultRefMin()+" - "+labAnalysis.getResultRefMax();
                sTmpResultDate  = stdDateFormat.format(labAnalysis.getResultDate());

                if(labAnalysis.getResultUserId().length() > 0){
                	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    sTmpResultUserName = ScreenHelper.getFullUserName(labAnalysis.getResultUserId(),ad_conn);
                    ad_conn.close();
                }

                // get default-data from DB
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                ps = oc_conn.prepareStatement(sSelect.toString());
                ps.setString(1,sTmpCode);
                ResultSet rs = ps.executeQuery();

                if(rs.next()){
                    sTmpType    = checkString(rs.getString("labtype"));
                    sTmpLabel   = checkString(rs.getString("OC_LABEL_VALUE"));
                    sTmpMonster = checkString(rs.getString("monster"));
                }

                // close DB-stuff
                rs.close();
                ps.close();
                oc_conn.close();

                // translate labtype
                     if(sTmpType.equals("1")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.blood",sPrintLanguage);
                else if(sTmpType.equals("2")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.urine",sPrintLanguage);
                else if(sTmpType.equals("3")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.other",sPrintLanguage);
                else if(sTmpType.equals("4")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.stool",sPrintLanguage);
                else if(sTmpType.equals("5")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.sputum",sPrintLanguage);
                else if(sTmpType.equals("6")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.smear",sPrintLanguage);
                else if(sTmpType.equals("7")) sTmpType = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.liquid",sPrintLanguage);

                // add lab to table
                chosenAnalyses = addLabAnalysisToPDFTable(chosenAnalyses,sTmpCode,sTmpType,sTmpLabel,
                                                          sTmpMonster,sTmpResultValue,sTmpReferences,sTmpResultUnit,
                                                          sTmpModifier,sTmpResultDate,sTmpResultUserName);

                // add monster if one is specified
                if(sTmpMonster.length() > 0){
                    if(monsters.indexOf(sTmpMonster) < 0){
                        monsters.append(sTmpMonster).append(", ");
                    }
                }
            }
        }

        // remove last comma from monsters
        if(monsters.indexOf(",") > -1){
            monsters = monsters.deleteCharAt(monsters.length()-2);
        }

        return chosenAnalyses;
    }

    //--- ADD LABANALYSIS TO PDF TABLE ------------------------------------------------------------
    private PdfPTable addLabAnalysisToPDFTable(PdfPTable pdfTable, String code, String type, String label,
                                               String monster, String resultValue, String references,
                                               String resultUnit, String resultModifier, String resultDate,
                                               String resultUserName){

        // add header if no header yet
        if(pdfTable.size() == 0){
            // default data
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.code"),1));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.type"),1));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.name"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.monster"),3));

            // result data
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultvalue"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.reference"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultunit"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultmodifier"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultdate"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultuser"),3));
        }

        // default data
        pdfTable.addCell(createValueCell(code,1));
        pdfTable.addCell(createValueCell(type,1));
        pdfTable.addCell(createValueCell(label,2));
        pdfTable.addCell(createValueCell(monster,3));

        // result data
        pdfTable.addCell(createValueCell(resultValue,2));
        pdfTable.addCell(createValueCell(references,2));
        pdfTable.addCell(createValueCell(resultUnit,2));
        pdfTable.addCell(createValueCell(resultModifier,2));
        pdfTable.addCell(createValueCell(resultDate,2));
        pdfTable.addCell(createValueCell(resultUserName,3));

        return pdfTable;
    }

}
