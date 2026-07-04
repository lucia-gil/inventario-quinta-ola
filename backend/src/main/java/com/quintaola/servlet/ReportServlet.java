package com.quintaola.servlet;

import com.quintaola.dao.ReportDAO;
import com.quintaola.dao.UserDAO;          // ← NUEVO
import com.quintaola.model.User;            // ← NUEVO
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
import java.util.ArrayList;      // ← NUEVO
import java.util.LinkedHashMap;  // ← NUEVO
import java.util.List;
import java.util.Map;

/**
 * ════════════════════════════════════════════════════════════════════
 * ReportServlet — Generación y descarga de reportes
 * ════════════════════════════════════════════════════════════════════
 *
 * URLs existentes:
 *   /ReportServlet?action=salidas&format=csv&from=...&to=...
 *   /ReportServlet?action=consumo&format=xlsx&from=...&to=...
 *   /ReportServlet?action=inventario&format=csv
 *
 * URLs nuevas:
 *   /ReportServlet?action=usuarios_por_rol&rol=X&format=xlsx
 *   /ReportServlet?action=todos_usuarios&format=xlsx
 *
 * Permisos:
 *   - usuarios_por_rol / todos_usuarios : solo SuperAdmin (5)
 *   - salidas / consumo                 : Manager (3), Admin (4)
 *   - inventario                        : Member (2), Manager (3), Admin (4)
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
                accesoOK = (role == 3 || role == 4);
                break;
            case "inventario":
                accesoOK = (role == 2 || role == 3 || role == 4);
                break;
            // ── NUEVOS: solo SuperAdmin ──────────────────────────────────
            case "usuarios_por_rol":
            case "todos_usuarios":
                accesoOK = (role == 5);
                break;
            // ─────────────────────────────────────────────────────────────
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

        // ─── 4. Obtener datos ───
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

                // ── NUEVO: usuarios de un rol específico ─────────────────────
                case "usuarios_por_rol": {
                    int rolIdParam = 0;
                    String rolStr = req.getParameter("rol");
                    if (rolStr != null && !rolStr.trim().isEmpty()) {
                        try { rolIdParam = Integer.parseInt(rolStr); }
                        catch (NumberFormatException ignored) {}
                    }

                    UserDAO userDAO = new UserDAO();
                    Map<Integer, String> inactiveStatus = userDAO.getInactiveUsersStatus();
                    List<User> todos = userDAO.getAll();

                    // Filtrar por rol si viene el param
                    final int rolFinal = rolIdParam;
                    rows = new ArrayList<>();
                    for (User u : todos) {
                        if (rolFinal > 0 && u.getRoleId() != rolFinal) continue;
                        rows.add(usuarioAFila(u, inactiveStatus));
                    }

                    // Ordenar A-Z por nombre
                    rows.sort((a, b) -> String.valueOf(a.getOrDefault("Nombre", ""))
                            .compareToIgnoreCase(String.valueOf(b.getOrDefault("Nombre", ""))));

                    String rolLabel = rolFinal > 0 ? "Rol_" + rolFinal : "Todos_los_Roles";
                    tituloReporte = "Listado de Usuarios – " + rolLabel.replace("_", " ");
                    nombreArchivo = "usuarios_" + rolLabel.toLowerCase() + "_" + LocalDate.now();
                    break;
                }

                // ── NUEVO: todos los usuarios del sistema ────────────────────
                case "todos_usuarios": {
                    UserDAO userDAO = new UserDAO();
                    Map<Integer, String> inactiveStatus = userDAO.getInactiveUsersStatus();
                    List<User> todos = userDAO.getAll();

                    rows = new ArrayList<>();
                    for (User u : todos) {
                        rows.add(usuarioAFila(u, inactiveStatus));
                    }

                    // Ordenar A-Z por nombre
                    rows.sort((a, b) -> String.valueOf(a.getOrDefault("Nombre", ""))
                            .compareToIgnoreCase(String.valueOf(b.getOrDefault("Nombre", ""))));

                    tituloReporte = "Listado General de Usuarios – Quinta Ola";
                    nombreArchivo = "todos_usuarios_" + LocalDate.now();
                    break;
                }

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

    /**
     * Convierte un User a Map<String, Object> con los campos del reporte.
     * Columnas: Nombre, Email, DNI, Rol, Estado, Fecha de Creación
     */
    private Map<String, Object> usuarioAFila(User u, Map<Integer, String> inactiveStatus) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("Nombre", u.getName() != null ? u.getName() : "—");
        row.put("Email",  u.getEmail() != null ? u.getEmail() : "—");
        row.put("DNI",    u.getDni()   != null ? u.getDni()   : "—");
        row.put("Rol",    u.getRoleName() != null ? u.getRoleName() : "—");

        String estado;
        if (u.getActivo() == 1) {
            estado = "Activo";
        } else {
            String tipo = inactiveStatus != null ? inactiveStatus.get(u.getId()) : null;
            estado = "DEACTIVATED".equals(tipo) ? "Desactivado" : "Pendiente";
        }
        row.put("Estado", estado);

        // Formatear fecha de creación a dd/MM/yyyy
        String fechaStr = "—";
        if (u.getCreatedAt() != null) {
            try {
                String s = u.getCreatedAt().toString().trim();
                if (s.length() > 19) s = s.substring(0, 19);
                java.text.SimpleDateFormat in  = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                java.text.SimpleDateFormat out = new java.text.SimpleDateFormat("dd/MM/yyyy");
                fechaStr = out.format(in.parse(s));
            } catch (Exception ignored) {
                fechaStr = u.getCreatedAt().toString();
            }
        }
        row.put("Fecha de Creación", fechaStr);

        return row;
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

        StringBuilder csv = new StringBuilder();

        if (rows.isEmpty()) {
            csv.append("Sin datos para el período seleccionado.\n");
        } else {
            Map<String, Object> primera = rows.get(0);
            String[] columnas = primera.keySet().toArray(new String[0]);

            for (int i = 0; i < columnas.length; i++) {
                if (i > 0) csv.append(",");
                csv.append(escaparCSV(columnas[i]));
            }
            csv.append("\n");

            for (Map<String, Object> fila : rows) {
                for (int i = 0; i < columnas.length; i++) {
                    if (i > 0) csv.append(",");
                    Object value = fila.get(columnas[i]);
                    csv.append(escaparCSV(value == null ? "" : value.toString()));
                }
                csv.append("\n");
            }
        }

        try (OutputStream out = res.getOutputStream()) {
            out.write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
            out.write(csv.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
            out.flush();
        }
    }

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

            CellStyle altDataStyle = workbook.createCellStyle();
            altDataStyle.cloneStyleFrom(dataStyle);
            altDataStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            altDataStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

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

            String[] columnas = rows.get(0).keySet().toArray(new String[0]);

            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(tituloReporte);
            titleCell.setCellStyle(titleStyle);
            titleRow.setHeightInPoints(28);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(
                    0, 0, 0, columnas.length - 1));

            sheet.createRow(1);

            Row headerRow = sheet.createRow(2);
            headerRow.setHeightInPoints(22);
            for (int i = 0; i < columnas.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columnas[i]);
                cell.setCellStyle(headerStyle);
            }

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

            for (int i = 0; i < columnas.length; i++) {
                sheet.autoSizeColumn(i);
                if (sheet.getColumnWidth(i) > 12000) sheet.setColumnWidth(i, 12000);
            }

            workbook.write(out);
        }
    }
}