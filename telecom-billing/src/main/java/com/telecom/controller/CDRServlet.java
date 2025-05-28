//package com.telecom.controller;
//
//import com.telecom.dao.CDRDAO;
//import com.telecom.model.CDR;
//import org.apache.commons.fileupload.FileItem;
//import org.apache.commons.fileupload.disk.DiskFileItemFactory;
//import org.apache.commons.fileupload.servlet.ServletFileUpload;
//
//import javax.servlet.http.HttpServletRequest;
//import javax.ws.rs.*;
//import javax.ws.rs.core.Context;
//import javax.ws.rs.core.MediaType;
//import javax.ws.rs.core.Response;
//import java.io.File;
//import java.nio.file.Paths;
//import java.util.List;
//import java.util.Map;
//import java.util.logging.Level;
//import java.util.logging.Logger;
//
//@Path("/cdrs")
//@Produces(MediaType.APPLICATION_JSON)
//public class CDRServlet {
//    private static final Logger LOGGER = Logger.getLogger(CDRServlet.class.getName());
//    private final CDRDAO cdrDAO;
//    private static final String UPLOAD_DIR = Paths.get(System.getProperty("user.dir"), "CDRs").toString();
//
//    public CDRServlet() {
//        this.cdrDAO = new CDRDAO();
//    }
//
//    @GET
//    public Response getAllCDRs() {
//        try {
//            LOGGER.info("Fetching all CDR records");
//            List<CDR> cdrs = cdrDAO.getAllCDRs();
//            LOGGER.info("Retrieved " + cdrs.size() + " CDR records");
//            return Response.ok(cdrs).build();
//        } catch (Exception e) {
//            e.printStackTrace();
//            LOGGER.log(Level.SEVERE, "Error retrieving CDR records", e);
//            String errorMessage = e.getMessage() != null ? e.getMessage() : "Unknown server error";
//            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
//                    .entity(Map.of("error", "Failed to retrieve CDR records", "message", errorMessage))
//                    .type(MediaType.APPLICATION_JSON)
//                    .build();
//        }
//    }
//
//    @GET
//    @Path("/process")
//    public Response processCDRs() {
//        try {
//            LOGGER.info("Processing CDR records");
//            cdrDAO.processCDRs();
//            return Response.ok(Map.of("message", "CDRs processed successfully")).build();
//        } catch (Exception e) {
//            e.printStackTrace();
//            LOGGER.log(Level.SEVERE, "Error processing CDRs", e);
//            String errorMessage = e.getMessage() != null ? e.getMessage() : "Unknown server error";
//            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
//                    .entity(Map.of("error", "Failed to process CDR records", "message", errorMessage))
//                    .type(MediaType.APPLICATION_JSON)
//                    .build();
//        }
//    }
//
//    @POST
//    @Consumes(MediaType.MULTIPART_FORM_DATA)
//    public Response uploadCDRFile(@Context HttpServletRequest request) {
//        try {
//            if (!ServletFileUpload.isMultipartContent(request)) {
//                return Response.status(Response.Status.BAD_REQUEST)
//                        .entity(Map.of("error", "Invalid request", "message", "Request must be multipart/form-data"))
//                        .build();
//            }
//
//            DiskFileItemFactory factory = new DiskFileItemFactory();
//            factory.setSizeThreshold(10 * 1024 * 1024); // 10MB
//            factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
//            ServletFileUpload upload = new ServletFileUpload(factory);
//            upload.setFileSizeMax(50 * 1024 * 1024); // 50MB
//            upload.setSizeMax(50 * 1024 * 1024); // 50MB
//
//            File uploadDir = new File(UPLOAD_DIR);
//            if (!uploadDir.exists()) {
//                uploadDir.mkdirs();
//                LOGGER.info("Created upload directory: " + UPLOAD_DIR);
//            }
//
//            List<FileItem> items = upload.parseRequest(request);
//            for (FileItem item : items) {
//                if (!item.isFormField()) {
//                    String filename = Paths.get(item.getName()).getFileName().toString();
//                    if (!filename.toLowerCase().endsWith(".csv")) {
//                        return Response.status(Response.Status.BAD_REQUEST)
//                                .entity(Map.of("error", "Invalid file type", "message", "Only CSV files are allowed"))
//                                .build();
//                    }
//
//                    File file = new File(UPLOAD_DIR, filename);
//                    if (file.exists()) {
//                        return Response.status(Response.Status.BAD_REQUEST)
//                                .entity(Map.of("error", "File conflict", "message", "File already exists: " + filename))
//                                .build();
//                    }
//
//                    item.write(file);
//                    CDR cdr = new CDR(filename, false);
//                    cdrDAO.saveCDR(cdr);
//                    LOGGER.info("Uploaded CDR file: " + filename);
//                }
//            }
//
//            return Response.status(Response.Status.CREATED)
//                    .entity(Map.of("message", "CDR file uploaded successfully"))
//                    .build();
//        } catch (org.apache.commons.fileupload.FileUploadException e) {
//            e.printStackTrace();
//            LOGGER.log(Level.SEVERE, "Error parsing file upload", e);
//            String errorMessage = e.getMessage() != null ? e.getMessage() : "Unknown file upload error";
//            return Response.status(Response.Status.BAD_REQUEST)
//                    .entity(Map.of("error", "Invalid file upload", "message", errorMessage))
//                    .build();
//        } catch (Exception e) {
//            e.printStackTrace();
//            LOGGER.log(Level.SEVERE, "Error uploading CDR file", e);
//            String errorMessage = e.getMessage() != null ? e.getMessage() : "Unknown server error";
//            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
//                    .entity(Map.of("error", "Failed to upload CDR file", "message", errorMessage))
//                    .type(MediaType.APPLICATION_JSON)
//                    .build();
//        }
//    }
//}