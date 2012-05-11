package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFBiometry extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(1);
                PdfPTable biometryTable = new PdfPTable(7);

                String sBio = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER");
                if (sBio.indexOf("£")>-1){
                    StringBuffer sTmpBio = new StringBuffer(sBio);
                    String sTmpDate, sTmpWeight, sTmpHeight, sTmpSkull, sTmpArm, sTmpFood;

                    while (sTmpBio.toString().toLowerCase().indexOf("$")>-1) {
                        sTmpDate = "";
                        if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpDate = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpWeight = "";
                        if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpWeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpHeight = "";
                        if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpHeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpSkull = "";
                        if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpSkull = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpArm = "";
                        if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpArm = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }
                        
                        sTmpFood = "";
                        if (sTmpBio.toString().toLowerCase().indexOf("$")>-1){
                            sTmpFood = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("$"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("$")+1));
                        }

                        // add biometry record
                        biometryTable = addBiometryToPDFTable(biometryTable,sTmpDate,sTmpWeight,sTmpHeight,sTmpSkull,sTmpArm,sTmpFood);
                    }
                }

                // add table to transaction
                if(biometryTable.size() > 0){
                    cell = new PdfPCell(biometryTable);
                    cell.setPadding(3);
                    cell.setBorder(PdfPCell.BOX);
                    
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


    //### PRIVATE METHODS #########################################################################

    //--- ADD BIOMETRY TO PDF TABLE ---------------------------------------------------------------
    private PdfPTable addBiometryToPDFTable(PdfPTable pdfTable, String sDate, String sWeight, String sHeight,
                                            String sSkull, String sArm, String sFood){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.common.date"),1));
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.weight"),1));
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.length"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","skull"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","arm"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","food"),2));
        }

        pdfTable.addCell(createValueCell(sDate,1));
        pdfTable.addCell(createValueCell(sWeight,1));
        pdfTable.addCell(createValueCell(sHeight,1));
        pdfTable.addCell(createValueCell(sSkull,1));
        pdfTable.addCell(createValueCell(sArm,1));
        pdfTable.addCell(createValueCell(getTran("biometry_food",sFood),2));

        return pdfTable;
    }

}