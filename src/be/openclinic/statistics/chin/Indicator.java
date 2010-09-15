package be.openclinic.statistics.chin;

import org.dom4j.Element;

import java.util.Hashtable;
import java.util.Iterator;

import be.mxs.common.util.system.ScreenHelper;

/**
 * User: Frank Verbeke
 * Date: 30-jul-2007
 * Time: 8:51:48
 */
public abstract class Indicator {
    private String id;
    private String type;
    private Hashtable comments=new Hashtable();

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Indicator(Element indicator){
        setId(indicator.attributeValue("id"));
        setType(indicator.attributeValue("type"));
        Iterator iComments = indicator.elementIterator("comment");
        while(iComments.hasNext()){
            Element comment = (Element)iComments.next();
            comments.put(comment.attributeValue("language").toLowerCase(),comment.getText());
        }
    }

    public String getComment(String language){
        return ScreenHelper.checkString((String)comments.get(language.toLowerCase()));
    }
}
