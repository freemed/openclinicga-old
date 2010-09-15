package be.mxs.common.util.pdf.util;

import org.jfree.chart.labels.AbstractCategoryItemLabelGenerator;
import org.jfree.data.category.CategoryDataset;
import java.text.NumberFormat;
import org.jfree.chart.labels.CategoryItemLabelGenerator;


/**
 * User: stijn smets
 * Date: 22-nov-2005
 */

//##################################################################################################
// To manipulate the content of the labels shown above the graph-value-points.
// (Used in PDFRespiratoryFunctionExamination)
//##################################################################################################
public class CustomCategoryLabelGenerator extends AbstractCategoryItemLabelGenerator implements CategoryItemLabelGenerator {

    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public CustomCategoryLabelGenerator(NumberFormat numberFormat){
        super("{2}",numberFormat);
    }

    //--- GENERATE LABEL ---------------------------------------------------------------------------
    public String generateLabel(CategoryDataset dataset, int series, int category){
        String label;

        Number gemNum   = dataset.getValue(0,0);
        //Number eigenNum = dataset.getValue(1,category);

        if(series==0) label = "";
        else          label = super.getNumberFormat().format(gemNum.doubleValue())+
                              " ("+super.getNumberFormat().format(gemNum.doubleValue())+")";

        return label;
    }

}
