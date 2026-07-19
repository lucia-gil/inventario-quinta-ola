package com.quintaola.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.servlet.ServletContext;

import java.util.Properties;

/**
 * ════════════════════════════════════════════════════════════════════
 * EmailService — Envío de correos vía Jakarta Mail + SMTP de Gmail
 * ════════════════════════════════════════════════════════════════════
 *
 * Cómo funciona internamente:
 *
 * 1. Lee las credenciales SMTP del web.xml (host, puerto, usuario, pass).
 * 2. Crea una Session de Jakarta Mail con esas propiedades + autenticación.
 * 3. Crea un MimeMessage con remitente, destinatario, asunto y cuerpo HTML.
 * 4. Transport.send() abre una conexión SSL al SMTP de Gmail (puerto 465),
 *    autentica con la contraseña de aplicación y envía el correo.
 * 5. Gmail entrega el correo al servidor del destinatario.
 *
 * Plantillas HTML inline con identidad visual Quinta Ola:
 *   - Header morado degradado con logo institucional.
 *   - Icono grande circular según el evento.
 *   - Caja de estado con color según el resultado.
 *   - Botón CTA dinámico.
 *   - Footer gris con info institucional.
 * ════════════════════════════════════════════════════════════════════
 */
public class EmailService {

    // ─── Credenciales SMTP cargadas desde web.xml ───
    private static String smtpHost;
    private static String smtpPort;
    private static String smtpUser;
    private static String smtpPass;
    private static String fromName;
    private static boolean initialized = false;

    // ─── Recursos visuales (constantes) ───
    private static final String LOGO_URL = "https://i.imgur.com/JwQo0O1.png";
    private static final String APP_URL =   "http://52.87.7.3:8080/inventario";
    private static final int    YEAR     = 2026;

    // ─── Paleta de colores Quinta Ola ───
    private static final String C_PURPLE      = "#5B1FA8";
    private static final String C_PURPLE_DARK = "#4A1690";
    private static final String C_PINK        = "#E91E8C";
    private static final String C_YELLOW      = "#FFC107";
    private static final String C_GREEN       = "#16A34A";
    private static final String C_GREEN_DARK  = "#14532D";
    private static final String C_RED         = "#DC2626";
    private static final String C_RED_DARK    = "#991B1B";
    private static final String C_BLUE        = "#2563EB";
    private static final String C_GRAY_TEXT   = "#374151";
    private static final String C_GRAY_SOFT   = "#6B7280";
    private static final String C_GRAY_BG     = "#F9FAFB";
    private static final String C_GRAY_LINE   = "#E5E7EB";

    /**
     * Inicializa el servicio leyendo las credenciales del web.xml.
     * Se llama una sola vez al arrancar Tomcat (desde AppInitializer).
     */
    public static void init(ServletContext ctx) {
        smtpHost = ctx.getInitParameter("smtp.host");
        smtpPort = ctx.getInitParameter("smtp.port");
        smtpUser = ctx.getInitParameter("smtp.user");
        smtpPass = ctx.getInitParameter("smtp.password");
        fromName = ctx.getInitParameter("smtp.fromName");
        initialized = true;
        System.out.println("[EmailService] Inicializado con remitente: " + smtpUser);
    }

    /**
     * Método base: envía un correo HTML a una dirección.
     */
    public static boolean enviar(String destinatario, String asunto, String cuerpoHtml) {
        if (!initialized) {
            System.err.println("[EmailService] ERROR: no inicializado. Llamar a init() primero.");
            return false;
        }

        try {
            // Configurar propiedades SMTP (SSL directo en puerto 465)
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.host", smtpHost);
            props.put("mail.smtp.port", smtpPort);
            props.put("mail.smtp.socketFactory.port", smtpPort);
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");

            // Crear sesión autenticada
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(smtpUser, smtpPass);
                }
            });

            // Armar el mensaje MIME
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(smtpUser, fromName, "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            message.setSubject(asunto, "UTF-8");
            message.setContent(cuerpoHtml, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("[EmailService] Correo enviado a: " + destinatario);
            return true;

        } catch (Exception e) {
            System.err.println("[EmailService] ERROR enviando a " + destinatario + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ════════════════════════════════════════════════════════════════
    // PLANTILLA BASE: header + cuerpo + footer reutilizables
    // ════════════════════════════════════════════════════════════════

    /**
     * Construye un correo con la estructura visual Quinta Ola.
     *
     * @param iconHtml    HTML del icono grande circular (SVG o emoji + estilos)
     * @param iconBgColor Color de fondo del círculo del icono (ej: #DCFCE7)
     * @param title       Título principal del correo
     * @param greeting    Saludo personalizado (ej: "Hola Lucía,")
     * @param mainText    Párrafo principal del correo (puede tener HTML)
     * @param statusBox   Caja de estado HTML (opcional, puede ser null)
     * @param ctaText     Texto del botón CTA (opcional, null = sin botón)
     * @param ctaLink     Link del botón CTA (opcional)
     * @param closing     Texto de cierre (opcional)
     */
    private static String construirCorreo(
            String iconHtml, String iconBgColor,
            String title, String greeting,
            String mainText, String statusBox,
            String ctaText, String ctaLink,
            String closing) {

        StringBuilder html = new StringBuilder();

        // Estructura base con Montserrat
        html.append("<!DOCTYPE html>")
                .append("<html lang='es'>")
                .append("<head>")
                .append("<meta charset='UTF-8'/>")
                .append("<meta name='viewport' content='width=device-width, initial-scale=1.0'/>")
                .append("<style>")
                .append("@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap');")
                .append("body, table, td, p, h1, h2, h3, a { font-family: 'Montserrat', Arial, sans-serif !important; }")
                .append("</style>")
                .append("</head>")
                .append("<body style='margin:0;padding:0;background-color:").append(C_GRAY_BG).append(";color:").append(C_GRAY_TEXT).append(";-webkit-font-smoothing:antialiased;'>")

                // Wrapper exterior
                .append("<table width='100%' cellpadding='0' cellspacing='0' style='background-color:").append(C_GRAY_BG).append(";padding:30px 15px;'>")
                .append("<tr><td align='center'>")

                // Card principal
                .append("<table width='600' cellpadding='0' cellspacing='0' style='background-color:#FFFFFF;border-radius:14px;overflow:hidden;box-shadow:0 4px 20px rgba(91,31,168,0.10);border:1px solid ").append(C_GRAY_LINE).append(";max-width:600px;'>")

                // ─── FRANJA SUPERIOR DECORATIVA (delgada, gradiente morado-rosa) ───
                .append("<tr>")
                .append("<td style='background:linear-gradient(90deg,").append(C_PURPLE).append(" 0%,").append(C_PINK).append(" 50%,").append(C_YELLOW).append(" 100%);height:6px;line-height:6px;font-size:0;'>&nbsp;</td>")
                .append("</tr>")

                // ─── HEADER blanco con logo bien visible ───
                .append("<tr>")
                .append("<td style='background-color:#FFFFFF;padding:36px 30px 28px;text-align:center;border-bottom:1px solid ").append(C_GRAY_LINE).append(";'>")
                // Logo grande y nítido
                .append("<img src='").append(LOGO_URL).append("' alt='Quinta Ola' style='max-height:62px;width:auto;display:block;margin:0 auto;'/>")
                // Tagline morada (no amarilla, para más legibilidad)
                .append("<p style='color:").append(C_PURPLE).append(";font-size:10.5px;margin:14px 0 0;letter-spacing:2.5px;text-transform:uppercase;font-weight:800;'>Sistema de Inventario</p>")
                .append("</td>")
                .append("</tr>")

                // ─── CUERPO ───
                .append("<tr>")
                .append("<td style='padding:35px 40px 25px;text-align:center;'>");

        // Icono circular grande
        if (iconHtml != null && !iconHtml.isEmpty()) {
            html.append("<div style='width:78px;height:78px;border-radius:50%;background:").append(iconBgColor).append(";display:inline-block;line-height:78px;margin-bottom:20px;text-align:center;font-size:36px;'>")
                    .append(iconHtml)
                    .append("</div>");
        }

        // Título
        html.append("<h1 style='color:").append(C_PURPLE).append(";font-size:22px;font-weight:800;margin:0 0 10px;letter-spacing:-0.4px;line-height:1.3;'>")
                .append(title)
                .append("</h1>");

        // Saludo
        if (greeting != null && !greeting.isEmpty()) {
            html.append("<p style='color:").append(C_GRAY_TEXT).append(";font-size:15px;font-weight:600;margin:18px 0 8px;text-align:left;'>")
                    .append(greeting)
                    .append("</p>");
        }

        // Texto principal
        html.append("<p style='color:").append(C_GRAY_TEXT).append(";font-size:14.5px;line-height:1.65;margin:0 0 18px;text-align:left;font-weight:500;'>")
                .append(mainText)
                .append("</p>");

        // Caja de estado (opcional)
        if (statusBox != null && !statusBox.isEmpty()) {
            html.append(statusBox);
        }

        // Botón CTA (opcional)
        if (ctaText != null && ctaLink != null) {
            html.append("<table align='center' style='margin:28px auto 10px;' cellpadding='0' cellspacing='0'>")
                    .append("<tr>")
                    .append("<td align='center' style='background-color:").append(C_YELLOW).append(";border-radius:10px;box-shadow:0 4px 14px rgba(255,193,7,0.40);'>")
                    .append("<a href='").append(ctaLink).append("' target='_blank' style='display:inline-block;padding:14px 36px;color:").append(C_PURPLE).append(";text-decoration:none;font-weight:800;font-size:14.5px;letter-spacing:0.3px;'>")
                    .append(ctaText)
                    .append(" &rarr;")
                    .append("</a>")
                    .append("</td>")
                    .append("</tr>")
                    .append("</table>");
        }

        // Cierre
        if (closing != null && !closing.isEmpty()) {
            html.append("<p style='color:").append(C_GRAY_SOFT).append(";font-size:13px;margin:25px 0 0;font-weight:500;line-height:1.5;text-align:left;'>")
                    .append(closing)
                    .append("</p>");
        }

        html.append("</td>")
                .append("</tr>")

                // ─── FOOTER ───
                .append("<tr>")
                .append("<td style='background-color:#F3F4F6;padding:22px 30px;text-align:center;border-top:1px solid ").append(C_GRAY_LINE).append(";'>")
                .append("<p style='color:").append(C_PURPLE).append(";font-size:13px;margin:0 0 4px;font-weight:800;letter-spacing:0.3px;'>Quinta Ola</p>")
                .append("<p style='color:").append(C_GRAY_SOFT).append(";font-size:11px;margin:0 0 10px;font-weight:500;'>Sistema de Gestión de Inventario</p>")
                .append("<p style='color:#9CA3AF;font-size:10.5px;margin:0;line-height:1.5;font-weight:500;'>")
                .append("&copy; ").append(YEAR).append(" Inventario Quinta Ola. Todos los derechos reservados.<br/>")
                .append("Este correo se generó automáticamente. Por favor, no respondas a este mensaje.")
                .append("</p>")
                .append("</td>")
                .append("</tr>")

                .append("</table>")
                .append("</td></tr>")
                .append("</table>")

                .append("</body>")
                .append("</html>");

        return html.toString();
    }

    /**
     * Construye una caja de estado coloreada (verde, ámbar, rojo, azul).
     */
    private static String construirCajaEstado(String tipo, String texto) {
        String bg, border, textColor;
        switch (tipo) {
            case "success":
                bg = "#DCFCE7"; border = C_GREEN; textColor = C_GREEN_DARK; break;
            case "warning":
                bg = "#FEF3C7"; border = "#F59E0B"; textColor = "#92400E"; break;
            case "danger":
                bg = "#FEE2E2"; border = C_RED; textColor = C_RED_DARK; break;
            case "info":
            default:
                bg = "#DBEAFE"; border = C_BLUE; textColor = "#1E3A8A"; break;
        }

        return "<div style='background:" + bg + ";border-left:4px solid " + border + ";padding:14px 18px;border-radius:8px;margin:20px 0;text-align:left;'>"
                + "<p style='color:" + textColor + ";font-size:14px;margin:0;font-weight:700;line-height:1.5;'>"
                + texto
                + "</p>"
                + "</div>";
    }

    /**
     * Escapa caracteres especiales de HTML. Se usa en cualquier texto que
     * venga de un usuario (ej. notas de entrega) antes de insertarlo en el
     * cuerpo del correo, para que no rompa el HTML ni permita inyectar código.
     */
    private static String escapeHtml(String texto) {
        if (texto == null) return "";
        return texto
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("\n", "<br/>");
    }

    // ════════════════════════════════════════════════════════════════
    // PLANTILLAS POR EVENTO
    // ════════════════════════════════════════════════════════════════

    public static boolean enviarBienvenida(String destinatario, String nombre) {
        String html = construirCorreo(
                "&#9203;",  // ⏳ reloj de arena
                "#FEF3C7",
                "¡Bienvenida a Quinta Ola!",
                "Hola <strong style='color:" + C_PURPLE + "'>" + nombre + "</strong>,",
                "Tu cuenta en el Sistema de Inventario de Quinta Ola ha sido creada exitosamente. "
                        + "Antes de poder iniciar sesión, un Administrador debe revisar y aprobar tu solicitud de acceso.",
                construirCajaEstado("warning",
                        "&#9888; Tu cuenta está pendiente de aprobación. Recibirás otro correo cuando sea activada."),
                null, null,
                "Si no fuiste tú quien se registró, simplemente ignora este correo."
        );

        return enviar(destinatario, "Bienvenida a Quinta Ola — Cuenta en revisión", html);
    }

    public static boolean enviarAprobacion(String destinatario, String nombre) {
        String html = construirCorreo(
                "<span style='color:" + C_GREEN + ";font-size:42px;font-weight:800;'>&#10003;</span>",  // ✓
                "#DCFCE7",
                "¡Tu cuenta fue aprobada!",
                "Hola <strong style='color:" + C_PURPLE + "'>" + nombre + "</strong>,",
                "Buenas noticias: tu solicitud de acceso al Sistema de Inventario de Quinta Ola "
                        + "<strong style='color:" + C_GREEN + "'>ha sido aprobada</strong> por un Administrador. "
                        + "Ya puedes iniciar sesión y comenzar a gestionar materiales.",
                construirCajaEstado("success", "&#10003; Cuenta activa y lista para usar"),
                "Iniciar sesión", APP_URL + "/AuthServlet?action=formLogin",
                "¡Bienvenida al equipo! Si tienes alguna duda, contacta con el coordinador del proyecto."
        );

        return enviar(destinatario, "Tu cuenta ha sido aprobada — Quinta Ola", html);
    }

    public static boolean enviarRechazo(String destinatario, String nombre) {
        String html = construirCorreo(
                "<span style='color:" + C_RED + ";font-size:38px;font-weight:800;'>&times;</span>",  // ×
                "#FEE2E2",
                "Información sobre tu cuenta",
                "Hola <strong style='color:" + C_PURPLE + "'>" + nombre + "</strong>,",
                "Lamentamos informarte que tu solicitud de registro en el Sistema de Inventario de Quinta Ola "
                        + "no pudo ser aprobada en esta ocasión.",
                construirCajaEstado("danger",
                        "Si crees que se trata de un error o necesitas más información sobre el motivo, "
                                + "por favor contacta directamente con el coordinador del proyecto."),
                null, null,
                null
        );

        return enviar(destinatario, "Solicitud de registro — Quinta Ola", html);
    }

    public static boolean enviarNuevaSolicitud(String destinatario, String nombreAprobador, String solicitante, int requestId) {
        String detalles =
                "<div style='background:#F9FAFB;border:1px solid " + C_GRAY_LINE + ";border-radius:10px;padding:16px 20px;margin:20px 0;text-align:left;'>"
                        + "  <table width='100%' cellpadding='6' cellspacing='0'>"
                        + "    <tr>"
                        + "      <td style='color:" + C_GRAY_SOFT + ";font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;'>Solicitante</td>"
                        + "      <td style='color:" + C_GRAY_TEXT + ";font-size:14px;font-weight:700;text-align:right;'>" + solicitante + "</td>"
                        + "    </tr>"
                        + "    <tr>"
                        + "      <td style='color:" + C_GRAY_SOFT + ";font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;'>ID de solicitud</td>"
                        + "      <td style='color:" + C_PURPLE + ";font-size:15px;font-weight:800;text-align:right;'>#" + requestId + "</td>"
                        + "    </tr>"
                        + "  </table>"
                        + "</div>";

        String html = construirCorreo(
                "<span style='color:" + C_BLUE + ";font-size:36px;'>&#128276;</span>",  // 🔔
                "#DBEAFE",
                "Nueva solicitud pendiente",
                "Hola <strong style='color:" + C_PURPLE + "'>" + nombreAprobador + "</strong>,",
                "Tienes una nueva solicitud de materiales pendiente de revisión en el sistema. "
                        + "Por favor ingresa para revisar los detalles y tomar una decisión.",
                detalles,
                "Revisar solicitud", APP_URL + "/TransactionServlet",
                null
        );

        return enviar(destinatario, "Nueva solicitud #" + requestId + " — Quinta Ola", html);
    }

    public static boolean enviarSolicitudAprobada(String destinatario, String solicitante, int requestId) {
        String html = construirCorreo(
                "<span style='color:" + C_GREEN + ";font-size:42px;font-weight:800;'>&#10003;</span>",
                "#DCFCE7",
                "Solicitud aprobada",
                "Hola <strong style='color:" + C_PURPLE + "'>" + solicitante + "</strong>,",
                "Tu solicitud <strong style='color:" + C_PURPLE + "'>#" + requestId + "</strong> "
                        + "ha sido <strong style='color:" + C_GREEN + "'>aprobada</strong>. "
                        + "El encargado de depósito te entregará los materiales pronto.",
                construirCajaEstado("success", "&#10003; Tu solicitud avanzó al siguiente paso"),
                "Ver detalles", APP_URL + "/HistoryServlet",
                "Te avisaremos por correo cuando los materiales sean entregados."
        );

        return enviar(destinatario, "Solicitud #" + requestId + " aprobada — Quinta Ola", html);
    }

    public static boolean enviarSolicitudRechazada(String destinatario, String solicitante, int requestId, String motivo) {
        String motivoSeguro = (motivo == null || motivo.isEmpty()) ? "No se especificó motivo." : motivo;

        String motivoBox =
                "<div style='background:#FEE2E2;border-left:4px solid " + C_RED + ";padding:14px 18px;border-radius:8px;margin:20px 0;text-align:left;'>"
                        + "  <p style='color:" + C_RED_DARK + ";font-size:12px;margin:0 0 6px;font-weight:800;text-transform:uppercase;letter-spacing:0.6px;'>Motivo del rechazo</p>"
                        + "  <p style='color:#7F1D1D;font-size:14px;margin:0;line-height:1.55;font-weight:500;'>" + motivoSeguro + "</p>"
                        + "</div>";

        String html = construirCorreo(
                "<span style='color:" + C_RED + ";font-size:38px;font-weight:800;'>&times;</span>",
                "#FEE2E2",
                "Tu solicitud fue rechazada",
                "Hola <strong style='color:" + C_PURPLE + "'>" + solicitante + "</strong>,",
                "Tu solicitud <strong>#" + requestId + "</strong> no pudo ser aprobada. "
                        + "Revisa el motivo a continuación:",
                motivoBox,
                "Ver detalles", APP_URL + "/HistoryServlet",
                "Si necesitas más información, contacta al aprobador o al coordinador del proyecto."
        );

        return enviar(destinatario, "Solicitud #" + requestId + " rechazada — Quinta Ola", html);
    }

    public static boolean enviarEntrega(String destinatario, String solicitante, int requestId) {
        String html = construirCorreo(
                "<span style='color:" + C_BLUE + ";font-size:36px;'>&#128230;</span>",  // 📦
                "#DBEAFE",
                "¡Materiales entregados!",
                "Hola <strong style='color:" + C_PURPLE + "'>" + solicitante + "</strong>,",
                "Los materiales de tu solicitud <strong style='color:" + C_PURPLE + "'>#" + requestId + "</strong> "
                        + "han sido entregados por el encargado de depósito.",
                construirCajaEstado("info", "&#128230; Solicitud cerrada exitosamente"),
                "Ver historial", APP_URL + "/HistoryServlet",
                "Gracias por usar el Sistema de Inventario Quinta Ola. ¡Sigue gestionando!"
        );

        return enviar(destinatario, "Materiales entregados — Solicitud #" + requestId, html);
    }

    /**
     * Igual que enviarEntrega(), pero además incluye un aviso del encargado
     * de depósito sobre algún imprevisto en la entrega (retraso, cambio de
     * color, material sustituto, etc.). Se usa cuando el encargado escribe
     * algo en el campo de notas al marcar la solicitud como entregada.
     */
    public static boolean enviarEntregaConNota(String destinatario, String solicitante, int requestId, String nota) {
        String notaSegura = escapeHtml(nota);

        String notaBox =
                "<div style='background:#FEF3C7;border-left:4px solid #F59E0B;padding:14px 18px;border-radius:8px;margin:20px 0;text-align:left;'>"
                        + "  <p style='color:#92400E;font-size:12px;margin:0 0 6px;font-weight:800;text-transform:uppercase;letter-spacing:0.6px;'>&#9888; Aviso del encargado de depósito</p>"
                        + "  <p style='color:#78350F;font-size:14px;margin:0;line-height:1.55;font-weight:500;'>" + notaSegura + "</p>"
                        + "</div>";

        String html = construirCorreo(
                "<span style='color:" + C_BLUE + ";font-size:36px;'>&#128230;</span>",  // 📦
                "#DBEAFE",
                "¡Materiales entregados!",
                "Hola <strong style='color:" + C_PURPLE + "'>" + solicitante + "</strong>,",
                "Los materiales de tu solicitud <strong style='color:" + C_PURPLE + "'>#" + requestId + "</strong> "
                        + "han sido entregados por el encargado de depósito. Antes de que revises todo, queremos que sepas lo siguiente:",
                notaBox,
                "Ver historial", APP_URL + "/HistoryServlet",
                "Si tienes dudas sobre este aviso, contacta directamente con el encargado de depósito o el coordinador del proyecto."
        );

        return enviar(destinatario, "Materiales entregados (con aviso) — Solicitud #" + requestId, html);
    }
}