package org.hnrw.chin;

import org.hnrw.chin.extractors.EncounterExtractor;
import org.hnrw.chin.extractors.Extractor;
import org.hnrw.chin.integrators.Integrator;
import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.Element;
import be.mxs.common.util.db.MedwanQuery;

import java.net.URL;
import java.util.Iterator;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 26-mei-2008
 * Time: 10:16:01
 * To change this template use File | Settings | File Templates.
 */
public class ExtractMessages {
    public static void main(String[] args){
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "healthnet.xml";
        SAXReader reader = new SAXReader(false);
        try {
            Document hnConfig = reader.read(new URL(sDoc));
            Element root=hnConfig.getRootElement();
            Element extractorlist=root.element("extractor");
            Iterator extractors = extractorlist.elementIterator("class");
            while(extractors.hasNext()){
                Element cls = (Element)extractors.next();
                Extractor extractor = (Extractor)Class.forName(cls.attributeValue("name")).newInstance();
                extractor.getMessage();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        MessageManager.sendMessages(false);
    }
}
