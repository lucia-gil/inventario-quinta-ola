package com.quintaola.util;

/**
 * ════════════════════════════════════════════════════════════════════
 * PasswordValidator — Política central de contraseñas
 * ════════════════════════════════════════════════════════════════════
 *
 * Regla aplicada (NIST + OWASP simplificado):
 *   - Mínimo 8 caracteres.
 *   - Al menos 1 letra mayúscula.
 *   - Al menos 1 letra minúscula.
 *   - Al menos 1 número.
 *   - Al menos 1 símbolo (!@#$%^&*()_+-=[]{};:'"<>,./?).
 *
 * Esta clase es la ÚNICA fuente de verdad. Cualquier punto del sistema
 * que reciba una contraseña nueva (signup, crear usuario, cambiar pass)
 * debe validarla aquí.
 * ════════════════════════════════════════════════════════════════════
 */
public class PasswordValidator {

    private static final int MIN_LENGTH = 8;

    /**
     * Devuelve true si la contraseña cumple la política completa.
     */
    public static boolean isValid(String password) {
        if (password == null) return false;
        if (password.length() < MIN_LENGTH) return false;

        boolean tieneMayuscula = password.matches(".*[A-Z].*");
        boolean tieneMinuscula = password.matches(".*[a-z].*");
        boolean tieneNumero    = password.matches(".*[0-9].*");
        boolean tieneSimbolo   = password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};:'\"<>,./?\\\\|`~].*");

        return tieneMayuscula && tieneMinuscula && tieneNumero && tieneSimbolo;
    }

    /**
     * Devuelve un mensaje legible explicando qué le falta a la contraseña.
     * Si es válida, devuelve null.
     */
    public static String getErrorMessage(String password) {
        if (password == null || password.isEmpty()) {
            return "La contraseña es obligatoria.";
        }
        if (password.length() < MIN_LENGTH) {
            return "La contraseña debe tener al menos " + MIN_LENGTH + " caracteres.";
        }
        if (!password.matches(".*[A-Z].*")) {
            return "La contraseña debe incluir al menos una letra mayúscula.";
        }
        if (!password.matches(".*[a-z].*")) {
            return "La contraseña debe incluir al menos una letra minúscula.";
        }
        if (!password.matches(".*[0-9].*")) {
            return "La contraseña debe incluir al menos un número.";
        }
        if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};:'\"<>,./?\\\\|`~].*")) {
            return "La contraseña debe incluir al menos un símbolo (ej: !@#$%&*).";
        }
        return null;
    }

    /**
     * Mensaje genérico para mostrar como hint al usuario en formularios.
     */
    public static String getRequisitos() {
        return "Mínimo 8 caracteres, con 1 mayúscula, 1 minúscula, 1 número y 1 símbolo.";
    }
}