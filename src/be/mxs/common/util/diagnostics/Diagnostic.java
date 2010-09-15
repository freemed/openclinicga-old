package be.mxs.common.util.diagnostics;

/**
 * User: frank
 * Date: 7-okt-2005
 */
public abstract class Diagnostic {
    public String name;
    public String id;
    public String author;
    public String description;
    public String version;
    public String date;
    public abstract Diagnosis check();
    public abstract boolean correct(Diagnosis diagnosis);

    public Diagnostic() {

    }

    public Diagnostic(String name, String id, String author, String description, String version, String date) {
        this.name = name;
        this.id = id;
        this.author = author;
        this.description = description;
        this.version = version;
        this.date = date;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
