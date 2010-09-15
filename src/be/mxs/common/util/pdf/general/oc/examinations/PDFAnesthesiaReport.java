package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.medical.Prescription;
import be.openclinic.pharmacy.Product;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

import java.util.Vector;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.DecimalFormat;

/**
 * User: ssm
 * Date: 13-jul-2007
 */
public class PDFAnesthesiaReport extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                //*** ANESTHESIA **********************************************
                PdfPTable hoursTable = new PdfPTable(4);
                
                // begin hour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_BEGIN");
                hoursTable.addCell(createValueCell(getTran("openclinic.chuk","begin_hour"),1));
                hoursTable.addCell(createValueCell(itemValue,3));

                // end hour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_END");
                hoursTable.addCell(createValueCell(getTran("openclinic.chuk","end_hour"),1));
                hoursTable.addCell(createValueCell(itemValue,3));

                // duration
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_DIFFERENCE");
                hoursTable.addCell(createValueCell(getTran("openclinic.chuk","duration"),1));
                hoursTable.addCell(createValueCell(itemValue,3));

                if(hoursTable.size() > 0){
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","anesthesie"),1);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);

                    table.addCell(createCell(new PdfPCell(hoursTable),4,Cell.ALIGN_CENTER,Cell.BOX));
                }

                //*** INTERVENTION ********************************************
                hoursTable = new PdfPTable(4);

                // intervention
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_BEGIN");
                hoursTable.addCell(createValueCell(getTran("openclinic.chuk","begin_hour"),1));
                hoursTable.addCell(createValueCell(itemValue,3));

                // end hour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_END");
                hoursTable.addCell(createValueCell(getTran("openclinic.chuk","end_hour"),1));
                hoursTable.addCell(createValueCell(itemValue,3));

                // duration
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_DIFFERENCE");
                hoursTable.addCell(createValueCell(getTran("openclinic.chuk","duration"),1));
                hoursTable.addCell(createValueCell(itemValue,3));

                if(hoursTable.size() > 0){
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","intervention"),1);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);

                    table.addCell(createCell(new PdfPCell(hoursTable),4,Cell.ALIGN_CENTER,Cell.BOX));
                }
                
                // diagnostic comment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_DIAGNOSTIC");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","diagnostic"),itemValue);
                }

                // intervention comment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","intervention"),itemValue);
                }

                //*** team composition ****************************************
                PdfPTable teamTable = new PdfPTable(4);
                String teamMemberName = "", teamMemberID;
                
                // anesthesist
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                teamMemberID = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIST");
                if(teamMemberID.length() > 0){
                    teamMemberName = ScreenHelper.getFullUserName(teamMemberID,ad_conn);
                }
                teamTable.addCell(createValueCell(getTran("openclinic.chuk","anesthesist"),1));
                teamTable.addCell(createValueCell(teamMemberName,3));

                // surgeon
                teamMemberID = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_SURGEON");
                if(teamMemberID.length() > 0){
                    teamMemberName = ScreenHelper.getFullUserName(teamMemberID,ad_conn);
                }
                teamTable.addCell(createValueCell(getTran("openclinic.chuk","surgeon"),1));
                teamTable.addCell(createValueCell(teamMemberName,3));

                // nurse
                teamMemberID = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_NURSE");
                if(teamMemberID.length() > 0){
                    teamMemberName = ScreenHelper.getFullUserName(teamMemberID,ad_conn);
                }
                ad_conn.close();
                teamTable.addCell(createValueCell(getTran("openclinic.chuk","nurse"),1));
                teamTable.addCell(createValueCell(teamMemberName,3));

                if(teamTable.size() > 0){
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","teamcomposition"),1);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);

                    table.addCell(createCell(new PdfPCell(teamTable),4,Cell.ALIGN_CENTER,Cell.BOX));
                }    

                // description
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","description"),itemValue);
                }

                //*** incidents ***********************************************
                PdfPTable incidentsTable = new PdfPTable(4);

                // foresees
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_FORESEES");
                incidentsTable.addCell(createValueCell(getTran("openclinic.chuk","foresees"),1));
                incidentsTable.addCell(createValueCell(itemValue,3));

                // unforesees
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_UNFORESEES");
                incidentsTable.addCell(createValueCell(getTran("openclinic.chuk","unforesees"),1));
                incidentsTable.addCell(createValueCell(itemValue,3));

                if(incidentsTable.size() > 0){
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","incidents"),1);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);

                    table.addCell(createCell(new PdfPCell(incidentsTable),4,Cell.ALIGN_CENTER,Cell.BOX));
                }
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }
                
                // add transaction to doc
                addTransactionToDoc();

                //*** checkboxes items ****************************************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                //*** anesthesie ***
                String sAnesthesie = "";
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_GENERAL");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sAnesthesie+= getTran("openclinic.chuk","anesthesie.general")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_REGIONAL");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sAnesthesie+= getTran("openclinic.chuk","anesthesie.regional")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_LOCAL");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sAnesthesie+= getTran("openclinic.chuk","anesthesie.local")+", ";
                }

                if(sAnesthesie.length() > 0){
                    // remove last comma
                    if(sAnesthesie.indexOf(",") > -1){
                        sAnesthesie = sAnesthesie.substring(0,sAnesthesie.length()-2);
                    }

                    addItemRow(table,getTran("openclinic.chuk","anesthesie"),sAnesthesie.toLowerCase());
                }

                //*** technical ***********************************************
                String sTechnical = "";
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_MASK");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sTechnical+= getTran("openclinic.chuk","technical.mask")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBEORAL");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sTechnical+= getTran("openclinic.chuk","technical.tubeoral")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBENASAL");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sTechnical+= getTran("openclinic.chuk","technical.tubenasal")+", ";
                }

                if(sTechnical.length() > 0){
                    // remove last comma
                    if(sTechnical.indexOf(",") > -1){
                        sTechnical = sTechnical.substring(0,sTechnical.length()-2);
                    }

                    addItemRow(table,getTran("openclinic.chuk","technical"),sTechnical.toLowerCase());
                }

                //*** position ************************************************
                String sPosition = "";
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_POSITION_BACK");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sPosition+= getTran("openclinic.chuk","position.back")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_POSITION_CENTRAL");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sPosition+= getTran("openclinic.chuk","position.central")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_POSITION_SIDE");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sPosition+= getTran("openclinic.chuk","position.side")+", ";
                }

                if(sPosition.length() > 0){
                    // remove last comma
                    if(sPosition.indexOf(",") > -1){
                        sPosition = sPosition.substring(0,sPosition.length()-2);
                    }

                    addItemRow(table,getTran("openclinic.chuk","position"),sPosition.toLowerCase());
                }

                //*** respiration *********************************************
                String sRespiration = "";
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_SPONTANEOUS");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sRespiration+= getTran("openclinic.chuk","respiration.spontaneous")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_ASSIST");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sRespiration+= getTran("openclinic.chuk","respiration.assist")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_VERIFY");
                if(itemValue.length() > 0 && itemValue.equalsIgnoreCase("medwan.common.true")){
                    sRespiration+= getTran("openclinic.chuk","respiration.verify")+", ";
                }

                if(sRespiration.length() > 0){
                    // remove last comma
                    if(sRespiration.indexOf(",") > -1){
                        sRespiration = sRespiration.substring(0,sRespiration.length()-2);
                    }

                    addItemRow(table,getTran("openclinic.chuk","respiration"),sRespiration.toLowerCase());
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                //*** technical problems **************************************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // reference equipment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_TP_REFERENCE");
                if(itemValue.length() > 0){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","reference_equipment"),2));
                    table.addCell(createValueCell(itemValue,3));
                }

                // problem description
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_TP_DESCRIPTION");
                if(itemValue.length() > 0){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","problem_description"),2));
                    table.addCell(createValueCell(itemValue,3));
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                //*** pharmacovigilance (active presciptions) *****************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                Vector vActivePrescriptions = Prescription.findActive(patient.personid,transactionVO.user.getUserId()+"","","","","","","");
                StringBuffer prescriptions = new StringBuffer();
                Vector idsVector = getActivePrescriptionsFromRs(prescriptions,vActivePrescriptions);
                PdfPTable vigilanceTable = new PdfPTable(4);

                if(idsVector.size() > 0){                      
                    // medicines
                    itemValue = prescriptions.toString();
                    if(itemValue.length() > 0){
                        cell = createValueCell(getTran("openclinic.chuk","administer_medicines"),1);
                        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                        vigilanceTable.addCell(cell);

                        vigilanceTable.addCell(createValueCell(itemValue,3));
                    }

                    // allergies
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_ALLERGIES");
                    if(itemValue.length() > 0){
                        cell = createValueCell(getTran("openclinic.chuk","allergies"),1);
                        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                        vigilanceTable.addCell(cell);

                        vigilanceTable.addCell(createValueCell(itemValue,3));
                    }

                    // others
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_OTHERS");
                    if(itemValue.length() > 0){
                        cell = createValueCell(getTran("openclinic.chuk","others"),1);  
                        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                        vigilanceTable.addCell(cell);

                        vigilanceTable.addCell(createValueCell(itemValue,3));
                    }

                    // add vigilance table
                    if(vigilanceTable.size() > 0){
                        // title
                        cell = createItemNameCell(getTran("openclinic.chuk","pharmacovigilance"),1);
                        cell.setBackgroundColor(BGCOLOR_LIGHT);
                        table.addCell(cell);

                        table.addCell(createCell(new PdfPCell(vigilanceTable),4,Cell.ALIGN_CENTER,Cell.BOX));
                    }
                }
                /*
                else {
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","pharmacovigilance"),1);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);

                    itemValue = getTran("web","noactiveprescriptionsfound");
                    table.addCell(createValueCell(itemValue,4));
                }
                */

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product;
        product = Product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }
    
    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions) throws SQLException {
        Vector idsVector = new Vector();
        Product product = null;
        String sClass = "1", sPrescriptionUid, sProductName = "", sProductUid, sPreviousProductUid = "",
               sTimeUnit, sTimeUnitCount,  sUnitsPerTimeUnit, sPrescrRule = "", sProductUnit, timeUnitTran;
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");

        // frequently used translations
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while (iter.hasNext()) {
            prescription = (Prescription) iter.next();
            sPrescriptionUid = prescription.getUid();

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            idsVector.add(sPrescriptionUid);

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if(product != null) sProductName = product.getName();
                else                sProductName = "";
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit         = prescription.getTimeUnit();
            sTimeUnitCount    = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule");
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if(product != null) sProductUnit = product.getUnit();
                else                sProductUnit = "";

                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran("product.unit", sProductUnit);
                }
                else {
                    sProductUnit = getTran("product.units", sProductUnit);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran("prescription.timeunit", sTimeUnit);
                }
                else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits", sTimeUnit);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append(sProductName+" ("+sPrescrRule.toLowerCase() + ")\n");
        }

        return idsVector;
    }

}

