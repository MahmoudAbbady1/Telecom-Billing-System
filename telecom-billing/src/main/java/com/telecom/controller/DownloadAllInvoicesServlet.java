package com.telecom.controller;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.text.SimpleDateFormat;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.borders.SolidBorder;
import com.telecom.model.InvoiceDetailsDTO;
import java.math.BigDecimal;
import javax.servlet.annotation.WebServlet;

@WebServlet("/invoices/downloadAll")
public class DownloadAllInvoicesServlet extends HttpServlet {

    private static final String INVOICES_DIR = "/invoices/";
    private static final DeviceRgb HEADER_COLOR = new DeviceRgb(33, 150, 243); // Blue accent for headers
    private static final DeviceRgb TABLE_BG_COLOR = new DeviceRgb(245, 245, 245); // Light gray background

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Create invoices directory if it doesn't exist
        String savePath = getServletContext().getRealPath(INVOICES_DIR);
        Path invoicesDir = Paths.get(savePath);
        try {
            Files.createDirectories(invoicesDir);
        } catch (IOException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Cannot create invoices directory: " + e.getMessage());
            return;
        }

        // Fetch all invoices from API
        URL url = new URL("http://localhost:8080/telecom-billing/api/invoices/all");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Accept", "application/json");

        if (conn.getResponseCode() != 200) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Invoices not found: HTTP " + conn.getResponseCode());
            conn.disconnect();
            return;
        }

        ObjectMapper mapper = new ObjectMapper();
        List<InvoiceDetailsDTO> invoices;
        try {
            invoices = mapper.readValue(conn.getInputStream(),
                    mapper.getTypeFactory().constructCollectionType(List.class, InvoiceDetailsDTO.class));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error parsing API response: " + e.getMessage());
            conn.disconnect();
            return;
        }
        conn.disconnect();

        if (invoices.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No invoices found");
            return;
        }

        // Generate ZIP file containing one PDF per invoice
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zipOut = new ZipOutputStream(baos)) {
            for (InvoiceDetailsDTO invoiceData : invoices) {
                if (invoiceData == null || invoiceData.getInvoice() == null || invoiceData.getInvoice().getInvoiceId() == null) {
                    System.err.println("Skipping invoice with missing data: " + (invoiceData != null && invoiceData.getInvoice() != null ? invoiceData.getInvoice().getInvoiceId() : "null"));
                    continue;
                }

                // Generate PDF for this invoice
                ByteArrayOutputStream pdfBaos = new ByteArrayOutputStream();
                try (PdfWriter writer = new PdfWriter(pdfBaos);
                     PdfDocument pdf = new PdfDocument(writer);
                     Document document = new Document(pdf)) {

                    // Set default font
                    PdfFont font = PdfFontFactory.createFont("Helvetica");
                    PdfFont boldFont = PdfFontFactory.createFont("Helvetica-Bold");
                    document.setFont(font);
                    document.setFontSize(12);

                    // Add logo to top right
                    String logoPath = getServletContext().getRealPath("/css/iti_logo.png");
                    try {
                        Image logo = new Image(ImageDataFactory.create(logoPath));
                        logo.setFixedPosition(pdf.getDefaultPageSize().getWidth() - 200, pdf.getDefaultPageSize().getHeight() - 75);
                        logo.setWidth(100);
                        logo.setAutoScale(true);
                        document.add(logo);
                    } catch (Exception e) {
                        System.err.println("Error adding logo for invoice " + invoiceData.getInvoice().getInvoiceId() + ": " + e.getMessage());
                    }

                    // Add top margin to avoid overlap
                    document.add(new Paragraph("\n"));

                    // Header: T3mya - Egypt
                    document.add(new Paragraph("T3mya - Egypt")
                            .setFont(boldFont)
                            .setFontSize(16)
                            .setFontColor(HEADER_COLOR)
                            .setTextAlignment(TextAlignment.LEFT)
                            .setMarginBottom(20));

                    // Title
                    document.add(new Paragraph("Invoice #" + invoiceData.getInvoice().getInvoiceId())
                            .setFont(boldFont)
                            .setFontSize(18)
                            .setTextAlignment(TextAlignment.CENTER)
                            .setMarginBottom(20));

                    // Customer Info
                    Table customerTable = new Table(UnitValue.createPercentArray(new float[]{50, 50}));
                    customerTable.setWidth(UnitValue.createPercentValue(100));
                    customerTable.setMarginBottom(20);

                    Cell leftCell = new Cell();
                    leftCell.setBorder(Border.NO_BORDER);
                    leftCell.add(new Paragraph("Bill To:")
                            .setFont(boldFont)
                            .setFontSize(14)
                            .setFontColor(HEADER_COLOR)
                            .setMarginBottom(10));
                    leftCell.add(new Paragraph("Name: " + (invoiceData.getCustomer() != null ? invoiceData.getCustomer().getName() : "N/A")));
                    leftCell.add(new Paragraph("Phone: " + (invoiceData.getCustomer() != null ? invoiceData.getCustomer().getPhone() : "N/A")));
                    leftCell.add(new Paragraph("Email: " + (invoiceData.getCustomer() != null ? invoiceData.getCustomer().getEmail() : "N/A")));

                    Cell rightCell = new Cell();
                    rightCell.setBorder(Border.NO_BORDER);
                    rightCell.setTextAlignment(TextAlignment.RIGHT);
                    rightCell.add(new Paragraph("Address: " + (invoiceData.getCustomer() != null ? invoiceData.getCustomer().getAddress() : "N/A")));
                    rightCell.add(new Paragraph("Invoice Date: " + (invoiceData.getInvoice().getInvoiceDate() != null
                            ? new SimpleDateFormat("MMM dd, yyyy").format(invoiceData.getInvoice().getInvoiceDate()) : "N/A"))
                            .setMarginTop(10));
                    rightCell.add(new Paragraph("Status: " + (invoiceData.getCustomer() != null ? invoiceData.getCustomer().getStatus() : "N/A")));

                    customerTable.addCell(leftCell);
                    customerTable.addCell(rightCell);
                    document.add(customerTable);

                    // Main Table
                    Table table = new Table(UnitValue.createPercentArray(new float[]{40, 40, 20}));
                    table.setWidth(UnitValue.createPercentValue(100));
                    table.setBorder(new SolidBorder(ColorConstants.LIGHT_GRAY, 1));
                    table.setPadding(10);
                    table.setBackgroundColor(TABLE_BG_COLOR);

                    // Table Header
                    table.addHeaderCell(new Cell().add(new Paragraph("Description").setFont(boldFont).setFontColor(HEADER_COLOR)));
                    table.addHeaderCell(new Cell().add(new Paragraph("Details").setFont(boldFont).setFontColor(HEADER_COLOR)));
                    table.addHeaderCell(new Cell().add(new Paragraph("Fees (EGP)").setFont(boldFont).setFontColor(HEADER_COLOR))
                            .setTextAlignment(TextAlignment.CENTER));

                    // Table Rows
                    table.addCell(new Cell().add(new Paragraph("Rate Plan:").setFont(boldFont)));
                    table.addCell(new Paragraph(invoiceData.getRatePlan() != null ? invoiceData.getRatePlan().getPlanName() : "N/A"));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getRatePlan() != null ? invoiceData.getRatePlan().getMonthlyFee() : 0.00))
                            .setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("Free Unit Package:").setFont(boldFont)));
                    table.addCell(new Paragraph(invoiceData.getFreeUnit() != null ? invoiceData.getFreeUnit().getServiceName() : "Not Have"));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getFreeUnit() != null ? invoiceData.getFreeUnit().getFreeUnitMonthlyFee() : 0.00))
                            .setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("OCC:").setFont(boldFont)));
                    table.addCell(new Paragraph(invoiceData.getCustomer() != null ? invoiceData.getCustomer().getOccName() : "Not Have"));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getCustomer() != null ? invoiceData.getCustomer().getPrice_occ_per_month() : 0.00))
                            .setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("ROR Usage:").setFont(boldFont)));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getInvoice().getRorUsage())));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getInvoice().getRorUsage()))
                            .setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("Subtotal:").setFont(boldFont)));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getInvoice().getSubtotal())));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getInvoice().getSubtotal()))
                            .setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("Tax (10%):").setFont(boldFont)));
                    table.addCell(new Paragraph(" "));
                    table.addCell(new Paragraph(
                            String.format("%.2f",
                                    invoiceData.getInvoice().getSubtotal()
                                            .multiply(invoiceData.getInvoice().getTax())
                                            .divide(BigDecimal.valueOf(100)))
                    ).setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("Promotion Package:").setFont(boldFont)));
                    table.addCell(new Paragraph(""));
                    table.addCell(new Paragraph(invoiceData.getCustomer() != null && invoiceData.getCustomer().getPromotionPackage() != 0
                            ? invoiceData.getCustomer().getPromotionPackage() + "" : "0.00").setTextAlignment(TextAlignment.CENTER));

                    table.addCell(new Cell().add(new Paragraph("Total:").setFont(boldFont)));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getInvoice().getTotal())));
                    table.addCell(new Paragraph(String.format("%.2f", invoiceData.getInvoice().getTotal()))
                            .setTextAlignment(TextAlignment.CENTER));

                    document.add(table);

                    // Save PDF to file
                    String phoneNumber = invoiceData.getCustomer() != null && invoiceData.getCustomer().getPhone() != null
                            ? invoiceData.getCustomer().getPhone().replaceAll("[^0-9]", "")
                            : "unknown";
                    String pdfFileName = "invoice_" + phoneNumber + "_" + invoiceData.getInvoice().getInvoiceId() + ".pdf";
                    Path pdfPath = invoicesDir.resolve(pdfFileName);
                    try {
                        Files.write(pdfPath, pdfBaos.toByteArray());
                    } catch (IOException e) {
                        System.err.println("Error saving PDF for invoice " + invoiceData.getInvoice().getInvoiceId() + ": " + e.getMessage());
                    }
                } catch (Exception e) {
                    System.err.println("Error generating PDF for invoice " + invoiceData.getInvoice().getInvoiceId() + ": " + e.getMessage());
                    continue; // Skip to next invoice instead of failing the entire request
                }

                // Add PDF to ZIP
                String phoneNumber = invoiceData.getCustomer() != null && invoiceData.getCustomer().getPhone() != null
                        ? invoiceData.getCustomer().getPhone().replaceAll("[^0-9]", "")
                        : "unknown";
                String pdfFileName = "invoice_" + phoneNumber + "_" + invoiceData.getInvoice().getInvoiceId() + ".pdf";
                zipOut.putNextEntry(new ZipEntry(pdfFileName));
                zipOut.write(pdfBaos.toByteArray());
                zipOut.closeEntry();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error creating ZIP file: " + e.getMessage());
            return;
        }

        // Stream ZIP to client
        response.setContentType("application/zip");
        response.setHeader("Content-Disposition", "attachment; filename=all_invoices.zip");
        try (OutputStream responseOut = response.getOutputStream()) {
            baos.writeTo(responseOut);
        } catch (IOException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error streaming ZIP file: " + e.getMessage());
        }
    }
}