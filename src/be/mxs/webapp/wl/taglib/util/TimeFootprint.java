package be.mxs.webapp.wl.taglib.util;

import javax.servlet.jsp.tagext.TagSupport;
import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 09-avr.-2003
 * Time: 15:22:17
 * To change this template use Options | File Templates.
 */
public class TimeFootprint extends TagSupport {

    // ------------------------------------------------------------- Properties

    private String prefix ="" ;
    private String suffix ="" ;

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public String getSuffix() {
        return suffix;
    }

    public void setSuffix(String suffix) {
        this.suffix = suffix;
    }


    // --------------------------------------------------------- Public Methods

    /**
     * Process the start tag.
     *
     */
    public int doStartTag() {

        try {

            String timeFootprint = "ts=" + new java.util.Date().hashCode();

            pageContext.getOut().print(getPrefix() + timeFootprint + getSuffix());

        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Continue processing this page
	    return (SKIP_BODY);

    }
}