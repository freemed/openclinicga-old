package be.dpms.medwan.webapp.wo.common.navigation;

import be.dpms.medwan.common.model.IConstants;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.webapp.wl.exceptions.WebLogicException;
import be.mxs.webapp.wl.session.SessionContainerFactory;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

public class URLHistoryHelper {

    // -----------------------------------------------------------------------------------------------------------------
    // Static members...
    // -----------------------------------------------------------------------------------------------------------------

    private static URLHistoryHelper urlHistoryHelper = null;
    private String historyHomepageURL;
    private String historyHomepageDisplayName;

    public static URLHistoryHelper getInstance(String homepageURL, String homepageDisplayName){
        if (urlHistoryHelper == null) urlHistoryHelper = new URLHistoryHelper(homepageURL, homepageDisplayName);
        else if (! urlHistoryHelper.getHistoryHomepageURL().equals(homepageURL) ) urlHistoryHelper = new URLHistoryHelper(homepageURL, homepageDisplayName);
        return urlHistoryHelper;
    }

    public URLHistoryHelper(String homepageURL, String homepageDisplayName){
        // @todo: the following intialization should be based on a config-file
        this.historyHomepageURL = homepageURL;
        this.historyHomepageDisplayName = homepageDisplayName;
        //historyHomepageURL = "/showWelcomePage.do";
        //historyHomepageDisplayName = "Home";
    }

    public String getHistoryHomepageURL() {
        return historyHomepageURL;
    }

    public String getHistoryHomepageDisplayName() {
        return historyHomepageDisplayName;
    }

    // -----------------------------------------------------------------------------------------------------------------
    // URLHistory management public methods
    // -----------------------------------------------------------------------------------------------------------------
    public void updateHistory(ServletRequest request, ServletResponse response) throws URLHistoryException, WebLogicException {

        String historyAction = request.getParameter(IConstants.HISTORY_ACTION);

        if (historyAction != null) {
            if (historyAction.equals(IConstants.ADD)) {
                addHistoryItem((HttpServletRequest)request);
            }
            else if (historyAction.equals(IConstants.REMOVE)) {
                removeItemToUrlHistory((HttpServletRequest)request);
            }

        }
        else {
            // We make a call to getHistory() in order to create HISTORY if it doesn't exist !
            getHistory((HttpServletRequest)request);
        }

    }

    // -----------------------------------------------------------------------------------------------------------------
    // URLHistory management private methods
    // -----------------------------------------------------------------------------------------------------------------
    private URLHistory getHistory(HttpServletRequest request) throws WebLogicException {
        // Get the URLHistory from the session (or create it if it doesn't exist)

        SessionContainerWO  sessionContainerWO;

        try {
            sessionContainerWO = (be.dpms.medwan.webapp.wo.common.system.SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO( request, SessionContainerWO.class.getName());

        }
        catch (SessionContainerFactoryException e) {
            throw new WebLogicException(e.getMessage());
        }

        URLHistory urlHistory = sessionContainerWO.getURLHistory();

        if ((urlHistory == null) || ((! urlHistory.getHomepageQueryString().equals(historyHomepageURL)))) {
            urlHistory = new URLHistory(historyHomepageDisplayName, historyHomepageURL);
            sessionContainerWO.setURLHistory(urlHistory);
            ////Debug.println("Adding new empty URLHistory to sessionContainerWO...");
        }

        return urlHistory;
    }

    private void addHistoryItem(HttpServletRequest request) throws URLHistoryException {

        String displayName = request.getParameter(IConstants.HISTORY_ITEM_DISPLAY_NAME);

        if (displayName == null) {
            throw new URLHistoryException(this.getClass().getName()+".addHistoryItem() - displayName can't be null");
        }
    }

    public void removeItemToUrlHistory(HttpServletRequest request) throws WebLogicException {

        String itemId           = request.getParameter(IConstants.ITEM_ID);
        URLHistory urlHistory   = getHistory(request);

        urlHistory.removeUrlItem(itemId);
    }
}
