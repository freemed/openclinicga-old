package be.openclinic.statistics.chin;

import be.mxs.common.util.db.MedwanQuery;
import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;

import java.net.URL;
import java.net.MalformedURLException;
import java.util.Iterator;
import java.util.Vector;

/**
 * User: Frank Verbeke
 * Date: 30-jul-2007
 * Time: 8:18:22
 */
public class CHINAnalyser {
    private Vector CHINIndicators=new Vector();

    public Vector getCHINIndicators() {
        return CHINIndicators;
    }

    public void setCHINIndicators(Vector CHINIndicators) {
        this.CHINIndicators = CHINIndicators;
    }

    public CHINAnalyser() {
        try {
            String sFilename= MedwanQuery.getInstance().getConfigString("templateSource")+"/CHIN.xml";
            SAXReader reader = new SAXReader(false);
            Document document = reader.read(new URL(sFilename));
            Element root = document.getRootElement();
            Iterator indicators=root.elementIterator("indicator");
            while(indicators.hasNext()){
                Element indicator = (Element)indicators.next();
                if(indicator.attributeValue("type").equalsIgnoreCase("diagnosistrend")){
                    DiagnosisTrend diagnosisTrend = new DiagnosisTrend(indicator);
                    CHINIndicators.add(diagnosisTrend);
                }
            }
        } catch (DocumentException e) {
            e.printStackTrace();  
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }

    }
}
