package be.mxs.common.model.vo;

public class IdentifierFactory {

    private static IdentifierFactory identifierFactory = null;
    private static int newIdentifierCounter = -1;


    //--- GET INSTANCE -----------------------------------------------------------------------------
    public static IdentifierFactory getInstance() {
        if (identifierFactory == null) identifierFactory = new IdentifierFactory();
        return identifierFactory;
    }

    //--- GET IDENTIFIER ---------------------------------------------------------------------------
    public String getIdentifier(IIdentifiable o, String prefix, String suffix) {
        if (prefix == null) prefix = "";
        else                prefix = prefix + ".";

        if (suffix == null) suffix = "";
        else                suffix = "." + suffix;

        return  getIdentifierStartTag() + prefix + getIdentifiableClassName(o) + "[" + getKeyName() + "=" + o.hashCode() + "]" + suffix + getIdentifierEndTag();
    }

    //--- GET NEW IDENTIFIER -----------------------------------------------------------------------
    public String getNewIdentifier(IIdentifiable o, String prefix, String suffix) {
        if (prefix == null) prefix = "";
        else                prefix = prefix + ".";

        if (suffix == null) suffix = "";
        else                suffix = "." + suffix;

        return  getIdentifierStartTag() + prefix + getIdentifiableClassName(o) + "[" + getNewDeclarator() + "=" + this.getTemporaryNewIdentifier() + "]" + suffix + getIdentifierEndTag();
    }

    //--- GET TEMPORARY NEW IDENTIFIER -------------------------------------------------------------
    public String getTemporaryNewIdentifier() {
        return Integer.toString(newIdentifierCounter--);
    }

    //--- GET TAGS ---------------------------------------------------------------------------------
    public String getIdentifierStartTag() { return "<"; }
    public String getIdentifierEndTag() { return ">"; }

    //--- GET IDENTIFIABLE CLASS NAME --------------------------------------------------------------
    public String getIdentifiableClassName(IIdentifiable o) {
        String className = o.getClass().getName();
        String packageName = o.getClass().getPackage().getName();

        return className.substring(packageName.length() + 1);
    }

    //--- GET IDENTIFIER CLASS NAME ----------------------------------------------------------------
    public String getIdentifierClassName(String identifier) {
        int beginIndex;
        int endIndex;

        endIndex = identifier.indexOf("["+getKeyName());
        beginIndex = identifier.substring(0, endIndex).indexOf(".") + 1;

        return identifier.substring(beginIndex,endIndex);
    }

    //--- GET IDENTIFIER PREFIX --------------------------------------------------------------------
    public String getIdentifierPrefix(String identifier) {
        int beginIndex = 0;
        int endIndex;

        endIndex = identifier.indexOf(getIdentifierClassName(identifier));
        if (identifier.substring(0,endIndex).endsWith(".")) endIndex--;

        if (endIndex < 0) endIndex = 0;

        return identifier.substring(beginIndex,endIndex);
    }

    //--- GET IDENTIFIER HASHCODE ------------------------------------------------------------------
    public String getIdentifierHashcode(String identifier) {
        int beginIndex;
        int endIndex;

        String s = "["+getKeyName()+"=";
        beginIndex = identifier.indexOf(s) + s.length();
        endIndex = identifier.indexOf("]");

        return identifier.substring(beginIndex,endIndex);
    }

    //--- GET IDENTIFIER SUFFIX --------------------------------------------------------------------
    public String getIdentifierSuffix(String identifier) {
        int beginIndex;
        int endIndex = identifier.length();

        beginIndex = identifier.indexOf("]") + 1;
        if (identifier.substring(beginIndex,endIndex).startsWith(".")) beginIndex++;

        return identifier.substring(beginIndex,endIndex);
    }

    //--- GET KEY NAME -----------------------------------------------------------------------------
    public static String getKeyName() {
        return "hashCode";
    }

    //--- GET NEW DECLARATOR -----------------------------------------------------------------------
    public static String getNewDeclarator() {
        return "new:id=";
    }
}
