package be.mxs.webapp.wl.taglib.navigation;

import be.dpms.medwan.common.model.IConstants;

import javax.servlet.jsp.tagext.TagSupport;
import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 09-avr.-2003
 * Time: 15:22:17
 * To change this template use Options | File Templates.
 */
public class URLHistoryTag extends TagSupport {

    // ------------------------------------------------------------- Properties
    private String uri;
    private String action;
    private String displayName;

    // --------------------------------------------------------- Private Methods

    private String getUri() {
        return uri;
    }

    private String getAction() {
        return action;
    }

    private String getDisplayName() {
        return displayName;
    }

    private String getRemoveFromHistoryQueryString(){
        String s;

        if (getUri().indexOf("?") == -1) {
            s = getUri() + "?" + IConstants.HISTORY_ACTION + "=" + IConstants.REMOVE + "&" + IConstants.ITEM_ID + "=" + getId();
        } else {
            s = getUri() + "&" + IConstants.HISTORY_ACTION + "=" + IConstants.REMOVE + "&" + IConstants.ITEM_ID + "=" + getId();
        }

        return s;
    }

    private String getAddToHistoryQueryString(){
        String s;

        if (getUri().indexOf("?") == -1) {
            s = getUri() + "?" + IConstants.HISTORY_ACTION + "=" + IConstants.ADD + "&" + IConstants.HISTORY_ITEM_DISPLAY_NAME + "=" + getDisplayName();
        } else {
            s = getUri() + "&" + IConstants.HISTORY_ACTION + "=" + IConstants.ADD + "&" + IConstants.HISTORY_ITEM_DISPLAY_NAME + "=" + getDisplayName();
        }

        return s;
    }

    // --------------------------------------------------------- Public Methods

    public void setUri(String uri){
        this.uri = uri;
    }

    public void setAction(String action){
        this.action = action;
    }

    public void setDisplayName(String displayName){
        this.displayName = displayName;
    }

    /**
     * Process the start tag.
     *
     */
    public int doStartTag() {

        String html = null;

        if (getAction().equals(IConstants.ADD)) {

            html = getAddToHistoryQueryString();

        }  else if (getAction().equals(IConstants.REMOVE)) {

            html = getRemoveFromHistoryQueryString();

        }

        try {
            pageContext.getOut().print(html);
        } catch (IOException e) {
            ////Debug.println(e.getMessage());
        }

        // Continue processing this page
	    return (SKIP_BODY);

    }
}