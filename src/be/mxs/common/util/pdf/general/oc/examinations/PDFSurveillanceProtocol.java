package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.openclinic.adt.Encounter;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

import java.util.*;
import java.text.SimpleDateFormat;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFSurveillanceProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addVitalSigns();
                addVitalSignsResp();
                addTransactionToDoc();

                addConscience();
                addTransactionToDoc();
                
                addBiometrie();
                addTransactionToDoc();

                addInputSummary();
                addOutputSummary();
                addBilanTotal();
                addTransactionToDoc();

                addNutritionalSituation();
                addOther();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD VITAL SIGNS -------------------------------------------------------------------------
    private void addVitalSigns(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(1);

        PdfPTable vitalSignsTable = new PdfPTable(5);
        String sSignesVitaux = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SIGN_VITAUX_");
        if(sSignesVitaux.indexOf("£")>-1){
            StringBuffer sTmpSignesVitaux = new StringBuffer(sSignesVitaux);
            String sTmpHeure, sTmpSys, sTmpDias, sTmpRythme, sTmpTemp;

            while(sTmpSignesVitaux.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpSys = "";
                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSys = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpDias = "";
                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDias = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpRythme = "";
                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpRythme = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTemp = "";
                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("$")>-1){
                    sTmpTemp = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("$"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("$")+1));
                }

                // add vital sign record
                vitalSignsTable = addVitalSignToPDFTable(vitalSignsTable,sTmpHeure,sTmpSys,sTmpDias,sTmpRythme,sTmpTemp);
            }
        }
        
        if(vitalSignsTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","vital.signs"),1));
            table.addCell(createCell(new PdfPCell(vitalSignsTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD VITAL SIGN TO PDF TABLE -------------------------------------------------------------
    private PdfPTable addVitalSignToPDFTable(PdfPTable pdfTable, String sHour, String sSys, String sDias,
                                             String sRythme, String sTemp){

        // add header if no header yet
        if(pdfTable.size() == 0){
            // main header
            pdfTable.addCell(createInvisibleCell(1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","ta"),2));
            pdfTable.addCell(createInvisibleCell(2));

            // sub header
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","sys"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","dias"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","heartfrequency"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","temperature"),1));
        }

        pdfTable.addCell(createValueCell(sHour,1));
        pdfTable.addCell(createValueCell(sSys,1));
        pdfTable.addCell(createValueCell(sDias,1));
        pdfTable.addCell(createValueCell(sRythme+" /"+getTran("unit","minute"),1));
        pdfTable.addCell(createValueCell(sTemp+" /"+getTran("unit","degreesCelcius"),1));

        return pdfTable;
    }
                
    //--- ADD VITAL SIGNS RESP --------------------------------------------------------------------
    private void addVitalSignsResp(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(1);

        PdfPTable vsRespTable = new PdfPTable(9);
        String sSignesVitauxResp = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SIGN_VITAUX_RESP_");
        if(sSignesVitauxResp.indexOf("£")>-1){
            StringBuffer sTmpSignesVitauxResp = new StringBuffer(sSignesVitauxResp);
            String sTmpHeure, sTmpResp, sTmpAmbient, sTmpUnder, sTmpVolume, sTmpMode, sTmpObservation;

            while (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpResp = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")>-1){
                    sTmpResp = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpAmbient = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")>-1){
                    sTmpAmbient = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpUnder = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")>-1){
                    sTmpUnder = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpVolume = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")>-1){
                    sTmpVolume = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpMode = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")>-1){
                    sTmpMode = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpObservation = "";
                if (sTmpSignesVitauxResp.toString().toLowerCase().indexOf("$")>-1){
                    sTmpObservation = sTmpSignesVitauxResp.substring(0,sTmpSignesVitauxResp.toString().toLowerCase().indexOf("$"));
                    sTmpSignesVitauxResp = new StringBuffer(sTmpSignesVitauxResp.substring(sTmpSignesVitauxResp.toString().toLowerCase().indexOf("$")+1));
                }

                // add vital sign record
                vsRespTable = addVitalSignRespToPDFTable(vsRespTable,sTmpHeure,sTmpResp,sTmpAmbient,sTmpUnder,sTmpVolume,sTmpMode,sTmpObservation);
            }
        }

        if(vsRespTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","vital.resp.signs"),1));
            table.addCell(createCell(new PdfPCell(vsRespTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD VITAL SIGN RESP TO PDF TABLE --------------------------------------------------------
    private PdfPTable addVitalSignRespToPDFTable(PdfPTable pdfTable, String sHour, String sResp, String sAmbient,
                                                String sUnder, String sVolume, String sMode, String sObservation){
                                                       
        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","respiration"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","air.ambient"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","under.o2"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","volume.o2"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","mode.o2"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","observation"),3));
        }

        pdfTable.addCell(createValueCell(sHour,1));
        pdfTable.addCell(createValueCell(sResp+" /"+getTran("unit","minute"),1));
        pdfTable.addCell(createValueCell(sAmbient+" "+getTran("unit","percentage"),1));
        pdfTable.addCell(createValueCell(sUnder+" "+getTran("unit","percentage"),1));
        pdfTable.addCell(createValueCell(sVolume+" "+getTran("unit","liter")+"/"+getTran("unit","minute"),1));
        pdfTable.addCell(createValueCell(sMode,1));
        pdfTable.addCell(createValueCell(sObservation,3));

        return pdfTable;
    }
                
    //--- ADD CONSCIENCE --------------------------------------------------------------------------
    private void addConscience(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(1);

        PdfPTable conscTable = new PdfPTable(6);
        String sConscience = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_CONSCIENCE_");
        if(sConscience.indexOf("£")>-1){
            StringBuffer sTmpConscience = new StringBuffer(sConscience);
            String sTmpHeure, sTmpYeux, sTmpMotrice, sTmpVerbale, sTmpTotal, sTmpPain;

            while(sTmpConscience.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                if(sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpYeux = "";
                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpYeux = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpMotrice = "";
                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpMotrice = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpVerbale = "";
                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpVerbale = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTotal = "";
                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTotal = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpPain = "";
                if (sTmpConscience.toString().toLowerCase().indexOf("$")>-1){
                    sTmpPain = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("$"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("$")+1));
                }

                // add conscience record
                conscTable = addConscienceToPDFTable(conscTable,sTmpHeure,sTmpYeux,sTmpMotrice,sTmpVerbale,sTmpTotal,sTmpPain);
            }
        }

        if(conscTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","consciousness"),1));
            table.addCell(createCell(new PdfPCell(conscTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }
                                                                     
    //--- ADD CONSCIENCE TO PDF TABLE -------------------------------------------------------------
    private PdfPTable addConscienceToPDFTable(PdfPTable pdfTable, String sHour, String sYeux, String sMotrice,
                                            String sVerbale, String sTotal, String sPain){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","opening.eyes")+" ( /4)",1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","mot.reaction")+" ( /6)",1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","verb.reaction")+" ( /5)",1));
            pdfTable.addCell(createHeaderCell(getTran("web.occup","total")+" ( /15)",1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","pain.score"),1));
        }

        pdfTable.addCell(createValueCell(sHour,1));
        pdfTable.addCell(createValueCell(sYeux,1));
        pdfTable.addCell(createValueCell(sMotrice,1));
        pdfTable.addCell(createValueCell(sVerbale,1));
        pdfTable.addCell(createValueCell(sTotal,1));
        pdfTable.addCell(createValueCell(sPain,1));

        return pdfTable;
    }

    //--- ADD BIOMETRIE ---------------------------------------------------------------------------
    private void addBiometrie(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(1);

        PdfPTable biometrieTable = new PdfPTable(4);
        String sBiometrie = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BIOMETRIE_");
        if(sBiometrie.indexOf("£")>-1){
            StringBuffer sTmpBiometrie = new StringBuffer(sBiometrie);
            String sTmpHeure, sTmpPoids, sTmpTaille, sTmpBMI;

            while (sTmpBiometrie.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                if (sTmpBiometrie.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("£"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpPoids = "";
                if (sTmpBiometrie.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPoids = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("£"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTaille = "";
                if (sTmpBiometrie.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTaille = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("£"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpBMI = "";
                if (sTmpBiometrie.toString().toLowerCase().indexOf("$")>-1){
                    sTmpBMI = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("$"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("$")+1));
                }

                // add biometrie record
                biometrieTable = addBiometrieToPDFTable(biometrieTable,sTmpHeure,sTmpPoids,sTmpTaille,sTmpBMI);
            }
        }

        if(biometrieTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","biometry"),1));
            table.addCell(createCell(new PdfPCell(biometrieTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD BIOMETRIE TO PDF TABLE --------------------------------------------------------------
    private PdfPTable addBiometrieToPDFTable(PdfPTable pdfTable, String sHour, String sPoids, String sTaille, String sBMI){
                          
        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","weigth"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","heigth"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","bmi"),1));
        }

        pdfTable.addCell(createValueCell(sHour,1));
        pdfTable.addCell(createValueCell(sPoids+" "+getTran("unit","kg"),1));
        pdfTable.addCell(createValueCell(sTaille+" "+getTran("unit","cm"),1));
        pdfTable.addCell(createValueCell(sBMI,1));

        return pdfTable;
    }

    //--- ADD INPUT SUMMARY -----------------------------------------------------------------------
    private void addInputSummary(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(1);

        PdfPTable inputTable = new PdfPTable(7);
        String sInput = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANENTREE_");
        if (sInput.indexOf("£")>-1){
            StringBuffer sTmpInput = new StringBuffer(sInput);
            String sTmpHeure, sTmpLactate, sTmpGlucose, sTmpPhysio, sTmpHaem, sTmpTrans, sTmpSang;

            while (sTmpInput.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                if (sTmpInput.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("£"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpLactate = "";
                if (sTmpInput.toString().toLowerCase().indexOf("£")>-1){
                    sTmpLactate = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("£"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpGlucose = "";
                if (sTmpInput.toString().toLowerCase().indexOf("£")>-1){
                    sTmpGlucose = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("£"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpPhysio = "";
                if (sTmpInput.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPhysio = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("£"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpHaem = "";
                if (sTmpInput.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHaem = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("£"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTrans = "";
                if (sTmpInput.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTrans = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("£"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpSang = "";
                if (sTmpInput.toString().toLowerCase().indexOf("$")>-1){
                    sTmpSang = sTmpInput.substring(0,sTmpInput.toString().toLowerCase().indexOf("$"));
                    sTmpInput = new StringBuffer(sTmpInput.substring(sTmpInput.toString().toLowerCase().indexOf("$")+1));
                }

                // add input record
                inputTable = addInputToPDFTable(inputTable,sTmpHeure,sTmpLactate,sTmpGlucose,sTmpPhysio,sTmpHaem,sTmpTrans,sTmpSang);
            }
        }

        if(inputTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","input.summary"),1));
            table.addCell(createCell(new PdfPCell(inputTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD INPUT TO PDF TABLE ------------------------------------------------------------------
    private PdfPTable addInputToPDFTable(PdfPTable pdfTable, String sHour, String sLactate, String sGlucose,
                                         String sPhysio, String sHaem, String sTrans, String sSang){

        // add header if no header yet
        if(pdfTable.size() == 0){
            // main header
            pdfTable.addCell(createInvisibleCell(1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","perfusions"),4));
            pdfTable.addCell(createInvisibleCell(2));

            // sub header
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","lactate"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","glucose"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","physiological"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","haem"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","transfusion"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","type"),1));
        }

        pdfTable.addCell(createValueCell(sHour,1));
        pdfTable.addCell(createValueCell(sLactate,1));
        pdfTable.addCell(createValueCell(sGlucose,1));
        pdfTable.addCell(createValueCell(sPhysio,1));
        pdfTable.addCell(createValueCell(sHaem,1));
        pdfTable.addCell(createValueCell(sTrans+" "+getTran("unit","ml"),1));
        pdfTable.addCell(createValueCell(sSang,1));

        return pdfTable;
    }

    //--- ADD OUTPUT SUMMARY ----------------------------------------------------------------------
    private void addOutputSummary(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);
        int itemCount = 0;
        
        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","output.summary"),10));

        // diuresis
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_DIURESE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","diuresis"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }

        // aspiration
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_ASPIRATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","aspiration"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }

        // vomiting
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_VOMISSEMENTS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","vomiting"),itemValue+" /j");
            itemCount++;
        }

        // selles
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_SELLES");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","selles"),itemValue+" /j");
            itemCount++;
        }

        // thoracic.drain
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_THORACIQUE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","thoracic.drain"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }
            
        // abdominal.drain
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_ABDOMINAL");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","abdominal.drain"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }

        // other.drain
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRE_DRAIN");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","other.drain"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }
        
        // nasogastric.probe
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_SONDE_NASOGASTRIQUE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","nasogastric.probe"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }

        // other.exits
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRES_SORTIES");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","other.exits"),itemValue+" "+getTran("unit","ml"));
            itemCount++;
        }  

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD BILAN TOTAL -------------------------------------------------------------------------
    private void addBilanTotal(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);

        Encounter activeEncounter = Encounter.getActiveEncounter(patient.personid);
        Vector vTransactions = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(patient.personid),IConstants_PREFIX+"TRANSACTION_TYPE_SURVEILLANCE_PROTOCOL");
        TransactionVO tranVO;
        Hashtable hBilanInput = new Hashtable(),
                  hBilanOutput = new Hashtable(),
                  hBilanTotal = new Hashtable();
        String sTmpBilanInput, sTmpBilanOutput, sTmpBilanTotal;
        ItemVO itemVO;

        for(int i=0; i<vTransactions.size(); i++) {
            tranVO = (TransactionVO)vTransactions.elementAt(i);

            if (activeEncounter!=null && tranVO!=null
                && !tranVO.getUpdateTime().before(activeEncounter.getBegin())
                && (activeEncounter.getEnd() == null || !tranVO.getUpdateTime().after(activeEncounter.getEnd()))){

                tranVO = MedwanQuery.getInstance().loadTransaction(tranVO.getServerId(),tranVO.getTransactionId().intValue());

                // input
                sTmpBilanInput = "0";
                itemVO = tranVO.getItem(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANENTREE_TOTAL");
                if (itemVO != null) {
                    sTmpBilanInput = checkString(itemVO.getValue());
                }
                hBilanInput.put(tranVO.getCreationDate(),sTmpBilanInput);

                // output
                sTmpBilanOutput = "0";
                itemVO = tranVO.getItem(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_TOTAL");
                if (itemVO != null) {
                    sTmpBilanOutput = checkString(itemVO.getValue());
                }
                hBilanOutput.put(tranVO.getCreationDate(),sTmpBilanOutput);

                // total
                sTmpBilanTotal = "0";
                itemVO = tranVO.getItem(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILAN_TOTAL");
                if (itemVO != null) {
                    sTmpBilanTotal = checkString(itemVO.getValue());
                }
                hBilanTotal.put(tranVO.getCreationDate(),sTmpBilanTotal);
            }
        }

        //*** left table : itenmaes & non-calculated sums *********************
        PdfPTable leftBilanTable = new PdfPTable(3);

        // spacer cell
        cell = createBorderlessCell("",9,3);
        cell.setBorder(Cell.NO_BORDER);
        leftBilanTable.addCell(cell);

        // bilan.input.total
        cell = createItemNameCell(getTran("openclinic.chuk","bilan.input.total"),2);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        leftBilanTable.addCell(cell);
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANENTREE_TOTAL");
        leftBilanTable.addCell(createValueCell(itemValue,1));

        // bilan.output.total
        cell = createItemNameCell(getTran("openclinic.chuk","bilan.output.total"),2);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        leftBilanTable.addCell(cell);
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILANSORTIE_TOTAL");
        leftBilanTable.addCell(createValueCell(itemValue,1));

        // bilan.input.total
        cell = createItemNameCell(getTran("openclinic.chuk","bilan.total"),2);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        leftBilanTable.addCell(cell);
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_BILAN_TOTAL");
        leftBilanTable.addCell(createValueCell(itemValue,1));

        //*** right table : dates table with dynamic width ********************
        PdfPTable rightBilanTable = new PdfPTable(hBilanInput.size());

        // bilan table header : dates
        Vector vBilanDates = new Vector(hBilanInput.keySet());
        Collections.sort(vBilanDates);
        Iterator dateIter = vBilanDates.iterator();
        java.util.Date date;
        while(dateIter.hasNext()){
            date = (java.util.Date)dateIter.next();

            cell = createHeaderCell(new SimpleDateFormat("dd/MM/yyyy").format(date),1);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            rightBilanTable.addCell(cell);
        }

        // bilan table input row
        String value;
        vBilanDates = new Vector(hBilanInput.keySet());
        Collections.sort(vBilanDates);
        dateIter = vBilanDates.iterator();
        while(dateIter.hasNext()){
            date = (java.util.Date)dateIter.next();
            value = checkString((String)hBilanInput.get(date));
            rightBilanTable.addCell(createValueCell(value,1));
        }

        // bilan table output row
        vBilanDates = new Vector(hBilanOutput.keySet());
        Collections.sort(vBilanDates);
        dateIter = vBilanDates.iterator();
        while(dateIter.hasNext()){
            date = (java.util.Date)dateIter.next();
            value = checkString((String)hBilanOutput.get(date));
            rightBilanTable.addCell(createValueCell(value,1));
        }

        // bilan table total row
        vBilanDates = new Vector(hBilanTotal.keySet());
        Collections.sort(vBilanDates);
        dateIter = vBilanDates.iterator();
        while(dateIter.hasNext()){
            date = (java.util.Date)dateIter.next();
            value = checkString((String)hBilanTotal.get(date));   
            rightBilanTable.addCell(createValueCell(value,1));
        }

        //*** add left and right table to table ***
        table.addCell(createTitleCell(getTran("openclinic.chuk","bilan.total"),10));
        table.addCell(createCell(new PdfPCell(leftBilanTable),3,Cell.ALIGN_CENTER,Cell.BOX));
        table.addCell(createCell(new PdfPCell(rightBilanTable),7,Cell.ALIGN_CENTER,Cell.BOX)); 

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD NUTRITIONAL SITUATION ---------------------------------------------------------------
    private void addNutritionalSituation(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","nutritional.situation"),5));

        //*** balanced.meal ***
        Vector mealItems = new Vector();
        mealItems.add(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MATIN");
        mealItems.add(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MIDI");
        mealItems.add(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_SOIR");

        if(verifyList(mealItems)){
            PdfPTable mealTable = new PdfPTable(8);

            // morning
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MATIN");
            if(itemValue.length() > 0){
                mealTable.addCell(createItemNameCell(getTran("openclinic.chuk","morning"),2));
                mealTable.addCell(createValueCell(itemValue,6));
            }

            // midday
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MIDI");
            if(itemValue.length() > 0){
                mealTable.addCell(createItemNameCell(getTran("openclinic.chuk","midday"),2));
                mealTable.addCell(createValueCell(itemValue,6));
            }

            // evening
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_SOIR");
            if(itemValue.length() > 0){
                mealTable.addCell(createItemNameCell(getTran("openclinic.chuk","evening"),2));
                mealTable.addCell(createValueCell(itemValue,6));
            }

            // add meal table
            if(mealTable.size() > 0){
                cell = createItemNameCell(getTran("openclinic.chuk","balanced.meal"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                table.addCell(cell);

                table.addCell(createCell(new PdfPCell(mealTable),4,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            }
        }
        
        // other_regime
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_OTHER_REGIME");
        if(itemValue.length() > 0){
            cell = createItemNameCell(getTran("openclinic.chuk","other_regime"));
            table.addCell(createValueCell(itemValue));               
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        addNutritionalRecords();    
    }

    //--- ADD NUTRITIONAL RECORDS -----------------------------------------------------------------
    private void addNutritionalRecords(){
        contentTable = new PdfPTable(1);

        PdfPTable nutriTable = new PdfPTable(15);
        String sSitNutri = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_");
        if (sSitNutri.indexOf("£")>-1){
            StringBuffer sTmpSitNutri = new StringBuffer(sSitNutri);
            String sTmpHeure, sTmpLait, sTmpBouillie, sTmpPotage, sTmpJuice, sTmpWater, sTmpPB, sTmpPT, sTmpIMC,sTmpObservation;

            while (sTmpSitNutri.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpLait = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpLait = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpBouillie = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpBouillie = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpPotage = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPotage = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpJuice = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpJuice = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpWater = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpWater = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpPB = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPB = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpPT = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPT = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpIMC = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpIMC = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpObservation = "";
                if (sTmpSitNutri.toString().toLowerCase().indexOf("$")>-1){
                    sTmpObservation = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("$"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("$")+1));
                }

                // add nutrition record
                nutriTable = addNutritionalRecordToPDFTable(nutriTable,sTmpHeure,sTmpLait,sTmpBouillie,sTmpPotage,
                                                            sTmpJuice,sTmpWater,sTmpPB,sTmpPT,sTmpIMC,sTmpObservation);
            }
        }

        // add table to transaction
        if(nutriTable.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(nutriTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }
                                                                           
    //--- ADD NUTRITIONAL RECORD TO PDF TABLE -----------------------------------------------------
    private PdfPTable addNutritionalRecordToPDFTable(PdfPTable pdfTable, String sHour, String sLait, String sBouillie,
                                                     String sPotage, String sJuice, String sWater, String sPB,
                                                     String sPT, String sIMC, String sObservation){

        // add header if no header yet
        if(pdfTable.size() == 0){
            // main header
            pdfTable.addCell(createInvisibleCell(2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","nutritive.liquid"),5));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","nutritional.state"),3));
            pdfTable.addCell(createInvisibleCell(5));

            // sub header
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","milk"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","pulp"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","soup"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","juice"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","water"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","pb"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","pt"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","imc"),1));                
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","observation"),5));
        }

        pdfTable.addCell(createValueCell(sHour,2));
        pdfTable.addCell(createValueCell(sLait+" "+getTran("unit","ml"),1));
        pdfTable.addCell(createValueCell(sBouillie+" "+getTran("unit","ml"),1));
        pdfTable.addCell(createValueCell(sPotage+" "+getTran("unit","ml"),1));
        pdfTable.addCell(createValueCell(sJuice+" "+getTran("unit","ml"),1));
        pdfTable.addCell(createValueCell(sWater+" "+getTran("unit","ml"),1));
        pdfTable.addCell(createValueCell(sPB+" "+getTran("unit","cm"),1));
        pdfTable.addCell(createValueCell(sPT,1));
        pdfTable.addCell(createValueCell(sIMC,1));
        pdfTable.addCell(createValueCell(sObservation,5));

        return pdfTable;
    }

    //--- ADD OTHER -------------------------------------------------------------------------------
    private void addOther(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // other
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTSURV_AUTRES");
        if(itemValue.length() > 0){
            table.addCell(createItemNameCell(getTran("openclinic.chuk","other")));
            table.addCell(createValueCell(itemValue));
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }          


    //### PRIVATE METHODS #########################################################################

    //--- ADD ITEM ROW ----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        cell = createItemNameCell(itemName);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }

}
