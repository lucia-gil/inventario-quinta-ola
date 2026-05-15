package com.quintaola.model;

public enum ItemStatus {
    OK, LOW_STOCK, UNAVAILABLE;

    @Override
    public String toString() {
        switch (this) {
            case OK:
                return "Ok";
            case LOW_STOCK:
                return "Bajo en Stock";
            case UNAVAILABLE:
                return "No disponible";
            default:
                return super.toString();
        }
    }
}
