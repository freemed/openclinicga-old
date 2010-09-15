package be.dpms.medwan.common.model;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 02-avr.-2003
 * Time: 17:02:36
 */
public interface IConstants {

    // -----------------------------------------------------------------------------------------------------------------
    // 0. Class constants
    // -----------------------------------------------------------------------------------------------------------------

    public static final String IConstants_PREFIX                = "be.dpms.medwan.common.model.IConstants.";
    public static final String CONSTANTS                        = IConstants_PREFIX + "CONSTANTS";

    // -----------------------------------------------------------------------------------------------------------------
    // 0.1. Test & debug constants - should be removed before going to production
    // -----------------------------------------------------------------------------------------------------------------

    public static final String TEST_SESSION_KEY                 = IConstants_PREFIX + "TEST_SESSION_KEY";
    public static final String TEST_SESSION_KEY_EXPIRED         = IConstants_PREFIX + "TEST_SESSION_KEY_EXPIRED";

    public static final String TEST_USER_DISPLAY_NAME           = "Michaël LERUTH";
    public static final String TEST_USERNAME                    = "medwan";
    public static final String TEST_PASSWORD                    = "p0lice";

    public static final String TEST_USER_EXPIRED_DISPLAY_NAME   = "Mister EXPIRED";
    public static final String TEST_USERNAME_EXPIRED            = "medwan_expired";
    public static final String TEST_PASSWORD_EXPIRED            = "p0lice_expired";

    // -----------------------------------------------------------------------------------------------------------------
    // 1. Common constants
    // -----------------------------------------------------------------------------------------------------------------

    // -----------------------------------------------------------------------------------------------------------------
    // 1.1. Common constants - Medwan application specific
    // -----------------------------------------------------------------------------------------------------------------

    public static final String DEFAULT                      = IConstants_PREFIX + "DEFAULT";

    public static final String SERVICE_FACTORY              = IConstants_PREFIX + "SERVICE_FACTORY";
    public static final String WO_SESSION_CONTAINER         = IConstants_PREFIX + "WO_SESSION_CONTAINER";
    public static final String WO_USER                      = "WO_USER";
//    public static final String MEDWAN_LOGIN_PAGE = "/medwan/showLoginPage.do";
    public static final String MEDWAN_LOGIN_PAGE            = "/showAuthenticationPage.do";

    // -----------------------------------------------------------------------------------------------------------------
    // 1.2. Common constants - User preferences
    // -----------------------------------------------------------------------------------------------------------------

    public static final String COUNTRY                      = "COUNTRY";
    public static final String COUNTRY_BE                   = "BE";

    public static final String LANGUAGE                     = "LANGUAGE";
    public static final String LANGUAGE_EN                  = "EN";
    public static final String LANGUAGE_FR                  = "FR";
    public static final String LANGUAGE_NL                  = "NL";

    // -----------------------------------------------------------------------------------------------------------------
    // 2. HTTPRequest parameter constants
    // -----------------------------------------------------------------------------------------------------------------

    //public static String YES = "YES";
    //public static String NO = "NO";
    public static final String ADD                          = "ADD";
    public static final String REMOVE                       = "REMOVE";
    public static final String ITEM_ID                      = "ITEM_ID";

    // -----------------------------------------------------------------------------------------------------------------
    // 2.1. Webpage History constants (for navigation purpose)
    // -----------------------------------------------------------------------------------------------------------------

    public static final String HISTORY                      = IConstants_PREFIX + "HISTORY";
    public static final String HISTORY_ACTION               = "HISTORY_ACTION";
    public static final String HISTORY_ITEM_DISPLAY_NAME    = "HISTORY_ITEM_DISPLAY_NAME";

    // -----------------------------------------------------------------------------------------------------------------
    // 3. AuthenticationService constants
    // -----------------------------------------------------------------------------------------------------------------

    public static final String AUTHENTICATION_TOKEN                         = IConstants_PREFIX + "AUTHENTICATION_TOKEN";
    public static final String AUTHENTICATION_TOKEN_INITIAL_HTTP_REQUEST    = IConstants_PREFIX + "AUTHENTICATION_TOKEN_INITIAL_HTTP_REQUEST";

    // -----------------------------------------------------------------------------------------------------------------
    // 4. OccupationalMedicine constants
    // -----------------------------------------------------------------------------------------------------------------

    public static final String RISK_PROFILE_ITEM_TYPE__FUNCTION_CATEGORY    = IConstants_PREFIX + "FUNCTION_CATEGORY";
    public static final String RISK_PROFILE_ITEM_TYPE__WORKPLACE            = IConstants_PREFIX + "WORKPLACE";
    public static final String RISK_PROFILE_ITEM_TYPE__FUNCTION_GROUP       = IConstants_PREFIX + "FUNCTION_GROUP";

    public static final String RISK_PROFILE_ITEM_TYPE__SYSTEM_RISK          = IConstants_PREFIX + "SYSTEM_RISK";
    public static final String RISK_PROFILE_ITEM_TYPE__SYSTEM_EXAMINATION   = IConstants_PREFIX + "SYSTEM_EXAMINATION";

    public static final String RISK_PROFILE_ITEM_TYPE__PERSONAL_RISK        = IConstants_PREFIX + "PERSONAL_RISK";
    public static final String RISK_PROFILE_ITEM_TYPE__PERSONAL_EXAMINATION = IConstants_PREFIX + "PERSONAL_EXAMINATION";

    public static final int RISK_PROFILE_ITEM__STATUS_NONE          = -2;
    public static final int RISK_PROFILE_ITEM__STATUS_DELETED       = -1;
    public static final int RISK_PROFILE_ITEM__STATUS_DEFAULT       = 0;
    public static final int RISK_PROFILE_ITEM__STATUS_ADDED         = 1;
    public static final int RISK_PROFILE_ITEM__STATUS_UPDATED       = 2;

    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__TYPE_SYSTEM        = "medwan.occupational-medicine.risk-profile.system";
    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__TYPE_PERSONAL      = "medwan.occupational-medicine.risk-profile.personal";

    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_DEFAULT     = "medwan.occupational-medicine.risk-profile.default";
    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_NONE        = "medwan.occupational-medicine.risk-profile.none";
    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_ADDED       = "medwan.occupational-medicine.risk-profile.added";
    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED     = "medwan.occupational-medicine.risk-profile.removed";
    public static final String RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_UPDATED        = "medwan.occupational-medicine.risk-profile.updated";

    // -----------------------------------------------------------------------------------------------------------------
    // 5. Recruitment constants
    // -----------------------------------------------------------------------------------------------------------------

    public static final String RECRUITMENT__STATUS_OPEN                 = "medwan.recruitment.status.open";
    public static final String RECRUITMENT__STATUS_CLOSED               = "medwan.recruitment.status.close";
    public static final String RECRUITMENT__APPEAL                      = "medwan.recruitment.status.appeal";
    public static final String RECRUITMENT__APPEAL_WITH_3_DECISIONS     = "medwan.recruitment.status.appeal-with-3-decisions";
}
