package com.quintaola.servlet;

import com.quintaola.dao.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * ════════════════════════════════════════════════════════════════════
 * ReportServlet — Generación y descarga de reportes
 * ════════════════════════════════════════════════════════════════════
 *
 * URLs:
 *   /ReportServlet?action=salidas&format=csv&from=2026-06-01&to=2026-06-30
 *   /ReportServlet?action=salidas&format=xlsx&from=...&to=...
 *   /ReportServlet?action=consumo&format=csv&from=...&to=...
 *   /ReportServlet?action=consumo&format=xlsx&from=...&to=...
 *   /ReportServlet?action=inventario&format=csv
 *   /ReportServlet?action=inventario&format=xlsx
 *
 * Permisos:
 *   - SuperAdmin (5): NO accede (es controlador, no operador).
 *   - Manager (3), Admin (4): SÍ acceden a todos los reportes.
 *   - Member (2): solo inventario (es operador de depósito).
 *   - Viewer (1): NO accede.
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "ReportServlet", value = "/ReportServlet")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // ─── 1. Verificar sesión ───
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        Integer roleId = (Integer) session.getAttribute("roleId");
        int role = roleId != null ? roleId : 0;

        // ─── 2. Validar rol según acción ───
        String action = req.getParameter("action");
        String format = req.getParameter("format");
        if (action == null) action = "";
        if (format == null) format = "csv";

        boolean accesoOK;
        switch (action) {
            case "salidas":
            case "consumo":
                // Reportes operativos: Manager, Admin
                accesoOK = (role == 3 || role == 4);
                break;
            case "inventario":
                // Inventario: Member, Manager, Admin
                accesoOK = (role == 2 || role == 3 || role == 4);
                break;
            default:
                accesoOK = false;
        }

        if (!accesoOK) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // ─── 3. Procesar fechas (con default = mes actual) ───
        String from = req.getParameter("from");
        String to   = req.getParameter("to");

        if (from == null || from.isEmpty()) {
            from = LocalDate.now().withDayOfMonth(1)
                    .format(DateTimeFormatter.ISO_LOCAL_DATE);
        }
        if (to == null || to.isEmpty()) {
            to = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
        }

        // ─── 4. Obtener datos del DAO ───
        ReportDAO dao = new ReportDAO();
        List<Map<String, Object>> rows;
        String tituloReporte;
        String nombreArchivo;

        try {
            switch (action) {
                case "salidas":
                    rows = dao.salidasDelPeriodo(from, to);
                    tituloReporte = "Reporte de Salidas del " + from + " al " + to;
                    nombreArchivo = "salidas_" + from + "_" + to;
                    break;
                case "consumo":
                    rows = dao.consumoPorMaterial(from, to);
                    tituloReporte = "Consumo por Material del " + from + " al " + to;
                    nombreArchivo = "consumo_" + from + "_" + to;
                    break;
                case "inventario":
                    rows = dao.inventarioActual();
                    tituloReporte = "Inventario Actual";
                    nombreArchivo = "inventario_" + LocalDate.now();
                    break;
                default:
                    res.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error generando reporte: " + e.getMessage());
            return;
        }

        // ─── 5. Generar archivo según formato ───
        if ("xlsx".equalsIgnoreCase(format)) {
            generarXLSX(res, rows, tituloReporte, nombreArchivo);
        } else {
            generarCSV(res, rows, nombreArchivo);
        }
    }

    // ════════════════════════════════════════════════════════════════
    // CSV — texto plano con comas
    // ════════════════════════════════════════════════════════════════
    private void generarCSV(HttpServletResponse res, List<Map<String, Object>> rows,
                            String nombreArchivo) throws IOException {

        res.setContentType("text/csv; charset=UTF-8");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Content-Disposition",
                "attachment; filename=\"" + nombreArchivo + ".csv\"");

        // Construimos TODO el contenido en memoria como String, luego lo
        // escribimos al OutputStream. Así NO mezclamos OutputStream con Writer.
        StringBuilder csv = new StringBuilder();

        if (rows.isEmpty()) {
            csv.append("Sin datos para el período seleccionado.\n");
        } else {
            // Encabezados (claves del primer Map)
            Map<String, Object> primera = rows.get(0);
            String[] columnas = primera.keySet().toArray(new String[0]);

            // Línea de cabecera
            for (int i = 0; i < columnas.length; i++) {
                if (i > 0) csv.append(",");
                csv.append(escaparCSV(columnas[i]));
            }
            csv.append("\n");

            // Filas de datos
            for (Map<String, Object> fila : rows) {
                for (int i = 0; i < columnas.length; i++) {
                    if (i > 0) csv.append(",");
                    Object value = fila.get(columnas[i]);
                    csv.append(escaparCSV(value == null ? "" : value.toString()));
                }
                csv.append("\n");
            }
        }

        // Escribir BOM + contenido como bytes UTF-8 al OutputStream
        try (OutputStream out = res.getOutputStream()) {
            // BOM UTF-8 (para que Excel reconozca tildes correctamente)
            out.write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
            // Contenido en UTF-8
            out.write(csv.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
            out.flush();
        }
    }

    /** Escapa un valor CSV: si contiene comas, comillas o saltos de línea, lo envuelve en comillas. */
    private String escaparCSV(String valor) {
        if (valor == null) return "";
        boolean necesitaComillas = valor.contains(",") || valor.contains("\"")
                || valor.contains("\n") || valor.contains("\r");
        String escaped = valor.replace("\"", "\"\"");
        return necesitaComillas ? "\"" + escaped + "\"" : escaped;
    }

    // ════════════════════════════════════════════════════════════════
    // XLSX — Apache POI con header morado bonito
    // ════════════════════════════════════════════════════════════════
    private void generarXLSX(HttpServletResponse res, List<Map<String, Object>> rows,
                             String tituloReporte, String nombreArchivo) throws IOException {

        res.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        res.setHeader("Content-Disposition",
                "attachment; filename=\"" + nombreArchivo + ".xlsx\"");

        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = res.getOutputStream()) {

            Sheet sheet = workbook.createSheet("Reporte");

            // ─── Estilo título principal ───
            CellStyle titleStyle = workbook.createCellStyle();
            Font titleFont = workbook.createFont();
            titleFont.setFontName("Arial");
            titleFont.setFontHeightInPoints((short) 14);
            titleFont.setBold(true);
            titleFont.setColor(IndexedColors.WHITE.getIndex());
            titleStyle.setFont(titleFont);
            titleStyle.setAlignment(HorizontalAlignment.CENTER);
            titleStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            titleStyle.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
            titleStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // ─── Estilo header de columnas ───
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setFontName("Arial");
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            headerStyle.setFillForegroundColor(IndexedColors.PINK.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);

            // ─── Estilo filas datos ───
            CellStyle dataStyle = workbook.createCellStyle();
            Font dataFont = workbook.createFont();
            dataFont.setFontName("Arial");
            dataFont.setFontHeightInPoints((short) 10);
            dataStyle.setFont(dataFont);
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            // ─── Estilo fila alternada (gris suave) ───
            CellStyle altDataStyle = workbook.createCellStyle();
            altDataStyle.cloneStyleFrom(dataStyle);
            altDataStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            altDataStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // ─── Caso sin datos ───
            if (rows.isEmpty()) {
                Row titleRow = sheet.createRow(0);
                Cell titleCell = titleRow.createCell(0);
                titleCell.setCellValue(tituloReporte);
                titleCell.setCellStyle(titleStyle);
                titleRow.setHeightInPoints(28);

                Row emptyRow = sheet.createRow(2);
                emptyRow.createCell(0).setCellValue("Sin datos para el período seleccionado.");

                sheet.setColumnWidth(0, 12000);
                workbook.write(out);
                return;
            }

            // ─── Obtener columnas ───
            String[] columnas = rows.get(0).keySet().toArray(new String[0]);

            // ─── Fila 0: Título grande con merge ───
            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(tituloReporte);
            titleCell.setCellStyle(titleStyle);
            titleRow.setHeightInPoints(28);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(
                    0, 0, 0, columnas.length - 1));

            // ─── Fila 1: vacía (espacio) ───
            sheet.createRow(1);

            // ─── Fila 2: Headers ───
            Row headerRow = sheet.createRow(2);
            headerRow.setHeightInPoints(22);
            for (int i = 0; i < columnas.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columnas[i]);
                cell.setCellStyle(headerStyle);
            }

            // ─── Filas de datos ───
            int rowIdx = 3;
            for (int r = 0; r < rows.size(); r++) {
                Row dataRow = sheet.createRow(rowIdx++);
                Map<String, Object> fila = rows.get(r);
                CellStyle styleToUse = (r % 2 == 0) ? dataStyle : altDataStyle;

                for (int c = 0; c < columnas.length; c++) {
                    Cell cell = dataRow.createCell(c);
                    Object value = fila.get(columnas[c]);
                    if (value == null) {
                        cell.setCellValue("");
                    } else if (value instanceof Number) {
                        cell.setCellValue(((Number) value).doubleValue());
                    } else {
                        cell.setCellValue(value.toString());
                    }
                    cell.setCellStyle(styleToUse);
                }
            }

            // ─── Auto-ajustar anchos de columna ───
            for (int i = 0; i < columnas.length; i++) {
                sheet.autoSizeColumn(i);
                int width = sheet.getColumnWidth(i);
                // Limitar ancho máximo para que no se desborde
                if (width > 12000) sheet.setColumnWidth(i, 12000);
            }

            workbook.write(out);
        }
    }
}