package org.quintaola.dto;

public enum TransactionStatus {
    PENDING,
    REJECTED,
    APPROVED,
    WAITING_CHANGES;

    @Override
    public String toString() {
        switch (this) {
            case PENDING:
                return "Pending";
            case REJECTED:
                return "Rejected";
            case APPROVED:
                return "Approved";
            case WAITING_CHANGES:
                return "Waiting Changes";
            default:
                return super.toString();
        }
    }
}
