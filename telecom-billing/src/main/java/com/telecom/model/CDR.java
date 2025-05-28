package com.telecom.model;

import java.io.Serializable;

public class CDR implements Serializable {
    private int id;
    private String filename;
    private boolean processed;

    public CDR() {
    }

    public CDR(String filename, boolean processed) {
        this.filename = filename;
        this.processed = processed;
    }

    public CDR(int id, String filename, boolean processed) {
        this.id = id;
        this.filename = filename;
        this.processed = processed;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public boolean isProcessed() {
        return processed;
    }

    public void setProcessed(boolean processed) {
        this.processed = processed;
    }

    @Override
    public String toString() {
        return "CDR{" +
                "id=" + id +
                ", filename='" + filename + '\'' +
                ", processed=" + processed +
                '}';
    }
}