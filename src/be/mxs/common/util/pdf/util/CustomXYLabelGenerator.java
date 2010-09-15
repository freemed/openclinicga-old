package be.mxs.common.util.pdf.util;

import org.jfree.chart.labels.AbstractXYItemLabelGenerator;
import org.jfree.chart.labels.XYItemLabelGenerator;
import org.jfree.data.xy.XYDataset;

import java.text.NumberFormat;

/**
 * User: ssm
 * Date: 23-jul-2007
 */
public class CustomXYLabelGenerator extends AbstractXYItemLabelGenerator implements XYItemLabelGenerator {

    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public CustomXYLabelGenerator(String format, NumberFormat numberFormatX, NumberFormat numberFormatY){
        super(format,numberFormatX,numberFormatY);
    }

    //--- GENERATE LABEL ---------------------------------------------------------------------------
    public String generateLabel(XYDataset dataset, int x, int y){
        String label;

        Number yNum = dataset.getY(0,y);
        label = super.getYFormat().format(yNum.doubleValue());

        return label;
    }

}
