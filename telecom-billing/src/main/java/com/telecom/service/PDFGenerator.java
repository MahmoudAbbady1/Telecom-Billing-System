/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.service;
import com.telecom.model.Invoice;
import com.telecom.model.InvoiceItem;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 *
 * @author mibrahim
 */



public class PDFGenerator {
    private static final Font TITLE_FONT = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
    private static final Font HEADER_FONT = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
    private static final Font NORMAL_FONT = new Font(Font.FontFamily.HELVETICA, 10);
    private static final String INVOICE_DIR = "invoices";
    
    public static void generateInvoicePDF(Invoice invoice) {
        try {
            // Create invoices directory if it doesn't exist
            new File(INVOICE_DIR).mkdirs();
            
            String filename = String.format("%s/invoice_%d.pdf", INVOICE_DIR, invoice.getInvoiceId());
            Document document = new Document();
            PdfWriter.getInstance(document, new FileOutputStream(filename));
            
            document.open();
            addInvoiceHeader(document, invoice);
            addCustomerInfo(document, invoice);
            addInvoiceDetails(document, invoice);
            addInvoiceItems(document, invoice);
            addInvoiceTotals(document, invoice);
            document.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private static void addInvoiceHeader(Document document, Invoice invoice) throws DocumentException {
        Paragraph title = new Paragraph("TELECOM BILLING SYSTEM", TITLE_FONT);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        
        Paragraph invoiceTitle = new Paragraph(
            String.format("INVOICE #%d", invoice.getInvoiceId()), HEADER_FONT);
        invoiceTitle.setAlignment(Element.ALIGN_CENTER);
        invoiceTitle.setSpacingAfter(20);
        document.add(invoiceTitle);
    }
    
    private static void addCustomerInfo(Document document, Invoice invoice) throws DocumentException {
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setSpacingAfter(20);
        
        // Customer Info
        PdfPCell cell = new PdfPCell(new Phrase("BILL TO:", HEADER_FONT));
        cell.setBorder(Rectangle.NO_BORDER);
        table.addCell(cell);
        
        cell = new PdfPCell(new Phrase(
            String.format("Invoice Date: %s", formatDate(invoice.getInvoiceDate())), NORMAL_FONT));
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(cell);
        
        // Add customer details here (name, address, etc.)
        // ...
        
        document.add(table);
    }
    
    private static void addInvoiceDetails(Document document, Invoice invoice) throws DocumentException {
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setSpacingAfter(20);
        
        addDetailRow(table, "Invoice Number", String.valueOf(invoice.getInvoiceId()));
        addDetailRow(table, "Invoice Date", formatDate(invoice.getInvoiceDate()));
        addDetailRow(table, "Due Date", formatDate(invoice.getDueDate()));
        addDetailRow(table, "Status", invoice.getStatus());
        
        document.add(table);
    }
    
    private static void addInvoiceItems(Document document, Invoice invoice) throws DocumentException {
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        table.setSpacingAfter(20);
        
        // Table headers
        table.addCell(createHeaderCell("Description"));
        table.addCell(createHeaderCell("Quantity"));
        table.addCell(createHeaderCell("Unit Price"));
        table.addCell(createHeaderCell("Amount"));
        
        // Table rows
        for (InvoiceItem item : invoice.getItems()) {
            table.addCell(createCell(item.getDescription()));
            table.addCell(createCell(item.getQuantity().toString()));
            table.addCell(createCell("$" + item.getUnitPrice()));
            table.addCell(createCell("$" + item.getAmount()));
        }
        
        document.add(table);
    }
    
    private static void addInvoiceTotals(Document document, Invoice invoice) throws DocumentException {
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(50);
        table.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.setSpacingBefore(20);
        
        addTotalRow(table, "Subtotal:", "$" + invoice.getSubtotal());
        addTotalRow(table, "Tax (10%):", "$" + invoice.getTax());
        addTotalRow(table, "Total:", "$" + invoice.getTotal(), HEADER_FONT);
        
        document.add(table);
    }
    
    // Helper methods
    private static PdfPCell createHeaderCell(String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, HEADER_FONT));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        return cell;
    }
    
    private static PdfPCell createCell(String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, NORMAL_FONT));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        return cell;
    }
    
    private static void addDetailRow(PdfPTable table, String label, String value) {
        table.addCell(createCell(label));
        table.addCell(createCell(value));
    }
    
    private static void addTotalRow(PdfPTable table, String label, String value) {
        addTotalRow(table, label, value, NORMAL_FONT);
    }
    
    private static void addTotalRow(PdfPTable table, String label, String value, Font font) {
        table.addCell(createCell(label));
        PdfPCell cell = new PdfPCell(new Phrase(value, font));
        cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        cell.setBorder(Rectangle.NO_BORDER);
        table.addCell(cell);
    }
    
    private static String formatDate(Date date) {
        return new SimpleDateFormat("MMM dd, yyyy").format(date);
    }
}