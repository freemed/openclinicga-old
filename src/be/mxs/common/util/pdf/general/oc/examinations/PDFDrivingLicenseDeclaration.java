package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Phrase;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFDrivingLicenseDeclaration extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // CATEGORY (checkboxes)
                String categories = "";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_B").equals(""))    categories+= "B, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_B_E").equals(""))  categories+= "B+E, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_C").equals(""))    categories+= "C, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_C_E").equals(""))  categories+= "C+E, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_C1").equals(""))   categories+= "C1, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_C1_E").equals("")) categories+= "C1+E, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_D").equals(""))    categories+= "D, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_D_E").equals(""))  categories+= "D+E, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_D1").equals(""))   categories+= "D1, ";
                if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_D1_E").equals("")) categories+= "D1+E, ";

                // add categories row
                if(categories.length() > 0){
                    // remove last comma
                    if(categories.indexOf(",") > -1){
                        categories = categories.substring(0,categories.lastIndexOf(","));
                    }

                    addItemRow(table,getTran("medwan.common.driving-license-declaration.candidate-questionnaire.actual-category-or-sub-category"),categories.toLowerCase());
                }

                // delivery place
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_DELIVERED_TO");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_DLD_DELIVERED_TO"),itemValue);
                }

                // expiration date
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_VALIDITY_DATE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_DLD_VALIDITY_DATE"),itemValue);
                }

                // questionnaire valide for category
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_CANDIDATE_CATEGORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_DLD_CANDIDATE_CATEGORY"),itemValue);
                }

                //*** in voorkomend geval : previous examination date & examinator name ***
                String prevExamDate   = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_EXAMINATION_DATE");
                String examinatorName = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_EXAMINATOR_NAME");

                if(prevExamDate.length() > 0 || examinatorName.length() > 0){
                    // sub title
                    cell = createHeaderCell(getTran("medwan.common.driving-license-declaration.candidate-questionnaire.if-applicable"),5);
                    cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                    table.addCell(cell);

                    if(prevExamDate.length() > 0){
                       addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_DLD_EXAMINATION_DATE"),prevExamDate);
                    }

                    if(examinatorName.length() > 0){
                        addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_DLD_EXAMINATOR_NAME"),examinatorName);
                    }
                }

                // add content to doc
                if(table.size() > 0){
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // add transaction part 1 to doc
                addTransactionToDoc();

                // add transaction part 2 to doc
                //*** QUESTIONNAIRE ***
                addQuestionnaire();
                addTransactionToDoc();

                //*** comment ***
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_REMARK");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("medwan.common.comment"),itemValue);

                    // add content to doc
                    if(table.size() > 0){
                        contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                        tranTable.addCell(createContentCell(contentTable));
                        addTransactionToDoc();
                    }
                }
            }
        }
        catch(Exception e){
           e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    //--- ADD QUESTIONNAIRE ------------------------------------------------------------------------
    private void addQuestionnaire(){
        if(isAtLeastOneQuestionAnswered()){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            PdfPTable questions = new PdfPTable(40);

            // header
            questions.addCell(createTitleCell(getTran("medwan.common.driving-license-declaration.candidate-questionnaire"),40));

            // questions
            String questionPrefix = "medwan.common.driving-license-declaration.candidate-questionnaire.question-";
            for(int i=1; i<=20; i++){
                questions = addQuestion(questions,i,getTran(questionPrefix+i),IConstants_PREFIX+"ITEM_TYPE_DLD_Q"+i);
            }

            // commitment
            String commPart1 = getTran("medwan.common.driving-license-declaration.candidate-questionnaire.commitment")+" ";
            String commPart2 = getTran("medwan.common.driving-license-declaration.candidate-questionnaire.commitment1");

            cell = new PdfPCell(new Phrase(commPart1+commPart2,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
            cell.setColspan(40);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            questions.addCell(cell);

            // add content to document
            if(questions.size() > 0){
                contentTable.addCell(createCell(new PdfPCell(questions),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- IS AT LEAST ONE QUESTION ANSWERED --------------------------------------------------------
    private boolean isAtLeastOneQuestionAnswered(){
        for(int i=1; i<=20; i++){
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_DLD_Q"+i).length() > 0){
                return true;
            }
        }

        return false;
    }

    //--- ADD QUESTION -----------------------------------------------------------------------------
    private PdfPTable addQuestion(PdfPTable table, int id, String question, String answer){
        // cel 1 : nr
        cell = new PdfPCell(new Phrase(id+"",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        table.addCell(cell);

        // cel 2-38 : question
        cell = new PdfPCell(new Phrase(question,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(37);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        table.addCell(cell);

        // cel 39 and 40 : answer
        cell = new PdfPCell(new Phrase(getTran(getItemValue(answer)),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        table.addCell(cell);

        return table;
    }

}
