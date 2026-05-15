package com.quintaola.model;

public enum TransactionType {
    IN, OUT;

    @Override
    public String toString() {
        switch (this) {
            case IN:
                return "Ingreso";
            case OUT:
                return "Retiro";
            default:
                return super.toString();
        }
    }
}
