package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFDelivery extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                //*** WORK ************************************************************************                
                contentTable = new PdfPTable(1);
                table = new PdfPTable(2);

                Vector itemList = new Vector();
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_ADMISSION");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_STARTHOUR");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_AGE_DATE_DR");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_AGE_TRIMESTRE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DELIVERYTYPE");

                if(verifyList(itemList)){
                    // title
                    table.addCell(createTitleCell(getTran("gynaeco","work"),2));

                    //@@@ LEFT TABLE @@@
                    PdfPTable leftTable = new PdfPTable(5);

                    // admission (urgence, transfer, spontane, other)
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_ADMISSION");
                    if(itemValue.length() > 0){
                        itemValue = itemValue.substring(itemValue.lastIndexOf(".")+1);
                        addItemRow(leftTable,getTran("gynaeco","admission"),getTran("gynaeco.admission",itemValue).toLowerCase());
                    }

                    // start.hour
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_STARTHOUR");
                    if(itemValue.length() > 0){
                        addItemRow(leftTable,getTran("gynaeco","start.hour"),itemValue);
                    }

                    //*** age.gestationnel ****************************************
                    PdfPTable ageTable = new PdfPTable(3);

                    // age.date.dr
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_AGE_DATE_DR");
                    if(itemValue.length() > 0){
                        itemValue+= " "+getTran("web","weeks").toLowerCase();
                        ageTable.addCell(createItemNameCell(getTran("gynaeco","age.date.dr")));
                        ageTable.addCell(createValueCell(itemValue));
                    }

                    // age.echography
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY");
                    if(itemValue.length() > 0){
                        itemValue+= " "+getTran("web","weeks").toLowerCase();
                        ageTable.addCell(createItemNameCell(getTran("gynaeco","age.echography")));
                        ageTable.addCell(createValueCell(itemValue));
                    }

                    // age.trimstre
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_AGE_TRIMESTRE");
                    if(itemValue.length() > 0){
                        ageTable.addCell(createItemNameCell(getTran("gynaeco","age.trimstre")));
                        ageTable.addCell(createValueCell(itemValue));
                    }

                    // add age table
                    if(ageTable.size() > 0){
                        cell = createItemNameCell(getTran("gynaeco","age.gestationnel"));
                        cell.setBackgroundColor(BGCOLOR_LIGHT);
                        leftTable.addCell(cell);

                        leftTable.addCell(createCell(new PdfPCell(ageTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    }

                    // add left table to table
                    cell = createCell(new PdfPCell(leftTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPadding(0);
                    table.addCell(cell);

                    //@@@ RIGHT TABLE @@@
                    PdfPTable rightTable = new PdfPTable(5);

                    String deliveryType = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DELIVERYTYPE");
                    if(deliveryType.length() > 0){
                        //*** deliveryType = eutocic ***
                        if(deliveryType.equals("openclinic.common.eutocic")){
                            cell = createValueCell(getTran("openclinic.chuk",deliveryType),5);
                            cell.setBackgroundColor(BGCOLOR_LIGHT);
                            rightTable.addCell(cell);
                        }
                        //*** deliveryType = dystocic ***
                        else if(deliveryType.equals("openclinic.common.dystocic")){
                            cell = createValueCell(getTran("openclinic.chuk",deliveryType)+" :",5);
                            cell.setBackgroundColor(BGCOLOR_LIGHT);
                            rightTable.addCell(cell);

                            PdfPTable dystocicTable = new PdfPTable(5);

                            //# ventousse #
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_VENTOUSSE");
                            if(itemValue.equals("medwan.common.true")){
                                dystocicTable.addCell(createValueCell(getTran("openclinic.chuk","gynaeco.ventousse"),5));

                                // number_tractions
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS");
                                if(itemValue.length() > 0){
                                    dystocicTable.addCell(createValueCell("    "+getTran("gynaeco","number_tractions"),2));
                                    dystocicTable.addCell(createValueCell(itemValue,3));
                                }

                                // number_lachage
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_NUMBER_LACHAGE");
                                if(itemValue.length() > 0){
                                    dystocicTable.addCell(createValueCell("    "+getTran("gynaeco","number_lachage"),2));
                                    dystocicTable.addCell(createValueCell(itemValue,3));
                                }
                            }

                            //# forceps #
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_FORCEPS");
                            if(itemValue.equals("medwan.common.true")){
                                dystocicTable.addCell(createValueCell(getTran("gynaeco","forceps"),5));
                            }

                            //# manoeuvre #
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_MANOEUVRE");
                            if(itemValue.equals("medwan.common.true")){
                                dystocicTable.addCell(createValueCell(getTran("gynaeco","manoeuvre"),5));
                            }

                            // cause
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE");
                            if(itemValue.length() > 0){
                                itemValue = itemValue.substring(itemValue.lastIndexOf(".")+1);
                                addItemRow(dystocicTable,getTran("gynaeco","cause"),getTran("gynaeco.cause",itemValue).toLowerCase());
                            }

                            // remark
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK");
                            if(itemValue.length() > 0){
                                addItemRow(dystocicTable,getTran("Web.Occup","medwan.common.remark"),itemValue);
                            }

                            // add dystocicTable to rightTable
                            if(dystocicTable.size() > 0){
                                cell = createCell(new PdfPCell(dystocicTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                                cell.setPadding(3);
                                rightTable.addCell(cell);
                            }
                        }
                        //*** deliveryType = caeserian ***
                        else if(deliveryType.equals("openclinic.common.caeserian")){
                            cell = createValueCell(getTran("openclinic.chuk",deliveryType)+" :",5);
                            cell.setBackgroundColor(BGCOLOR_LIGHT);
                            rightTable.addCell(cell);

                            PdfPTable caeserianTable = new PdfPTable(5);

                            // type of delivery
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CAESERIAN");
                            if(itemValue.length() > 0){
                                itemValue = itemValue.substring(itemValue.lastIndexOf(".")+1);
                                addItemRow(caeserianTable,getTran("gynaeco","time"),getTran("gynaeco.caeserian",itemValue));
                            }

                            // cause
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE");
                            if(itemValue.length() > 0){
                                itemValue = itemValue.substring(itemValue.lastIndexOf(".")+1);
                                addItemRow(caeserianTable,getTran("gynaeco","cause"),getTran("gynaeco.cause",itemValue).toLowerCase());
                            }

                            // remark
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK");
                            if(itemValue.length() > 0){
                                addItemRow(caeserianTable,getTran("Web.Occup","medwan.common.remark"),itemValue);
                            }

                            // add caeserianTable to rightTable
                            if(caeserianTable.size() > 0){
                                cell = createCell(new PdfPCell(caeserianTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                                cell.setPadding(3);
                                rightTable.addCell(cell);
                            }
                        }
                    }

                    // add right table to table
                    cell = createCell(new PdfPCell(rightTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPadding(0);
                    table.addCell(cell);

                    // add table to doc
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                        tranTable.addCell(createContentCell(contentTable));
                        addTransactionToDoc();
                    }
                }
                
                //*** DELIVERANCE *****************************************************************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);
                int itemCount = 0;

                itemList = new Vector();
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DELIVERYHOUR");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_PLACENTA");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_HEMORRAGIE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_PERINEE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_PERINEE_DEGREE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_EPISIOTOMIE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION");

                if(verifyList(itemList)){
                    // title
                    table.addCell(createTitleCell(getTran("gynaeco","delivrance"),10));

                    // delivery.hour
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DELIVERYHOUR");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","delivery.hour"),itemValue);
                        itemCount++;
                    }

                    // deliverance_type
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","delivery.type"),getTran("openclinic.chuk",itemValue).toLowerCase());
                        itemCount++;
                    }

                    // placenta
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_PLACENTA");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","placenta"),getTran("openclinic.chuk",itemValue).toLowerCase());
                        itemCount++;
                    }

                    // hemorragie
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_HEMORRAGIE");
                    if(itemValue.length() > 0){
                        String hemorragie = getTran("web.occup",itemValue).toLowerCase();

                        // hemorragie.intervention
                        String intervention = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION");
                        if(intervention.length() > 0){
                            hemorragie+= "\n\n"+getTran("gynaeco","hemorragie.intervention")+" : "+intervention;
                        }

                        addItemRow(table,getTran("gynaeco","hemorragie"),hemorragie);
                        itemCount++;
                    }

                    // perinee
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_PERINEE");
                    if(itemValue.length() > 0){
                        String perinee = getTran("web.occup",itemValue).toLowerCase();

                        // perinee.degree
                        String degree = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_PERINEE_DEGREE");
                        if(degree.length() > 0){
                            perinee+= ", "+getTran("gynaeco","perinee.degree").toLowerCase()+" : "+degree;
                        }

                        addItemRow(table,getTran("gynaeco","perinee"),perinee);
                        itemCount++;
                    }

                    // episiotomie
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_EPISIOTOMIE");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("gynaeco","episiotomie"),getTran("web.occup",itemValue).toLowerCase());
                        itemCount++;
                    }

                    // observation
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","observation"),itemValue);
                        itemCount++;
                    }

                    // intervention
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","intervention"),itemValue);
                        itemCount++;
                    }

                    // add cell to achieve an even number of displayed cells
                    if(itemCount%2==1){
                        cell = new PdfPCell();
                        cell.setColspan(5);
                        cell.setBorder(PdfPCell.NO_BORDER);
                        table.addCell(cell);
                    }

                    // add table to doc
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                        tranTable.addCell(createContentCell(contentTable));
                        addTransactionToDoc();
                    }
                }

                //*** ENFANT **********************************************************************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);
                itemCount = 0;

                itemList = new Vector();
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_GENDER");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDWEIGHT");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDHEIGHT");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDCRANIEN");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDALIVE");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DEAD_TYPE");

                if(verifyList(itemList)){
                    // title
                    table.addCell(createTitleCell(getTran("openclinic.chuk","child"),10));

                    // gender
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_GENDER");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("gynaeco","gender"),getTran("web.occup",itemValue).toLowerCase());
                        itemCount++;
                    }

                    // weight
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDWEIGHT");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("gynaeco","weight"),itemValue+" "+getTran("unit","gr"));
                        itemCount++;
                    }

                    // height
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDHEIGHT");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("gynaeco","height"),itemValue+" "+getTran("unit","cm"));
                        itemCount++;
                    }

                    // cranien
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDCRANIEN");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("gynaeco","cranien"),itemValue+" "+getTran("unit","cm"));
                        itemCount++;
                    }

                    // add cell to achieve an even number of displayed cells
                    if(itemCount%2==1){
                        cell = new PdfPCell();
                        cell.setColspan(5);
                        cell.setBorder(PdfPCell.NO_BORDER);
                        table.addCell(cell);
                    }

                    //@@@ DEATH OR ALIVE TABLE @@@
                    PdfPTable deathOrAliveTable = new PdfPTable(10);

                    String bornType = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDALIVE");
                    if(bornType.length() > 0){
                        //*** bornType = borndead ***
                        if(bornType.equals("openclinic.common.borndead")){
                            bornType = getTran("openclinic.chuk",bornType);
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_DEAD_TYPE");
                            if(itemValue.length() > 0){
                                itemValue = itemValue.substring(itemValue.lastIndexOf("_")+1).toLowerCase(); // _
                                bornType+= ", "+getTran("gynaeco.deadtype",itemValue).toLowerCase();
                            }

                            deathOrAliveTable.addCell(createValueCell(bornType,10));
                        }
                        //*** bornType = bornalive ***
                        else if(bornType.equals("openclinic.common.bornalive")){
                            deathOrAliveTable.addCell(createValueCell(getTran("openclinic.chuk",bornType).toLowerCase(),10));

                            PdfPTable bornaliveTable = new PdfPTable(5);

                            // dead.in.24h
                            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_DEADIN24H");
                            if(itemValue.equals("medwan.common.true")){
                                 bornaliveTable.addCell(createValueCell(getTran("openclinic.chuk","dead.in.24h").toLowerCase(),5));
                            }

                            //@@@ LEFt TABLE (left) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                            //*** APGAR ***
                            Vector apgarItemList = new Vector();
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COEUR_1");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COEUR_5");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COEUR_10");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_RESP_1");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_RESP_5");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_RESP_10");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TONUS_1");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TONUS_5");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TONUS_10");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_REFL_1");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_REFL_5");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_REFL_10");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COLOR_1");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COLOR_5");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COLOR_10");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TOTAL_1");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TOTAL_5");
                            apgarItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TOTAL_10");

                            if(verifyList(apgarItemList)){
                                PdfPTable apgarTable = new PdfPTable(5);

                                // header
                                apgarTable.addCell(createHeaderCell(getTran("gynaeco","apgar"),2));
                                apgarTable.addCell(createHeaderCell("1'",1));
                                apgarTable.addCell(createHeaderCell("5'",1));
                                apgarTable.addCell(createHeaderCell("10'",1));

                                // apgar.coeur
                                apgarTable.addCell(createItemNameCell(getTran("gynaeco","apgar.coeur"),2));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COEUR_1");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COEUR_5");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COEUR_10");
                                apgarTable.addCell(createValueCell(itemValue,1));

                                // apgar.resp
                                apgarTable.addCell(createItemNameCell(getTran("gynaeco","apgar.resp"),2));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_RESP_1");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_RESP_5");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_RESP_10");
                                apgarTable.addCell(createValueCell(itemValue,1));

                                // apgar.tonus
                                apgarTable.addCell(createItemNameCell(getTran("gynaeco","apgar.tonus"),2));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TONUS_1");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TONUS_5");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TONUS_10");
                                apgarTable.addCell(createValueCell(itemValue,1));

                                // apgar.refl
                                apgarTable.addCell(createItemNameCell(getTran("gynaeco","apgar.refl"),2));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_REFL_1");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_REFL_5");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_REFL_10");
                                apgarTable.addCell(createValueCell(itemValue,1));

                                // apgar.color
                                apgarTable.addCell(createItemNameCell(getTran("gynaeco","apgar.color"),2));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COLOR_1");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COLOR_5");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_COLOR_10");
                                apgarTable.addCell(createValueCell(itemValue,1));

                                // apgar.total
                                apgarTable.addCell(createItemNameCell(getTran("gynaeco","apgar.total"),2));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TOTAL_1");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TOTAL_5");
                                apgarTable.addCell(createValueCell(itemValue,1));
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_APGAR_TOTAL_10");
                                apgarTable.addCell(createValueCell(itemValue,1));

                                // add table
                                cell = createCell(new PdfPCell(apgarTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                                cell.setPadding(3);
                                bornaliveTable.addCell(cell);
                            }
                            
                            //@@@ INFO TABLE (right) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                            Vector infoItemList = new Vector();
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_REANIMATION");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_MALFORMATION");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_OBSERVATION");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_TREATMENT");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDPOLIO");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDBCG");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_LASTNAME");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_FIRSTNAME");
                            infoItemList.add(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_DOB");

                            if(verifyList(infoItemList)){
                                PdfPTable infoTable = new PdfPTable(5);

                                // reanimation
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_REANIMATION");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("openclinic.chuk","reanimation"),itemValue);
                                }

                                // malformation
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_MALFORMATION");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("openclinic.chuk","malformation"),itemValue);
                                }

                                // observation
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_OBSERVATION");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("openclinic.chuk","observation"),itemValue);
                                }

                                // treatment
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_TREATMENT");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("openclinic.chuk","treatment"),itemValue);
                                }

                                // polio.date
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDPOLIO");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("openclinic.chuk","polio.date"),itemValue);
                                }

                                // bcg.date
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILDBCG");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("openclinic.chuk","bcg.date"),itemValue);
                                }

                                // lastname
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_LASTNAME");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("web","lastname"),itemValue);
                                }

                                // firstname
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_FIRSTNAME");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("web","firstname"),itemValue);
                                }

                                // dateofbirth
                                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DELIVERY_CHILD_DOB");
                                if(itemValue.length() > 0){
                                    addItemRow(infoTable,getTran("web","dateofbirth"),itemValue);
                                }

                                // add table
                                cell = createCell(new PdfPCell(infoTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                                cell.setPadding(3);
                                bornaliveTable.addCell(cell);
                            }

                            if(bornaliveTable.size() > 0){
                                deathOrAliveTable.addCell(emptyCell(1));
                                deathOrAliveTable.addCell(createCell(new PdfPCell(bornaliveTable),9,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                            }
                        }

                        cell = createItemNameCell(getTran("openclinic.chuk","birth.type"),2);
                        cell.setBackgroundColor(BGCOLOR_LIGHT);
                        table.addCell(cell);

                        table.addCell(createCell(new PdfPCell(deathOrAliveTable),8,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    }
                }
                
                // add transaction to doc
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    tranTable.addCell(createContentCell(contentTable));
                }

                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
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

